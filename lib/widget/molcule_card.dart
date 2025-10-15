import 'package:flutter/material.dart';

class MoleculeCard extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color bgColor;
  final double width;
  final double height;

  const MoleculeCard({
    Key? key,
    required this.label,
    required this.onPressed,
    this.bgColor = Colors.white,
    this.width = 320,
    this.height = 120,
  }) : super(key: key);

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
          ),
          elevation: 8,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
