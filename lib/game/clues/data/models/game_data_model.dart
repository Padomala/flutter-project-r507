import 'package:flutter/foundation.dart';

/// Représente les données d'une manche de jeu de devinettes.
///
/// Ce modèle est immuable ([immutable]), ce qui garantit que les données
/// ne changent pas après la création de l'instance.
@immutable
class GuessingGameDataModel {
  /// Le mot secret que le joueur doit faire deviner.
  final String targetWord;

  /// La liste des mots que l'orateur n'a pas le droit d'utiliser.
  final List<String> forbiddenWords;

  /// La dernière proposition envoyée par le joueur qui devine.
  final String? guess;

  /// Indique si la proposition ([guess]) correspond au [targetWord].
  final bool? isCorrect;

  /// Le score de la manche.
  final int score;

  const GuessingGameDataModel({
    required this.targetWord,
    required this.forbiddenWords,
    this.guess,
    this.isCorrect,
    this.score = 0,
  });

  /// Crée une instance de [GuessingGameDataModel] à partir d'un objet JSON.
  factory GuessingGameDataModel.fromJson(Map<String, dynamic> json) {
    // Transformation de la liste dynamique en liste de chaînes de caractères
    final forbidden = (json['forbiddenWords'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return GuessingGameDataModel(
      targetWord: json['targetWord'] as String? ?? 'ERREUR',
      forbiddenWords: forbidden,
      guess: json['guess'] as String?,
      isCorrect: json['isCorrect'] as bool?,
      score: (json['score'] as int?) ?? 0,
    );
  }

  /// Convertit l'instance actuelle en une [Map] compatible avec le format JSON.
  Map<String, dynamic> toJson() {
    return {
      'targetWord': targetWord,
      'forbiddenWords': forbiddenWords,
      'guess': guess,
      'isCorrect': isCorrect,
      'score': score,
    };
  }
}
