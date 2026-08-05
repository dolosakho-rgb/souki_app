
-- KHAYMIA Consumer Marketplace Foundation
-- Migration 0003
-- Ajout couche marketplace consommateur sans regression B2B

BEGIN;

-- Activation catalogue marketplace
ALTER TABLE public.produits
ADD COLUMN IF NOT EXISTS actif boolean DEFAULT true NOT NULL;


-- Catalogue spécifique par boutique
CREATE TABLE IF NOT EXISTS public.boutique_produits (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    boutique_id uuid NOT NULL REFERENCES public.boutiquiers(id) ON DELETE CASCADE,
    produit_id uuid NOT NULL REFERENCES public.produits(id) ON DELETE CASCADE,
    prix_vente numeric NOT NULL,
    stock_disponible integer DEFAULT 0,
    actif boolean DEFAULT true NOT NULL,
    created_at timestamptz DEFAULT now(),
    UNIQUE(boutique_id, produit_id)
);


CREATE INDEX IF NOT EXISTS idx_boutique_produits_boutique
ON public.boutique_produits(boutique_id);


CREATE INDEX IF NOT EXISTS idx_boutique_produits_produit
ON public.boutique_produits(produit_id);


COMMIT;
