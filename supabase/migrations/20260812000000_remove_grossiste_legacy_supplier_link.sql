-- KHAYMIA
-- Remove legacy grossiste -> fournisseur direct link
-- The relationship is now represented exclusively by
-- public.fournisseur_grossistes.

BEGIN;

-- ============================================================
-- 1. SUPPRIMER L'ANCIENNE CONTRAINTE
-- ============================================================

ALTER TABLE public.grossistes
DROP CONSTRAINT IF EXISTS grossistes_fournisseur_id_fkey;

-- ============================================================
-- 2. SUPPRIMER L'ANCIEN INDEX HISTORIQUE
-- ============================================================

DROP INDEX IF EXISTS public.idx_grossistes_fournisseur;

-- ============================================================
-- 3. SUPPRIMER L'ANCIENNE COLONNE
-- ============================================================

ALTER TABLE public.grossistes
DROP COLUMN IF EXISTS fournisseur_id;

COMMIT;
