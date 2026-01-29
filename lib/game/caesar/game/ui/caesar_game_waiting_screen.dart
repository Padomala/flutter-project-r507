import 'package:flutter/material.dart';
import '../../../../app_colors.dart';

class CaesarGameWaitingScreen extends StatelessWidget {
  const CaesarGameWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const String message = "En attente du second joueur...";

    return Center(
      child: Container(
        width: screenSize.width * 0.85,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),

            const CircularProgressIndicator(color: AppColors.blue),

            const SizedBox(height: 30),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Préparez-vous !",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
