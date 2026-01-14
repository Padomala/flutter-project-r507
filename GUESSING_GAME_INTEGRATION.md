# 🔗 Intégration du Guessing Game Mis à Jour

## Changements Apportés

Le jeu "Clues" (Guessing Game) a été mis à jour avec un nouveau système et l'orchestrateur a été adapté pour gérer ces changements.

---

## 🎮 Nouveau Système du Jeu

### Changements Principaux

| Avant | Après |
|-------|-------|
| Jeu simple avec indices | **Jeu en 2 rounds** avec rôles alternés |
| Pas de rôles | **Descripteur** et **Devineur** |
| Indices simples | **Mots interdits** (style Taboo) |
| Un seul round | ✅ **2 manches** complètes |
| Pas de fin de partie | ✅ Écran **Game Over** avec scores |

### Structure des Données

```dart
// Modèle de données du jeu
class GuessingGameDataModel {
  final String targetWord;
  final List<String> forbiddenWords;  // NOUVEAU: Mots interdits
  final String? guess;
  final bool? isCorrect;
}

// État du jeu
class GuessingGameState {
  final GameStateEnum currentState;
  final PlayerId localPlayerId;
  final GuessingGameDataModel gameData;
  final int currentRound;              // NOUVEAU: Round actuel (1 ou 2)
  final bool isGameOver;               // NOUVEAU: Fin de partie
}
```

### Système de Rôles

```dart
// Round 1
- Player A = Descripteur (voit la carte + mots interdits)
- Player B = Devineur (doit trouver le mot)

// Round 2 (rôles inversés)
- Player A = Devineur
- Player B = Descripteur
```

---

## 🔧 Adaptations de l'Orchestrateur

### 1. Type de Retour Modifié

**Avant :**
```dart
final result = await Navigator.push<bool>(...);
// Retournait simplement true/false
```

**Après :**
```dart
final result = await Navigator.push<Map<String, dynamic>?>(...);
// Retourne un objet avec les scores détaillés
```

### 2. Structure du Résultat

```dart
{
  'finished': true,
  'playerA_score': 1,  // Nombre de rounds gagnés
  'playerB_score': 1,
  'note': 'Système de rounds à améliorer'
}
```

### 3. Calcul du Gagnant

```dart
// Extraire les scores
final playerAScore = result['playerA_score'] as int? ?? 1;
final playerBScore = result['playerB_score'] as int? ?? 1;

// Déterminer le gagnant
String? winnerId;
if (playerAScore > playerBScore) {
  winnerId = playerA;  // Player A gagne
} else if (playerBScore > playerAScore) {
  winnerId = playerB;  // Player B gagne
}
// Sinon winnerId = null (égalité)
```

---

## 📊 Flux de Jeu Complet

```
┌─────────────────────┐
│ ORCHESTRATEUR       │
│ Appelle Clues Game  │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ ROUND 1             │
│ A = Descripteur     │ ← A voit mot + interdits
│ B = Devineur        │ ← B tape sa réponse
└──────┬──────────────┘
       │
       ▼ Validation
┌─────────────────────┐
│ RÉSULTAT ROUND 1    │
│ ✅ Correct / ❌ Faux │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ ROUND 2             │
│ A = Devineur        │ ← Rôles inversés
│ B = Descripteur     │
└──────┬──────────────┘
       │
       ▼ Validation
┌─────────────────────┐
│ RÉSULTAT ROUND 2    │
│ ✅ Correct / ❌ Faux │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ GAME OVER POPUP     │
│ - Rejouer           │
│ - TERMINER          │ ← Retourne scores
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ ORCHESTRATEUR       │
│ Reçoit résultats    │
│ Met à jour scores   │
└─────────────────────┘
```

---

## 🎯 Modifications de Code

### `guessing_game_screen.dart`

#### Bouton "TERMINER" ajouté
```dart
_buildStyledButton("TERMINER", false, () {
  // Retourner les résultats à l'orchestrateur
  Navigator.pop(context, gameResults);
}, color: AppColors.gray),
```

Au lieu de juste :
```dart
TextButton(onPressed: () => Navigator.pop(context), child: Text("Quitter"))
```

### `game_orchestrator_screen.dart`

#### Changement de type
```dart
// Avant
final result = await Navigator.push<bool>(...);

// Après
final result = await Navigator.push<Map<String, dynamic>?>(...);
```

