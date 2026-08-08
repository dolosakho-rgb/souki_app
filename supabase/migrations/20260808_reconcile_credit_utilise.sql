-- Réconciliation des compteurs historiques credit_utilise.
-- Ne modifie aucune commande.
-- Le trigger trg_ajuster_credit_utilise reste inchangé.

UPDATE public.boutiquiers b
SET credit_utilise = COALESCE(
    (
        SELECT SUM(c.total)
        FROM public.commandes c
        WHERE c.boutiquier_id = b.id
          AND c.consommateur_id IS NULL
          AND c.statut IS DISTINCT FROM 'annulee'
    ),
    0
)
WHERE b.id IN (
    'd1cdaefd-8190-44ae-849c-601d38502425',
    '678ad3fa-76e0-4b5a-b118-dfdabec14072'
);
