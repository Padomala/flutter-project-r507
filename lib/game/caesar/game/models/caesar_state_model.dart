import '../../core/game_enums.dart';
import '../../data/models/game_data_model.dart';

// all the game state for the caesar game
class CaesarGameState {
  /// The state of the game (waiting, results, etc.)
  final GameStateEnum currentState;

  /// The player Id to identify himself
  final PlayerId localPlayerId;

  /// raw game data (score)
  final CaesarGameDataModel gameData;

  /// If the game is over
  final bool isGameOver;

  // If the round isOver (for the transition screen with result)
  final bool isRoundOver;

  /// the current round from 1 to the max in the constants (2 normally)
  final int gameRound;

  CaesarGameState({
    required this.currentState,
    required this.localPlayerId,
    required this.gameData,
    this.isGameOver = false,
    this.isRoundOver = false,
    this.gameRound = 0,
  });

  CaesarGameState copyWith({
    GameStateEnum? currentState,
    PlayerId? localPlayerId,
    CaesarGameDataModel? gameData,
    bool? isGameOver,
    bool? isRoundOver,
    int? gameRound,
  }) {
    return CaesarGameState(
      currentState: currentState ?? this.currentState,
      localPlayerId: localPlayerId ?? this.localPlayerId,
      gameData: gameData ?? this.gameData,
      isGameOver: isGameOver ?? this.isGameOver,
      isRoundOver: isRoundOver ?? this.isRoundOver,
      gameRound: gameRound ?? this.gameRound,
    );
  }
}