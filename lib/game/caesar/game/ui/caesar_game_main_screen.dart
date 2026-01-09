import 'package:flutter/material.dart';
import 'caesar_game_infoter_screen.dart';
import 'caesar_game_inputer_screen.dart';

class CaesarGamePage extends StatefulWidget {
  const CaesarGamePage({super.key});

  @override
  State<CaesarGamePage> createState() => _CaesarGamePageState();
}

class _CaesarGamePageState extends State<CaesarGamePage> {
  // Set this variable to switch between Infoter (false) and Inputer (true)
  bool showInputer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Caesar'),
        backgroundColor: Colors.pink,
        actions: [
          // Button to toggle between Infoter and Inputer for demonstration
          IconButton(
            icon: Icon(showInputer ? Icons.info_outline : Icons.edit),
            onPressed: () {
              setState(() {
                showInputer = !showInputer;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image adapting to the available space (covers the background)
          Positioned.fill(
            child: Image.asset(
              'assets/images/salon_magneto.png',
              fit: BoxFit.cover,
            ),
          ),
          showInputer
              ? CaesarGamePageInputer()
              : CaesarGamePageInfoter(),
        ],
      ),
    );
  }
}
