import 'package:flutter/material.dart';

class AtomTitle extends StatelessWidget {
  final String text;

  const AtomTitle({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 64,
        color: Colors.white,
        shadows: [
          Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4),
        ],
      ),
    );
  }
}
