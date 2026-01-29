import 'package:flutter/material.dart';
import 'package:game_v1/game/caesar/game/ui/caesar_game_result_screen.dart';
import 'package:game_v1/game/caesar/game/ui/caesar_game_waiting_screen.dart';
import 'package:provider/provider.dart';
import 'package:game_v1/game/caesar/core/game_enums.dart';
import 'package:game_v1/game/caesar/game/models/caesar_state_model.dart';
import 'package:game_v1/game/caesar/game/state/caesar_game_notifier.dart';

import 'caesar_game_infoter_screen.dart';
import 'caesar_game_inputer_screen.dart';

class CaesarGamePage extends StatefulWidget {
  const CaesarGamePage({super.key, required this.gameId});

  final String gameId;

  @override
  State<CaesarGamePage> createState() => _CaesarGamePageState();
}

class _CaesarGamePageState extends State<CaesarGamePage> {
  @override
  Widget build(BuildContext context) {
    // We get the Notifier
    final gameState = context.watch<CaesarGameNotifier>().state;
    final isLoading = context.select<CaesarGameNotifier, bool>(
      (n) => n.isLoading,
    );

    // 2. LOGIQUE DE RÔLE
    final bool isLocalPlayerInputer =
        (gameState.localPlayerId == PlayerId.playerA)
        ? gameState.gameRound % 2 != 0
        : gameState.gameRound % 2 == 0;
    // here we set the correct screen for the round
    final bool isLocalPlayerInputer =
        (gameState.localPlayerId == PlayerId.playerA)
        ? gameState.gameRound % 2 != 0
        : gameState.gameRound % 2 == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Code Caesar - ${isLocalPlayerInputer ? "Joueur A" : "Joueur B"}',
        ),
        backgroundColor: Colors.pink,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Score: ${gameState.gameData.score}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/salon_magneto.png',
              fit: BoxFit.cover,
            ),
          ),
          _buildGameContent(gameState, isLocalPlayerInputer),
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.pink),
              ),
            ),
        ],
      ),
    );
  }

  /// Functuion that show the correct screen for each gameState
  Widget _buildGameContent(CaesarGameState state, bool isInputer) {
    if (state.isGameOver) {
      return const CaesarGameResultScreen(finalResult: true);
    }

    if (state.isRoundOver) {
      return const CaesarGameResultScreen();
    }

    if (state.currentState == GameStateEnum.waiting) {
      return const CaesarGameWaitingScreen();
    }

    return isInputer
        ? const CaesarGamePageInputer()
        : const CaesarGamePageInfoter();
  }
}
