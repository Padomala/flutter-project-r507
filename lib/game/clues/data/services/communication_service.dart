import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; 

class CommunicationService {
  final String gameId;
  final SupabaseClient _client = Supabase.instance.client;

  CommunicationService({required this.gameId});

/**
   * Stream qui émet TOUTE la ligne (IDs + JSON)
   * Cela permet à l'UI de savoir quand player_b_id n'est plus null
   */
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
/**
   * Crée la ligne de données initiale complète
   */
  Future<void> createGameData(Map<String, dynamic> initialData) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
        debugPrint("Erreur critique: Utilisateur non connecté");
        return; 
    }

    try {
      await _client.from('game_data').upsert({
        'game_id': gameId,
        'player_a_id': userId, 
        'data': initialData, 
      }, onConflict: 'game_id');
    } catch (e) {
      debugPrint('Erreur lors de la création initiale des données de jeu: $e');
    }
  }

  /**
 * Permet au joueur B de rejoindre une partie existante
 * Renvoie true si succès, false sinon
 */
Future<bool> joinGameAsPlayerB() async {
  final userId = _client.auth.currentUser?.id;

  if (userId == null) {
    debugPrint("Erreur: Utilisateur non connecté");
    return false;
  }

  try {
    // 1. On vérifie d'abord si la place est libre (optionnel mais recommandé)
    final check = await _client
        .from('game_data')
        .select('player_b_id')
        .eq('game_id', gameId)
        .maybeSingle();
    
    if (check == null) {
       debugPrint("Erreur: Partie introuvable");
       return false;
    }

    if (check['player_b_id'] != null && check['player_b_id'] != userId) {
      debugPrint("Erreur: La partie est déjà complète !");
      return false;
    }

    // 2. On met à jour la ligne pour s'y inscrire
    await _client.from('game_data').update({
      'player_b_id': userId, // C'est ici que B prend sa place
    }).eq('game_id', gameId);

    debugPrint("Succès: Joueur B ($userId) a rejoint la partie $gameId");
    return true;

  } catch (e) {
    debugPrint("Erreur lors de la jonction : $e");
    return false;
  }
}

/**
 * Lit les IDs des joueurs (métadonnées). 
 */
  Future<Map<String, dynamic>?> getGameMetadata() async {
    final response = await _client
        .from('game_data') 
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

  Future<void> updateGameDataBatch(Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('game_data')
          .select('data')
          .eq('game_id', gameId)
          .maybeSingle();

      if (response == null || response['data'] == null) return;
      
      Map<String, dynamic> currentData = Map<String, dynamic>.from(response['data']);
      
      // On applique toutes les modifications
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
