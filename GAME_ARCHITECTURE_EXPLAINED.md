# 📁 Organisation des Jeux & Liaison Room → Jeux

## 1️⃣ **Analyse de l'Organisation Actuelle**

### 📂 **Structure des Fichiers**

```
lib/
├── game/                          ← Dossier principal des jeux
│   ├── caesar/                    ← Jeu Caesar
│   │   └── game/
│   │       └── ui/
│   │           ├── caesar_game_infoter_screen.dart
│   │           ├── caesar_game_inputer_screen.dart
│   │           └── caesar_game_main_screen.dart
│   │
│   └── clues/                     ← Jeu Clues (Guessing Game)
│       ├── core/                  ← Configuration
│       │   ├── constants.dart
│       │   └── game_enums.dart
│       ├── data/                  ← Couche données
│       │   ├── models/
│       │   │   └── game_data_model.dart
│       │   └── services/
│       │       └── communication_service.dart
│       └── game/                  ← Logique de jeu
│           ├── models/
│           │   └── guessing_state_model.dart
│           ├── state/
│           │   └── guessing_game_notifier.dart
│           └── ui/
│               └── guessing_game_screen.dart
```

---

## ✅ **Évaluation de l'Organisation**

### **Jeu Clues - ✅ EXCELLENTE organisation**

```
clues/
├── core/          ← Config, constantes, enums
├── data/          ← Modèles de données + services Supabase
└── game/          ← Logique + UI
    ├── models/    ← État local
    ├── state/     ← Provider/Notifier
    └── ui/        ← Widgets
```

**Points forts :**
- ✅ **Séparation claire** des responsabilités
- ✅ **Architecture en couches** (data / logic / UI)
- ✅ **Évolutif** et maintenable
- ✅ **Suit les bonnes pratiques Flutter**

**C'est le modèle idéal !** 🌟

---

### **Jeu Caesar - ⚠️ Organisation INCOMPLÈTE**

```
caesar/
└── game/
    └── ui/        ← Seulement l'UI
        ├── caesar_game_infoter_screen.dart
        ├── caesar_game_inputer_screen.dart
        └── caesar_game_main_screen.dart
```

**Problèmes :**
- ❌ Pas de dossier `core/` (constantes, enums)
- ❌ Pas de dossier `data/` (modèles, services)
- ❌ Pas de dossier `state/` (notifier)
- ⚠️ Tout semble être dans l'UI

**Recommandation :** Restructurer comme Clues

---

## 🎯 **Organisation Recommandée pour Caesar**

### **Structure Idéale**

```
caesar/
├── core/
│   ├── constants.dart           ← Alphabet Caesar, shifts, etc.
│   └── game_enums.dart          ← GameState, Player, etc.
│
├── data/
│   ├── models/
│   │   └── caesar_data_model.dart    ← Données du jeu
│   └── services/
│       └── communication_service.dart ← Supabase
│
└── game/
    ├── models/
    │   └── caesar_state_model.dart   ← État local
    ├── state/
    │   └── caesar_game_notifier.dart ← Provider
    └── ui/
        ├── caesar_game_main_screen.dart
        ├── caesar_game_infoter_screen.dart   ← Widget Info
        └── caesar_game_inputer_screen.dart   ← Widget Input
```

### **Bénéfices de cette Organisation**

1. **Réutilisabilité** : Les services peuvent être réutilisés
2. **Testabilité** : Facile de tester chaque couche
3. **Maintenabilité** : Chaque fichier a une responsabilité claire
4. **Cohérence** : Même structure que Clues

---

## 📝 **Plan de Réorganisation Caesar**

### Étape 1 : Créer les dossiers manquants

```
caesar/
├── core/              ← NOUVEAU
├── data/              ← NOUVEAU
│   ├── models/        ← NOUVEAU
│   └── services/      ← NOUVEAU
└── game/
    ├── models/        ← NOUVEAU
    ├── state/         ← NOUVEAU
    └── ui/            ← EXISTE DÉJÀ
```

### Étape 2 : Extraire la logique métier

```dart
// AVANT (tout dans l'UI)
class CaesarGameMainScreen extends StatefulWidget {
  // Logique + UI mélangées
}

// APRÈS (séparé)
// 1. caesar_game_notifier.dart
class CaesarGameNotifier extends ChangeNotifier {
  // Toute la logique métier
}

// 2. caesar_game_main_screen.dart
class CaesarGameMainScreen extends StatefulWidget {
  // Seulement l'UI
}
```

### Étape 3 : Créer les modèles

