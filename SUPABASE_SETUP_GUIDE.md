# Guide de Configuration Supabase 🗄️

## Étapes pour configurer les tables de jeu

### 1. Accéder à Supabase

1. Ouvrez votre projet Supabase
2. Allez dans l'onglet **SQL Editor**
3. Créez une nouvelle requête

### 2. Exécuter le script

Copiez-collez le contenu du fichier `supabase_setup_game_sessions.sql` et exécutez-le.

Ou exécutez les commandes suivantes une par une :

#### Créer la table game_sessions

```sql
CREATE TABLE IF NOT EXISTS game_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  games_queue JSONB NOT NULL DEFAULT '[]'::jsonb,
  current_game_index INTEGER NOT NULL DEFAULT 0,
  player_scores JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Créer la table game_results

```sql
CREATE TABLE IF NOT EXISTS game_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
  game_type TEXT NOT NULL,
  winner_id UUID,
  scores JSONB NOT NULL DEFAULT '{}'::jsonb,
  additional_data JSONB,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Créer les index

```sql
CREATE INDEX IF NOT EXISTS idx_game_sessions_room_id ON game_sessions(room_id);
CREATE INDEX IF NOT EXISTS idx_game_sessions_status ON game_sessions(status);
CREATE INDEX IF NOT EXISTS idx_game_results_session_id ON game_results(session_id);
```

#### Activer RLS

```sql
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_results ENABLE ROW LEVEL SECURITY;
```

#### Créer les policies

```sql
-- game_sessions
CREATE POLICY "Enable read access for authenticated users" ON game_sessions
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert access for authenticated users" ON game_sessions
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update access for authenticated users" ON game_sessions
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete access for authenticated users" ON game_sessions
    FOR DELETE USING (auth.role() = 'authenticated');

-- game_results
CREATE POLICY "Enable read access for authenticated users" ON game_results
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert access for authenticated users" ON game_results
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

#### Activer le temps réel

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE game_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE game_results;
```

### 3. Vérification

Exécutez cette requête pour vérifier que tout est en place :

```sql
SELECT 
  table_name,
  (SELECT count(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
  AND table_name IN ('game_sessions', 'game_results');
```

Résultat attendu :
```
table_name      | column_count
----------------|-------------
game_sessions   | 8
game_results    | 7
```

### 4. Test de la structure

Testez que vous pouvez insérer des données :

```sql
-- Test insertion session
INSERT INTO game_sessions (room_id, games_queue, player_scores, status)
VALUES (
  (SELECT id FROM rooms LIMIT 1), -- Utilisez un room_id existant
  '[{"game_type": "clues", "order": 0}]'::jsonb,
  '{"test_player": 0}'::jsonb,
  'pending'
) RETURNING *;

-- Vérification
SELECT * FROM game_sessions ORDER BY created_at DESC LIMIT 1;

-- Nettoyage du test
DELETE FROM game_sessions WHERE status = 'pending' AND player_scores::text LIKE '%test_player%';
```

### 5. Vérifier le temps réel

Dans Supabase, allez dans **Database** > **Replication** et assurez-vous que :
- ✅ `game_sessions` est dans la liste des tables répliquées
- ✅ `game_results` est dans la liste des tables répliquées

## ⚠️ Troubleshooting

### Erreur : "relation already exists"

Si les tables existent déjà, supprimez-les d'abord :

```sql
DROP TABLE IF EXISTS game_results CASCADE;
DROP TABLE IF EXISTS game_sessions CASCADE;

-- Puis réexécutez le script de création
```

### Erreur : "permission denied"

Vérifiez que vous êtes connecté en tant qu'administrateur du projet Supabase.

### Les policies ne fonctionnent pas

Vérifiez que RLS est activé :

```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('game_sessions', 'game_results');
```

Les deux doivent avoir `rowsecurity = true`.

## 📊 Structure des données

### game_sessions

| Colonne              | Type      | Description                          |
|---------------------|-----------|--------------------------------------|
| id                  | UUID      | Identifiant unique                   |
| room_id             | UUID      | Référence à la room                  |
| games_queue         | JSONB     | Liste des jeux à jouer               |
| current_game_index  | INTEGER   | Index du jeu en cours (0-based)      |
| player_scores       | JSONB     | Scores globaux {user_id: points}     |
| status              | TEXT      | 'pending', 'in_progress', 'completed'|
| created_at          | TIMESTAMP | Date de création                     |
| updated_at          | TIMESTAMP | Date de dernière modification        |

### game_results

| Colonne         | Type      | Description                          |
|----------------|-----------|--------------------------------------|
| id             | UUID      | Identifiant unique                   |
| session_id     | UUID      | Référence à game_sessions            |
| game_type      | TEXT      | Type de jeu ('clues', 'caesar', etc.)|
| winner_id      | UUID      | ID du gagnant (NULL si égalité)      |
| scores         | JSONB     | Scores du jeu {user_id: points}      |
| additional_data| JSONB     | Données supplémentaires (optionnel)  |
| completed_at   | TIMESTAMP | Date de fin du jeu                   |

## ✅ Configuration terminée !

Une fois toutes ces étapes complétées, votre base de données est prête à gérer les sessions de mini-jeux. 🎉
