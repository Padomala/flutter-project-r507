import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../../core/game_enums.dart';
import '../../core/constants.dart';
import '../../data/services/communication_service.dart';
import '../models/hot_cold_state_model.dart';
import '../../data/models/hot_cold_model.dart';

class HotColdGameNotifier extends ChangeNotifier {
  final String gameId;
  final CommunicationService _commService;
  late PlayerId _localPlayerId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  HotColdGameNotifier({required this.gameId})
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
    _isLoading = loading;
    notifyListeners();
  }

  // --- LOGIQUE D'INITIALISATION ET ÉCOUTE ---

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
        if (success) {
          _localPlayerId = PlayerId.playerB;
        } else {
          return;
        }
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

      // Conversion sécurisée du JSON en Modèle
      final gameData = HotColdGameDataModel.fromJson(jsonData);

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

  GameStateEnum _determineState(
    HotColdGameDataModel gameData,
    String? playerBId,
    bool isGameOver,
  ) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;

    // Si le mot est trouvé (isCorrect == true), on passe à l'écran de résultats de manche
    if (gameData.isCorrect == true) {
      return GameStateEnum.results;
    }

    return GameStateEnum.playerATurn; // En jeu actif
  }

  Future<void> _createInitialGameData({int round = 1}) async {
    final random = Random();
    // On suppose que hotColdWords est une Map<String, List<String>> dans constants.dart
    final List<String> themes = hotColdWords.keys.toList();
    final String selectedTheme = themes[random.nextInt(themes.length)];
    final List<String> wordsInTheme = hotColdWords[selectedTheme]!;
    final String selectedWord =
        wordsInTheme[random.nextInt(wordsInTheme.length)];

    final initialData = {
      'theme': selectedTheme,
      'targetWord': selectedWord,
      'round': round,
      'history': [], // Liste vide au départ
      'game_over': false,
      'isCorrect': false,
      'score': 0,
    };

    await _commService.createGameData(initialData);
  }

  /// 1. LE CHERCHEUR PROPOSE UN MOT
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

    // Mise à jour partielle (Batch update)
    await _commService.updateGameDataField(
      key: 'history',
      value: currentHistory,
    );

    _setLoading(false);
  }

  /// 2. LE MAÎTRE JUGE LA PROPOSITION (Chaud/Froid/Trouvé)
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

  /// 3. PASSER À LA SUITE (Manche suivante ou Fin de partie)
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
        'history': [], // Reset historique
        'isCorrect': false, // Reset victoire
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
