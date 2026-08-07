-- KHAYMIA Phase 1
-- Professional Actors Foundation
-- Fournisseurs + Grossistes indépendants
-- Migration additive et rétrocompatible

BEGIN;

-- ============================================================
-- 1. FOURNISSEURS
-- ============================================================

ALTER TABLE public.fournisseurs
ADD COLUMN IF NOT EXISTS auth_user_id uuid
REFERENCES auth.users(id);

ALTER TABLE public.fournisseurs
ADD COLUMN IF NOT EXISTS raison_sociale text;

ALTER TABLE public.fournisseurs
ADD COLUMN IF NOT EXISTS adresse_commerciale text;

ALTER TABLE public.fournisseurs
ADD COLUMN IF NOT EXISTS zone text;

CREATE UNIQUE INDEX IF NOT EXISTS idx_fournisseurs_auth_user
ON public.fournisseurs(auth_user_id)
WHERE auth_user_id IS NOT NULL;


-- ============================================================
-- 2. GROSSISTES
-- ============================================================

ALTER TABLE public.grossistes
ADD COLUMN IF NOT EXISTS auth_user_id uuid
REFERENCES auth.users(id);

ALTER TABLE public.grossistes
ADD COLUMN IF NOT EXISTS raison_sociale text;

ALTER TABLE public.grossistes
ADD COLUMN IF NOT EXISTS adresse_commerciale text;

ALTER TABLE public.grossistes
ALTER COLUMN fournisseur_id DROP NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_grossistes_auth_user
ON public.grossistes(auth_user_id)
WHERE auth_user_id IS NOT NULL;


-- ============================================================
-- 3. RELATION FOURNISSEUR ↔ GROSSISTE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.fournisseur_grossistes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    fournisseur_id uuid NOT NULL
        REFERENCES public.fournisseurs(id)
        ON DELETE CASCADE,

    grossiste_id uuid NOT NULL
        REFERENCES public.grossistes(id)
        ON DELETE CASCADE,

    statut text DEFAULT 'actif' NOT NULL,

    conditions_commerciales text,

    created_at timestamptz DEFAULT now(),

    updated_at timestamptz DEFAULT now(),

    CONSTRAINT fournisseur_grossistes_statut_check
    CHECK (statut IN ('en_attente','actif','inactif','bloque')),

    UNIQUE(fournisseur_id, grossiste_id)
);

CREATE INDEX IF NOT EXISTS idx_fournisseur_grossistes_fournisseur
ON public.fournisseur_grossistes(fournisseur_id);

CREATE INDEX IF NOT EXISTS idx_fournisseur_grossistes_grossiste
ON public.fournisseur_grossistes(grossiste_id);


-- ============================================================
-- 4. MISE À JOUR DES RÔLES PROFESSIONNELS
-- ============================================================

ALTER TABLE public.users
DROP CONSTRAINT IF EXISTS users_roles_check;

ALTER TABLE public.users
ADD CONSTRAINT users_roles_check
CHECK (
    roles <@ ARRAY[
        'consommateur',
        'boutiquier',
        'livreur',
        'restaurant',
        'admin',
        'grossiste',
        'fournisseur'
    ]::text[]
);


-- ============================================================
-- 5. UPDATED_AT
-- ============================================================

DROP TRIGGER IF EXISTS trigger_fournisseur_grossistes_updated_at ON public.fournisseur_grossistes;
CREATE TRIGGER trigger_fournisseur_grossistes_updated_at
BEFORE UPDATE ON public.fournisseur_grossistes
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

COMMIT;
