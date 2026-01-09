import 'package:flutter/material.dart';

class CaesarGamePage extends StatefulWidget {
  const CaesarGamePage({super.key});

  @override
  State<CaesarGamePage> createState() => _CaesarGamePageState();
}

class _CaesarGamePageState extends State<CaesarGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Caesar'),
        backgroundColor: Colors.pink,
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: Container(
            color: Colors.yellow,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/caesar_transmutation_tablet_yellow.png',
                width: 500,
                height: 500,
                fit: BoxFit.contain,
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
