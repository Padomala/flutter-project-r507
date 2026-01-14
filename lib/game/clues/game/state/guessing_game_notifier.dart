import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../../core/game_enums.dart';
import '../../core/constants.dart';
import '../../data/services/communication_service.dart';
import '../models/guessing_state_model.dart';
import '../../data/models/game_data_model.dart';

class GuessingGameNotifier extends ChangeNotifier {
  final String gameId;
  final CommunicationService _commService;
  late PlayerId _localPlayerId;
  
  bool _isLoading = false; 
  bool get isLoading => _isLoading;

  GuessingGameNotifier({required this.gameId})
      : _commService = CommunicationService(gameId: gameId) {
    _initializeGame();
  }

  GuessingGameState _state = GuessingGameState(
    currentState: GameStateEnum.waiting,
    localPlayerId: PlayerId.playerA,
    gameData: const GuessingGameDataModel(targetWord: '', forbiddenWords: []),
    currentRound: 1,
  );
  GuessingGameState get state => _state;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // --- LOGIQUE D'ÉTAT ---
  GameStateEnum _determineState(GuessingGameDataModel gameData, String? playerBId, bool isGameOver) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;

    // Si le mot a été trouvé (ou perdu), on affiche le résultat de la manche
    if (gameData.isCorrect != null) {
      return GameStateEnum.results;
    } 
    
    // Sinon, on est en plein jeu (Descripteur parle, Devineur tape)
    return GameStateEnum.playerATurn; // On utilise cet enum comme "En cours de jeu"
  }

  // Initialisation (Création Round 1)
  Future<void> _createInitialGameData({int round = 1}) async {
    final random = Random();
    final List<String> availableWords = kTabooWords.keys.toList();
    final targetWord = availableWords[random.nextInt(availableWords.length)];
    final forbidden = kTabooWords[targetWord] ?? [];

    final initialData = {
      'round': round,
      'game_over': false,
      'targetWord': targetWord,
      'forbiddenWords': forbidden,
      'guess': null,
      'isCorrect': null,
    };

    await _commService.createGameData(initialData);
  }

  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    var gameMetadata = await _commService.getGameMetadata();

    if (gameMetadata == null) {
      await _createInitialGameData(round: 1); 
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
        if (success) _localPlayerId = PlayerId.playerB;
        else return;
      } else {
        return; 
      }
    }

    _commService.gameStream.listen((row) {
      if (row.isEmpty) return;
      
      final playerBId = row['player_b_id']; 
      final jsonData = row['data'] as Map<String, dynamic>? ?? {}; 
      final int round = jsonData['round'] ?? 1;
      final bool gameOver = jsonData['game_over'] ?? false;
      final gameData = GuessingGameDataModel.fromJson(jsonData);

      _state = _state.copyWith(
        localPlayerId: _localPlayerId,
        currentState: _determineState(gameData, playerBId, gameOver),
        gameData: gameData,
        currentRound: round,
        isGameOver: gameOver,
      );
      notifyListeners();
    });
  }

  // --- ACTIONS DU JEU ---

  // Action du DEVINEUR : Proposer un mot
  Future<void> submitGuess(String guess) async {
    if (_isLoading || guess.trim().isEmpty) return;
    _setLoading(true);

    final target = _state.gameData.targetWord;
    // Vérification automatique insensible à la casse
    final isMatch = guess.trim().toLowerCase() == target.trim().toLowerCase();

    Map<String, dynamic> updates = {
      'guess': guess.trim(),
      'isCorrect': isMatch, 
    };

    // Si manche 2 et correct => Fin du jeu
    if (_state.currentRound == 2 && isMatch) {
       updates['game_over'] = true;
    }

    await _commService.updateGameDataBatch(updates);
    _setLoading(false);
  }

  // Passer à la manche suivante ou finir
  Future<void> proceedToNextStep() async {
    if (_isLoading) return;
    _setLoading(true);

    if (_state.currentRound == 1) {
      // Setup Round 2 : Nouveau mot
      final random = Random();
      final List<String> availableWords = kTabooWords.keys.toList();
      final newWord = availableWords[random.nextInt(availableWords.length)];
      final newForbidden = kTabooWords[newWord] ?? [];

      Map<String, dynamic> updateData = {
        'round': 2,
        'targetWord': newWord,
        'forbiddenWords': newForbidden,
        'guess': null,
        'isCorrect': null,
      };
      
      await _commService.updateGameDataBatch(updateData);
    } else {
      await _commService.updateGameDataField(key: 'game_over', value: true);
    }
    _setLoading(false);
  }

  Future<void> resetGameFull() async {
    if (_isLoading) return;
    _setLoading(true);
    await _createInitialGameData(round: 1);
    _setLoading(false);
  }
}