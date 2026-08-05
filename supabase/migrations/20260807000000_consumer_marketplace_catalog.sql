-- KHAYMIA Consumer Marketplace Catalog
-- Migration 0005
-- Vue catalogue consommateur sécurisée

BEGIN;

CREATE OR REPLACE VIEW public.consumer_marketplace_catalog AS
SELECT
    bp.id AS offre_id,
    b.id AS boutique_id,
    b.boutique_nom,
    p.id AS produit_id,
    p.nom AS produit_nom,
    p.description,
    p.image_url,
    bp.prix_vente,
    bp.stock_disponible
FROM public.boutique_produits bp
JOIN public.boutiquiers b
    ON b.id = bp.boutique_id
JOIN public.produits p
    ON p.id = bp.produit_id
WHERE
    b.statut = 'actif'
    AND bp.actif = true
    AND p.actif = true
    AND bp.stock_disponible > 0;

COMMIT;
