import 'package:flutter/foundation.dart';
import '../../core/game_enums.dart';
import '../../data/models/game_data_model.dart';

class GuessingGameState {
  final GameStateEnum currentState;
  final PlayerId localPlayerId;
  final GuessingGameDataModel gameData; 

  GuessingGameState({
    required this.currentState,
    required this.localPlayerId,
    required this.gameData,
  });

  GuessingGameState copyWith({
    GameStateEnum? currentState,
    GuessingGameDataModel? gameData,
    PlayerId? localPlayerId,
  }) {
    return GuessingGameState(
      currentState: currentState ?? this.currentState,
      localPlayerId: localPlayerId ?? this.localPlayerId,
      gameData: gameData ?? this.gameData,
    );
  }
}