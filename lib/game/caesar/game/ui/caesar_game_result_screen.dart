import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/caesar_game_notifier.dart';

class CaesarGameResultScreen extends StatelessWidget {
  final bool finalResult;

  const CaesarGameResultScreen({super.key, this.finalResult = false});

  // quand on passe au round suivant
  void onNextRound(BuildContext context) {
    context.read<CaesarGameNotifier>().nextRound();
  }

  // quand le jeu est fini
  void onFinish(BuildContext context) {
    // 1. On récupère le score final via le provider
    final notifier = context.read<CaesarGameNotifier>();
    final score = notifier.state.gameData.score;

    // 2. On prépare le résultat (Format attendu par l'Orchestrator)
    // On peut renvoyer une Map ou directement un GameResult selon ton implémentation
    final result = {'score': score, 'game_type': 'caesar'};

    // 3. On quitte l'écran en renvoyant le résultat
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    // On récupère l'état pour afficher le score final
    final gameState = context.watch<CaesarGameNotifier>().state;
    final score = gameState.gameData.score;
    final bool isFinalResult = finalResult;

    return Center(
      child: Card(
        margin: const EdgeInsets.all(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFinalResult ? "Jeu fini !" : "MANCHE TERMINÉE",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isFinalResult
                    ? "Score final : $score"
                    : "Score actuel : $score",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              // Bouton pour passer à la manche suivante ou finir
              ElevatedButton(
                onPressed: () =>
                    isFinalResult ? onFinish(context) : onNextRound(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  isFinalResult
                      ? "PASSER AU JEU SUIVANT"
                      : "ÉCHANGER LES RÔLES",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
