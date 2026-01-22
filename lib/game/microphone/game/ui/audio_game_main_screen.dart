import 'package:flutter/material.dart';
import 'package:game_v1/game/microphone/game/ui/audio_game_infoter_screen.dart';
import 'package:game_v1/game/microphone/game/ui/audio_game_microter_screen.dart';

class MicrophoneGamePage extends StatefulWidget {
  const MicrophoneGamePage({super.key});

  @override
  State<MicrophoneGamePage> createState() => _MicrophoneGamePageState();
}

class _MicrophoneGamePageState extends State<MicrophoneGamePage> {
  // Set this variable to switch between Infoter (false) and Inputer (true)
  bool showInputer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1, 2, 3, criez !'),
        backgroundColor: Colors.pink,
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
              ? MicrophoneGamePageMicroter()
              : MicrophoneGamePageInfoter(),
        ],
      ),
    );
  }
}
