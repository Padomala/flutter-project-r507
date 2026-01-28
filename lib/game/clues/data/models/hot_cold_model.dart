import 'package:flutter/foundation.dart';

@immutable
class HotColdGameDataModel {
  final String targetWord;

  final List<Map<String, String>> history;

  final String theme;

  final bool? isCorrect;

  final int score;

  const HotColdGameDataModel({
    required this.targetWord,
    required this.theme,
    this.history = const [],
    this.isCorrect,
    this.score = 0,
  });

  factory HotColdGameDataModel.fromJson(Map<String, dynamic> json) {
    // conversion de la liste JSON en List<Map<String, String>>
    final rawHistory = json['history'] as List<dynamic>? ?? [];
    final List<Map<String, String>> historyList = rawHistory.map((item) {
      return Map<String, String>.from(item as Map);
    }).toList();

    return HotColdGameDataModel(
      targetWord: json['targetWord'] as String? ?? 'ERREUR',
      theme: json['theme'] as String? ?? 'Général',
      history: historyList,
      isCorrect: json['isCorrect'] as bool?,
      score: (json['score'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetWord': targetWord,
      'theme': theme,
      'history': history,
      'isCorrect': isCorrect,
      'score': score,
    };
  }

  /// helper pour obtenir la dernière température envoyée par le Maître de la manche
  String get currentTemperature =>
      history.isNotEmpty ? (history.last['temperature'] ?? 'froid') : 'froid';
}
