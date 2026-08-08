-- KHAYMIA
-- Protection des profils professionnels
-- Fournisseurs + Grossistes
--
-- Principe :
-- users = identité personnelle / compte
-- fournisseurs = identité commerciale fournisseur
-- grossistes = identité commerciale grossiste
--
-- L'acteur peut modifier ses informations commerciales.
-- L'acteur ne peut jamais modifier :
--   - id
--   - auth_user_id
--   - statut
--
-- Seul un administrateur peut modifier le statut.

BEGIN;

-- ============================================================
-- 1. FONCTION DE PROTECTION FOURNISSEUR
-- ============================================================

CREATE OR REPLACE FUNCTION public.protect_fournisseur_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
BEGIN
    -- Un administrateur peut effectuer les changements
    -- nécessaires à la gestion du profil.
    IF EXISTS (
        SELECT 1
        FROM public.admins
        WHERE admins.auth_user_id = auth.uid()
    ) THEN
        RETURN NEW;
    END IF;

    -- Un fournisseur ne peut pas changer son identité technique.
    IF NEW.id <> OLD.id THEN
        RAISE EXCEPTION
            'Impossible de modifier l''identifiant du fournisseur';
    END IF;

    IF NEW.auth_user_id <> OLD.auth_user_id THEN
        RAISE EXCEPTION
            'Impossible de modifier le compte Auth du fournisseur';
    END IF;

    -- Un fournisseur ne peut pas modifier son statut.
    IF NEW.statut <> OLD.statut THEN
        RAISE EXCEPTION
            'Le statut du fournisseur est géré uniquement par un administrateur';
    END IF;

    RETURN NEW;
END;
$function$;


-- ============================================================
-- 2. FONCTION DE PROTECTION GROSSISTE
-- ============================================================

CREATE OR REPLACE FUNCTION public.protect_grossiste_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
BEGIN
    -- Un administrateur peut effectuer les changements
    -- nécessaires à la gestion du profil.
    IF EXISTS (
        SELECT 1
        FROM public.admins
        WHERE admins.auth_user_id = auth.uid()
    ) THEN
        RETURN NEW;
    END IF;

    -- Un grossiste ne peut pas changer son identité technique.
    IF NEW.id <> OLD.id THEN
        RAISE EXCEPTION
            'Impossible de modifier l''identifiant du grossiste';
    END IF;

    IF NEW.auth_user_id <> OLD.auth_user_id THEN
        RAISE EXCEPTION
            'Impossible de modifier le compte Auth du grossiste';
    END IF;

    -- Un grossiste ne peut pas modifier son statut.
    IF NEW.statut <> OLD.statut THEN
        RAISE EXCEPTION
            'Le statut du grossiste est géré uniquement par un administrateur';
    END IF;

    RETURN NEW;
END;
$function$;


-- ============================================================
-- 3. TRIGGER FOURNISSEUR
-- ============================================================

DROP TRIGGER IF EXISTS trigger_protect_fournisseur_profile
ON public.fournisseurs;

CREATE TRIGGER trigger_protect_fournisseur_profile
BEFORE UPDATE ON public.fournisseurs
FOR EACH ROW
EXECUTE FUNCTION public.protect_fournisseur_profile();


-- ============================================================
-- 4. TRIGGER GROSSISTE
-- ============================================================

DROP TRIGGER IF EXISTS trigger_protect_grossiste_profile
ON public.grossistes;

CREATE TRIGGER trigger_protect_grossiste_profile
BEFORE UPDATE ON public.grossistes
FOR EACH ROW
EXECUTE FUNCTION public.protect_grossiste_profile();


COMMIT;
