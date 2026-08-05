-- KHAYMIA Consumer Marketplace RLS
-- Migration 0004
-- Sécurisation accès marketplace consommateur

BEGIN;

ALTER TABLE public.boutique_produits
ENABLE ROW LEVEL SECURITY;


-- Consommateurs : voir uniquement les offres actives
CREATE POLICY "Lecture publique offres boutique actives"
ON public.boutique_produits
FOR SELECT
USING (
    actif = true
);


-- Boutiquier : gérer ses propres offres
CREATE POLICY "Boutiquier gere ses offres"
ON public.boutique_produits
FOR ALL
USING (
    boutique_id IN (
        SELECT id
        FROM public.boutiquiers
        WHERE auth_user_id = auth.uid()
    )
)
WITH CHECK (
    boutique_id IN (
        SELECT id
        FROM public.boutiquiers
        WHERE auth_user_id = auth.uid()
    )
);


COMMIT;
