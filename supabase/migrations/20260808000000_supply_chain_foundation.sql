-- KHAYMIA Supply Chain Foundation
-- Fournisseurs + Grossistes + Catalogue achat + Approvisionnement

BEGIN;

CREATE TABLE IF NOT EXISTS public.fournisseurs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    nom text NOT NULL,
    telephone text,
    adresse text,
    ville_id uuid REFERENCES public.villes(id),
    statut text DEFAULT 'actif' NOT NULL,
    created_at timestamptz DEFAULT now(),

    CONSTRAINT fournisseurs_statut_check
    CHECK (statut IN ('actif','inactif','bloque'))
);

CREATE INDEX IF NOT EXISTS idx_fournisseurs_ville
ON public.fournisseurs(ville_id);


CREATE TABLE IF NOT EXISTS public.grossistes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    fournisseur_id uuid NOT NULL
    REFERENCES public.fournisseurs(id)
    ON DELETE CASCADE,

    zone text,
    conditions_paiement text,

    statut text DEFAULT 'actif' NOT NULL,

    created_at timestamptz DEFAULT now(),

    CONSTRAINT grossistes_statut_check
    CHECK (statut IN ('actif','inactif','bloque'))
);

CREATE INDEX IF NOT EXISTS idx_grossistes_fournisseur
ON public.grossistes(fournisseur_id);


CREATE TABLE IF NOT EXISTS public.fournisseur_produits (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    fournisseur_id uuid NOT NULL
    REFERENCES public.fournisseurs(id)
    ON DELETE CASCADE,

    produit_id uuid NOT NULL
    REFERENCES public.produits(id)
    ON DELETE CASCADE,

    prix_achat numeric NOT NULL,

    stock_disponible integer DEFAULT 0,

    minimum_commande integer DEFAULT 1,

    actif boolean DEFAULT true,

    created_at timestamptz DEFAULT now(),

    UNIQUE(fournisseur_id, produit_id)
);

CREATE INDEX IF NOT EXISTS idx_fournisseur_produits_produit
ON public.fournisseur_produits(produit_id);


CREATE TABLE IF NOT EXISTS public.approvisionnements (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    boutiquier_id uuid NOT NULL
    REFERENCES public.boutiquiers(id),

    grossiste_id uuid NOT NULL
    REFERENCES public.grossistes(id),

    total numeric NOT NULL DEFAULT 0,

    statut text DEFAULT 'brouillon',

    statut_paiement text DEFAULT 'non_initie',

    created_at timestamptz DEFAULT now(),

    updated_at timestamptz DEFAULT now(),

    CONSTRAINT approvisionnements_statut_check
    CHECK (
        statut IN (
            'brouillon',
            'envoye',
            'accepte',
            'expedie',
            'livre',
            'annule'
        )
    )
);


CREATE INDEX IF NOT EXISTS idx_approvisionnements_boutiquier
ON public.approvisionnements(boutiquier_id);


CREATE INDEX IF NOT EXISTS idx_approvisionnements_grossiste
ON public.approvisionnements(grossiste_id);


CREATE TABLE IF NOT EXISTS public.approvisionnement_lignes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,

    approvisionnement_id uuid NOT NULL
    REFERENCES public.approvisionnements(id)
    ON DELETE CASCADE,

    produit_id uuid NOT NULL
    REFERENCES public.produits(id),

    quantite integer NOT NULL,

    prix_unitaire numeric NOT NULL
);


CREATE INDEX IF NOT EXISTS idx_approvisionnement_lignes_parent
ON public.approvisionnement_lignes(approvisionnement_id);


CREATE TRIGGER trigger_approvisionnements_updated_at
BEFORE UPDATE ON public.approvisionnements
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();


COMMIT;
