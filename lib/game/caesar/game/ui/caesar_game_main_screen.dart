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
  const CaesarGamePage({super.key});

  @override
  State<CaesarGamePage> createState() => _CaesarGamePageState();
}

class _CaesarGamePageState extends State<CaesarGamePage> {
  // Suppression de la variable 'showInputer' car on utilise maintenant le 'gameState'

  @override
  Widget build(BuildContext context) {
    // 1. RÉCUPÉRATION DES DONNÉES (Le Notifier que nous avons créé)
    // On utilise gameState pour ne pas confondre avec le State du widget
    final gameState = context.watch<CaesarGameNotifier>().state;
    final isLoading = context.select<CaesarGameNotifier, bool>((n) => n.isLoading);

    // 2. LOGIQUE DE RÔLE
    final bool isLocalPlayerInputer = (gameState.localPlayerId == PlayerId.playerA) 
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
          )
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

  /// Méthode qui affiche le bon écran selon l'état de jeu
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


    return isInputer ? const CaesarGamePageInputer() : const CaesarGamePageInfoter();
    }
}