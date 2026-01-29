import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/provider/user_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    // route actuelle
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              tooltip: 'Profil',
              onPressed: () {
                if (userProvider.isConnected) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  Navigator.pushNamed(context, '/register');
                }
              },
              child:
                  (userProvider.isConnected &&
                      user.avatarUrl != null &&
                      user.avatarUrl!.isNotEmpty)
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(user.avatarUrl!),
                        onBackgroundImageError: (_, __) {
                          debugPrint("Erreur chargement avatar");
                        },
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            _NavItem(
              tooltip: 'Accueil',
              isActive: currentRoute == '/home',
              onPressed: () {
                if (currentRoute != '/home') {
                  Navigator.pushNamed(context, '/home');
                }
              },
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            _NavItem(
              tooltip: 'Shop',
              onPressed: () {
                Navigator.pushNamed(context, '/shop');
              },
              child: const Icon(
                Icons.store_mall_directory_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// widget pour les boutons de navigation
class _NavItem extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String tooltip;
  final bool isActive;

  const _NavItem({
    required this.onPressed,
    required this.child,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: isActive
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                )
              : null,
          child: Tooltip(message: tooltip, child: child),
        ),
      ),
    );
  }
}
