import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math';
import '../../core/game_enums.dart';
import '../../core/constants.dart';
import '../../data/services/communication_service.dart';
import '../models/hot_cold_state_model.dart';
import '../../data/models/hot_cold_model.dart';

class HotColdGameNotifier extends ChangeNotifier {
  final String gameId;
  final String? playerAId;
  final String? playerBId;
  final CommunicationService _commService;
  StreamSubscription<Map<String, dynamic>>? _gameSubscription;
  bool _isDisposed = false;
  late PlayerId _localPlayerId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  HotColdGameNotifier({required this.gameId, this.playerAId, this.playerBId})
    : _commService = CommunicationService(gameId: gameId) {
    _initializeGame();
  }

  HotColdGameState _state = HotColdGameState(
    currentState: GameStateEnum.waiting,
    localPlayerId: PlayerId.playerA,
    gameData: const HotColdGameDataModel(
      targetWord: '',
      theme: '',
      history: [],
    ),
    currentRound: 1,
  );

  HotColdGameState get state => _state;

  void _setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('HotCold: Pas d\'utilisateur connecté');
      return;
    }

    debugPrint('Init HotCold. User: ${user.id}. GameId: $gameId');
    if (_isDisposed) return;

    var gameMetadata = await _commService.getGameMetadata();
    debugPrint(
      'GameMetadata received: $gameMetadata (isDisposed: $_isDisposed)',
    );
    if (_isDisposed) return;

    if (playerAId != null && playerBId != null) {
      if (user.id == playerAId) {
        _localPlayerId = PlayerId.playerA;
        debugPrint('Role: Player A (Describer)');
      } else if (user.id == playerBId) {
        _localPlayerId = PlayerId.playerB;
        debugPrint('Role: Player B (Guesser)');
      } else {
        debugPrint(
          'ERROR: User ID ${user.id} introuvable dans [$playerAId, $playerBId]. Force assign Player B to avoid crash.',
        );
        _localPlayerId = PlayerId.playerB;
      }

      if (gameMetadata == null) {
        if (_localPlayerId == PlayerId.playerA) {
          debugPrint('Creating game (Player A)...');
          await _createInitialGameData(round: 1, playerBId: playerBId);
          if (_isDisposed) return;
        } else {
          debugPrint('Waiting for Player A to create game...');
          await _createInitialGameData(round: 1, playerBId: playerBId);
          if (_isDisposed) return;
        }
      }
    } else {
      if (gameMetadata == null) {
        await _createInitialGameData(round: 1);
        _localPlayerId = PlayerId.playerA;
      } else {
        final pA = gameMetadata['player_a_id'];
        final pB = gameMetadata['player_b_id'];

        if (user.id == pA) {
          _localPlayerId = PlayerId.playerA;
        } else if (user.id == pB) {
          _localPlayerId = PlayerId.playerB;
        } else if (pB == null) {
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

    _gameSubscription = _commService.gameStream.listen((row) {
      if (row.isEmpty || _isDisposed) return;

      final playerBIdRow = row['player_b_id'];
      final jsonData = row['data'] as Map<String, dynamic>? ?? {};
      final int round = jsonData['round'] ?? 1;
      final bool gameOver = jsonData['game_over'] ?? false;

      final gameData = HotColdGameDataModel.fromJson(jsonData);

      _state = _state.copyWith(
        localPlayerId: _localPlayerId,
        currentState: _determineState(gameData, playerBIdRow, gameOver),
        gameData: gameData,
        currentRound: round,
        isGameOver: gameOver,
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _gameSubscription?.cancel();
    super.dispose();
  }

  GameStateEnum _determineState(
    HotColdGameDataModel gameData,
    String? playerBId,
    bool isGameOver,
  ) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;

    if (gameData.isCorrect == true) {
      return GameStateEnum.results;
    }

    return GameStateEnum.playerATurn;
  }

  Future<void> _createInitialGameData({
    int round = 1,
    String? playerBId,
  }) async {
    final random = Random();
    final List<String> themes = hotColdWords.keys.toList();
    final String selectedTheme = themes[random.nextInt(themes.length)];
    final List<String> wordsInTheme = hotColdWords[selectedTheme]!;
    final String selectedWord =
        wordsInTheme[random.nextInt(wordsInTheme.length)];

    final initialData = {
      'theme': selectedTheme,
      'targetWord': selectedWord,
      'round': round,
      'history': [],
      'game_over': false,
      'isCorrect': false,
      'score': 0,
    };

    await _commService.createGameData(initialData, playerBId: playerBId);
  }

  /// Ajoute le mot à l'historique avec le statut 'waiting'
  Future<void> submitAttempt(String word) async {
    if (_isLoading || word.trim().isEmpty) return;
    _setLoading(true);

    // On récupère l'historique actuel
    List<dynamic> currentHistory = List.from(_state.gameData.history);

    // On ajoute la nouvelle tentative
    currentHistory.add({
      'word': word.trim(),
      'temperature': 'waiting', // En attente du verdict du maître
    });

    // Mise à jour partielle
    await _commService.updateGameDataField(
      key: 'history',
      value: currentHistory,
    );

    _setLoading(false);
  }

  /// Met à jour la dernière entrée de l'historique
  Future<void> rateLastAttempt(String rating) async {
    if (_isLoading || _state.gameData.history.isEmpty) return;
    _setLoading(true);

    List<dynamic> currentHistory = List.from(_state.gameData.history);

    // Modifie le dernier élément
    final lastIndex = currentHistory.length - 1;
    final lastItem = Map<String, dynamic>.from(currentHistory[lastIndex]);

    // rating peut être : 'hot', 'cold', ou 'found'
    lastItem['temperature'] = rating;
    currentHistory[lastIndex] = lastItem;

    Map<String, dynamic> updates = {'history': currentHistory};

    // Si c'est "trouvé", on marque la manche comme gagnée
    if (rating == 'found') {
      updates['isCorrect'] = true;
      // On peut ajouter du score ici si on veut
      int newScore = _state.gameData.score + 10;
      updates['score'] = newScore;
    }

    await _commService.updateGameDataBatch(updates);
    _setLoading(false);
  }

  /// Manche suivante ou Fin de partie
  Future<void> proceedToNextStep() async {
    if (_isLoading) return;
    _setLoading(true);

    // Si on est en manche 1, on prépare la manche 2
    if (_state.currentRound == 1) {
      final random = Random();

      // Logique simple pour changer de mot/thème
      final List<String> themes = hotColdWords.keys.toList();
      final String selectedTheme = themes[random.nextInt(themes.length)];
      final List<String> wordsInTheme = hotColdWords[selectedTheme]!;
      final String newWord = wordsInTheme[random.nextInt(wordsInTheme.length)];

      Map<String, dynamic> updateData = {
        'round': 2,
        'theme': selectedTheme,
        'targetWord': newWord,
        'history': [],
        'isCorrect': false,
      };

      await _commService.updateGameDataBatch(updateData);
    }
    // Si on est déjà en manche 2 (ou plus), le jeu est fini
    else {
      await _commService.updateGameDataField(key: 'game_over', value: true);
    }

    _setLoading(false);
  }
}
