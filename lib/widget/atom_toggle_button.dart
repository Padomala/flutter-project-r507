import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final IconData icon;
  final String labelOn;
  final String labelOff;
  final bool value;
  final VoidCallback onPressed;

  const ToggleButton({
    super.key,
    required this.icon,
    required this.labelOn,
    required this.labelOff,
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: value ? Colors.red : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: Colors.white, width: 4),
          ),
          elevation: 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              value ? labelOn : labelOff,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
