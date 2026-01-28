import 'package:flutter/material.dart';
import '../../core/utils/avatar_helper.dart';

class Player {
  final String pseudo;
  final String avatarUrl;
  final bool isHost;

  const Player({
    required this.pseudo,
    required this.avatarUrl,
    this.isHost = false,
  });
}

class AtomHub extends StatelessWidget {
  // liste des joueurs dans la salle. (max 2 joueurs)
  final List<Player> players;

  const AtomHub({super.key, required this.players});

  // widget pour afficher un seul joueur
  Widget _buildPlayerTile(Player player) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: player.isHost ? Colors.blue.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo de profil (Avatar)
          CircleAvatar(
            radius: 24,
            backgroundImage: player.avatarUrl.isNotEmpty
                ? AvatarHelper.getAvatarImage(player.avatarUrl)
                : null,
            onBackgroundImageError: (exception, stackTrace) {},
            child: player.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
            backgroundColor: player.isHost
                ? Colors.blue.shade400
                : Colors.grey.shade400,
          ),
          const SizedBox(width: 16),

          // Pseudo du joueur
          Expanded(
            child: Text(
              player.pseudo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          if (player.isHost)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Host',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Joueurs dans la Partie (${players.length}/2)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            const SizedBox(height: 10),

            ...players.map(_buildPlayerTile).toList(),

            // affiche "En attente" si un emplacement est libre
            if (players.length < 2)
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.red.shade400,
                      child: const Icon(
                        Icons.hourglass_empty,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'En attente d\'un ami...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
