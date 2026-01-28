import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:game_v1/app_colors.dart';
import 'package:game_v1/widget/atoms/atom_background_page.dart';
import 'package:game_v1/widget/atoms/atom_button.dart';
import 'package:game_v1/widget/atoms/atom_title_page.dart';
import 'package:game_v1/widget/atoms/atom_hub.dart';
import '../../store/provider/room_provider.dart';
import '../../core/game_orchestrator/providers/game_session_provider.dart';
import '../../core/game_orchestrator/ui/game_orchestrator_screen.dart';

class RoomHub extends StatefulWidget {
  const RoomHub({super.key});

  @override
  State<RoomHub> createState() => _RoomHubState();
}

class _RoomHubState extends State<RoomHub> {
  int _previousParticipantCount = 0;
  bool _hasNavigatedToGame = false; // Pour éviter la double navigation
  DateTime? _hostMissingTimestamp; // Track when host went missing
  static const _hostMissingGracePeriod = Duration(
    seconds: 3,
  ); // Grace period before ejecting

  @override
  void initState() {
    super.initState();
    final roomProvider = context.read<RoomProvider>();
    _previousParticipantCount = roomProvider.participants.length;

    // Use addPostFrameCallback to safely check state after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (roomProvider.currentRoom == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Aucune room active.')),
        );
      }
    });
  }

  void _playGames() async {
    try {
      final roomProvider = context.read<RoomProvider>();
      final sessionProvider = context.read<GameSessionProvider>();

      // 1. Mettre à jour le statut de la room
      await roomProvider.startGame();

      // 2. Créer la session de jeu
      final playerIds = roomProvider.participants.map((p) => p.id).toList();
      // Force limit to 2 games max as per new requirement
      final int rawNbGames =
          roomProvider.currentRoom?.settings?['nb_games'] ?? 2;
      final int nbGames = rawNbGames > 2 ? 2 : rawNbGames;

      final sessionId = await sessionProvider.createSession(
        roomId: roomProvider.currentRoom!.id,
        nbGames: nbGames,
        playerIds: playerIds,
      );

      if (sessionId == null) {
        throw Exception('Impossible de créer la session de jeu');
      }

      // 3. Naviguer vers l'orchestrateur
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameOrchestratorScreen(sessionId: sessionId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur lancement: $e')));
      }
    }
  }

  late RoomProvider _roomProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roomProvider = context.read<RoomProvider>();
  }

  void _leaveRoom() async {
    // If I am host, we might want to warn or delete room.
    // For now, standard leave.
    await _roomProvider.leaveRoom();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Ensure we leave the room when the page is disposed
    // This handles cases where the user exits via system back button, etc.
    if (_roomProvider.currentRoom != null) {
      // Call leaveRoom without awaiting to avoid blocking dispose
      _roomProvider.leaveRoom().catchError((e) {
        debugPrint("Error leaving room on dispose: $e");
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes
    final roomProvider = context.watch<RoomProvider>();
    final room = roomProvider.currentRoom;
    final players = roomProvider.participants;
    final amIHost = roomProvider.amIHost;

    // --- LOGIC: HANDLE DEPARTURES ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // SKIP CHECKS if we're in a game to avoid false positives during transitions
      if (_hasNavigatedToGame || room?.status == 'playing') {
        return;
      }

      // 1. Check if room was deleted (Host left)
      if (room == null) {
        // Room was deleted, navigate back
        Navigator.popUntil(
          context,
          (route) => route.isFirst || route.settings.name == '/home',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("L'hôte a quitté la partie. La room est fermée."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // 2. Guest detects Host left (if participants list doesn't contain host)
      if (!amIHost) {
        final bool hasHost = players.any((p) => p.isHost);

        if (!hasHost) {
          // Start or continue grace period
          _hostMissingTimestamp ??= DateTime.now();
          final gracePeriodElapsed =
              DateTime.now().difference(_hostMissingTimestamp!) >
              _hostMissingGracePeriod;

          // Only eject if grace period elapsed and we're in lobby/waiting status
          if (gracePeriodElapsed &&
              (room?.status == 'waiting' || room?.status == 'lobby')) {
            debugPrint(
              '⚠️ Host missing for ${_hostMissingGracePeriod.inSeconds}s, ejecting guest',
            );
            context.read<RoomProvider>().leaveLocalInfo();
            Navigator.popUntil(
              context,
              (route) => route.isFirst || route.settings.name == '/home',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("L'hôte a quitté la partie. La room est fermée."),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
            return;
          }
        } else {
          // Host is back, reset grace period
          if (_hostMissingTimestamp != null) {
            debugPrint('✅ Host reconnected, resetting grace period');
            _hostMissingTimestamp = null;
          }
        }
      }

      // 3. Host detects Guest left (Notification only)
      if (players.length < _previousParticipantCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Un joueur a quitté la partie."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      // Update counter for next frame
      _previousParticipantCount = players.length;
    });

    // Check if game started - Auto navigate for guest
    if (room != null && room.status == 'playing' && !_hasNavigatedToGame) {
      // Marquer comme déjà navigué
      _hasNavigatedToGame = true;

      // Charger ou créer la session de jeu
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final sessionProvider = context.read<GameSessionProvider>();

        // Essayer de charger la session existante par room_id
        await sessionProvider.loadSessionByRoomId(room.id);

        if (sessionProvider.currentSession != null && mounted) {
          // Session trouvée, naviguer vers l'orchestrateur
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameOrchestratorScreen(
                sessionId: sessionProvider.currentSession!.id,
              ),
            ),
          ).then((_) {
            // Quand on revient de l'orchestrateur, réinitialiser le flag
            if (mounted) {
              setState(() {
                _hasNavigatedToGame = false;
              });
            }
          });
        } else {
          // Session non trouvée (ne devrait pas arriver)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Session de jeu non trouvée'),
              backgroundColor: Colors.red,
            ),
          );
          // Réinitialiser le flag en cas d'erreur
          setState(() {
            _hasNavigatedToGame = false;
          });
        }
      });
    } else if (room != null && room.status != 'playing') {
      // Si la room n'est plus en 'playing', réinitialiser le flag
      if (_hasNavigatedToGame) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasNavigatedToGame = false;
            });
          }
        });
      }
    }

    // Convert RoomParticipant to AtomHub Player model if needed, or update AtomHub to use RoomParticipant.
    // AtomHub expects List<Player>. Let's map.
    final atomPlayers = players
        .map(
          (p) => Player(
            pseudo: p.pseudo ?? (p.isHost ? 'Host' : 'Joueur'),
            avatarUrl:
                p.avatarUrl ??
                "https://placehold.co/100x100/18B80A/FFFFFF?text=${p.id.substring(0, 2)}",
            isHost: p.isHost,
          ),
        )
        .toList();

    // afficher atomPlayers
    // debugPrint(atomPlayers.toString());

    final int nbGames = room?.settings?['nb_games'] ?? 0;
    final String roomCode = room?.code ?? '??????';

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundPage(pathBackground: "assets/images/carrefour.png"),

          AtomTitle(
            title: "Hub de la Partie",
            color: Colors.red,
            showBack: true,
            onBack: _leaveRoom,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0, bottom: 20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // ---- INFO ROOM CODE ----
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "CODE SALLE",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                roomCode,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: 2,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: roomCode),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Code copié !'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Text("$nbGames mini-jeux"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ---- LISTE DES JOUEURS (AtomHub) ----
                    // AtomHub expects specific Player class, check import
                    AtomHub(players: atomPlayers),

                    const SizedBox(height: 30),

                    // ---- BOUTON LANCER LA PARTIE & MESSAGES D'ATTENTE ----
                    if (room?.status == 'playing') ...[
                      const CircularProgressIndicator(),
                      const Text("Lancement du jeu..."),
                    ] else if (amIHost && roomProvider.isRoomFull)
                      // Host peut lancer si la room est pleine
                      AtomButton(
                        label: "Lancer la Partie",
                        onPressed: _playGames,
                        bgColor: const Color.fromARGB(255, 18, 184, 10),
                      )
                    else if (amIHost)
                      // Host attend un adversaire
                      _WaitingMessage(
                        text: "En attente de l'adversaire...",
                        color: Colors.yellow,
                      )
                    else
                      // Guest attend le Host
                      _WaitingMessage(
                        text: "En attente du Host pour lancer la partie...",
                        color: Colors.grey,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget privé pour simplifier l'affichage des messages d'attente
class _WaitingMessage extends StatelessWidget {
  final String text;
  final Color color;

  const _WaitingMessage({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: AppColors.gray),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
