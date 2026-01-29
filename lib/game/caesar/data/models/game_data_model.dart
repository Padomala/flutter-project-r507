import 'package:flutter/foundation.dart';
// Based on the document from the guessing game

@immutable
class CaesarGameDataModel {
  final int score;

  const CaesarGameDataModel({
    this.score = 0,
  });

  /// create the json at the start of the game
  factory CaesarGameDataModel.fromJson(Map<String, dynamic> json) {
    return CaesarGameDataModel(
      score: (json['score'] as int?) ?? 0,
    );
  }

  /// Convert the score to send it at into supabase
  Map<String, dynamic> toJson() {
    return {
      'score': score,
    };
  }

  /// Copy the object and changing only the score
  CaesarGameDataModel copyWith({
    int? score,
  }) {
    return CaesarGameDataModel(
      score: score ?? this.score,
    );
  }
}