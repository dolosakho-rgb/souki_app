-- KHAYMIA
-- Professional Actors RLS
-- Fournisseurs + Grossistes indépendants
-- Migration additive

BEGIN;

-- ============================================================
-- 1. ACTIVER RLS
-- ============================================================

ALTER TABLE public.fournisseurs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grossistes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fournisseur_grossistes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fournisseur_produits ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- 2. FOURNISSEUR — SON PROPRE PROFIL
-- ============================================================

CREATE POLICY "fournisseur_voit_son_profil"
ON public.fournisseurs
FOR SELECT
USING (
    auth_user_id = auth.uid()
);

CREATE POLICY "fournisseur_modifie_son_profil"
ON public.fournisseurs
FOR UPDATE
USING (
    auth_user_id = auth.uid()
)
WITH CHECK (
    auth_user_id = auth.uid()
);


-- ============================================================
-- 3. FOURNISSEUR — SES PRODUITS
-- ============================================================

CREATE POLICY "fournisseur_voit_ses_produits"
ON public.fournisseur_produits
FOR SELECT
USING (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "fournisseur_cree_ses_produits"
ON public.fournisseur_produits
FOR INSERT
WITH CHECK (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "fournisseur_modifie_ses_produits"
ON public.fournisseur_produits
FOR UPDATE
USING (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
)
WITH CHECK (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "fournisseur_supprime_ses_produits"
ON public.fournisseur_produits
FOR DELETE
USING (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
);


-- ============================================================
-- 4. GROSSISTE — SON PROPRE PROFIL
-- ============================================================

CREATE POLICY "grossiste_voit_son_profil"
ON public.grossistes
FOR SELECT
USING (
    auth_user_id = auth.uid()
);

CREATE POLICY "grossiste_modifie_son_profil"
ON public.grossistes
FOR UPDATE
USING (
    auth_user_id = auth.uid()
)
WITH CHECK (
    auth_user_id = auth.uid()
);


-- ============================================================
-- 5. RELATION FOURNISSEUR ↔ GROSSISTE
-- ============================================================

CREATE POLICY "fournisseur_voit_ses_relations"
ON public.fournisseur_grossistes
FOR SELECT
USING (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
);

CREATE POLICY "fournisseur_cree_relation"
ON public.fournisseur_grossistes
FOR INSERT
WITH CHECK (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
    AND statut = 'en_attente'
);

CREATE POLICY "fournisseur_supprime_relation"
ON public.fournisseur_grossistes
FOR DELETE
USING (
    fournisseur_id IN (
        SELECT id
        FROM public.fournisseurs
        WHERE auth_user_id = auth.uid()
    )
);


-- ============================================================
-- 6. GROSSISTE — SES RELATIONS
-- ============================================================

CREATE POLICY "grossiste_voit_ses_relations"
ON public.fournisseur_grossistes
FOR SELECT
USING (
    grossiste_id IN (
        SELECT id
        FROM public.grossistes
        WHERE auth_user_id = auth.uid()
    )
);


-- ============================================================
-- 7. GROSSISTE — CATALOGUE FOURNISSEUR
-- ============================================================

CREATE POLICY "grossiste_voit_produits_fournisseurs_lies"
ON public.fournisseur_produits
FOR SELECT
USING (
    fournisseur_id IN (
        SELECT fg.fournisseur_id
        FROM public.fournisseur_grossistes fg
        WHERE fg.grossiste_id IN (
            SELECT g.id
            FROM public.grossistes g
            WHERE g.auth_user_id = auth.uid()
        )
        AND fg.statut = 'actif'
    )
);


-- ============================================================
-- 8. GROSSISTE — ACCEPTER / REFUSER UNE RELATION
-- ============================================================

CREATE POLICY "grossiste_modifie_ses_relations"
ON public.fournisseur_grossistes
FOR UPDATE
USING (
    grossiste_id IN (
        SELECT id
        FROM public.grossistes
        WHERE auth_user_id = auth.uid()
    )
)
WITH CHECK (
    grossiste_id IN (
        SELECT id
        FROM public.grossistes
        WHERE auth_user_id = auth.uid()
    )
);


-- ============================================================
-- 9. PROTECTION DE L'IDENTITE DE LA RELATION
-- ============================================================

CREATE OR REPLACE FUNCTION public.protect_fournisseur_grossiste_identity()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.fournisseur_id <> OLD.fournisseur_id
       OR NEW.grossiste_id <> OLD.grossiste_id THEN
        RAISE EXCEPTION 'Impossible de modifier le fournisseur ou le grossiste d''une relation existante';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_protect_fournisseur_grossiste_identity
ON public.fournisseur_grossistes;

CREATE TRIGGER trigger_protect_fournisseur_grossiste_identity
BEFORE UPDATE ON public.fournisseur_grossistes
FOR EACH ROW
EXECUTE FUNCTION public.protect_fournisseur_grossiste_identity();

COMMIT;
