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
  final String? playerAId; // Optionnel: UUID du joueur A (pour orchestrateur)
  final String? playerBId; // Optionnel: UUID du joueur B (pour orchestrateur)
  final CommunicationService _commService;
  late PlayerId _localPlayerId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GuessingGameNotifier({required this.gameId, this.playerAId, this.playerBId})
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
  GameStateEnum _determineState(
    GuessingGameDataModel gameData,
    String? playerBId,
    bool isGameOver,
  ) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;

    // Si le mot a été trouvé (ou perdu), on affiche le résultat de la manche
    if (gameData.isCorrect != null) {
      return GameStateEnum.results;
    }

    // Sinon, on est en plein jeu (Descripteur parle, Devineur tape)
    return GameStateEnum
        .playerATurn; // On utilise cet enum comme "En cours de jeu"
  }

  // Initialisation (Création Round 1)
  Future<void> _createInitialGameData({
    int round = 1,
    String? playerBId,
  }) async {
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

    await _commService.createGameData(initialData, playerBId: playerBId);
  }

  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    var gameMetadata = await _commService.getGameMetadata();

    // CAS 1: L'orchestrateur a fourni les IDs des deux joueurs
    if (playerAId != null && playerBId != null) {
      debugPrint(
        '🎮 Mode Orchestrateur: playerA=$playerAId, playerB=$playerBId',
      );

      // Déterminer qui est le joueur local
      if (user.id == playerAId) {
        _localPlayerId = PlayerId.playerA;
      } else if (user.id == playerBId) {
        _localPlayerId = PlayerId.playerB;
      } else {
        debugPrint(
          '⚠️ Erreur: L\'utilisateur actuel ne fait pas partie de cette game',
        );
        return;
      }

      // Si la game_data n'existe pas encore, la créer avec les deux joueurs
      if (gameMetadata == null) {
        debugPrint('Création game_data avec les 2 joueurs...');
        await _createInitialGameData(round: 1, playerBId: playerBId);

        // Re-lire les métadonnées pour avoir la version complète
        gameMetadata = await _commService.getGameMetadata();
        debugPrint('game_data créée: $gameMetadata');
      }

      // Initialiser l'état immédiatement avec les données qu'on connaît
      final initialGameData = await _commService.getGameData();
      if (initialGameData != null) {
        final gameData = GuessingGameDataModel.fromJson(initialGameData);
        final int round = initialGameData['round'] ?? 1;
        final bool gameOver = initialGameData['game_over'] ?? false;

        // Récupérer player_b_id depuis les métadonnées DB (pas le paramètre)
        final playerBIdFromDb = gameMetadata?['player_b_id'];

        _state = _state.copyWith(
          localPlayerId: _localPlayerId,
          currentState: _determineState(gameData, playerBIdFromDb, gameOver),
          gameData: gameData,
          currentRound: round,
          isGameOver: gameOver,
        );

        debugPrint(
          'État initial: ${_state.currentState}, playerBIdFromDb: $playerBIdFromDb',
        );
        notifyListeners();
      }
    }
    // CAS 2: Mode standalone (sans orchestrateur)
    else {
      debugPrint('🎮 Mode Standalone');

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
          if (success)
            _localPlayerId = PlayerId.playerB;
          else
            return;
        } else {
          return;
        }
      }
    }

    // Écouter le stream pour les mises à jour futures
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
