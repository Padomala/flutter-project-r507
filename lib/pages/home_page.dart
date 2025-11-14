import 'package:flutter/material.dart';
import '../widget/atom_button.dart';
import '../widget/atom_title.dart';
import '../widget/molcule_card.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double cardSpacing = 20.0;

    return Scaffold(
      body: Stack(
        children: [
          // Image d'arrière-plan associée à la maquette
          Positioned.fill(
            child: Image.asset(
              '../../assets/images/feu_vert.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dégradé sombre pour lisibilité
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 28.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  // Titre
                  Spacer(),
                  AtomTitle(text: 'SPLIT'),
                  SizedBox(height: 16),
                  // Boutons principaux en Molécule
                  Column(
                    children: [
                      MoleculeCard(
                        label: 'CREER UNE PARTIE',
                        onPressed: () {
                          Navigator.pushNamed(context, '/create_party');
                        },
                        bgColor: Colors.redAccent,
                        width: 320,
                        height: 120,
                      ),
                      SizedBox(height: cardSpacing),
                      MoleculeCard(
                        label: 'REJOINDRE UNE PARTIE',
                        onPressed: () {
                          Navigator.pushNamed(context, '/join_party');
                        },
                        bgColor: Colors.blueAccent,
                        width: 320,
                        height: 120,
                      ),
                    ],
                  ),
                  SizedBox(height: 56),
                  Spacer(),
                ],
              ),
            ),
          ),
          // Boutons de navigation inférieurs (barre fixe)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green, // Fond vert
                border: Border.all(
                  color: Colors.white,
                  width: 12, // Bordure blanche épaisse
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    icon: Icon(Icons.person, color: Colors.white, size: 28),
                    tooltip: 'Profil',
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.home, color: Colors.white, size: 28),
                    tooltip: 'Accueil',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    icon: Icon(Icons.store, color: Colors.white, size: 28),
                    tooltip: 'Magasin',
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
