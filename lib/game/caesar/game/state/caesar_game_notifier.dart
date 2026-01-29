import 'dart:async'; // Nécessaire pour StreamSubscription
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

  // --- AJOUT : Variable pour stocker l'abonnement ---
  StreamSubscription? _gameSubscription;

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

  // --- AJOUT : Nettoyage propre quand l'écran est détruit ---
  @override
  void dispose() {
    _gameSubscription?.cancel(); // On coupe l'écoute de Supabase
    super.dispose();
  }

  void _setLoading(bool loading) {
    // Sécurité : Si le notifier est déjà "dispose", on ne fait rien
    // (Même si dispose() est appelé, parfois des callbacks async traînent encore)
    try {
      if (_isLoading == loading) return;
      _isLoading = loading;
      notifyListeners();
    } catch (_) {
      // Ignore error if disposed
    }
  }

  GameStateEnum _determineState(String? playerBId, bool isGameOver) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;
    return GameStateEnum.playerATurn;
  }

  Future<bool> submitAttempt(
    String playerInput,
    String expectedSolution,
  ) async {
    if (_isLoading || _state.isGameOver) return false;

    _setLoading(true);
    try {
      String playerInputFormated = enleverAccents(
        playerInput.trim().toLowerCase(),
      );
      String exceptedSolutionFormated = enleverAccents(
        expectedSolution.trim().toLowerCase(),
      );
      if (playerInputFormated == exceptedSolutionFormated) {
        final newScore = _state.gameData.score + kCaesarPointPerGoodAnswer;
        await submitScore(newScore);
        return true;
      } else {
        return false;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<({bool gameOver})> goToResult() async {
    if (_isLoading) return (gameOver: false);
    _setLoading(true);

    try {
      final bool isFinal = _state.gameRound >= kMaxRounds;

      await _commService.updateGameDataBatch({
        'isRoundOver': true,
        'game_over': isFinal,
      });

      _state = _state.copyWith(isRoundOver: true, isGameOver: isFinal);

      return (gameOver: isFinal);
    } catch (e) {
      debugPrint("Erreur goToResult: $e");
      return (gameOver: false);
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

  Future<void> finishGame() async {
    // Logique de fin si nécessaire
  }

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

  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    var gameMetadata = await _commService.getGameMetadata();

    if (gameMetadata == null) {
      final created = await _createInitialGameData();
      if (created) {
        _localPlayerId = PlayerId.playerA;
      } else {
        gameMetadata = await _commService.getGameMetadata();
      }
    }

    if (gameMetadata != null) {
      final playerA = gameMetadata['player_a_id'];
      final playerB = gameMetadata['player_b_id'];

      if (user.id == playerA) {
        _localPlayerId = PlayerId.playerA;
      } else if (user.id == playerB) {
        _localPlayerId = PlayerId.playerB;
      } else {
        final success = await _commService.joinGameAsPlayerB();
        if (success) {
          _localPlayerId = PlayerId.playerB;
        } else {
          _localPlayerId = PlayerId.playerB;
        }
      }
    }

    final playerBFromMeta = gameMetadata?['player_b_id'] as String?;
    String? effectivePlayerB = playerBFromMeta;
    if (_localPlayerId == PlayerId.playerB) {
      effectivePlayerB = user.id;
    }

    _state = _state.copyWith(
      localPlayerId: _localPlayerId,
      currentState: _determineState(effectivePlayerB, _state.isGameOver),
    );
    notifyListeners();

    // --- CORRECTION : On stocke l'abonnement ici ---
    _gameSubscription = _commService.gameStream.listen((row) {
      if (row.isEmpty) return;

      final jsonData = row['data'] as Map<String, dynamic>? ?? {};
      final playerBId = row['player_b_id'] as String?;

      final bool dbGameOver = jsonData['game_over'] ?? false;
      final bool dbRoundOver = jsonData['isRoundOver'] ?? false;
      final int dbRound = jsonData['round'] ?? 0;
      final int dbScore = jsonData['score'] ?? 0;

      // Sécurité : Si le stream envoie des données mais qu'on a fermé l'écran entre temps
      try {
        _state = _state.copyWith(
          isGameOver: dbGameOver,
          isRoundOver: dbRoundOver,
          gameRound: dbRound,
          gameData: _state.gameData.copyWith(score: dbScore),
          currentState: _determineState(playerBId, dbGameOver),
        );
        notifyListeners();
      } catch (_) {
        // Le notifier a été disposé, on ignore
      }
    });
  }

  Future<bool> _createInitialGameData() async {
    return await _commService.createGameData({
      'game_over': false,
      'score': 0,
      'round': 0,
      'isRoundOver': false,
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
  const withAccent = 'àâäáãçéèêëîïíôöóõùûüúÿñÀÂÄÁÃÇÉÈÊËÎÏÍÔÖÓÕÙÛÜÚŸÑ';
  const withoutAccent = 'aaaaaceeeeiiioooouuuuynAAAAACEEEEIIIOOOOUUUUYN';

  var result = texte;
  for (var i = 0; i < withAccent.length; i++) {
    result = result.replaceAll(withAccent[i], withoutAccent[i]);
  }
  return result;
}