```dart
// data/models/caesar_data_model.dart
class CaesarDataModel {
  final String encryptedText;
  final int shift;
  final String? userGuess;
  final bool? isCorrect;
}

// game/models/caesar_state_model.dart
class CaesarGameState {
  final GameStateEnum currentState;
  final PlayerId localPlayerId;
  final CaesarDataModel gameData;
}
```

---

## 2️⃣ **Explication Pédagogique : Liaison Room → Jeux**

### **Vue d'Ensemble** 🌍

Imaginez un **parcours du combattant** en 4 zones :

```
🏠 ZONE 1      🎪 ZONE 2         🎮 ZONE 3           🏆 ZONE 4
  ROOM    →   SESSION    →   MINI-JEUX    →    RÉSULTATS
(Salon)    (Organisateur)   (Épreuves)      (Podium)
```

---

### **ZONE 1 : La Room (Le Salon d'Attente)** 🏠

**Fichiers impliqués :**
- `lib/pages/party/room_hub.dart`
- `lib/store/provider/room_provider.dart`
- `lib/core/services/supabase_service.dart`

**Tables Supabase :**
- `rooms`
- `room_participants`

**But :** Rassembler les joueurs avant de jouer

#### Analogie 🎭
C'est comme un **salon de jeu** où les joueurs se retrouvent :
- Le host **crée** la room (crée le salon)
- Le guest **rejoint** avec un code (entre dans le salon)
- Ils **attendent** que tout le monde soit prêt

#### Code Simplifié

```dart
// 1. Host crée une room
RoomProvider.createRoom(settings: {'nb_games': 5});
// → INSERT INTO rooms (host_id, code, status) VALUES (...)

// 2. Guest rejoint avec le code
RoomProvider.joinRoom(code: "ABC123");
// → INSERT INTO room_participants (room_id, user_id) VALUES (...)

// 3. Host clique "Lancer la Partie"
RoomProvider.startGame();
// → UPDATE rooms SET status = 'playing' WHERE id = ...
```

**Ce qui se passe en base :**
```sql
-- Table rooms
id    | host_id | status   | code    | settings
------|---------|----------|---------|----------
abc   | user1   | playing  | ABC123  | {"nb_games": 5}

-- Table room_participants
id  | room_id | user_id | is_host
----|---------|---------|--------
1   | abc     | user1   | true
2   | abc     | user2   | false
```

---

### **ZONE 2 : La Session (L'Organisateur)** 🎪

**Fichiers impliqués :**
- `lib/core/game_orchestrator/providers/game_session_provider.dart`
- `lib/core/game_orchestrator/services/game_session_service.dart`
- `lib/core/game_orchestrator/ui/game_orchestrator_screen.dart`

**Tables Supabase :**
- `game_sessions`
- `game_results`

**But :** Organiser et séquencer les mini-jeux

#### Analogie 🎪
C'est comme un **maître de cérémonie** qui :
- Décide de l'**ordre des jeux** (tire au sort)
- **Annonce** chaque jeu (transition)
- **Enregistre** les scores
- **Déclare** le gagnant final

#### Code Simplifié

```dart
// Dans room_hub.dart - Quand host clique "Lancer"

void _playGames() async {
  // 1. Récupérer les infos de la room
  final roomId = roomProvider.currentRoom!.id;
  final playerIds = roomProvider.participants.map((p) => p.id).toList();
  final nbGames = roomProvider.currentRoom?.settings?['nb_games'] ?? 3;
  
  // 2. CRÉER LA SESSION
  final sessionId = await sessionProvider.createSession(
    roomId: roomId,        // Lie à la room
    nbGames: nbGames,      // Combien de jeux
    playerIds: playerIds,  // Qui joue
  );
  
  // 3. Naviguer vers l'orchestrateur
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GameOrchestratorScreen(sessionId: sessionId),
    ),
  );
}
```

**Ce qui se passe en base :**
```sql
-- Table game_sessions
id      | room_id | games_queue                          | current_game_index | player_scores
--------|---------|--------------------------------------|--------------------|--------------
sess1   | abc     | [{"type":"clues",order:0}, ...]     | 0                  | {user1:0, user2:0}
```

**Explication du `games_queue` :**
```json
[
  {"game_type": "clues", "order": 0},      // Jeu 1
  {"game_type": "caesar", "order": 1},     // Jeu 2
  {"game_type": "labyrinthe", "order": 2}, // Jeu 3
]
```
→ Cette liste est **générée aléatoirement** par le système

---

### **ZONE 3 : Les Mini-Jeux (Les Épreuves)** 🎮

**Fichiers impliqués :**
- `lib/game/clues/game/ui/guessing_game_screen.dart`
- `lib/game/clues/game/state/guessing_game_notifier.dart`
- `lib/game/clues/data/services/communication_service.dart`

