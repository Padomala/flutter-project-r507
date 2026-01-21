enum GameStateEnum {
  /// En attente de connexion
  waiting,

  /// Le tour du joueur A
  playerATurn,

  /// Le tour du joueur B
  playerBTurn,

  /// Affichage des résultats
  results,
}

enum PlayerId {
  /// Le joueur A
  playerA,

  /// Le joueur B
  playerB,
}
