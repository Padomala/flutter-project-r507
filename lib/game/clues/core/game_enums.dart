enum GameStateEnum {
  // En attente de connexion
  waiting,
  // Le joueur A doit deviner
  playerATurn,
  // Le joueur B doit confirmer/valider
  playerBTurn,
  // Affichage des résultats
  results,
}

enum PlayerId { playerA, playerB }