import 'package:flutter/material.dart';
import 'package:game_v1/app_colors.dart';
import 'package:game_v1/widget/atoms/atom_background_page.dart';
import 'package:game_v1/widget/atoms/atom_button.dart';
import 'package:game_v1/widget/atoms/atom_title_page.dart';
import 'package:game_v1/widget/atoms/atom_hub.dart'; // Import du modèle Player et AtomHub

class RoomHub extends StatefulWidget {
  final int nb;

  const RoomHub({
    super.key,
    required this.nb,
  });

  @override
  State<RoomHub> createState() => _RoomHubState();
}

class _RoomHubState extends State<RoomHub> {
  // Simule l'utilisateur actuel dans la room
  final String _currentUserId = 'user_host_123'; 
  final String _hostId = 'user_host_123';

  // Liste mockée des joueurs (pour l'exemple)
  // Dans une vraie app, cette liste serait mise à jour via Firestore/API
  List<Player> _players = [];
  
  @override
  void initState() {
    super.initState();
    // Initialisation temporaire des joueurs pour le test
    _players = [
      Player(
        pseudo: "PlayerOne (Moi)",
        avatarUrl: "https://placehold.co/100x100/18B80A/FFFFFF?text=Host",
        isHost: true,
      ),
      Player(
        pseudo: "Adversaire",
        avatarUrl: "https://placehold.co/100x100/FF4665/FFFFFF?text=Adv",
        isHost: false,
      ),
    ];
    
    // Pour simuler l'attente, décommentez la ligne ci-dessous :
    // _players = [_players.first];
  }

  void _playGames() {
    // La logique de navigation pour lancer le premier mini-jeu
    print("Lancement de la partie avec ${widget.nb} mini-jeux.");
    // Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bool isHost = _currentUserId == _hostId;
    final bool isRoomFull = _players.length == 2;

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundPage(pathBackground: "assets/images/carrefour.png"),
          
          AtomTitle(
            title: "Hub de la Partie",
            color: Colors.red,
            showBack: false,
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0, bottom: 20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // ---- INFO PARTIE ----
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Mini-jeux prévus : ${widget.nb}",
                        style: const TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.w600,
                          color: Colors.black87
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),

                    // ---- LISTE DES JOUEURS (AtomHub) ----
                    AtomHub(players: _players),
                    
                    const SizedBox(height: 30),

                    // ---- BOUTON LANCER LA PARTIE & MESSAGES D'ATTENTE ----
                    if (isHost && isRoomFull)
                      // Host peut lancer si la room est pleine
                      AtomButton(
                        label: "Lancer la Partie", 
                        onPressed: _playGames, 
                        // Utilise une couleur sécurisée si AppColors n'est pas défini
                        bgColor: Color.fromARGB(255, 18, 184, 10), 
                      )
                    else if (isHost)
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