import 'package:flutter/material.dart';
import 'package:game_v1/widget/atoms/atom_background_page.dart';
import 'package:game_v1/widget/atoms/atom_title_page.dart';
// import 'package:game_v1/widget/atoms/atom_title.dart'; // Décommente si besoin

class RoomHub extends StatelessWidget {
  final int nb;

  const RoomHub({
    super.key,
    required this.nb,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundPage(pathBackground: "assets/images/carrefour.png"),
          AtomTitle(
                  title: "Hub de la Partie",
                  color: Colors.red,
                  showBack: false,
                ),
          SafeArea( // Ajout de SafeArea pour éviter que le texte soit sous la barre de notif
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Nombre de mini-jeux choisis : $nb",
                      style: const TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}