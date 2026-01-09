import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/game_enums.dart';
import '../state/guessing_game_notifier.dart';
import '../models/guessing_state_model.dart';

class GuessingGameScreen extends StatefulWidget {
  final String gameId;

  const GuessingGameScreen({super.key, required this.gameId});

  @override
  State<GuessingGameScreen> createState() => _GuessingGameScreenState();
}

class _GuessingGameScreenState extends State<GuessingGameScreen> {
  // 2. On définit les controllers ici pour qu'ils ne soient pas recréés à chaque clic
  final TextEditingController _guessController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    // Toujours nettoyer les controllers quand on quitte l'écran
    _guessController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Attention : avec StatefulWidget, on utilise context.read/watch normalement
    final notifier = context.read<GuessingGameNotifier>();
    final state = context.watch<GuessingGameNotifier>().state;
    // On récupère isLoading depuis le notifier (assurez-vous d'avoir ajouté le getter dans le Notifier comme vu précédemment)
    final isLoading = context.select<GuessingGameNotifier, bool>((n) => n.isLoading);

    final isLocalPlayerA = state.localPlayerId == PlayerId.playerA;

    Widget buildBodyContent() {
      switch (state.currentState) {
        case GameStateEnum.waiting:
          return _buildWaitingScreen('En attente de l\'autre joueur...');

        case GameStateEnum.playerATurn:
          if (isLocalPlayerA) {
            return _buildPlayerATurn(context, state, notifier, isLoading);
          } else {
            return _buildWaitingScreen('Joueur A réfléchit...', secretWord: state.gameData.targetWord);
          }

        case GameStateEnum.playerBTurn:
          if (!isLocalPlayerA) { // Joueur B
            return _buildPlayerBTurn(context, state, notifier, isLoading);
          } else {
            return _buildWaitingScreen('Joueur B valide l\'hypothèse...');
          }

        case GameStateEnum.results:
          return _buildResultsScreen(state, notifier, isLoading);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Indices Flous (${state.localPlayerId == PlayerId.playerA ? 'Joueur A' : 'Joueur B'})',
          style: const TextStyle(color: kTextColor),
        ),
        backgroundColor: kBackgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: buildBodyContent(),
        ),
      ),
      backgroundColor: kBackgroundColor,
    );
  }

  // --- Widgets spécifiques aux états ---

  Widget _buildPlayerATurn(BuildContext context, GuessingGameState state, GuessingGameNotifier notifier, bool isLoading) {
    // Note : On utilise _guessController défini tout en haut de la classe
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Vous devez deviner le mot !', style: TextStyle(color: kTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Vos indices :', style: TextStyle(color: kTextColor, fontSize: 18)),
          const SizedBox(height: 10),
          ...state.gameData.cluesForA.map((clue) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text('• $clue', style: const TextStyle(color: kSuccessColor, fontSize: 18)),
          )).toList(),
          
          const SizedBox(height: 40),
          TextField(
            controller: _guessController, // Utilisation du controller de la classe
            style: const TextStyle(color: kTextColor),
            decoration: const InputDecoration(
              labelText: 'Votre hypothèse (un seul mot) :',
              labelStyle: TextStyle(color: kTextColor),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            // Correction ici : on vérifie isLoading et on utilise _guessController
            onPressed: isLoading ? null : () => notifier.submitGuess(_guessController.text),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Soumettre l\'Hypothèse'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBTurn(BuildContext context, GuessingGameState state, GuessingGameNotifier notifier, bool isLoading) {
    // Note : On utilise _confirmController défini tout en haut de la classe
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Le mot secret est :', style: TextStyle(color: kTextColor, fontSize: 18)),
        Text(state.gameData.targetWord, style: const TextStyle(color: kPrimaryColor, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),

        const Text('Hypothèse de Joueur A :', style: TextStyle(color: kTextColor, fontSize: 18)),
        const SizedBox(height: 10),
        Text(state.gameData.playerAGuess ?? '...', style: const TextStyle(color: kSuccessColor, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),

        const Text('Confirmez le mot final :', style: TextStyle(color: kTextColor, fontSize: 16)),
        TextField(
          controller: _confirmController, // Utilisation du controller de la classe
          style: const TextStyle(color: kTextColor),
          decoration: const InputDecoration(
            labelText: 'Mot final à confirmer :',
            labelStyle: TextStyle(color: kTextColor),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          // Correction ici : on vérifie isLoading et on utilise _confirmController
          onPressed: isLoading ? null : () => notifier.confirmFinalWord(_confirmController.text),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirmer & Terminer'),
        ),
      ],
    );
  }

  Widget _buildResultsScreen(GuessingGameState state, GuessingGameNotifier notifier, bool isLoading) {
    final bool? isCorrect = state.gameData.isCorrect;
    final String verdict = isCorrect == true ? 'RÉUSSITE !' : 'ÉCHEC';
    final Color color = isCorrect == true ? kSuccessColor : kErrorColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(verdict, style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text('Mot cible : ${state.gameData.targetWord}', style: const TextStyle(color: kTextColor, fontSize: 20)),
        Text('Hypothèse A : ${state.gameData.playerAGuess}', style: const TextStyle(color: kTextColor, fontSize: 20)),
        Text('Mot final B : ${state.gameData.playerBResult}', style: const TextStyle(color: kTextColor, fontSize: 20)),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: isLoading ? null : () {
             // On vide les champs de texte pour la prochaine partie
             _guessController.clear();
             _confirmController.clear();
             notifier.resetGame();
          },
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          child: isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Nouvelle Partie'),
        ),
      ],
    );
  }

  Widget _buildWaitingScreen(String message, {String? secretWord}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: kPrimaryColor),
        const SizedBox(height: 20),
        Text(message, style: const TextStyle(color: kTextColor, fontSize: 18)),
        if (secretWord != null) ...[
           const SizedBox(height: 20),
           const Text('Mot Secret :', style: TextStyle(color: kTextColor, fontSize: 16)),
           Text(secretWord, style: const TextStyle(color: kErrorColor, fontSize: 28, fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }
}