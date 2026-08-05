BEGIN;

ALTER TABLE public.fournisseurs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grossistes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fournisseur_produits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approvisionnements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approvisionnement_lignes ENABLE ROW LEVEL SECURITY;


-- ADMIN ACCES

CREATE POLICY "admins_manage_fournisseurs"
ON public.fournisseurs
FOR ALL
USING (
 auth.uid() IN (
  SELECT auth_user_id FROM public.admins
 )
);


CREATE POLICY "admins_manage_grossistes"
ON public.grossistes
FOR ALL
USING (
 auth.uid() IN (
  SELECT auth_user_id FROM public.admins
 )
);


CREATE POLICY "admins_manage_fournisseur_produits"
ON public.fournisseur_produits
FOR ALL
USING (
 auth.uid() IN (
  SELECT auth_user_id FROM public.admins
 )
);


CREATE POLICY "admins_manage_approvisionnements"
ON public.approvisionnements
FOR ALL
USING (
 auth.uid() IN (
  SELECT auth_user_id FROM public.admins
 )
);


CREATE POLICY "admins_manage_approvisionnement_lignes"
ON public.approvisionnement_lignes
FOR ALL
USING (
 auth.uid() IN (
  SELECT auth_user_id FROM public.admins
 )
);


-- BOUTIQUIER APPROVISIONNEMENT

CREATE POLICY "boutiquier_voit_ses_approvisionnements"
ON public.approvisionnements
FOR SELECT
USING (
 boutiquier_id IN (
   SELECT id 
   FROM public.boutiquiers
   WHERE auth_user_id = auth.uid()
 )
);


CREATE POLICY "boutiquier_cree_approvisionnement"
ON public.approvisionnements
FOR INSERT
WITH CHECK (
 boutiquier_id IN (
   SELECT id 
   FROM public.boutiquiers
   WHERE auth_user_id = auth.uid()
 )
);


CREATE POLICY "boutiquier_voit_lignes_approvisionnement"
ON public.approvisionnement_lignes
FOR SELECT
USING (
 approvisionnement_id IN (
   SELECT id
   FROM public.approvisionnements
   WHERE boutiquier_id IN (
      SELECT id
      FROM public.boutiquiers
      WHERE auth_user_id = auth.uid()
   )
 )
);


COMMIT;
git add .
git commit;
