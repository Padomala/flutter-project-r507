# Système d'Orchestration des Mini-Jeux 🎮

Ce document explique comment fonctionne le système d'orchestration des mini-jeux et comment l'utiliser.

## 📋 Architecture

Le système est organisé en plusieurs couches :

```
lib/
├── core/game_orchestrator/
│   ├── models/                  # Modèles de données
│   │   ├── game_session_model.dart
│   │   └── game_result_model.dart
│   ├── services/                # Services Supabase
│   │   └── game_session_service.dart
│   ├── providers/               # State management
│   │   └── game_session_provider.dart
│   └── ui/                      # Interfaces utilisateur
│       ├── game_orchestrator_screen.dart
│       ├── transition_screen.dart
│       └── final_results_screen.dart
```

## 🚀 Installation

### 1. Créer les tables Supabase

Exécutez le script SQL dans l'éditeur SQL de Supabase :
```bash
supabase_setup_game_sessions.sql
```

Ce script créera :
- Table `game_sessions` : Gestion des sessions de jeu
- Table `game_results` : Stockage des résultats de chaque mini-jeu
- Index et policies RLS appropriés
- Support temps réel

### 2. Dépendances

Toutes les dépendances sont déjà ajoutées au `pubspec.yaml` :
- `provider` : State management
- `confetti` : Animations de célébration
- `supabase_flutter` : Backend

## 🎯 Utilisation

### Flux de jeu complet

1. **Dans RoomHub** : Le host clique sur "Lancer la Partie"
2. **Création de session** : Une session est créée avec N jeux aléatoires
3. **Navigation** : L'utilisateur est dirigé vers le `GameOrchestratorScreen`
4. **Pour chaque jeu** :
   - Écran de transition (3...2...1...)
   - Lancement du mini-jeu
   - Récupération du résultat
   - Mise à jour des scores
5. **Résultats finaux** : Affichage du gagnant et des scores

### Ajouter un nouveau mini-jeu

Pour ajouter un nouveau mini-jeu au système :

#### 1. Créer le jeu

Créez votre mini-jeu dans `lib/game/mon_jeu/` avec :
- Les modèles de données
- Le service de communication
- Le provider/notifier
- L'UI

#### 2. Retourner un résultat

Votre jeu **doit** retourner un résultat quand il se termine :

```dart
// À la fin du jeu, retournez un bool ou un GameResult
Navigator.pop(context, true); // true = gagnant, false = perdant
```

#### 3. Ajouter au router

Dans `game_orchestrator_screen.dart`, ajoutez un cas dans `_navigateToGame()` :

```dart
case 'mon_jeu':
  return await _launchMonJeu();
```

Et créez la méthode :

```dart
Future<GameResult?> _launchMonJeu() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MonJeuScreen(),
    ),
  );
  
  if (result == null) return null; // Utilisateur a quitté
  
  // Convertir le résultat en GameResult
  final provider = context.read<GameSessionProvider>();
  final playerIds = provider.currentSession!.playerScores.keys.toList();
  
  return GameResult.winnerLoser(
    gameType: 'mon_jeu',
    winnerId: result ? playerIds[0] : playerIds[1],
    loserId: result ? playerIds[1] : playerIds[0],
  );
}
```

#### 4. Ajouter à la liste des jeux disponibles

Dans `game_session_service.dart`, ligne 11 :

```dart
static const List<String> availableGames = ['clues', 'caesar', 'labyrinthe', 'mon_jeu'];
```

## 🎨 Personnalisation

### Écran de transition

Modifiez `transition_screen.dart` pour :
- Changer l'animation du countdown
- Ajouter des effets visuels
- Personnaliser les icônes de jeux

### Écran de résultats

Modifiez `final_results_screen.dart` pour :
- Changer les animations
- Ajouter des statistiques
- Personnaliser les couleurs

## 📊 Modèles de données

### GameSession

```dart
{
  id: 'uuid',
  roomId: 'uuid',
  gamesQueue: [
    {gameType: 'clues', order: 0},
    {gameType: 'caesar', order: 1},
    // ...
  ],
  currentGameIndex: 0,
  playerScores: {
    'player1_id': 5,
    'player2_id': 3,
  },
  status: 'in_progress',
}
```

### GameResult

```dart
{
  gameType: 'clues',
  winnerId: 'player1_id',
  scores: {
    'player1_id': 1,  // Points gagnés dans CE jeu
    'player2_id': 0,
  },
  completedAt: DateTime.now(),
}
```

## 🔄 Synchronisation temps réel

Le système utilise Supabase Realtime pour :
- Synchroniser l'état de la session entre les joueurs
- Mettre à jour les scores en temps réel
- Détecter les changements de jeu

Les deux joueurs voient automatiquement les mêmes écrans au même moment.

## 🐛 Debugging

Activez les logs pour voir le flux :

```
✅ Session créée: abc-123
✅ Passage au jeu 2/5
🎮 Lancement du jeu: caesar
✅ Résultat enregistré: caesar
```

## ⚠️ Notes importantes

1. **Synchronisation** : Les deux joueurs doivent être connectés et dans la même room
2. **Résultats** : Chaque jeu DOIT retourner un résultat, sinon l'orchestrateur s'arrête
3. **Base de données** : Assurez-vous que les tables `game_sessions` et `game_results` existent
4. **Providers** : `GameSessionProvider` doit être ajouté dans `app_providers.dart`

## 🎯 Prochaines étapes

- [ ] Implémenter les jeux manquants (Caesar, Labyrinthe)
- [ ] Ajouter plus de types de jeux
- [ ] Améliorer les animations de transition
- [ ] Ajouter des statistiques détaillées
- [ ] Implémenter le bouton "Rejouer"
- [ ] Ajouter un système de trophées/achievements

## 📚 Ressources

- [Provider Documentation](https://pub.dev/packages/provider)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Confetti Package](https://pub.dev/packages/confetti)
