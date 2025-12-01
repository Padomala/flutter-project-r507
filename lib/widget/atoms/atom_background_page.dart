import 'package:flutter/material.dart';

class BackgroundPage extends StatelessWidget {
  final String pathBackground;

  const BackgroundPage({super.key, required this.pathBackground});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withAlpha(20),
          BlendMode.darken,
        ),
        child: Image.asset(pathBackground, fit: BoxFit.cover),
      ),
    );
  }
}
