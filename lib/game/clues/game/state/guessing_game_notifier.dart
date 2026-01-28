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
  final String? playerAId; // Optionnel: UUID du joueur A (pour orchestrateur)
  final String? playerBId; // Optionnel: UUID du joueur B (pour orchestrateur)
  final CommunicationService _commService;

  /// Identifiant du joueur local (A ou B).
  late PlayerId _localPlayerId;

  /// Indicateur de chargement.
  bool _isLoading = false;

  /// Expose l'état actuel aux widgets.
  bool get isLoading => _isLoading;

  GuessingGameNotifier({required this.gameId, this.playerAId, this.playerBId})
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
      'score': 0,
    };

    await _commService.createGameData(initialData, playerBId: playerBId);
  }

  /// Configure la session au démarrage.
  /// 1. Détermine si l'utilisateur est le créateur (A) ou doit rejoindre (B).
  /// 2. S'abonne au flux de données pour mettre à jour [_state] en temps réel dès que Supabase change.
  void _initializeGame() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('🛑 GuessingGame: Pas d\'utilisateur connecté');
      return;
    }

    debugPrint('🏁 Init GuessingGame. User: ${user.id}. GameId: $gameId');
    debugPrint('Args: playerA=$playerAId, playerB=$playerBId');

    var gameMetadata = await _commService.getGameMetadata();

    // Mode Orchestrateur Check
    if (playerAId != null && playerBId != null) {
      if (user.id == playerAId) {
        _localPlayerId = PlayerId.playerA;
        debugPrint('✅ Role: Player A');
      } else if (user.id == playerBId) {
        _localPlayerId = PlayerId.playerB;
        debugPrint('✅ Role: Player B');
      } else {
        debugPrint(
          '⛔ ERROR: User ID ${user.id} introuvable dans [$playerAId, $playerBId]',
        );
        // Fallback pour ne pas crash: prendre A par défaut mais c'est risqué
        // Mieux vaut return, mais le widget restera en waiting.
        return;
      }

      // Création lazy
      if (gameMetadata == null) {
        if (_localPlayerId == PlayerId.playerA) {
          debugPrint('Creating game (Player A)...');
          await _createInitialGameData(round: 1, playerBId: playerBId);
          gameMetadata = await _commService.getGameMetadata();
        } else {
          debugPrint('Waiting for Player A to create game...');
          // Player B doit peut-être attendre que A crée ?
          // Normalement createGameData gère l'upsert s'il n'existe pas.
          // Mais ici on utilise createInitialGameData, faisons pareil.
          await _createInitialGameData(round: 1, playerBId: playerBId);
        }
      }
    }
    // Mode Standalone
    else {
      // ... logic existante ...
      if (gameMetadata == null) {
        await _createInitialGameData(round: 1);
        _localPlayerId = PlayerId.playerA;
      } else {
        final playerA = gameMetadata['player_a_id'];
        final playerB = gameMetadata['player_b_id'];
        if (user.id == playerA)
          _localPlayerId = PlayerId.playerA;
        else if (user.id == playerB)
          _localPlayerId = PlayerId.playerB;
        else if (playerB == null && await _commService.joinGameAsPlayerB()) {
          _localPlayerId = PlayerId.playerB;
        } else {
          return;
        }
      }
    }

    // Chargement initial
    final initialGameData = await _commService.getGameData();
    if (initialGameData != null) {
      debugPrint('📥 Initial Data loaded: $initialGameData');
      final gameData = GuessingGameDataModel.fromJson(initialGameData);
      final int round = initialGameData['round'] ?? 1;
      final bool gameOver = initialGameData['game_over'] ?? false;
      final playerBIdFromDb = gameMetadata?['player_b_id'] ?? playerBId;

      _state = _state.copyWith(
        localPlayerId: _localPlayerId,
        currentState: _determineState(gameData, playerBIdFromDb, gameOver),
        gameData: gameData,
        currentRound: round,
        isGameOver: gameOver,
      );
      notifyListeners();
    }

    // Écoute Live
    debugPrint('🎧 Subscribing to game stream...');
    _commService.gameStream.listen((row) {
      if (row.isEmpty) return;
      // debugPrint('⚡ Live Update: $row');

      final playerBIdRow = row['player_b_id'];
      final jsonData = row['data'] as Map<String, dynamic>? ?? {};
      final int round = jsonData['round'] ?? 1;
      final bool gameOver = jsonData['game_over'] ?? false;
      final gameData = GuessingGameDataModel.fromJson(jsonData);

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

  /// Compare le mot tapé avec la cible, définit si c'est correct, et met à jour Supabase.
  Future<void> submitGuess(String guess) async {
    if (_isLoading || guess.trim().isEmpty) return;
    _setLoading(true);

    final target = _state.gameData.targetWord;
    // Vérification automatique insensible à la casse
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
      // Setup Round 2 : Nouveau mot
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
        'isCorrect': null,
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
