import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/provider/user_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
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
                final userProvider = context.read<UserProvider>();
                if (userProvider.isConnected) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  Navigator.pushNamed(context, '/register');
                }
              },
              icon: Icon(Icons.person, color: Colors.white, size: 28),
              tooltip: 'Profil',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              icon: Icon(Icons.home, color: Colors.white, size: 28),
              tooltip: 'Accueil',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shop');
              },
              icon: Icon(Icons.store, color: Colors.white, size: 28),
              tooltip: 'Shop',
            ),
          ],
        ),
      ),
    );
  }
}
