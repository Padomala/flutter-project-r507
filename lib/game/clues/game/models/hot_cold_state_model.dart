import 'package:flutter/foundation.dart';
import '../../core/game_enums.dart';
import '../../data/models/hot_cold_model.dart';

/// Représente l'état complet de l'écran de jeu à un instant T.
///
/// Cette classe est utilisée pour reconstruire l'interface utilisateur (UI)
/// dès qu'une donnée change (changement de manche, nouveau mot, etc.).
class HotColdGameState {
  /// L'étape actuelle du jeu
  final GameStateEnum currentState;

  /// L'identifiant du joueur (soit PlayerA, soit PlayerB).
  final PlayerId localPlayerId;

  /// Les données de la manche (mot cible, mots interdits).
  final HotColdGameDataModel gameData;

  /// Le numéro de la manche actuelle (permet de gérer l'alternance des rôles).
  final int currentRound;

  /// Indique si la partie complète est finie.
  final bool isGameOver;

  HotColdGameState({
    required this.currentState,
    required this.localPlayerId,
    required this.gameData,
    this.currentRound = 1,
    this.isGameOver = false,
  });

  /// En Manche 1, c'est le Joueur B qui devine.
  /// En Manche 2, les rôles s'inversent : c'est le Joueur A.
  bool get amIGuesser {
    if (currentRound == 1) {
      return localPlayerId == PlayerId.playerB;
    } else {
      return localPlayerId == PlayerId.playerA;
    }
  }

  /// L'opposé de [amIGuesser] : si je ne devine pas, je décris.
  bool get amIDescriber => !amIGuesser;

  /// Créer une nouvelle version de l'état en ne modifiant que certains champs.
  /// On en crée un nouveau avec les mises à jour => rafraîchissement de l'UI.
  HotColdGameState copyWith({
    GameStateEnum? currentState,
    HotColdGameDataModel? gameData,
    PlayerId? localPlayerId,
    int? currentRound,
    bool? isGameOver,
  }) {
    return HotColdGameState(
      currentState: currentState ?? this.currentState,
      localPlayerId: localPlayerId ?? this.localPlayerId,
      gameData: gameData ?? this.gameData,
      currentRound: currentRound ?? this.currentRound,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}
