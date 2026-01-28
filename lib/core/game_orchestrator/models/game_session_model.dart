import 'package:flutter/foundation.dart';

@immutable
class GameSession {
  final String id;
  final String roomId;
  final List<GameConfig> gamesQueue;
  final int currentGameIndex;
  final Map<String, int> playerScores;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GameSession({
    required this.id,
    required this.roomId,
    required this.gamesQueue,
    this.currentGameIndex = 0,
    required this.playerScores,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  // Méthodes utiles
  bool get hasMoreGames => currentGameIndex < gamesQueue.length;
  GameConfig get currentGame => gamesQueue[currentGameIndex];
  int get totalGames => gamesQueue.length;
  bool get isCompleted => status == 'completed' || currentGameIndex >= gamesQueue.length;

  factory GameSession.fromJson(Map<String, dynamic> json) {
    final gamesQueueJson = json['games_queue'] as List<dynamic>? ?? [];
    final gamesQueue = gamesQueueJson
        .map((e) => GameConfig.fromJson(e as Map<String, dynamic>))
        .toList();

    final playerScoresJson = json['player_scores'] as Map<String, dynamic>? ?? {};
    final playerScores = playerScoresJson.map(
      (key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 0),
    );

    return GameSession(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      gamesQueue: gamesQueue,
      currentGameIndex: json['current_game_index'] as int? ?? 0,
      playerScores: playerScores,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'games_queue': gamesQueue.map((e) => e.toJson()).toList(),
      'current_game_index': currentGameIndex,
      'player_scores': playerScores,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  GameSession copyWith({
    String? id,
    String? roomId,
    List<GameConfig>? gamesQueue,
    int? currentGameIndex,
    Map<String, int>? playerScores,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GameSession(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      gamesQueue: gamesQueue ?? this.gamesQueue,
      currentGameIndex: currentGameIndex ?? this.currentGameIndex,
      playerScores: playerScores ?? this.playerScores,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@immutable
class GameConfig {
  final String gameType; // 'clues', 'caesar', 'labyrinthe'
  final int order;
  final Map<String, dynamic>? settings;

  const GameConfig({
    required this.gameType,
    required this.order,
    this.settings,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    return GameConfig(
      gameType: json['game_type'] as String,
      order: json['order'] as int,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_type': gameType,
      'order': order,
      if (settings != null) 'settings': settings,
    };
  }
}