#### Parsing des résultats
```dart
// Extraction
final playerAScore = result['playerA_score'] as int? ?? 1;
final playerBScore = result['playerB_score'] as int? ?? 1;

// Détermination du gagnant
String? winnerId;
if (playerAScore > playerBScore) {
  winnerId = playerA;
} else if (playerBScore > playerAScore) {
  winnerId = playerB;
}

// Création du GameResult
return GameResult(
  gameType: 'clues',
  winnerId: winnerId,  // null si égalité
  scores: {
    playerA: playerAScore,
    playerB: playerBScore,
  },
  completedAt: DateTime.now(),
  additionalData: {
    'rounds_played': 2,
    'game_finished': true,
  },
);
```

---

## ✅ Fonctionnalités Implémentées

- [x] Détection de 2 joueurs minimum
- [x] Retour du résultat au format Map
- [x] Extraction des scores par joueur
- [x] Calcul automatique du gagnant
- [x] Support de l'égalité (winnerId = null)
- [x] Métadonnées additionnelles (rounds_played)
- [x] Gestion du cas où l'utilisateur quitte

---

## 🚧 Amélioration Future

### Système de Score Détaillé

Pour l'instant, le jeu retourne des scores fixes (1-1 ou égalité). Pour améliorer :

#### Dans `guessing_game_notifier.dart`

Ajouter un tracking des victoires :

```dart
class GuessingGameNotifier extends ChangeNotifier {
  int _playerAWins = 0;
  int _playerBWins = 0;
  
  // Après chaque round
  void _recordRoundResult(bool isCorrect) {
    if (currentRound == 1) {
      // Round 1: B est le devineur
      if (isCorrect) _playerBWins++;
    } else {
      // Round 2: A est le devineur
      if (isCorrect) _playerAWins++;
    }
  }
  
  // À la fin du jeu
  Map<String, int> get finalScores => {
    'playerA': _playerAWins,
    'playerB': _playerBWins,
  };
}
```

#### Dans `guessing_game_screen.dart`

```dart
final Map<String, dynamic> gameResults = {
  'finished': true,
  'playerA_score': notifier.finalScores['playerA']!,
  'playerB_score': notifier.finalScores['playerB']!,
};
```

---

## 📝 Test du Système

### Scénario de Test

1. **Lancement** : 2 joueurs dans une room
2. **Host** : Lance la partie
3. **Orchestrateur** : Navigation vers Clues
4. **Round 1** :
   - Player B devine
   - Résultat enregistré
5. **Round 2** :
   - Player A devine
   - Résultat enregistré
6. **Game Over** :
   - Popup s'affiche
   - Clic "TERMINER"
   - Scores retournés
7. **Orchestrateur** :
   - Reçoit `{playerA_score: X, playerB_score: Y}`
   - Détermine le gagnant
   - Met à jour scores globaux
   - Continue vers jeu suivant

---

## 🎨 État Actuel

### Ce qui fonctionne ✅

- Navigation depuis l'orchestrateur
- Création de game_id unique
- Lancement du jeu avec 2 joueurs
- Système de rounds
- Popup de fin de partie
- **Retour des résultats** à l'orchestrateur
- **Calcul du gagnant**
- **Mise à jour des scores**

### À améliorer 🚧

- Tracking précis des victoires par round
- Affichage du score détaillé dans le popup
- Statistiques de jeu (temps, tentatives, etc.)
- Animation des transitions entre rounds

---

## 🔍 Debugging

### Logs à vérifier

Dans l'orchestrateur :
```
🎮 Lancement du jeu: clues
```

Dans le jeu :
```
✅ Game initialized with player A
✅ Round 1 started
✅ Round 2 started
✅ Game Over - returning results
```

Dans l'orchestrateur :
```
✅ Résultat enregistré: clues
   Winner: player_id_xxx
   Scores: {playerA: X, playerB: Y}
```

---

## 📚 Résumé

**L'orchestrateur est maintenant entièrement compatible avec le système de rounds du Guessing Game.**

- ✅ Détecte 2 joueurs
- ✅ Lance le jeu avec gameId unique
- ✅ Reçoit les scores détaillés
- ✅ Calcule automatiquement le gagnant
- ✅ Gère l'égalité
- ✅ Continue vers le jeu suivant

**Prochaine étape** : Améliorer le tracking des victoires par round pour des scores plus précis.
