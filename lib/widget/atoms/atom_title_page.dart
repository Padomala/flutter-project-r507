import 'package:flutter/material.dart';

class AtomTitle extends StatelessWidget {
  final String title;
  final Color color;

  final bool showBack;
  final VoidCallback? onSettings;
  final VoidCallback? onBack;

  const AtomTitle({
    super.key,
    required this.title,
    required this.color,
    this.showBack = true,
    this.onSettings,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ellipse en haut
          Positioned(
            top: -210,
            left: -100,
            right: -100,
            child: Container(
              clipBehavior: Clip.none,
              height: 300,
              decoration: BoxDecoration(
                color: color.withAlpha(220),
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
          ),

          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showBack)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  )
                else
                  const SizedBox(width: 48),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: onSettings,
                ),
              ],
            ),
          ),

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
