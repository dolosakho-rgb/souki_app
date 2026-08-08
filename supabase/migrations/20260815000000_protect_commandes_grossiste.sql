-- KHAYMIA
-- Protect commandes.grossiste_id and fournisseur_type consistency

ALTER TABLE public.commandes
    ADD CONSTRAINT commandes_grossiste_id_fkey
    FOREIGN KEY (grossiste_id)
    REFERENCES public.grossistes(id);

ALTER TABLE public.commandes
    ADD CONSTRAINT commandes_fournisseur_grossiste_coherence_check
    CHECK (
        (fournisseur_type = 'khaymia' AND grossiste_id IS NULL)
        OR
        (fournisseur_type = 'grossiste_partenaire' AND grossiste_id IS NOT NULL)
    );
