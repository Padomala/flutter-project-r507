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
  bool _hasNavigatedToGame = false;
  DateTime? _hostMissingTimestamp;
  static const _hostMissingGracePeriod = Duration(seconds: 3);
  late RoomProvider _roomProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final roomProvider = context.read<RoomProvider>();
      _previousParticipantCount = roomProvider.participants.length;

      if (roomProvider.currentRoom == null) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Erreur: Aucune room active.')),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roomProvider = context.read<RoomProvider>();
  }

  void _playGames() async {
    try {
      final roomProvider = context.read<RoomProvider>();
      final sessionProvider = context.read<GameSessionProvider>();

      await roomProvider.startGame();
      if (!mounted) return;

      final playerIds = roomProvider.participants.map((p) => p.id).toList();
      final int rawNbGames =
          roomProvider.currentRoom?.settings?['nb_games'] ?? 2;
      final int nbGames = rawNbGames > 2 ? 2 : rawNbGames;

      final sessionId = await sessionProvider.createSession(
        roomId: roomProvider.currentRoom!.id,
        nbGames: nbGames,
        playerIds: playerIds,
      );

      if (!mounted) return;
      if (sessionId == null) {
        throw Exception('Impossible de créer la session de jeu');
      }

      _navigateToGameOrchestrator(sessionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur lancement: $e')));
      }
    }
  }

  // --- MÉTHODE DE NAVIGATION SÉCURISÉE ---
  void _navigateToGameOrchestrator(String sessionId) {
    // 1. On verrouille la navigation
    setState(() {
      _hasNavigatedToGame = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameOrchestratorScreen(sessionId: sessionId),
      ),
    ).then((_) {
      // 2. Au retour, on vérifie si on doit déverrouiller
      if (mounted) {
        final sessionProvider = context.read<GameSessionProvider>();

        // ANTI-BOUCLE : Si la session est finie, on ne remet PAS le flag à false.
        // Cela empêche le Hub de relancer le jeu immédiatement.
        if (sessionProvider.isCompleted) {
          debugPrint("🛑 [RoomHub] Session terminée. Auto-join bloqué.");
          return;
        }

        // Sinon (retour arrière manuel), on autorise à relancer
        setState(() {
          _hasNavigatedToGame = false;
        });
      }
    });
  }

  void _leaveRoom() async {
    await _roomProvider.leaveRoom();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    if (_roomProvider.currentRoom != null) {
      _roomProvider.leaveRoom().catchError((e) {
        debugPrint("Error leaving room on dispose: $e");
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final room = roomProvider.currentRoom;
    final players = roomProvider.participants;
    final amIHost = roomProvider.amIHost;

    // --- LOGIC: HANDLE DEPARTURES ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_hasNavigatedToGame || room?.status == 'playing') {
        return;
      }

      if (room == null) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.popUntil(
          context,
          (route) => route.isFirst || route.settings.name == '/home',
        );
        messenger.showSnackBar(
          const SnackBar(
            content: Text("L'hôte a quitté la partie. La room est fermée."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      if (!amIHost) {
        final bool hasHost = players.any((p) => p.isHost);
        if (!hasHost) {
          _hostMissingTimestamp ??= DateTime.now();
          final gracePeriodElapsed =
              DateTime.now().difference(_hostMissingTimestamp!) >
              _hostMissingGracePeriod;

          if (gracePeriodElapsed &&
              (room.status == 'waiting' || room.status == 'lobby')) {
            final messenger = ScaffoldMessenger.of(context);
            context.read<RoomProvider>().leaveLocalInfo();
            Navigator.popUntil(
              context,
              (route) => route.isFirst || route.settings.name == '/home',
            );
            messenger.showSnackBar(
              const SnackBar(
                content: Text("L'hôte a quitté la partie."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } else {
          _hostMissingTimestamp = null;
        }
      }

      if (players.length < _previousParticipantCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Un joueur a quitté la partie."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _previousParticipantCount = players.length;
    });

    // --- LOGIC: AUTO JOIN GAME ---
    if (room != null && room.status == 'playing' && !_hasNavigatedToGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Double check pour éviter la race condition
        if (!mounted || _hasNavigatedToGame) return;

        // VERIFICATION DE SECURITE SUPPLEMENTAIRE
        final sessionProvider = context.read<GameSessionProvider>();
        if (sessionProvider.isCompleted) {
          debugPrint("🛑 [RoomHub] Session déjà complétée, pas d'auto-join.");
          return;
        }

        // On marque immédiatement
        setState(() {
          _hasNavigatedToGame = true;
        });

        await sessionProvider.loadSessionByRoomId(room.id);

        if (!mounted) return;

        if (sessionProvider.currentSession != null) {
          // On utilise la méthode de navigation sécurisée
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameOrchestratorScreen(
                sessionId: sessionProvider.currentSession!.id,
              ),
            ),
          ).then((_) {
            if (mounted) {
              // Même check au retour
              if (context.read<GameSessionProvider>().isCompleted) return;
              setState(() {
                _hasNavigatedToGame = false;
              });
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur: Session de jeu non trouvée'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _hasNavigatedToGame = false;
          });
        }
      });
    }

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
                    AtomHub(players: atomPlayers),
                    const SizedBox(height: 30),
                    if (room?.status == 'playing') ...[
                      const CircularProgressIndicator(),
                      const Text("Lancement du jeu..."),
                    ] else if (amIHost && roomProvider.isRoomFull)
                      AtomButton(
                        label: "Lancer la Partie",
                        onPressed: _playGames,
                        bgColor: const Color.fromARGB(255, 18, 184, 10),
                      )
                    else if (amIHost)
                      _WaitingMessage(
                        text: "En attente de l'ami...",
                        color: Colors.yellow,
                      )
                    else
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
