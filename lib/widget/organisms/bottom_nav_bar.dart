import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/provider/user_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(color: Colors.white, width: 12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (userProvider.isConnected) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  Navigator.pushNamed(context, '/register');
                }
              },
              // Si connecté et avatar présent -> Photo, Sinon -> Icone
              icon:
                  (userProvider.isConnected &&
                      user.avatarUrl != null &&
                      user.avatarUrl!.isNotEmpty)
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(user.avatarUrl!),
                      onBackgroundImageError: (_, __) {
                        debugPrint("Erreur chargement avatar");
                      },
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 28),
              tooltip: 'Profil',
            ),

            IconButton(
              onPressed: () {
                if (ModalRoute.of(context)?.settings.name != '/home') {
                  Navigator.pushNamed(context, '/home');
                }
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 28),
              tooltip: 'Accueil',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shop');
              },
              icon: const Icon(Icons.store, color: Colors.white, size: 28),
              tooltip: 'Shop',
            ),
          ],
        ),
      ),
    );
  }
}
