import 'package:flutter/material.dart';

class AtomTitle extends StatelessWidget {
  final String title;
  final Color color;
  final bool showBack;
  final VoidCallback? onSettings;

  const AtomTitle({
    Key? key,
    required this.title,
    required this.color,
    this.showBack = true,
    this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, 
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          // --- Ellipse géante ---
          Positioned(
            top: -210,
            left: -100,
            right: -100,
            child: Container(
              clipBehavior: Clip.none,
              height: 300,
              decoration: BoxDecoration(
                color: color.withOpacity(0.85),
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
          ),

          // --- Boutons top bar (retour + settings) ---
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton retour (optionnel)
                if (showBack)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                else
                  const SizedBox(width: 48), // pour conserver l'alignement

                // Bouton settings
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: onSettings,
                ),
              ],
            ),
          ),

          // --- Titre centré en bas du header ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
