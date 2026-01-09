import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; 

class CommunicationService {
  final String gameId;
  final SupabaseClient _client = Supabase.instance.client;

  CommunicationService({required this.gameId});

/**
 * Stream qui émet le contenu du champ 'data' (JSONB)
 */
  Stream<Map<String, dynamic>> get gameDataStream {
    return _client
        .from('game_data')
        .stream(primaryKey: ['game_id']) 
        .eq('game_id', gameId) 
        .limit(1)
        .execute()
        .map((dataList) {
          if (dataList.isEmpty || dataList.first['data'] == null) return {};
          return dataList.first['data'] as Map<String, dynamic>; 
        });
  }

/**
 * Lit les données complètes du jeu (JSONB 'data') pour l'initialisation
 */
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

/**
 * Crée la ligne de données initiale complète
 */
  Future<void> createGameData(Map<String, dynamic> initialData) async {
    try {
      await _client.from('game_data').upsert({
        'game_id': gameId,
        'data': initialData, 
      }, onConflict: 'game_id');
    } catch (e) {
      debugPrint('Erreur lors de la création initiale des données de jeu: $e');
    }
  }

/**
 * Lit les IDs des joueurs (métadonnées). 
 */
  Future<Map<String, dynamic>?> getGameMetadata() async {
    final response = await _client
        .from('games') 
        .select('player_a_id, player_b_id') 
        .eq('game_id', gameId)
        .maybeSingle();

    return response; 
  }


/**
 * Met à jour un champ spécifique dans le JSONB 'data'
 */
Future<void> updateGameDataField({
    required String key,
    required dynamic value,
  }) async {
    try {
      final response = await _client
          .from('game_data')
          .select('data')
          .eq('game_id', gameId)
          .maybeSingle();

      if (response == null || response['data'] == null) return;
      
      Map<String, dynamic> currentData = Map<String, dynamic>.from(response['data']); // Copie mutable
      currentData[key] = value;

      await _client
          .from('game_data')
          .update({'data': currentData})
          .eq('game_id', gameId);
          
    } catch (e) {
      debugPrint("Erreur Update Supabase: $e");
      // Ici on pourrait re-throw l'erreur pour afficher une snackbar dans l'UI
    }
  }
}
