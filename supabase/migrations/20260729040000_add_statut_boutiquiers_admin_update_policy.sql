-- Ajout de la colonne statut sur boutiquiers (module admin - gestion utilisateurs)
alter table boutiquiers
add column statut text not null default 'actif';

alter table boutiquiers
add constraint boutiquiers_statut_check
check (statut in ('en_attente', 'actif', 'bloque'));

-- Ajout d'une policy RLS permettant aux admins de modifier n'importe quel boutiquier
-- (la policy UPDATE existante limitait la modification au boutiquier lui-meme)
create policy "admins_update_all_boutiquiers"
on boutiquiers
for update
using (auth.uid() in (select auth_user_id from admins))
with check (auth.uid() in (select auth_user_id from admins));
