import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart'; 
import '../../core/game_enums.dart';
import '../state/guessing_game_notifier.dart';
import '../models/guessing_state_model.dart';
import '../../../../app_colors.dart'; 

class GuessingGameScreen extends StatefulWidget {
  final String gameId;
  const GuessingGameScreen({super.key, required this.gameId});

  @override
  State<GuessingGameScreen> createState() => _GuessingGameScreenState();
}

class _GuessingGameScreenState extends State<GuessingGameScreen> {
  final TextEditingController _guessController = TextEditingController();

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final notifier = context.read<GuessingGameNotifier>();
    final state = context.watch<GuessingGameNotifier>().state;
    final isLoading = context.select<GuessingGameNotifier, bool>((n) => n.isLoading);

    if (state.isGameOver) {
      return _buildGameOverPopup(context, notifier);
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. FOND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/voiture_rouge.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)), // Assombrir un peu plus

          // 2. BOUTON RETOUR
          Positioned(
            top: 40, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textColor, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // 3. INFO BAR
          Positioned(
            top: 40, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(20)),
              child: Text(
                "Manche ${state.currentRound} / 2",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          // 4. CONTENU PRINCIPAL
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenSize.width * 0.9,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // Fond blanc pour faire ressortir le style "Carte"
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: _buildGameContent(state, notifier, isLoading),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(GuessingGameState state, GuessingGameNotifier notifier, bool isLoading) {
    // Si on attend le joueur B
    if (state.currentState == GameStateEnum.waiting) {
      return _buildWaitingScreen('En attente du second joueur...');
    }

    // Si la manche est terminée (Gagné ou Perdu)
    if (state.currentState == GameStateEnum.results) {
      return _buildRoundResultsScreen(state, notifier, isLoading);
    }

    // --- EN JEU ---
    if (state.amIDescriber) {
      // VUE DU DESCRIPTEUR (Voir la carte)
      return _buildDescriberView(state);
    } else {
      // VUE DU DEVINEUR (Champ texte)
      return _buildGuesserView(state, notifier, isLoading);
    }
  }

  // --- 1. VUE DU DESCRIPTEUR (La Carte Taboo) ---
  Widget _buildDescriberView(GuessingGameState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("FAITES DEVINER CE MOT", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        
        // LE MOT CIBLE
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.blue, width: 2)
          ),
          child: Text(
            state.gameData.targetWord.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
          ),
        ),
        
        const SizedBox(height: 25),
        const Text("SANS DIRE CES MOTS :", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),

        // LES MOTS INTERDITS
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.red.withOpacity(0.3))
          ),
          child: Column(
            children: state.gameData.forbiddenWords.map((word) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, color: AppColors.red, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    word.toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.red),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        
        const SizedBox(height: 30),
        const LinearProgressIndicator(color: AppColors.yellow), // Juste pour l'animation visuelle
        const SizedBox(height: 10),
        const Text("L'autre joueur essaye de deviner...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      ],
    );
  }

  // --- 2. VUE DU DEVINEUR (L'input) ---
  Widget _buildGuesserView(GuessingGameState state, GuessingGameNotifier notifier, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.hearing, size: 60, color: AppColors.blue),
        const SizedBox(height: 10),
        _buildTitle('ÉCOUTEZ BIEN !'),
        const SizedBox(height: 10),
        const Text(
          "L'autre joueur vous décrit un mot.\nNe regardez pas son écran !",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 40),

        _buildStyledTextField(_guessController, 'Votre réponse...', Icons.lightbulb),
        const SizedBox(height: 20),
        _buildStyledButton('PROPOSER', isLoading, () {
          notifier.submitGuess(_guessController.text);
          _guessController.clear();
        }),
      ],
    );
  }

  // --- 3. RÉSULTATS ---
  Widget _buildRoundResultsScreen(GuessingGameState state, GuessingGameNotifier notifier, bool isLoading) {
    final bool isCorrect = state.gameData.isCorrect == true;
    final bool isLastRound = state.currentRound == 2;
    final String target = state.gameData.targetWord;
    final String guess = state.gameData.guess ?? "?";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isCorrect ? Icons.check_circle : Icons.cancel, size: 80, color: isCorrect ? Colors.green : Colors.red),
        const SizedBox(height: 15),
        _buildTitle(isCorrect ? 'TROUVÉ !' : 'RATÉ !'),
        const SizedBox(height: 20),
        
        Text("Le mot était :", style: TextStyle(color: Colors.grey[600])),
        Text(target, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Proposition : $guess", style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),

        const SizedBox(height: 30),
        _buildStyledButton(
          isLastRound ? 'VOIR LE SCORE FINAL' : 'MANCHE SUIVANTE', 
          isLoading, 
          () => notifier.proceedToNextStep(), 
          color: isCorrect ? Colors.green : AppColors.blue
        ),
      ],
    );
  }

  // --- HELPERS UI ---
  Widget _buildTitle(String text) {
    return Text(
      text, 
      textAlign: TextAlign.center, 
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textColor, letterSpacing: 1.2)
    );
  }

  Widget _buildWaitingScreen(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.blue),
        const SizedBox(height: 30),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStyledTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        decoration: InputDecoration(
          hintText: label, 
          prefixIcon: Icon(icon, color: AppColors.blue), 
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
        ),
      ),
    );
  }

  Widget _buildStyledButton(String label, bool isLoading, VoidCallback onPressed, {Color color = AppColors.blue}) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: isLoading ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
  
  // Le popup game over reste inchangé mais je l'inclus pour complétude
  Widget _buildGameOverPopup(BuildContext context, GuessingGameNotifier notifier) {
    final state = notifier.state;
    
    // Compter les victoires (pour l'instant égalité car pas de tracking des rounds)
    // TODO: Ajouter un système pour tracker qui a gagné chaque round
    final Map<String, dynamic> gameResults = {
      'finished': true,
      'playerA_score': 1, // Pour l'instant on met 1-1
      'playerB_score': 1,
      'note': 'Système de rounds à améliorer'
    };
    
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.8)),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppColors.yellow, 
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag, size: 60, color: AppColors.textColor),
                  const SizedBox(height: 15),
                  const Text("PARTIE TERMINÉE", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 30),
                  _buildStyledButton("REJOUER", false, () {
                       _guessController.clear();
                       notifier.resetGameFull();
                  }, color: AppColors.blue),
                  _buildStyledButton("TERMINER", false, () {
                    // Retourner les résultats à l'orchestrateur
                    Navigator.pop(context, gameResults);
                  }, color: AppColors.gray),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}