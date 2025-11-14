import 'package:flutter/material.dart';

class AtomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const AtomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color = Colors.redAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Colors.white,
            width:
                4, // ← épaisseur du contour, mets 5 si tu veux un truc bien bourrin
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        elevation: 6,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
