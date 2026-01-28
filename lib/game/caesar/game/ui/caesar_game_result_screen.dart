import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/caesar_game_notifier.dart';

class CaesarGameResultScreen extends StatelessWidget {
  final bool finalResult;

  const CaesarGameResultScreen({super.key, this.finalResult = false});

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
              const Text(
                "MANCHE TERMINÉE",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Score actuel : $score",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              // Bouton pour passer à la manche suivante (échange)
              ElevatedButton(
                onPressed: () {
                  // On demande au notifier de préparer la manche suivante
                  context.read<CaesarGameNotifier>().nextRound();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  isFinalResult ? "PASSER AU JEU SUIVANT" : "ÉCHANGER LES RÔLES",
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