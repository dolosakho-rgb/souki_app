-- Migration : ajout des axes statut_paiement, statut_livraison, payment_method
-- + updated_at sur commandes (architecture Commande/Paiement/Livraison v1.2)
-- Additif uniquement : aucune modification de commandes.statut

-- ============================================
-- STATUT PAIEMENT
-- ============================================

alter table commandes
add column statut_paiement text not null default 'non_initie';

alter table commandes
add constraint commandes_statut_paiement_check
check (statut_paiement in (
  'non_initie', 'en_attente', 'partiellement_paye', 'paye',
  'echec', 'annule', 'rembourse', 'partiellement_rembourse'
));

-- ============================================
-- STATUT LIVRAISON
-- ============================================

alter table commandes
add column statut_livraison text not null default 'non_expediee';

alter table commandes
add constraint commandes_statut_livraison_check
check (statut_livraison in (
  'non_expediee', 'en_preparation', 'expediee', 'en_transit',
  'livree', 'partiellement_livree', 'retournee'
));

-- ============================================
-- PAYMENT METHOD (nullable)
-- ============================================

alter table commandes
add column payment_method text;

alter table commandes
add constraint commandes_payment_method_check
check (payment_method is null or payment_method in (
  'cash', 'bankily', 'masrvi', 'sedad', 'wallet_khaymia', 'bnpl', 'autre'
));

-- ============================================
-- UPDATED_AT — creation defensive
-- ============================================

alter table commandes
add column updated_at timestamptz not null default now();

do $$
begin
  if not exists (
    select 1 from pg_proc where proname = 'set_updated_at'
  ) then
    raise exception 'set_updated_at() introuvable — verifier que 001_create_users_consommateurs.sql a bien ete applique avant cette migration.';
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'trigger_commandes_updated_at'
  ) then
    create trigger trigger_commandes_updated_at
    before update on commandes
    for each row
    execute function set_updated_at();
  end if;
end $$;

-- ============================================
-- NOTE : aucun rattrapage retroactif des commandes BNPL (decision actee)
-- ============================================
