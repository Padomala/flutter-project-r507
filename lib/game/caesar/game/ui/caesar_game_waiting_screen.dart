import 'package:flutter/material.dart';

class CaesarGameWaitingScreen extends StatelessWidget {
  const CaesarGameWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining the message locally within the build method
    const String message = "En attente du second joueur...";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            const CircularProgressIndicator(
              color: Colors.blue, // You can change this to your AppColors.blue
            ),
            const SizedBox(height: 30),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}