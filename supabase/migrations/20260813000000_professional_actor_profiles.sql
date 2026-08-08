-- KHAYMIA
-- Professional Actor Profiles
--
-- Principe :
-- users = identité personnelle / compte
-- fournisseurs = identité commerciale fournisseur
-- grossistes = identité commerciale grossiste
-- fournisseur_grossistes = relation commerciale
--
-- Les nouveaux acteurs professionnels commencent en attente
-- et doivent être validés avant de devenir actifs.

BEGIN;

-- ============================================================
-- 1. FOURNISSEURS — STATUT
-- ============================================================

ALTER TABLE public.fournisseurs
    DROP CONSTRAINT IF EXISTS fournisseurs_statut_check;

ALTER TABLE public.fournisseurs
    ADD CONSTRAINT fournisseurs_statut_check
    CHECK (
        statut IN (
            'en_attente',
            'actif',
            'inactif',
            'bloque'
        )
    );

ALTER TABLE public.fournisseurs
    ALTER COLUMN statut SET DEFAULT 'en_attente';

-- ============================================================
-- 2. FOURNISSEURS — IDENTITÉ PROFESSIONNELLE
-- ============================================================

-- Un fournisseur professionnel possède obligatoirement
-- un compte Auth.
ALTER TABLE public.fournisseurs
    ALTER COLUMN auth_user_id SET NOT NULL;

-- Informations commerciales essentielles obligatoires.
ALTER TABLE public.fournisseurs
    ALTER COLUMN raison_sociale SET NOT NULL,
    ALTER COLUMN adresse_commerciale SET NOT NULL,
    ALTER COLUMN zone SET NOT NULL;

-- La ville est obligatoire.
ALTER TABLE public.fournisseurs
    ALTER COLUMN ville_id SET NOT NULL;

-- ============================================================
-- 3. GROSSISTES — STATUT
-- ============================================================

ALTER TABLE public.grossistes
    DROP CONSTRAINT IF EXISTS grossistes_statut_check;

ALTER TABLE public.grossistes
    ADD CONSTRAINT grossistes_statut_check
    CHECK (
        statut IN (
            'en_attente',
            'actif',
            'inactif',
            'bloque'
        )
    );

ALTER TABLE public.grossistes
    ALTER COLUMN statut SET DEFAULT 'en_attente';

-- ============================================================
-- 4. GROSSISTES — LOCALISATION
-- ============================================================

ALTER TABLE public.grossistes
    ADD COLUMN IF NOT EXISTS ville_id uuid;

-- ============================================================
-- 5. GROSSISTES — IDENTITÉ PROFESSIONNELLE
-- ============================================================

-- Un grossiste professionnel possède obligatoirement
-- un compte Auth.
ALTER TABLE public.grossistes
    ALTER COLUMN auth_user_id SET NOT NULL;

-- Informations commerciales essentielles obligatoires.
ALTER TABLE public.grossistes
    ALTER COLUMN raison_sociale SET NOT NULL,
    ALTER COLUMN adresse_commerciale SET NOT NULL,
    ALTER COLUMN zone SET NOT NULL;

-- La ville est obligatoire.
ALTER TABLE public.grossistes
    ALTER COLUMN ville_id SET NOT NULL;

-- ============================================================
-- 6. GROSSISTES → VILLES
-- ============================================================

ALTER TABLE public.grossistes
    DROP CONSTRAINT IF EXISTS grossistes_ville_id_fkey;

ALTER TABLE public.grossistes
    ADD CONSTRAINT grossistes_ville_id_fkey
    FOREIGN KEY (ville_id)
    REFERENCES public.villes(id);

COMMIT;
