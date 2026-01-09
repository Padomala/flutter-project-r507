import 'package:flutter/foundation.dart';

@immutable
class GuessingGameDataModel {
  final String targetWord;
  final List<String> cluesForA;
  final String? playerAGuess;
  final String? playerBResult;
  final bool? isCorrect; // Doit rester nullable !

  const GuessingGameDataModel({
    required this.targetWord,
    required this.cluesForA,
    this.playerAGuess,
    this.playerBResult,
    this.isCorrect,
  });

  factory GuessingGameDataModel.fromJson(Map<String, dynamic> json) {
    final clues = (json['cluesForA'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return GuessingGameDataModel(
      targetWord: json['targetWord'] as String? ?? 'ERREUR',
      cluesForA: clues,
      // On garde null si c'est null, sinon on prend la string
      playerAGuess: json['playerAGuess'] as String?, 
      playerBResult: json['playerBResult'] as String?,
      // CRUCIAL : Ne pas mettre ?? false ici, sinon le jeu finit instantanément
      isCorrect: json['isCorrect'] as bool?, 
    );
  }

  // Pour faciliter la création du JSON à envoyer à Supabase
  Map<String, dynamic> toJson() {
    return {
      'targetWord': targetWord,
      'cluesForA': cluesForA,
      'playerAGuess': playerAGuess,
      'playerBResult': playerBResult,
      'isCorrect': isCorrect,
    };
  }
}