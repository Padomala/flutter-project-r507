import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:game_v1/app_colors.dart';
import 'package:game_v1/widget/atoms/atom_background_page.dart';
import 'package:game_v1/widget/atoms/atom_button.dart';
import 'package:game_v1/widget/atoms/atom_title_page.dart';
import 'package:game_v1/widget/atoms/atom_hub.dart';
import '../../store/provider/room_provider.dart';

class RoomHub extends StatefulWidget {
  const RoomHub({super.key});

  @override
  State<RoomHub> createState() => _RoomHubState();
}

class _RoomHubState extends State<RoomHub> {
  
  int _previousParticipantCount = 0;

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
      await context.read<RoomProvider>().startGame();
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lancement: $e')),
          );
       }
    }
  }

  void _leaveRoom() async {
    // If I am host, we might want to warn or delete room.
    // For now, standard leave.
    await context.read<RoomProvider>().leaveRoom();
    if (!mounted) return;
    Navigator.pop(context);
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
       // 1. Guest detects Host left
       if (!amIHost) {
          final bool hasHost = players.any((p) => p.isHost);
          // If no host is found (list empty or host left), we must exit
          if (!hasHost) {
              context.read<RoomProvider>().leaveLocalInfo(); 
              Navigator.popUntil(context, (route) => route.isFirst || route.settings.name == '/home');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("L'hôte a quitté la partie. La room est fermée."),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
              return;
          }
       }

       // 2. Host detects Guest left (Notification only)
       if (players.length < _previousParticipantCount) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Un joueur a quitté la partie."),
              backgroundColor: Colors.orange,
            )
         );
       }
       // Update counter for next frame
       _previousParticipantCount = players.length;
    });
    
    // Check if game started
    if (room != null && room.status == 'playing') {
       // ... existing game start logic ...
    }

    // Convert RoomParticipant to AtomHub Player model if needed, or update AtomHub to use RoomParticipant.
    // AtomHub expects List<Player>. Let's map.
    final atomPlayers = players.map((p) => Player(
      pseudo: p.pseudo ?? (p.isHost ? 'Host' : 'Joueur'),
      avatarUrl: p.avatarUrl ?? "https://placehold.co/100x100/18B80A/FFFFFF?text=${p.id.substring(0,2)}",
      isHost: p.isHost,
    )).toList();

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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text("CODE SALLE", style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                                  Clipboard.setData(ClipboardData(text: roomCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Code copié !')),
                                  );
                                },
                              )
                            ],
                          ),
                          Text("$nbGames mini-jeux"),
                        ],
                      )
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
                       )
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
        border: Border.all(color: AppColors.gray)
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
              style: TextStyle(color: AppColors.gray, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}