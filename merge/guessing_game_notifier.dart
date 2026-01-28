import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../../core/game_enums.dart';
import '../../core/constants.dart';
import '../../data/services/communication_service.dart';
import '../models/guessing_state_model.dart';
import '../../data/models/game_data_model.dart';

/// Gestionnaire d'état qui pilote toute la logique de la partie de devinettes.
///
/// Il fait le lien entre Supabase et les widgets (en gérant les tours, les rôles et la validation des mots).
class GuessingGameNotifier extends ChangeNotifier {
  /// Identifiant unique de la partie.
  final String gameId;

  /// Service de communication avec Supabase.
  final CommunicationService _commService;

  /// Identifiant du joueur local (A ou B).
  late PlayerId _localPlayerId;

  /// Indicateur de chargement.
  bool _isLoading = false;

  /// Expose l'état actuel aux widgets.
  bool get isLoading => _isLoading;

  /// Initialise le service et lance la configuration de la partie.
  GuessingGameNotifier({required this.gameId})
    : _commService = CommunicationService(gameId: gameId) {
    _initializeGame();
  }

  /// État local privé contenant toutes les infos de la partie.
  GuessingGameState _state = GuessingGameState(
    currentState: GameStateEnum.waiting,
    localPlayerId: PlayerId.playerA,
    gameData: const GuessingGameDataModel(targetWord: '', forbiddenWords: []),
    currentRound: 1,
  );

  /// Expose l'état actuel aux widgets.
  GuessingGameState get state => _state;

  /// Gérer l'affichage d'un indicateur de chargement.
  /// Met à jour [_isLoading] et prévient l'UI de se rafraîchir.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Détermine l'étape visuelle du jeu (Enum) selon les données reçues.
  /// Analyse si le joueur B est là, si la manche est finie ou si le jeu est terminé.
  GameStateEnum _determineState(
    GuessingGameDataModel gameData,
    String? playerBId,
    bool isGameOver,
  ) {
    if (isGameOver) return GameStateEnum.results;
    if (playerBId == null) return GameStateEnum.waiting;

    // Si isCorrect n'est plus null, c'est que le résultat de la manche est connu
    if (gameData.isCorrect != null) {
      return GameStateEnum.results;
    }

    // État par défaut : la partie est en cours
    return GameStateEnum.playerATurn;
  }

  /// Prépare les données d'une nouvelle manche.
  /// Pioche un mot au hasard, récupère ses mots interdits et crée l'objet JSON initial en base de données via le service.
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
      'score': 0,
    };

    await _commService.createGameData(initialData);
  }

  /// Configure la session au démarrage.
  /// 1. Détermine si l'utilisateur est le créateur (A) ou doit rejoindre (B).
  /// 2. S'abonne au flux de données pour mettre à jour [_state] en temps réel dès que Supabase change.
  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    var gameMetadata = await _commService.getGameMetadata();

    if (gameMetadata == null) {
      // Cas où la ligne n'existe pas encore : l'utilisateur actuel est le créateur (A)
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
        // La place B est vide : on tente de la prendre
        final success = await _commService.joinGameAsPlayerB();
        if (success) {
          _localPlayerId = PlayerId.playerB;
        } else {
          return;
        }
      } else {
        return; // Partie déjà complète
      }
    }

    // Écoute en continu les modifications de Supabase
    _commService.gameStream.listen((row) {
      if (row.isEmpty) return;

      final playerBId = row['player_b_id'];
      final jsonData = row['data'] as Map<String, dynamic>? ?? {};
      final int round = jsonData['round'] ?? 1;
      final bool gameOver = jsonData['game_over'] ?? false;
      final gameData = GuessingGameDataModel.fromJson(jsonData);

      // Mise à jour de l'état local et notification des widgets
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

  /// Compare le mot tapé avec la cible, définit si c'est correct, et met à jour Supabase.
  Future<void> submitGuess(String guess) async {
    if (_isLoading || guess.trim().isEmpty) return;
    _setLoading(true);

    final target = _state.gameData.targetWord;
    final isMatch = guess.trim().toLowerCase() == target.trim().toLowerCase();

    int currentScore = _state.gameData.score;

    if (isMatch) {
      currentScore += 10;
    }

    Map<String, dynamic> updates = {
      'guess': guess.trim(),
      'isCorrect': isMatch,
      'score': currentScore,
    };

    // Si on gagne à la manche finale (2), on clôture le jeu
    if (_state.currentRound == 2 && isMatch) {
      updates['game_over'] = true;
    }

    await _commService.updateGameDataBatch(updates);
    _setLoading(false);
  }

  /// Gérer la transition entre les manches.
  /// Si manche 1 finie, prépare la manche 2 (nouveau mot). Si manche 2 finie, clôture la partie.
  Future<void> proceedToNextStep() async {
    if (_isLoading) return;
    _setLoading(true);

    if (_state.currentRound == 1) {
      final random = Random();
      //liste des mots disponibles
      final List<String> availableWords = kTabooWords.keys.toList();
      final String currentWord = _state.gameData.targetWord;
      availableWords.remove(currentWord);

      if (availableWords.isEmpty) {
        availableWords.add(currentWord);
      }

      final newWord = availableWords[random.nextInt(availableWords.length)];
      final newForbidden = kTabooWords[newWord] ?? [];

      Map<String, dynamic> updateData = {
        'round': 2,
        'targetWord': newWord,
        'forbiddenWords': newForbidden,
        'guess': null,
      };

      await _commService.updateGameDataBatch(updateData);
    } else {
      await _commService.updateGameDataField(key: 'game_over', value: true);
    }
    _setLoading(false);
  }

  /// Relancer une partie de zéro.
  /// Réinitialise toutes les données à la Manche 1 avec un nouveau mot.
  Future<void> resetGameFull() async {
    if (_isLoading) return;
    _setLoading(true);
    await _createInitialGameData(round: 1);
    _setLoading(false);
  }
}
