import 'package:flutter/material.dart';

class AtomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color bgColor;
  final double width;
  final double height;

  const AtomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.bgColor = Colors.white,
    this.width = 300,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Colors.white, width: 12),
          ),
          elevation: 8,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
