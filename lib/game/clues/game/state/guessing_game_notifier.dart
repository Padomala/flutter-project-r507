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
  
  // UX : Pour afficher des spinners sur les boutons
  bool _isLoading = false; 
  bool get isLoading => _isLoading;

  GuessingGameNotifier({required this.gameId})
      : _commService = CommunicationService(gameId: gameId) {
    _initializeGame();
  }

  GuessingGameState _state = GuessingGameState(
    currentState: GameStateEnum.waiting,
    localPlayerId: PlayerId.playerA,
    gameData: const GuessingGameDataModel(targetWord: '', cluesForA: []),
  );
  GuessingGameState get state => _state;

  void _setState(GuessingGameState newState) {
    _state = newState;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Logique d'état corrigée
  GameStateEnum _determineState(GuessingGameDataModel gameData) {
    // 1. Si on a un verdict (vrai ou faux), c'est fini
    if (gameData.isCorrect != null) {
      return GameStateEnum.results;
    } 
    // 2. Si le joueur A n'a pas encore deviné (ou null ou vide)
    else if (gameData.playerAGuess == null || gameData.playerAGuess!.isEmpty) {
      return GameStateEnum.playerATurn;
    } 
    // 3. Sinon, c'est au tour de B
    else {
      return GameStateEnum.playerBTurn;
    }
  }

  Future<void> _createInitialGameData() async {
    final random = Random();
    final List<String> availableWords = kGuessingGameClues.keys.toList();
    final targetWord = availableWords[random.nextInt(availableWords.length)];
    final clues = kGuessingGameClues[targetWord] ?? [];

    // On utilise le modèle pour générer le JSON propre
    final newData = GuessingGameDataModel(
      targetWord: targetWord,
      cluesForA: clues,
      playerAGuess: null,
      playerBResult: null,
      isCorrect: null,
    );

    await _commService.createGameData(newData.toJson());
  }

  void _initializeGame() async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    // Détermination du rôle (inchangé)
    if (currentUserId == null) {
      _localPlayerId = PlayerId.playerA;
    } else {
      final gameMetadata = await _commService.getGameMetadata();
      if (gameMetadata != null && gameMetadata['player_b_id'] == currentUserId) {
        _localPlayerId = PlayerId.playerB;
      } else {
        _localPlayerId = PlayerId.playerA;
      }
    }

    // Chargement initial
    Map<String, dynamic>? initialGameDataJson = await _commService.getGameData();

    if (initialGameDataJson == null || initialGameDataJson['targetWord'] == null) {
      await _createInitialGameData();
      initialGameDataJson = await _commService.getGameData();
    }
    
    final initialGameData = GuessingGameDataModel.fromJson(initialGameDataJson ?? {});
    
    _setState(GuessingGameState(
      localPlayerId: _localPlayerId,
      currentState: _determineState(initialGameData),
      gameData: initialGameData
    ));
    
    // Écoute du stream
    _commService.gameDataStream.listen((jsonData) {
      if (jsonData.isEmpty) return;
      final gameData = GuessingGameDataModel.fromJson(jsonData);
      _setState(_state.copyWith(
        currentState: _determineState(gameData),
        gameData: gameData,
      ));
    });
  }

  // --- ACTIONS ---

  Future<void> submitGuess(String guess) async {
    if (_isLoading) return; // Anti-spam
    if (guess.trim().isEmpty) return;
    
    _setLoading(true);
    await _commService.updateGameDataField(key: 'playerAGuess', value: guess.trim());
    _setLoading(false);
  }

  Future<void> confirmFinalWord(String finalWord) async {
    if (_isLoading) return;
    if (finalWord.trim().isEmpty) return;

    _setLoading(true);
    final trimmedFinalWord = finalWord.trim();
      
    await _commService.updateGameDataField(key: 'playerBResult', value: trimmedFinalWord);
    
    final bool isCorrect = trimmedFinalWord.toLowerCase() == _state.gameData.targetWord.toLowerCase().trim();
    await _commService.updateGameDataField(key: 'isCorrect', value: isCorrect);
    
    _setLoading(false);
  }

  Future<void> resetGame() async {
    if (_isLoading) return;
    _setLoading(true);
    await _createInitialGameData();
    _setLoading(false);
  }
}