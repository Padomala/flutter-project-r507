import 'package:flutter/material.dart';

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
          color: Colors.green, // Fond vert
          border: Border.all(
            color: Colors.white,
            width: 12, // Bordure blanche épaisse
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
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
              tooltip: 'Magasin',
            ),
          ],
        ),
      ),
    );
  }
}
