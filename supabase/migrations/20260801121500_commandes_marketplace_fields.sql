-- Migration : preparation marketplace B2B sur commandes
-- Colonnes deja appliquees en base au moment de ce commit (verifie via information_schema)
-- Additif uniquement, table vide au moment de l'execution

alter table public.commandes
  add column if not exists grossiste_id uuid,
  add column if not exists fournisseur_type text not null default 'khaymia',
  add column if not exists livreur_id uuid;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'commandes_fournisseur_type_check'
  ) then
    alter table public.commandes
      add constraint commandes_fournisseur_type_check
      check (fournisseur_type in ('khaymia', 'grossiste_partenaire'));
  end if;
end $$;

-- NON INCLUS (volontairement, decision CTO 2026-08-01) :
--   commandes_statut_check (audit writers requis avant)
--   commandes_grossiste_coherence_check
--   FK grossiste_id -> grossistes(id), livreur_id -> livreurs(id)
