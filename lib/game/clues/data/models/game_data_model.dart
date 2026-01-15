import 'package:flutter/foundation.dart';

@immutable
class GuessingGameDataModel {
  final String targetWord;
  final List<String> forbiddenWords; // Changement ici
  final String? guess; // Proposition du devineur
  final bool? isCorrect; // Résultat de la manche

  const GuessingGameDataModel({
    required this.targetWord,
    required this.forbiddenWords,
    this.guess,
    this.isCorrect,
  });

  factory GuessingGameDataModel.fromJson(Map<String, dynamic> json) {
    final forbidden = (json['forbiddenWords'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return GuessingGameDataModel(
      targetWord: json['targetWord'] as String? ?? 'ERREUR',
      forbiddenWords: forbidden,
      guess: json['guess'] as String?, 
      isCorrect: json['isCorrect'] as bool?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetWord': targetWord,
      'forbiddenWords': forbiddenWords,
      'guess': guess,
      'isCorrect': isCorrect,
    };
  }
}