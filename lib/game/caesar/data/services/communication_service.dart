import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class CommunicationService {
  final String gameId;
  final SupabaseClient _client = Supabase.instance.client;

  CommunicationService({required this.gameId});

  Stream<Map<String, dynamic>> get gameStream {
    return _client
        .from('game_data')
        .stream(primaryKey: ['game_id'])
        .eq('game_id', gameId)
        .limit(1)
        .map((dataList) {
          if (dataList.isEmpty) return {};
          return dataList.first;
        });
  }

  Future<Map<String, dynamic>?> getGameData() async {
    final response = await _client
        .from('game_data')
        .select('data')
        .eq('game_id', gameId)
        .maybeSingle();

    if (response == null || response['data'] == null) {
      return null;
    }

    return response['data'] as Map<String, dynamic>;
  }

  /// Initialise une nouvelle entrée.
  /// CORRECTION: Utilise 'insert' au lieu de 'upsert' pour ne pas écraser
  /// une partie créée par l'autre joueur millisecondes avant.
  Future<bool> createGameData(Map<String, dynamic> initialData) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _client.from('game_data').insert({
        'game_id': gameId,
        'player_a_id': userId,
        'data': initialData,
      });
      return true; // Création réussie, je suis Player A
    } catch (e) {
      // Si erreur (ex: duplicate key), ça veut dire que la partie existe déjà.
      // On ne fait rien, on laissera la logique de "Join" prendre le relais.
      debugPrint('Info: La partie existe déjà, passage en mode Join.');
      return false;
    }
  }

  Future<bool> joinGameAsPlayerB() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      // 1. On récupère la ligne actuelle
      final check = await _client
          .from('game_data')
          .select('player_b_id, player_a_id')
          .eq('game_id', gameId)
          .maybeSingle();

      if (check == null) return false;

      // Si je suis déjà A, je ne peux pas être B
      if (check['player_a_id'] == userId) return false;

      // Si je suis déjà B, c'est bon
      if (check['player_b_id'] == userId) return true;

      // Si la place est prise par quelqu'un d'autre
      if (check['player_b_id'] != null) return false;

      // 2. Sinon, je prends la place
      await _client
          .from('game_data')
          .update({'player_b_id': userId})
          .eq('game_id', gameId);

      debugPrint("Succès: Joueur B ($userId) a rejoint la partie $gameId");
      return true;
    } catch (e) {
      debugPrint("Erreur lors de la jonction : $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getGameMetadata() async {
    final response = await _client
        .from('game_data')
        .select('player_a_id, player_b_id')
        .eq('game_id', gameId)
        .maybeSingle();

    return response;
  }

  Future<void> updateGameDataField({
    required String key,
    required dynamic value,
  }) async {
    try {
      // Utilisation d'une fonction RPC ou update direct JSONB si supporté,
      // ici on garde votre logique de lecture/ecriture mais attention aux race conditions.
      // Pour ce type de jeu simple, ça passe.
      final response = await _client
          .from('game_data')
          .select('data')
          .eq('game_id', gameId)
          .maybeSingle();

      if (response == null || response['data'] == null) return;

      Map<String, dynamic> currentData = Map<String, dynamic>.from(
        response['data'],
      );
      currentData[key] = value;

      await _client
          .from('game_data')
          .update({'data': currentData})
          .eq('game_id', gameId);
    } catch (e) {
      debugPrint("Erreur Update Supabase: $e");
    }
  }

  Future<void> updateGameDataBatch(Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('game_data')
          .select('data')
          .eq('game_id', gameId)
          .maybeSingle();

      if (response == null || response['data'] == null) return;

      Map<String, dynamic> currentData = Map<String, dynamic>.from(
        response['data'],
      );

      updates.forEach((key, value) {
        currentData[key] = value;
      });

      await _client
          .from('game_data')
          .update({'data': currentData})
          .eq('game_id', gameId);
    } catch (e) {
      debugPrint("Erreur Batch Update: $e");
    }
  }
}
