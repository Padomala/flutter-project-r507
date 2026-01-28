import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_enums.dart';
import '../../data/services/communication_service.dart';
import '../models/caesar_state_model.dart';
import '../../data/models/game_data_model.dart';

import 'package:game_v1/game/caesar/game/state/caesar_game_notifier.dart';

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

  /// Centralisation de la notification UI
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Logique de détermination de l'état (La machine à états)
  GameStateEnum _determineState(String? playerBId, bool isGameOver) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;
    // On peut imaginer ici une logique de tour par tour plus complexe
    return GameStateEnum.playerATurn; 
  }

  /// Valider la réponse, on teste si la prop est bonne et si on ajoute le score dcp
  Future<bool> submitAttempt(String playerInput, String expectedSolution) async {
    if (_isLoading || _state.isGameOver) return false;
    
    _setLoading(true);
    try {
      String playerInputFormated = enleverAccents(playerInput.trim().toLowerCase());
      String exceptedSolutionFormated = enleverAccents(expectedSolution.trim().toLowerCase());
      if (playerInputFormated == exceptedSolutionFormated) {
        // CORRECT
        final newScore = _state.gameData.score + 10;
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

  Future<void> goToResult() async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      // On active le flag de fin de manche, mais game_over RESTE à false
      await _commService.updateGameDataField(key: 'isRoundOver', value: true);
    } finally {
      _setLoading(false);
    }
  }

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

  /// ACTION : Envoi du score à Supabase
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

  /// Ici on va relier les utilisateurs entre eux et mettre en place les écouteurs pour écouter les changements
  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    var gameMetadata = await _commService.getGameMetadata();

    // Ici on créé la partie si elle existe pas, sinon, on va la rejoindre dcp
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

    // on met en place l'écouteur qui met à jour les données en direct
    _commService.gameStream.listen((row) {
      if (row.isEmpty) return;

      final playerBId = row['player_b_id'];
      final jsonData = row['data'] as Map<String, dynamic>? ?? {};
      
      final bool gameOver = jsonData['game_over'] ?? false;
      final bool roundOver = jsonData['isRoundOver'] ?? false;
      final int currentRound = jsonData['round'] ?? 1;

      final gameData = CaesarGameDataModel.fromJson(jsonData);

      _state = _state.copyWith(
        localPlayerId: _localPlayerId,
        currentState: _determineState(playerBId, gameOver),
        gameData: gameData,
        isGameOver: gameOver,
        isRoundOver: roundOver, // <--- CRUCIAL : Informe l'UI que la manche est finie
        gameRound: currentRound, // <--- CRUCIAL : Pour l'échange des rôles
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


String enleverAccents(String texte) {
  const withAccent =    'àâäáãçéèêëîïíôöóõùûüúÿñÀÂÄÁÃÇÉÈÊËÎÏÍÔÖÓÕÙÛÜÚŸÑ';
  const withoutAccent = 'aaaaaceeeeiiioooouuuuynAAAAACEEEEIIIOOOOUUUUYN';
  
  var result = texte;
  for (var i = 0; i < withAccent.length; i++) {
    result = result.replaceAll(withAccent[i], withoutAccent[i]);
  }
  return result;
}