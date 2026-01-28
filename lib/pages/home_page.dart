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
          Positioned.fill(
            child: Image.asset('assets/images/feu_vert.png', fit: BoxFit.cover),
          ),
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
                  Spacer(),
                  AtomTitle(text: "SPLIT"),
                  SizedBox(height: 16),
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
                    ],
                  ),
                  SizedBox(height: 56),
                  Spacer(),
                ],
              ),
            ),
          ),
          const BottomNavBar(),
        ],
      ),
    );
  }
}
