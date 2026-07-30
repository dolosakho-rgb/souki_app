-- Migration: 001_create_users_consommateurs.sql
-- Objectif: fondations compte unifie (Option C), sans impact sur boutiquiers existants

-- ============================================
-- TABLE users
-- ============================================

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id uuid UNIQUE NOT NULL,
  telephone text UNIQUE NOT NULL,
  prenom text NOT NULL,
  nom text NOT NULL,
  langue_preferee text NOT NULL DEFAULT 'fr'
    CHECK (langue_preferee IN ('fr', 'ar', 'pul', 'snk', 'wo')),
  ville_id uuid REFERENCES villes(id),
  zone_livraison_id uuid REFERENCES zones_livraison(id),
  statut_compte text NOT NULL DEFAULT 'actif'
    CHECK (statut_compte IN ('actif', 'en_attente', 'bloque')),
  roles text[] NOT NULL DEFAULT '{}'
    CHECK (roles <@ ARRAY['consommateur','boutiquier','livreur','restaurant','admin']::text[]),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================
-- TABLE consommateurs
-- ============================================

CREATE TABLE consommateurs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE NOT NULL REFERENCES users(id),
  adresse_complement text,
  points_fidelite integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================
-- INDEX
-- ============================================

CREATE INDEX users_ville_id_idx ON users(ville_id);
CREATE INDEX users_zone_livraison_id_idx ON users(zone_livraison_id);
CREATE INDEX users_roles_idx ON users USING GIN(roles);

-- ============================================
-- TRIGGER updated_at (fonction generique reutilisable)
-- ============================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $func$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$func$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trigger_consommateurs_updated_at
BEFORE UPDATE ON consommateurs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- ============================================
-- RLS
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE consommateurs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_voit_son_propre_compte"
ON users FOR SELECT
USING (auth.uid() = auth_user_id);

CREATE POLICY "user_modifie_son_propre_compte"
ON users FOR UPDATE
USING (auth.uid() = auth_user_id)
WITH CHECK (auth.uid() = auth_user_id);

CREATE POLICY "user_cree_son_propre_compte"
ON users FOR INSERT
WITH CHECK (auth.uid() = auth_user_id);

CREATE POLICY "admins_select_all_users"
ON users FOR SELECT
USING (auth.uid() IN (SELECT auth_user_id FROM admins));

CREATE POLICY "consommateur_voit_son_profil"
ON consommateurs FOR SELECT
USING (user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid()));

CREATE POLICY "consommateur_modifie_son_profil"
ON consommateurs FOR UPDATE
USING (user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid()))
WITH CHECK (user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid()));

CREATE POLICY "consommateur_cree_son_profil"
ON consommateurs FOR INSERT
WITH CHECK (user_id IN (SELECT id FROM users WHERE auth_user_id = auth.uid()));

CREATE POLICY "admins_select_all_consommateurs"
ON consommateurs FOR SELECT
USING (auth.uid() IN (SELECT auth_user_id FROM admins));
