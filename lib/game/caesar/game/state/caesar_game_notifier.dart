import 'package:flutter/material.dart';
import 'package:game_v1/game/caesar/core/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_enums.dart';
import '../../data/services/communication_service.dart';
import '../models/caesar_state_model.dart';
import '../../data/models/game_data_model.dart';

class CaesarGameNotifier extends ChangeNotifier {
  final String gameId;
  final CommunicationService _commService;
  PlayerId _localPlayerId = PlayerId.playerA;
  bool _isLoading = false;
  bool get isLoading => _isLoading;


  CaesarGameState _state = CaesarGameState(
    currentState: GameStateEnum.waiting,
    localPlayerId: PlayerId.playerA,
    gameData: const CaesarGameDataModel(score: 0),
    isGameOver: false,
    gameRound: 0,
  );

  CaesarGameState get state => _state;

  CaesarGameNotifier({required this.gameId})
      : _commService = CommunicationService(gameId: gameId) {
    _initializeGame();
  }

  /// we set the code in loading state, with a circle in the middle
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// HERE, we determine wich state of the game to show
  GameStateEnum _determineState(String? playerBId, bool isGameOver) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;
    return GameStateEnum.playerATurn; 
  }

  /// Submit an attempt with a playerInput and a expected solution
  /// manage the verification, and the change in DB
  /// Return true if it's the worrect answer, false if not
  Future<bool> submitAttempt(String playerInput, String expectedSolution) async {
    if (_isLoading || _state.isGameOver) return false;
    
    _setLoading(true);
    try {
      String playerInputFormated = enleverAccents(playerInput.trim().toLowerCase());
      String exceptedSolutionFormated = enleverAccents(expectedSolution.trim().toLowerCase());
      if (playerInputFormated == exceptedSolutionFormated) {
        // CORRECT
        final newScore = _state.gameData.score + kCaesarPointPerGoodAnswer;
        await submitScore(newScore);
        return true;
      } else {
        // INCORRECT
        return false;
      }
    } finally {
      _setLoading(false);
    }
  }

  /// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
  /// ▒▒▒       fonctions de gameplays       ▒▒▒
  /// ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒


  /// Launch when we need to go to the result page, we update the db and return if gameOver (not used)
  Future<({bool gameOver})> goToResult() async {
    if (_isLoading) return (gameOver: false);
    _setLoading(true);

    try {
      // if we are at the last round, we chaneg not only roundOver but also gameOver
      final bool isFinal = _state.gameRound >= kMaxRounds;

      await _commService.updateGameDataBatch({
        'isRoundOver': true,
        'game_over': isFinal,
      });

      _state = _state.copyWith(
        isRoundOver: true,
        isGameOver: isFinal,
      );

      return (gameOver: isFinal);
    } catch (e) {
      debugPrint("Erreur goToResult: $e");
      return (gameOver: false);
    } finally {
      _setLoading(false);
    }
  }

  /// update all the data related stuff to inform the other page to go to the next gamepage after result
  Future<void> nextRound() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      final int nextRoundNumber = _state.gameRound + 1;
      
      Map<String, dynamic> updates = {
        'round': nextRoundNumber,
        'isRoundOver': false,
        'isCorrect': null,
      };

      await _commService.updateGameDataBatch(updates);
    } finally {
      _setLoading(false);
    }
  }

  /// Function run when we finish the current game, ready to change to a new game
  Future<void> finishGame() async {
    // here we have access to the score
    // int scoreActuel = _state.gameData.score;
  }



  /// ACTION : Send score to supabase
  Future<void> submitScore(int newScore, {bool finishGame = false}) async {
    try {
      Map<String, dynamic> updates = {
        'score': newScore,
        'game_over': finishGame,
      };
      await _commService.updateGameDataBatch(updates);
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour : $e");
    }
  }

  /// Initialize the game
  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    var gameMetadata = await _commService.getGameMetadata();

    // we create the party if it doesnt exist for now, if it exist, we join it
    if (gameMetadata == null) {
      await _createInitialGameData();
      _localPlayerId = PlayerId.playerA;
    } else {
      final playerA = gameMetadata['player_a_id'];
      final playerB = gameMetadata['player_b_id'];

      if (user.id == playerA) {
        _localPlayerId = PlayerId.playerA;
      } else if (user.id == playerB) {
        _localPlayerId = PlayerId.playerB;
      } else if (playerB == null) {
        final success = await _commService.joinGameAsPlayerB();
        _localPlayerId = success ? PlayerId.playerB : PlayerId.playerA;
      }
    }

    // Update the initial currentState from metadata
    final playerBFromMeta = gameMetadata?['player_b_id'] as String?;
    _state = _state.copyWith(
      localPlayerId: _localPlayerId,
      currentState: _determineState(
        playerBFromMeta, _state.isGameOver
        ),
    );
    notifyListeners();

    //we put a  listener that update the data to change the data dynamically (especially the gameState)
    _commService.gameStream.listen((row) {
      if (row.isEmpty) return;

      final jsonData = row['data'] as Map<String, dynamic>? ?? {};
      final playerBId = row['player_b_id'] as String?;

      final bool dbGameOver = jsonData['game_over'] ?? false;
      final bool dbRoundOver = jsonData['isRoundOver'] ?? false;
      final int dbRound = jsonData['round'] ?? 1;
      final int dbScore = jsonData['score'] ?? 0;

      _state = _state.copyWith(
        isGameOver: dbGameOver,
        isRoundOver: dbRoundOver,
        gameRound: dbRound,
        gameData: _state.gameData.copyWith(score: dbScore),
        currentState: _determineState(playerBId, dbGameOver),
      );
      notifyListeners();
    });
  }

  Future<void> _createInitialGameData() async {
    await _commService.createGameData({
      'game_over': false,
      'score': 0,
    });
  }

  Future<void> resetGame() async {
    _setLoading(true);
    try {
      await _createInitialGameData();
    } finally {
      _setLoading(false);
    }
  }
}

// c'est assez explicite
String enleverAccents(String texte) {
  const withAccent =    'àâäáãçéèêëîïíôöóõùûüúÿñÀÂÄÁÃÇÉÈÊËÎÏÍÔÖÓÕÙÛÜÚŸÑ';
  const withoutAccent = 'aaaaaceeeeiiioooouuuuynAAAAACEEEEIIIOOOOUUUUYN';
  
  var result = texte;
  for (var i = 0; i < withAccent.length; i++) {
    result = result.replaceAll(withAccent[i], withoutAccent[i]);
  }
  return result;
}