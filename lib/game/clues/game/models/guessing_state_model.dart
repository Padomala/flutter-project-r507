import 'package:flutter/foundation.dart';
import '../../core/game_enums.dart';
import '../../data/models/game_data_model.dart';

class GuessingGameState {
  final GameStateEnum currentState;
  final PlayerId localPlayerId;
  final GuessingGameDataModel gameData;
  final int currentRound;
  final bool isGameOver;

  GuessingGameState({
    required this.currentState,
    required this.localPlayerId,
    required this.gameData,
    this.currentRound = 1,
    this.isGameOver = false,
  });

  // --- LOGIQUE DES RÔLES TABOO ---
  
  // Le Devineur est celui qui doit trouver le mot
  bool get amIGuesser {
    if (currentRound == 1) {
      return localPlayerId == PlayerId.playerB; // Manche 1 : B devine
    } else {
      return localPlayerId == PlayerId.playerA; // Manche 2 : A devine
    }
  }

  // Le Descripteur est celui qui voit la carte et les mots interdits
  bool get amIDescriber => !amIGuesser;

  GuessingGameState copyWith({
    GameStateEnum? currentState,
    GuessingGameDataModel? gameData,
    PlayerId? localPlayerId,
    int? currentRound,
    bool? isGameOver,
  }) {
    return GuessingGameState(
      currentState: currentState ?? this.currentState,
      localPlayerId: localPlayerId ?? this.localPlayerId,
      gameData: gameData ?? this.gameData,
      currentRound: currentRound ?? this.currentRound,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}