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
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/feu_vert.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
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
                  const Spacer(),
                  const AtomTitle(text: "SPLIT"),

                  if (userProvider.isConnected) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        "Bonjour, ${user.name}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Column(
                    children: [
                      AtomButton(
                        label: 'CRÉER UNE PARTIE',
                        onPressed: () {
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
                  const SizedBox(height: 56),
                  const Spacer(),
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
