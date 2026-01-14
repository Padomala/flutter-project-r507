-- Script SQL pour créer les tables de gestion de sessions de jeux
-- À exécuter dans l'éditeur SQL de Supabase

-- Table des sessions de jeu (orchestration des mini-jeux)
CREATE TABLE IF NOT EXISTS game_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  games_queue JSONB NOT NULL DEFAULT '[]'::jsonb, -- Liste des GameConfig [{game_type, order, settings}]
  current_game_index INTEGER NOT NULL DEFAULT 0,
  player_scores JSONB NOT NULL DEFAULT '{}'::jsonb, -- {user_id: score}
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'in_progress', 'completed'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des résultats de chaque mini-jeu
CREATE TABLE IF NOT EXISTS game_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES game_sessions(id) ON DELETE CASCADE,
  game_type TEXT NOT NULL,
  winner_id UUID, -- NULL si égalité
  scores JSONB NOT NULL DEFAULT '{}'::jsonb, -- {user_id: points}
  additional_data JSONB, -- Données supplémentaires (stats, etc.)
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_game_sessions_room_id ON game_sessions(room_id);
CREATE INDEX IF NOT EXISTS idx_game_sessions_status ON game_sessions(status);
CREATE INDEX IF NOT EXISTS idx_game_results_session_id ON game_results(session_id);

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour game_sessions
DROP TRIGGER IF EXISTS update_game_sessions_updated_at ON game_sessions;
CREATE TRIGGER update_game_sessions_updated_at
    BEFORE UPDATE ON game_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_results ENABLE ROW LEVEL SECURITY;

-- Policies pour game_sessions (tous les utilisateurs authentifiés peuvent lire/écrire)
CREATE POLICY "Enable read access for authenticated users" ON game_sessions
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert access for authenticated users" ON game_sessions
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update access for authenticated users" ON game_sessions
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete access for authenticated users" ON game_sessions
    FOR DELETE USING (auth.role() = 'authenticated');

-- Policies pour game_results (tous les utilisateurs authentifiés peuvent lire/écrire)
CREATE POLICY "Enable read access for authenticated users" ON game_results
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert access for authenticated users" ON game_results
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Activer le temps réel sur les tables
ALTER PUBLICATION supabase_realtime ADD TABLE game_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE game_results;

-- Vérification
SELECT 'game_sessions table created successfully' as status;
SELECT 'game_results table created successfully' as status;
