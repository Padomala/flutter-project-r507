import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service gérant la communication en temps réel avec Supabase pour une partie spécifique.
class CommunicationService {
  /// L'identifiant unique de la partie en cours.
  final String gameId;

  /// Instance du client Supabase pour effectuer les requêtes.
  final SupabaseClient _client = Supabase.instance.client;

  CommunicationService({required this.gameId});

  /// Écoute en temps réel les changements de la ligne correspondant à [gameId] dans la table 'game_data'.
  ///
  /// Émet une [Map] contenant l'intégralité de la ligne (colonnes et JSONB).
  /// Utile pour détecter quand un second joueur rejoint la partie via `player_b_id`.
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

  /// Récupère ponctuellement le contenu du champ JSONB 'data'.
  ///
  /// Retourne `null` si la partie n'existe pas ou si les données sont vides.
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

  /// Initialise une nouvelle entrée dans la table 'game_data' pour cette partie.
  ///
  /// Enregistre l'utilisateur actuel comme `player_a_id`.
  /// Utilise un `upsert` avec [onConflict] pour éviter les doublons sur l'ID de partie.
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

  /// Permet à l'utilisateur actuel de s'enregistrer en tant que second joueur (`player_b_id`).
  ///
  /// Vérifie d'abord si la place est disponible ou si l'utilisateur y est déjà.
  /// Retourne `true` si l'inscription est validée, `false` en cas d'erreur ou de partie pleine.
  Future<bool> joinGameAsPlayerB() async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      debugPrint("Erreur: Utilisateur non connecté");
      return false;
    }

    try {
      // 1. Vérification de la disponibilité de la place
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

      // 2. Mise à jour de la colonne player_b_id
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

  /// Récupère les identifiants des deux joueurs (`player_a_id` et `player_b_id`).
  ///
  /// Permet de vérifier les rôles (qui est le maître du jeu / qui est le devineur).
  Future<Map<String, dynamic>?> getGameMetadata() async {
    final response = await _client
        .from('game_data')
        .select('player_a_id, player_b_id')
        .eq('game_id', gameId)
        .maybeSingle();

    return response;
  }

  /// Modifie une seule valeur à l'intérieur de la colonne JSONB 'data'.
  ///
  /// Cette méthode lit l'état actuel, modifie la clé demandée localement,
  /// puis renvoie l'objet complet à Supabase.
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

  /// Modifie plusieurs valeurs simultanément dans la colonne JSONB 'data'.
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
