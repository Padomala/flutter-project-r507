import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app_colors.dart';
import '../../core/game_enums.dart';
import '../models/caesar_state_model.dart';
import '../state/caesar_game_notifier.dart';
import 'caesar_game_result_screen.dart';
import 'caesar_game_waiting_screen.dart';
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

    return Scaffold(
      body: Stack(
        children: [
          // 1. FOND (Image spécifique au Caesar)
          Positioned.fill(
            child: Image.asset(
              'assets/images/salon_magneto.png',
              fit: BoxFit.cover,
            ),
          ),

          // Optionnel : Un léger overlay sombre pour la lisibilité si nécessaire
          // Container(color: Colors.black.withOpacity(0.1)),

          // 2. CONTENU DU JEU (Avec padding pour ne pas être sous les boutons)
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: _buildGameContent(gameState, isLocalPlayerInputer),
          ),

          // 3. BOUTON RETOUR (Style harmonisé)
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textColor, // Utilise la couleur globale
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 4. INFO BAR (Manche / Score - Style harmonisé)
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.yellow, // Jaune comme les autres jeux
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    // On adapte l'affichage pour montrer la manche
                    "Manche ${gameState.gameRound + 1} / 2",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                  // Optionnel : Si tu veux garder le score visible ici aussi
                  const SizedBox(width: 8),
                  Container(width: 1, height: 14, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    "${gameState.gameData.score} pts",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. LOADER
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.blue),
              ),
            ),
        ],
      ),
    );
  }

  /// Function that show the correct screen for each gameState
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
