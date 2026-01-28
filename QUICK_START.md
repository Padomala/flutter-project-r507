# 🚀 Guide de Démarrage Rapide

## Système d'orchestration des mini-jeux - Prêt à l'emploi !

### ✅ Ce qui est fait

- **Architecture complète** : Modèles, services, providers, UI
- **Écrans** : Transitions animées, résultats avec confettis
- **Intégration** : Connexion avec RoomHub
- **Jeu Clues** : Entièrement fonctionnel
- **Compilation** : Tout fonctionne sans erreur

---

## 📝 Étape 1 : Configurer Supabase (OBLIGATOIRE)

### Option A : Script complet

1. Ouvrez votre projet Supabase
2. Allez dans **SQL Editor**
3. Copiez-collez tout le contenu de `supabase_setup_game_sessions.sql`
4. Cliquez sur **Run**

### Option B : Commandes SQL individuelles

Consultez `SUPABASE_SETUP_GUIDE.md` pour exécuter les commandes une par une.

### Vérification

Exécutez cette requête :
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_name IN ('game_sessions', 'game_results');
```

Vous devriez voir 2 tables.

---

## 🎮 Étape 2 : Tester le Système

### 1. Créer une Room

```
Dans l'app :
1. Connectez-vous avec 2 comptes (2 appareils ou émulateurs)
2. Joueur 1 : Créez une partie (définissez nb_games)
3. Joueur 2 : Rejoignez avec le code
```

### 2. Lancer la Partie

```
1. Host clique "Lancer la Partie"
   → Création de la session
   
2. Navigation automatique :
   → GameOrchestratorScreen
   
3. Pour chaque jeu :
   → TransitionScreen (3, 2, 1...)
   → Jeu (ex: Clues)
   → Scores mis à jour
   
4. Fin :
   → FinalResultsScreen (confettis + classement)
```

### 3. Ce que vous verrez

- ✨ **Transition animée** avec countdown
- 🎲 **Jeu Clues** (Devine le Mot)
- 🏆 **Écran de résultats** avec confettis
- 📊 **Scores finaux** et gagnant

---

## 🔧 Étape 3 : Ajouter d'Autres Jeux (Optionnel)

### Pour Caesar

Consultez `CORRECTIONS_APPLIED.md` section "Pour intégrer Caesar".

En résumé :
1. Choisissez quelle page Caesar utiliser
2. Décommentez l'import dans `game_orchestrator_screen.dart`
3. Mettez à jour `_launchCaesarGame()`
4. Adaptez le jeu pour retourner un résultat

### Pour Labyrinthe

Même processus que Caesar :
1. Créez le jeu dans `lib/game/labyrinthe/`
2. Ajoutez-le dans `_navigateToGame()`
3. Retournez un `GameResult` à la fin

---

## 📚 Documentation Complète

- **Architecture détaillée** : `GAME_ORCHESTRATOR_README.md`
- **Setup Supabase** : `SUPABASE_SETUP_GUIDE.md`
- **Corrections** : `CORRECTIONS_APPLIED.md`

---

## ⚠️ Points d'Attention

### 1. Supabase OBLIGATOIRE

Sans les tables `game_sessions` et `game_results`, l'app crashera.

### 2. Nombre de Joueurs

Le système est conçu pour **2 joueurs**. Pour plus, adaptez la logique de scoring.

### 3. Jeux Disponibles

Actuellement fonctionnel :
- ✅ **Clues** (Devine le Mot)
- ⏳ **Caesar** (structure existe, pas intégré)
- ⏳ **Labyrinthe** (à créer)

---

## 🐛 Debugging

### L'app ne lance pas de jeux

Vérifiez dans la console :
```
✅ Session créée: abc-123
```

Si vous ne voyez pas ce message :
- Vérifiez que les tables Supabase existent
- Vérifiez que `GameSessionProvider` est dans `app_providers.dart`

### Erreur "Table not found"

Vous n'avez pas exécuté le script SQL. Retournez à l'Étape 1.

### Les deux joueurs ne voient pas la même chose

- Vérifiez la connexion internet
- Vérifiez que Realtime est activé sur Supabase
- Relancez l'app

---

## 🎯 Workflow de Jeu

```
┌─────────────┐
│  RoomHub    │ Host clique "Lancer"
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ GameSessionProvider │ Crée session + jeux aléatoires
└──────┬──────────────┘
       │
       ▼
┌────────────────────┐
│ GameOrchestrator   │ Gère le flux
└──────┬─────────────┘
       │
       ▼ (Pour chaque jeu)
┌──────────────┐
│ Transition   │ 3...2...1...
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Mini-jeu     │ (Clues, Caesar, etc.)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ GameResult   │ Scores mis à jour
└──────┬───────┘
       │
       ▼ (Jeu suivant ou...)
┌──────────────┐
│ FinalResults │ 🎊 Gagnant + Confettis
└──────────────┘
```

---

## ✨ Fonctionnalités Implémentées

- [x] Création de session multi-jeux
- [x] Sélection aléatoire des jeux
- [x] Transitions animées
- [x] Scoring automatique
- [x] Synchronisation temps réel
- [x] Écran de résultats avec confettis
- [x] Gestion des erreurs
- [x] Support 2 joueurs
- [x] Integration avec RoomHub

---

## 🎉 C'est Prêt !

**Exécutez le script SQL et testez !** 🚀

Si vous avez des questions, consultez la documentation complète ou vérifiez les fichiers de debug.

Bon jeu ! 🎮✨
