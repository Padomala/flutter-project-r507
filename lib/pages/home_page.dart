import 'package:flutter/material.dart';
import '../widget/atom_button.dart';
import '../widget/atom_title.dart';
import '../widget/molcule_card.dart';
import '../widget/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../store/provider/userProvider.dart';
import '../widget/settings_popup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  AtomTitle(text: "SPLIT"),
                  SizedBox(height: 16),
                  // Boutons principaux en Molécule
                  Column(
                    children: [
                      MoleculeCard(
                        label: 'CRÉER UNE PARTIE',
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
          const SettingsPopup(),

          const BottomNavBar(),
        ],
      ),
    );
  }
}