**Tables Supabase :**
- `game_data` (ou `game_cesar`, `game_clues`, etc.)

**But :** Jouer à un mini-jeu spécifique

#### Analogie 🎯
C'est comme une **épreuve de Fort Boyard** :
- Chaque jeu a ses **propres règles**
- Les joueurs **jouent en temps réel**
- À la fin, on **retourne un résultat** (gagné/perdu)

#### Code Simplifié

```dart
// Dans game_orchestrator_screen.dart

Future<GameResult?> _launchCluesGame(String sessionId) async {
  // 1. Créer un ID unique pour ce jeu
  final gameId = '${sessionId}_clues';
  
  // 2. Lancer le jeu
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => GuessingGameNotifier(gameId: gameId), // ← Lie au jeu
        child: GuessingGameScreen(gameId: gameId),
      ),
    ),
  );
  
  // 3. Le jeu retourne les scores
  // result = {'playerA_score': 1, 'playerB_score': 0}
  
  // 4. Convertir en GameResult
  return GameResult(
    gameType: 'clues',
    winnerId: playerA,  // Si A a gagné
    scores: {playerA: 1, playerB: 0},
  );
}
```

**Ce qui se passe en base :**
```sql
-- Table game_data (pendant le jeu)
game_id          | data
-----------------|--------------------------------------
sess1_clues      | {"targetWord":"CHIEN", "guess":"CHAT", "isCorrect":false}
```

---

### **ZONE 4 : Les Résultats (Le Podium)** 🏆

**Fichiers impliqués :**
- `lib/core/game_orchestrator/ui/final_results_screen.dart`

**Tables Supabase :**
- `game_results` (historique)
- `game_sessions` (scores finaux)

**But :** Afficher qui a gagné

#### Analogie 🏅
C'est comme la **cérémonie de remise des prix** :
- On **cumule** tous les scores
- On **déclare** le grand gagnant
- On affiche le **podium**

#### Code Simplifié

```dart
// Dans game_orchestrator_screen.dart

void _showFinalResults() {
  // Marquer la session comme terminée
  sessionProvider.completeSession();
  
  // Naviguer vers les résultats
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => FinalResultsScreen(sessionId: sessionId),
    ),
  );
}
```

**Ce qui se passe en base :**
```sql
-- Table game_sessions (mise à jour finale)
id      | player_scores          | status
--------|------------------------|----------
sess1   | {user1: 3, user2: 2}  | completed

-- Table game_results (historique)
id  | session_id | game_type | winner_id | scores
----|------------|-----------|-----------|------------------
1   | sess1      | clues     | user1     | {user1:1, user2:0}
2   | sess1      | caesar    | user2     | {user1:0, user2:1}
3   | sess1      | labyrinth | user1     | {user1:2, user2:1}
```

---

## 🔗 **Schéma Complet de Liaison**

