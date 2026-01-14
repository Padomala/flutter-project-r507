import 'package:flutter/material.dart';
import 'dart:async';
import '../models/game_session_model.dart';
import '../models/game_result_model.dart';
import '../services/game_session_service.dart';

class GameSessionProvider extends ChangeNotifier {
  final GameSessionService _service = GameSessionService();
  
  GameSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<GameSession>? _sessionSubscription;
  
  // Getters
  GameSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreGames => _currentSession?.hasMoreGames ?? false;
  bool get isCompleted => _currentSession?.isCompleted ?? false;
  
  // Infos du jeu actuel
  String? get currentGameType => _currentSession?.currentGame.gameType;
  int get currentGameIndex => _currentSession?.currentGameIndex ?? 0;
  int get totalGames => _currentSession?.totalGames ?? 0;
  
  /// Créer une nouvelle session
  Future<String?> createSession({
    required String roomId,
    required int nbGames,
    required List<String> playerIds,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentSession = await _service.createSession(
        roomId: roomId,
        nbGames: nbGames,
        playerIds: playerIds,
      );
      
      // S'abonner aux changements en temps réel
      _subscribeToSession(_currentSession!.id);
      
      // Passer le statut à "in_progress"
      await _service.updateStatus(_currentSession!.id, 'in_progress');
      
      return _currentSession!.id;
    } catch (e) {
      _setError('Erreur création session: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Charger une session existante
  Future<void> loadSession(String sessionId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentSession = await _service.getSession(sessionId);
      _subscribeToSession(sessionId);
    } catch (e) {
      _setError('Erreur chargement session: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Charger une session par room ID
  Future<void> loadSessionByRoomId(String roomId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final session = await _service.getSessionByRoomId(roomId);
      if (session != null) {
        _currentSession = session;
        _subscribeToSession(session.id);
      } else {
        _setError('Aucune session trouvée pour cette room');
      }
    } catch (e) {
      _setError('Erreur chargement session: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Passer au jeu suivant
  Future<bool> moveToNextGame() async {
    if (_currentSession == null) return false;
    
    try {
      await _service.moveToNextGame(_currentSession!.id);
      return true;
    } catch (e) {
      _setError('Erreur passage au jeu suivant: $e');
      return false;
    }
  }
  
  /// Enregistrer un résultat de jeu
  Future<bool> saveGameResult(GameResult result) async {
    if (_currentSession == null) return false;
    
    try {
      await _service.saveGameResult(
        sessionId: _currentSession!.id,
        result: result,
      );
      return true;
    } catch (e) {
      _setError('Erreur enregistrement résultat: $e');
      return false;
    }
  }
  
  /// Récupérer tous les résultats de la session
  Future<List<GameResult>> getResults() async {
    if (_currentSession == null) return [];
    
    try {
      return await _service.getSessionResults(_currentSession!.id);
    } catch (e) {
      _setError('Erreur récupération résultats: $e');
      return [];
    }
  }
  
  /// Marquer la session comme terminée
  Future<void> completeSession() async {
    if (_currentSession == null) return;
    
    try {
      await _service.updateStatus(_currentSession!.id, 'completed');
    } catch (e) {
      _setError('Erreur finalisation session: $e');
    }
  }
  
  /// S'abonner aux changements en temps réel
  void _subscribeToSession(String sessionId) {
    _unsubscribeFromSession();
    
    _sessionSubscription = _service.watchSession(sessionId).listen(
      (session) {
        _currentSession = session;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Erreur stream session: $error');
        _setError('Erreur synchronisation: $error');
      },
    );
  }
  
  /// Se désabonner du stream
  void _unsubscribeFromSession() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
  }
  
  /// Nettoyer la session locale
  void clearSession() {
    _unsubscribeFromSession();
    _currentSession = null;
    _error = null;
    notifyListeners();
  }
  
  // Helpers privés
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _error = message;
    debugPrint('⚠️ GameSessionProvider: $message');
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  @override
  void dispose() {
    _unsubscribeFromSession();
    super.dispose();
  }
}
