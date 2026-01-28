import 'package:flutter/foundation.dart';

@immutable
class GameResult {
  final String gameType;
  final String? winnerId;
  final Map<String, int> scores; // {playerId: points}
  final DateTime completedAt;
  final Map<String, dynamic>? additionalData; // Pour stats supplémentaires

  const GameResult({
    required this.gameType,
    this.winnerId,
    required this.scores,
    required this.completedAt,
    this.additionalData,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    final scoresJson = json['scores'] as Map<String, dynamic>? ?? {};
    final scores = scoresJson.map(
      (key, value) => MapEntry(
        key, 
        value is int ? value : int.tryParse(value.toString()) ?? 0,
      ),
    );

    return GameResult(
      gameType: json['game_type'] as String,
      winnerId: json['winner_id'] as String?,
      scores: scores,
      completedAt: DateTime.parse(json['completed_at'] as String),
      additionalData: json['additional_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_type': gameType,
      'winner_id': winnerId,
      'scores': scores,
      'completed_at': completedAt.toIso8601String(),
      if (additionalData != null) 'additional_data': additionalData,
    };
  }

  // Helper pour créer un résultat simple (gagnant/perdant)
  factory GameResult.winnerLoser({
    required String gameType,
    required String winnerId,
    required String loserId,
    int winnerPoints = 1,
    int loserPoints = 0,
  }) {
    return GameResult(
      gameType: gameType,
      winnerId: winnerId,
      scores: {
        winnerId: winnerPoints,
        loserId: loserPoints,
      },
      completedAt: DateTime.now(),
    );
  }

  // Helper pour égalité
  factory GameResult.draw({
    required String gameType,
    required List<String> playerIds,
    int pointsEach = 0,
  }) {
    return GameResult(
      gameType: gameType,
      winnerId: null,
      scores: Map.fromIterable(
        playerIds,
        key: (id) => id.toString(),
        value: (_) => pointsEach,
      ),
      completedAt: DateTime.now(),
    );
  }
}
