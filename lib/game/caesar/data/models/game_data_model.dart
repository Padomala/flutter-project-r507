import 'package:flutter/foundation.dart';

/// Modèle de données simplifié pour le jeu.
/// 
/// Se concentre uniquement sur la persistence du score. 
/// La logique d'affichage (Waiting/Qui joue) est gérée par le State et le Notifier.
@immutable
class CaesarGameDataModel {
  /// Le score actuel de la partie.
  final int score;

  const CaesarGameDataModel({
    this.score = 0,
  });

  /// Crée une instance à partir du JSON provenant de Supabase.
  factory CaesarGameDataModel.fromJson(Map<String, dynamic> json) {
    return CaesarGameDataModel(
      score: (json['score'] as int?) ?? 0,
    );
  }

  /// Convertit le modèle en JSON pour la mise à jour en base de données.
  Map<String, dynamic> toJson() {
    return {
      'score': score,
    };
  }

  /// Permet de créer une nouvelle instance avec un score modifié facilement.
  CaesarGameDataModel copyWith({
    int? score,
  }) {
    return CaesarGameDataModel(
      score: score ?? this.score,
    );
  }
}