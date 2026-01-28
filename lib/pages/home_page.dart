import 'package:flutter/material.dart';
import '../widget/atoms/atom_button.dart';
import '../widget/atoms/atom_title.dart';
import '../widget/organisms/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../store/provider/user_provider.dart';

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
            child: Image.asset('assets/images/feu_vert.png', fit: BoxFit.cover),
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
                      AtomButton(
                        label: 'CRÉER UNE PARTIE',
                        onPressed: () {
                          final userProvider = context.read<UserProvider>();
                          if (userProvider.isConnected) {
                            Navigator.pushNamed(context, '/create_party');
                          } else {
                            Navigator.pushNamed(context, '/login');
                          }
                        },
                        bgColor: Colors.redAccent,
                        width: double.infinity,
                        height: 120,
                      ),
                      SizedBox(height: cardSpacing),
                      AtomButton(
                        label: 'REJOINDRE UNE PARTIE',
                        onPressed: () {
                          final userProvider = context.read<UserProvider>();
                          if (userProvider.isConnected) {
                            Navigator.pushNamed(context, '/join_party');
                          } else {
                            Navigator.pushNamed(context, '/login');
                          }
                        },
                        bgColor: Colors.blueAccent,
                        width: double.infinity,
                        height: 120,
                      ),
                      // ##### DEBUG ##### début
                      SizedBox(height: cardSpacing),
                      AtomButton(
                        label: 'CAESAR DEBUG',
                        onPressed: () {
                          Navigator.pushNamed(context, '/game/caesar_game');
                        },
                        bgColor: const Color.fromARGB(255, 161, 32, 155),
                        width: double.infinity,
                        height: 120,
                      ),
                      SizedBox(height: cardSpacing),
                      AtomButton(
                        label: 'MICROPHONE DEBUG',
                        onPressed: () {
                          Navigator.pushNamed(context, '/game/microphone_game');
                        },
                        bgColor: const Color.fromARGB(255, 161, 32, 155),
                        width: double.infinity,
                        height: 120,
                      ),
                      // ##### DEBUG ##### fin
                    ],
                  ),
                  SizedBox(height: 56),
                  Spacer(),
                ],
              ),
            ),
          ),
          // Boutons de navigation inférieurs (barre fixe)
          const BottomNavBar(),
        ],
      ),
    );
  }
}
