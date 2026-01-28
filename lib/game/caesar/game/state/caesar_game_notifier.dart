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

  // ---------- fonctions de gameplays ------------
  /// Met à jour les données pour afficher l'écran de résultat.
  /// la fonction retourne un objet indiquant si le jeu est définitivement terminé.
  Future<({bool gameOver})> goToResult() async {
    if (_isLoading) return (gameOver: false);
    _setLoading(true);

    try {
      // CONDITION CORRIGÉE : 
      // Si on vient de finir le round 2, alors isFinal devient TRUE
      final bool isFinal = _state.gameRound >= kMaxRounds;

      await _commService.updateGameDataBatch({
        'isRoundOver': true,
        'game_over': isFinal, // C'est ici que Supabase recevra enfin "true"
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

  /// update all the data related stuff to inform the other page to go to the next gamepage
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

  //NATHAN
  Future<void> finishGame() async {
    //cette partie de la fonction a accès au variable du jeu (score par exemple)
    // int scoreActuel = _state.gameData.score;
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

    // Mise à jour initiale de currentState à partir des métadonnées (évite blocage si 2 joueurs déjà en DB)
    final playerBFromMeta = gameMetadata?['player_b_id'] as String?;
    _state = _state.copyWith(
      localPlayerId: _localPlayerId,
      currentState: _determineState(
        playerBFromMeta, _state.isGameOver
        ),
    );
    notifyListeners();

    // on met en place l'écouteur qui met à jour les données en direct
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


String enleverAccents(String texte) {
  const withAccent =    'àâäáãçéèêëîïíôöóõùûüúÿñÀÂÄÁÃÇÉÈÊËÎÏÍÔÖÓÕÙÛÜÚŸÑ';
  const withoutAccent = 'aaaaaceeeeiiioooouuuuynAAAAACEEEEIIIOOOOUUUUYN';
  
  var result = texte;
  for (var i = 0; i < withAccent.length; i++) {
    result = result.replaceAll(withAccent[i], withoutAccent[i]);
  }
  return result;
}