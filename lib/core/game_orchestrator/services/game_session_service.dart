import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_session_model.dart';
import '../models/game_result_model.dart';

class GameSessionService {
  final SupabaseClient _client = Supabase.instance.client;

  // Liste des jeux disponibles
  static const List<String> availableGames = ['clues', 'caesar', 'labyrinthe'];

  /// Créer une session de jeu
  Future<GameSession> createSession({
    required String roomId,
    required int nbGames,
    required List<String> playerIds,
  }) async {
    try {
      // 1. Générer la liste aléatoire de jeux
      final gamesQueue = _generateRandomGames(nbGames);

      // 2. Initialiser les scores à 0 pour chaque joueur
      final playerScores = Map<String, int>.fromIterable(
        playerIds,
        key: (id) => id.toString(),
        value: (_) => 0,
      );

      // 3. Créer en base de données
      final response = await _client
          .from('game_sessions')
          .insert({
            'room_id': roomId,
            'games_queue': gamesQueue.map((e) => e.toJson()).toList(),
            'current_game_index': 0,
            'player_scores': playerScores,
            'status': 'pending',
          })
          .select()
          .single();

      debugPrint('✅ Session créée: ${response['id']}');
      return GameSession.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erreur création session: $e');
      rethrow;
    }
  }

  /// Générer une liste aléatoire de jeux
  List<GameConfig> _generateRandomGames(int count) {
    final random = Random();

    return List.generate(count, (index) {
      final gameType = availableGames[random.nextInt(availableGames.length)];
      return GameConfig(gameType: gameType, order: index);
    });
  }

  /// Récupérer une session par son ID
  Future<GameSession> getSession(String sessionId) async {
    try {
      final response = await _client
          .from('game_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      return GameSession.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erreur récupération session: $e');
      rethrow;
    }
  }

  /// Récupérer une session par room_id
  Future<GameSession?> getSessionByRoomId(String roomId) async {
    try {
      final response = await _client
          .from('game_sessions')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return GameSession.fromJson(response);
    } catch (e) {
      debugPrint('❌ Erreur récupération session par room: $e');
      return null;
    }
  }

  /// Mettre à jour le statut de la session
  Future<void> updateStatus(String sessionId, String status) async {
    try {
      await _client
          .from('game_sessions')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);

      debugPrint('✅ Statut mis à jour: $status');
    } catch (e) {
      debugPrint('❌ Erreur mise à jour statut: $e');
      rethrow;
    }
  }

  /// Passer au jeu suivant
  Future<void> moveToNextGame(String sessionId) async {
    try {
      final current = await getSession(sessionId);
      final newIndex = current.currentGameIndex + 1;

      // Déterminer le nouveau statut
      String newStatus = 'in_progress';
      if (newIndex >= current.totalGames) {
        newStatus = 'completed';
      }

      await _client
          .from('game_sessions')
          .update({
            'current_game_index': newIndex,
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);

      debugPrint('✅ Passage au jeu ${newIndex + 1}/${current.totalGames}');
    } catch (e) {
      debugPrint('❌ Erreur passage jeu suivant: $e');
      rethrow;
    }
  }

  /// Enregistrer le résultat d'un jeu
  Future<void> saveGameResult({
    required String sessionId,
    required GameResult result,
    required int gameIndex,
  }) async {
    try {
      // 1. Ajouter l'index du jeu aux métadonnées
      final enhancedResult = GameResult(
        gameType: result.gameType,
        winnerId: result.winnerId,
        scores: result.scores,
        completedAt: result.completedAt,
        additionalData: {...?result.additionalData, 'game_index': gameIndex},
      );

      // 2. Sauvegarder le résultat dans game_results
      await _client.from('game_results').insert({
        'session_id': sessionId,
        'game_type': enhancedResult.gameType,
        'winner_id': enhancedResult.winnerId,
        'scores': enhancedResult.scores,
        'additional_data': enhancedResult.additionalData,
      });

      // 3. Mettre à jour les scores globaux dans game_sessions
      final session = await getSession(sessionId);
      final updatedScores = Map<String, int>.from(session.playerScores);

      result.scores.forEach((playerId, points) {
        updatedScores[playerId] = (updatedScores[playerId] ?? 0) + points;
      });

      await _client
          .from('game_sessions')
          .update({
            'player_scores': updatedScores,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);

      debugPrint(
        '✅ Résultat enregistré: ${result.gameType} (index: $gameIndex)',
      );

      // 4. BARRIER SYNCHRONIZATION
      // Vérifier si tous les joueurs ont fini ce jeu
      final allResults = await _client
          .from('game_results')
          .select()
          .eq('session_id', sessionId);

      // Filtrer pour ne garder que les résultats du jeu actuel
      final currentLevelResults = allResults.where((r) {
        final data = r['additional_data'] as Map<String, dynamic>?;
        return data != null && data['game_index'] == gameIndex;
      }).toList();

      debugPrint(
        '📊 Résultats reçus pour jeu $gameIndex: ${currentLevelResults.length}/${session.playerScores.length}',
      );

      // Si le nombre de résultats correspond au nombre de joueurs, on passe au suivant
      if (currentLevelResults.length >= session.playerScores.length) {
        debugPrint('🚀 Tous les joueurs ont fini ! Passage au jeu suivant...');
        await moveToNextGame(sessionId);
      } else {
        debugPrint('⏳ Attente des autres joueurs...');
      }
    } catch (e) {
      debugPrint('❌ Erreur enregistrement résultat: $e');
      rethrow;
    }
  }

  /// Récupérer tous les résultats d'une session
  Future<List<GameResult>> getSessionResults(String sessionId) async {
    try {
      final response = await _client
          .from('game_results')
          .select()
          .eq('session_id', sessionId)
          .order('completed_at', ascending: true);

      return response
          .map<GameResult>((json) => GameResult.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur récupération résultats: $e');
      return [];
    }
  }

  /// Stream pour suivre les changements de session en temps réel
  Stream<GameSession> watchSession(String sessionId) {
    return _client
        .from('game_sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('Session not found');
          }
          return GameSession.fromJson(data.first);
        });
  }

  /// Supprimer une session (nettoyage)
  Future<void> deleteSession(String sessionId) async {
    try {
      await _client.from('game_sessions').delete().eq('id', sessionId);
      debugPrint('✅ Session supprimée: $sessionId');
    } catch (e) {
      debugPrint('❌ Erreur suppression session: $e');
    }
  }
}