```
┌─────────────────────────────────────────────────────────────┐
│                    1. CRÉATION ROOM                         │
│                                                             │
│  RoomHub → RoomProvider → Supabase                          │
│                              │                              │
│                              ▼                              │
│                    TABLE: rooms (id=abc)                    │
│                    TABLE: room_participants                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Host clique "Lancer"
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 2. CRÉATION SESSION                         │
│                                                             │
│  _playGames() → GameSessionProvider                         │
│                     │                                       │
│                     ▼                                       │
│          createSession(                                     │
│            roomId: abc,        ← LIE À LA ROOM             │
│            nbGames: 3,                                      │
│            playerIds: [user1, user2]                        │
│          )                                                  │
│                     │                                       │
│                     ▼                                       │
│          TABLE: game_sessions (id=sess1)                    │
│          {                                                  │
│            room_id: abc,       ← LIEN AVEC ROOM            │
│            games_queue: [clues, caesar, labyrinth],         │
│            current_game_index: 0,                           │
│            player_scores: {user1:0, user2:0}                │
│          }                                                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Navigation
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              3. ORCHESTRATEUR (Boucle)                      │
│                                                             │
│  Pour chaque jeu dans games_queue:                          │
│                                                             │
│    ┌─────────────────────────────────────┐                 │
│    │ 3a. Transition Screen               │                 │
│    │ "Jeu 1/3 - Clues"                   │                 │
│    └─────────────────────────────────────┘                 │
│                     │                                       │
│                     ▼                                       │
│    ┌─────────────────────────────────────┐                 │
│    │ 3b. Lancer mini-jeu                 │                 │
│    │                                     │                 │
│    │ gameId = sess1_clues  ← LIEN!       │                 │
│    │                                     │                 │
│    │ GuessingGameNotifier(gameId)        │                 │
│    │        │                            │                 │
│    │        ▼                            │                 │
│    │ CommunicationService                │                 │
│    │        │                            │                 │
│    │        ▼                            │                 │
│    │ TABLE: game_data                    │                 │
│    │ {                                   │                 │
│    │   game_id: sess1_clues  ← LIEN!     │                 │
│    │   data: {...}                       │                 │
│    │ }                                   │                 │
│    └─────────────────────────────────────┘                 │
│                     │                                       │
│                     ▼                                       │
│    ┌─────────────────────────────────────┐                 │
│    │ 3c. Jeu retourne résultat           │                 │
│    │ {playerA_score: 1, playerB_score:0} │                 │
│    └─────────────────────────────────────┘                 │
│                     │                                       │
│                     ▼                                       │
│    ┌─────────────────────────────────────┐                 │
│    │ 3d. Enregistrer résultat            │                 │
│    │                                     │                 │
│    │ TABLE: game_results                 │                 │
│    │ {                                   │                 │
│    │   session_id: sess1     ← LIEN!     │                 │
│    │   game_type: clues,                 │                 │
│    │   winner_id: user1,                 │
│    │   scores: {user1:1, user2:0}        │                 │
│    │ }                                   │                 │
│    │                                     │                 │
│    │ UPDATE game_sessions                │                 │
│    │ SET player_scores = {user1:1, ...}  │                 │
│    │     current_game_index = 1          │                 │
│    └─────────────────────────────────────┘                 │
│                     │                                       │
│                     │ Répéter pour jeu suivant              │
│                     │                                       │
└─────────────────────┼───────────────────────────────────────┘
                      │
                      │ Tous les jeux terminés
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  4. RÉSULTATS FINAUX                        │
│                                                             │
│  FinalResultsScreen                                         │
│        │                                                    │
│        ├─ Lit game_sessions.player_scores                   │
│        │  → {user1: 3, user2: 2}                            │
│        │                                                    │
│        └─ Affiche:                                          │
│           🏆 GAGNANT: user1 (3 points)                      │
│           🥈 user2 (2 points)                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 **Les Liens Clés**

### Lien 1 : **Room → Session**
```dart
createSession(
  roomId: room.id,  // ← C'est ici que se fait le lien !
  ...
)
```
→ Dans la table `game_sessions`, on stocke le `room_id`

### Lien 2 : **Session → Mini-Jeu**
```dart
final gameId = '${sessionId}_clues';  // ← Construction de l'ID
GuessingGameNotifier(gameId: gameId);
```
→ Chaque jeu a un `gameId` qui contient le `sessionId`

### Lien 3 : **Mini-Jeu → game_data**
```dart
CommunicationService(gameId: gameId);  // ← Communication avec Supabase
// → Query: WHERE game_id = 'sess1_clues'
```

### Lien 4 : **Mini-Jeu → game_results**
```dart
await saveGameResult(
  sessionId: sessionId,  // ← Lien avec la session
  result: GameResult(...),
);
```
→ Dans la table `game_results`, on stocke le `session_id`

---

## 📊 **Résumé des Identifiants**

| Niveau | ID | Exemple | Usage |
|--------|----|---------|----|
| Room | `room.id` | `abc-123` | Identifie le salon |
| Session | `session.id` | `sess-456` | Identifie la série de jeux |
| Mini-Jeu | `gameId` | `sess-456_clues` | Identifie une instance de jeu |

**Chaîne complète :**
```
room(abc) 
  → game_session(sess-456) {room_id: abc}
    → game_data {game_id: sess-456_clues}
    → game_results {session_id: sess-456}
```

---

## 🎓 **Explication Simple**

Imaginez que vous organisez une **soirée jeux** :

1. **La Room** = Votre salon où les invités arrivent
2. **La Session** = Le planning de la soirée (Jeu 1, 2, 3...)
3. **Les Mini-Jeux** = Chaque jeu individuel (Monopoly, Uno, etc.)
4. **Les Résultats** = Le carnet de scores final

**Liens :**
- Votre salon (room) → a un planning (session)
- Le planning (session) → contient plusieurs jeux (games)
- Chaque jeu (game) → produit un score (result)
- Les scores (results) → sont cumulés dans le planning (session)

---

## ✅ **Checklist de Compréhension**

- [ ] Je comprends à quoi sert chaque table
- [ ] Je comprends comment room → session sont liés
- [ ] Je comprends comment session → game sont liés
- [ ] Je comprends comment game → game_data sont liés
- [ ] Je comprends le flux complet Room → Résultats

**Avez-vous des questions sur une partie spécifique ?** 🤔
