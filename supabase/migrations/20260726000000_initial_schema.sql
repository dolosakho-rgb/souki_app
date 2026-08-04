


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."confirm_commande_bnpl"("p_commande_id" "uuid", "p_boutiquier_id" "uuid", "p_montant" numeric) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  update commandes
  set statut = 'confirmee'
  where id = p_commande_id
    and statut is distinct from 'confirmee';

  if not found then
    raise exception 'Commande introuvable ou deja confirmee';
  end if;
end;
$$;


ALTER FUNCTION "public"."confirm_commande_bnpl"("p_commande_id" "uuid", "p_boutiquier_id" "uuid", "p_montant" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_ajuster_credit_utilise"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if (tg_op = 'INSERT') then
      if (new.consommateur_id is null and new.statut is distinct from 'annulee') then
            update boutiquiers set credit_utilise = coalesce(credit_utilise, 0) + new.total where id = new.boutiquier_id;
                end if;
                    return new;
                      end if;

                        if (tg_op = 'UPDATE') then
                            if (new.consommateur_id is null) then
                                  if (old.statut is distinct from 'annulee' and new.statut = 'annulee') then
                                          update boutiquiers set credit_utilise = greatest(coalesce(credit_utilise, 0) - old.total, 0) where id = old.boutiquier_id;
                                                elsif (old.statut = 'annulee' and new.statut is distinct from 'annulee') then
                                                        update boutiquiers set credit_utilise = coalesce(credit_utilise, 0) + new.total where id = new.boutiquier_id;
                                                              elsif (old.statut is distinct from 'annulee' and new.statut is distinct from 'annulee' and old.total is distinct from new.total) then
                                                                      update boutiquiers set credit_utilise = greatest(coalesce(credit_utilise, 0) - old.total + new.total, 0) where id = new.boutiquier_id;
                                                                            end if;
                                                                                end if;
                                                                                    return new;
                                                                                      end if;

                                                                                        if (tg_op = 'DELETE') then
                                                                                            if (old.consommateur_id is null and old.statut is distinct from 'annulee') then
                                                                                                  update boutiquiers set credit_utilise = greatest(coalesce(credit_utilise, 0) - old.total, 0) where id = old.boutiquier_id;
                                                                                                      end if;
                                                                                                          return old;
                                                                                                            end if;

                                                                                                              return null;
                                                                                                              end;
                                                                                                              $$;


ALTER FUNCTION "public"."fn_ajuster_credit_utilise"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."admins" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auth_user_id" "uuid" NOT NULL,
    "nom" "text" NOT NULL,
    "role" "text" DEFAULT 'admin'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."admins" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "admin_id" "uuid",
    "admin_nom" "text" NOT NULL,
    "admin_role" "text" NOT NULL,
    "action" "text" NOT NULL,
    "objet_type" "text" NOT NULL,
    "objet_id" "uuid",
    "ancienne_valeur" "jsonb",
    "nouvelle_valeur" "jsonb",
    "justification" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."audit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."boutiquiers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auth_user_id" "uuid",
    "nom" "text" NOT NULL,
    "boutique_nom" "text" NOT NULL,
    "telephone" "text" NOT NULL,
    "adresse" "text",
    "credit_disponible" numeric DEFAULT 15000,
    "credit_utilise" numeric DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "ville_id" "uuid",
    "statut" "text" DEFAULT 'actif'::"text" NOT NULL,
    CONSTRAINT "boutiquiers_statut_check" CHECK (("statut" = ANY (ARRAY['en_attente'::"text", 'actif'::"text", 'bloque'::"text"])))
);


ALTER TABLE "public"."boutiquiers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."commande_lignes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "commande_id" "uuid" NOT NULL,
    "produit_id" "uuid" NOT NULL,
    "quantite" integer NOT NULL,
    "prix_unitaire" numeric NOT NULL
);


ALTER TABLE "public"."commande_lignes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."commandes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "boutiquier_id" "uuid" NOT NULL,
    "total" numeric NOT NULL,
    "statut" "text" DEFAULT 'en_attente'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "ville_id" "uuid",
    "statut_paiement" "text" DEFAULT 'non_initie'::"text" NOT NULL,
    "statut_livraison" "text" DEFAULT 'non_expediee'::"text" NOT NULL,
    "payment_method" "text",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "grossiste_id" "uuid",
    "fournisseur_type" "text" DEFAULT 'khaymia'::"text" NOT NULL,
    "livreur_id" "uuid",
    "consommateur_id" "uuid",
    CONSTRAINT "commandes_fournisseur_type_check" CHECK (("fournisseur_type" = ANY (ARRAY['khaymia'::"text", 'grossiste_partenaire'::"text"]))),
    CONSTRAINT "commandes_payment_method_check" CHECK ((("payment_method" IS NULL) OR ("payment_method" = ANY (ARRAY['cash'::"text", 'bankily'::"text", 'masrvi'::"text", 'sedad'::"text", 'wallet_khaymia'::"text", 'bnpl'::"text", 'autre'::"text"])))),
    CONSTRAINT "commandes_statut_livraison_check" CHECK (("statut_livraison" = ANY (ARRAY['non_expediee'::"text", 'en_preparation'::"text", 'expediee'::"text", 'en_transit'::"text", 'livree'::"text", 'partiellement_livree'::"text", 'retournee'::"text"]))),
    CONSTRAINT "commandes_statut_paiement_check" CHECK (("statut_paiement" = ANY (ARRAY['non_initie'::"text", 'en_attente'::"text", 'partiellement_paye'::"text", 'paye'::"text", 'echec'::"text", 'annule'::"text", 'rembourse'::"text", 'partiellement_rembourse'::"text"])))
);


ALTER TABLE "public"."commandes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."consommateurs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "adresse_complement" "text",
    "points_fidelite" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."consommateurs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."credit_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "boutiquier_id" "uuid" NOT NULL,
    "ancien_montant" numeric NOT NULL,
    "nouveau_montant" numeric NOT NULL,
    "raison" "text" NOT NULL,
    "demandeur_id" "uuid" NOT NULL,
    "demandeur_nom" "text" NOT NULL,
    "statut" "text" DEFAULT 'en_attente'::"text" NOT NULL,
    "validateur_id" "uuid",
    "validateur_nom" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "credit_requests_statut_check" CHECK (("statut" = ANY (ARRAY['en_attente'::"text", 'approuve'::"text", 'refuse'::"text"])))
);


ALTER TABLE "public"."credit_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."produits" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nom" "text" NOT NULL,
    "description" "text",
    "prix" numeric NOT NULL,
    "stock" integer DEFAULT 0,
    "categorie" "text",
    "image_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."produits" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."transactions_wallet" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "boutiquier_id" "uuid" NOT NULL,
    "type" "text" NOT NULL,
    "montant" numeric NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "transactions_wallet_type_check" CHECK (("type" = ANY (ARRAY['recharge'::"text", 'remboursement'::"text"])))
);


ALTER TABLE "public"."transactions_wallet" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "auth_user_id" "uuid" NOT NULL,
    "telephone" "text" NOT NULL,
    "prenom" "text" NOT NULL,
    "nom" "text" NOT NULL,
    "langue_preferee" "text" DEFAULT 'fr'::"text" NOT NULL,
    "ville_id" "uuid",
    "zone_livraison_id" "uuid",
    "statut_compte" "text" DEFAULT 'actif'::"text" NOT NULL,
    "roles" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "users_langue_preferee_check" CHECK (("langue_preferee" = ANY (ARRAY['fr'::"text", 'ar'::"text", 'pul'::"text", 'snk'::"text", 'wo'::"text"]))),
    CONSTRAINT "users_roles_check" CHECK (("roles" <@ ARRAY['consommateur'::"text", 'boutiquier'::"text", 'livreur'::"text", 'restaurant'::"text", 'admin'::"text"])),
    CONSTRAINT "users_statut_compte_check" CHECK (("statut_compte" = ANY (ARRAY['actif'::"text", 'en_attente'::"text", 'bloque'::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."villes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nom" "text" NOT NULL,
    "wilaya" "text" NOT NULL,
    "code" "text" NOT NULL,
    "actif" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."villes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."zones_livraison" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ville_id" "uuid" NOT NULL,
    "nom" "text" NOT NULL,
    "actif" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."zones_livraison" OWNER TO "postgres";


ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_auth_user_id_key" UNIQUE ("auth_user_id");



ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."boutiquiers"
    ADD CONSTRAINT "boutiquiers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."boutiquiers"
    ADD CONSTRAINT "boutiquiers_telephone_key" UNIQUE ("telephone");



ALTER TABLE ONLY "public"."commande_lignes"
    ADD CONSTRAINT "commande_lignes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."commandes"
    ADD CONSTRAINT "commandes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."consommateurs"
    ADD CONSTRAINT "consommateurs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."consommateurs"
    ADD CONSTRAINT "consommateurs_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."credit_requests"
    ADD CONSTRAINT "credit_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."produits"
    ADD CONSTRAINT "produits_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transactions_wallet"
    ADD CONSTRAINT "transactions_wallet_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_auth_user_id_key" UNIQUE ("auth_user_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_telephone_key" UNIQUE ("telephone");



ALTER TABLE ONLY "public"."villes"
    ADD CONSTRAINT "villes_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."villes"
    ADD CONSTRAINT "villes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."zones_livraison"
    ADD CONSTRAINT "zones_livraison_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_commandes_consommateur_id" ON "public"."commandes" USING "btree" ("consommateur_id");



CREATE INDEX "users_roles_idx" ON "public"."users" USING "gin" ("roles");



CREATE INDEX "users_ville_id_idx" ON "public"."users" USING "btree" ("ville_id");



CREATE INDEX "users_zone_livraison_id_idx" ON "public"."users" USING "btree" ("zone_livraison_id");



CREATE OR REPLACE TRIGGER "trg_ajuster_credit_utilise" AFTER INSERT OR DELETE OR UPDATE ON "public"."commandes" FOR EACH ROW EXECUTE FUNCTION "public"."fn_ajuster_credit_utilise"();



CREATE OR REPLACE TRIGGER "trigger_commandes_updated_at" BEFORE UPDATE ON "public"."commandes" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_consommateurs_updated_at" BEFORE UPDATE ON "public"."consommateurs" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_users_updated_at" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_auth_user_id_fkey" FOREIGN KEY ("auth_user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_admin_id_fkey" FOREIGN KEY ("admin_id") REFERENCES "public"."admins"("id");



ALTER TABLE ONLY "public"."boutiquiers"
    ADD CONSTRAINT "boutiquiers_auth_user_id_fkey" FOREIGN KEY ("auth_user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."boutiquiers"
    ADD CONSTRAINT "boutiquiers_ville_id_fkey" FOREIGN KEY ("ville_id") REFERENCES "public"."villes"("id");



ALTER TABLE ONLY "public"."commande_lignes"
    ADD CONSTRAINT "commande_lignes_commande_id_fkey" FOREIGN KEY ("commande_id") REFERENCES "public"."commandes"("id");



ALTER TABLE ONLY "public"."commande_lignes"
    ADD CONSTRAINT "commande_lignes_produit_id_fkey" FOREIGN KEY ("produit_id") REFERENCES "public"."produits"("id");



ALTER TABLE ONLY "public"."commandes"
    ADD CONSTRAINT "commandes_boutiquier_id_fkey" FOREIGN KEY ("boutiquier_id") REFERENCES "public"."boutiquiers"("id");



ALTER TABLE ONLY "public"."commandes"
    ADD CONSTRAINT "commandes_consommateur_id_fkey" FOREIGN KEY ("consommateur_id") REFERENCES "public"."consommateurs"("id");



ALTER TABLE ONLY "public"."commandes"
    ADD CONSTRAINT "commandes_ville_id_fkey" FOREIGN KEY ("ville_id") REFERENCES "public"."villes"("id");



ALTER TABLE ONLY "public"."consommateurs"
    ADD CONSTRAINT "consommateurs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");



ALTER TABLE ONLY "public"."credit_requests"
    ADD CONSTRAINT "credit_requests_boutiquier_id_fkey" FOREIGN KEY ("boutiquier_id") REFERENCES "public"."boutiquiers"("id");



ALTER TABLE ONLY "public"."credit_requests"
    ADD CONSTRAINT "credit_requests_demandeur_id_fkey" FOREIGN KEY ("demandeur_id") REFERENCES "public"."admins"("id");



ALTER TABLE ONLY "public"."credit_requests"
    ADD CONSTRAINT "credit_requests_validateur_id_fkey" FOREIGN KEY ("validateur_id") REFERENCES "public"."admins"("id");



ALTER TABLE ONLY "public"."transactions_wallet"
    ADD CONSTRAINT "transactions_wallet_boutiquier_id_fkey" FOREIGN KEY ("boutiquier_id") REFERENCES "public"."boutiquiers"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_ville_id_fkey" FOREIGN KEY ("ville_id") REFERENCES "public"."villes"("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_zone_livraison_id_fkey" FOREIGN KEY ("zone_livraison_id") REFERENCES "public"."zones_livraison"("id");



ALTER TABLE ONLY "public"."zones_livraison"
    ADD CONSTRAINT "zones_livraison_ville_id_fkey" FOREIGN KEY ("ville_id") REFERENCES "public"."villes"("id");



CREATE POLICY "Admin voit son propre profil" ON "public"."admins" FOR SELECT USING (("auth"."uid"() = "auth_user_id"));



CREATE POLICY "Boutiquier cree ses commandes" ON "public"."commandes" FOR INSERT WITH CHECK (("boutiquier_id" IN ( SELECT "boutiquiers"."id"
   FROM "public"."boutiquiers"
  WHERE ("boutiquiers"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Boutiquier cree ses lignes de commande" ON "public"."commande_lignes" FOR INSERT WITH CHECK (("commande_id" IN ( SELECT "c"."id"
   FROM ("public"."commandes" "c"
     JOIN "public"."boutiquiers" "b" ON (("c"."boutiquier_id" = "b"."id")))
  WHERE ("b"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Boutiquier cree ses transactions" ON "public"."transactions_wallet" FOR INSERT WITH CHECK (("boutiquier_id" IN ( SELECT "boutiquiers"."id"
   FROM "public"."boutiquiers"
  WHERE ("boutiquiers"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Boutiquier cree son propre profil" ON "public"."boutiquiers" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "auth_user_id"));



CREATE POLICY "Boutiquier modifie ses commandes" ON "public"."commandes" FOR UPDATE USING (("boutiquier_id" IN ( SELECT "boutiquiers"."id"
   FROM "public"."boutiquiers"
  WHERE ("boutiquiers"."auth_user_id" = "auth"."uid"())))) WITH CHECK (("boutiquier_id" IN ( SELECT "boutiquiers"."id"
   FROM "public"."boutiquiers"
  WHERE ("boutiquiers"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Boutiquier modifie son propre profil" ON "public"."boutiquiers" FOR UPDATE USING (("auth"."uid"() = "auth_user_id"));



CREATE POLICY "Boutiquier voit ses commandes" ON "public"."commandes" FOR SELECT USING (("boutiquier_id" IN ( SELECT "boutiquiers"."id"
   FROM "public"."boutiquiers"
  WHERE ("boutiquiers"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Boutiquier voit ses lignes de commande" ON "public"."commande_lignes" FOR SELECT USING (("commande_id" IN ( SELECT "c"."id"
   FROM ("public"."commandes" "c"
     JOIN "public"."boutiquiers" "b" ON (("c"."boutiquier_id" = "b"."id")))
  WHERE ("b"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Boutiquier voit ses transactions" ON "public"."transactions_wallet" FOR SELECT USING (("boutiquier_id" IN ( SELECT "boutiquiers"."id"
   FROM "public"."boutiquiers"
  WHERE ("boutiquiers"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Boutiquier voit son propre profil" ON "public"."boutiquiers" FOR SELECT USING (("auth"."uid"() = "auth_user_id"));



CREATE POLICY "Consommateur cree ses commandes" ON "public"."commandes" FOR INSERT WITH CHECK (("consommateur_id" IN ( SELECT "c"."id"
   FROM ("public"."consommateurs" "c"
     JOIN "public"."users" "u" ON (("u"."id" = "c"."user_id")))
  WHERE ("u"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Consommateur cree ses lignes de commande" ON "public"."commande_lignes" FOR INSERT WITH CHECK (("commande_id" IN ( SELECT "c"."id"
   FROM (("public"."commandes" "c"
     JOIN "public"."consommateurs" "co" ON (("co"."id" = "c"."consommateur_id")))
     JOIN "public"."users" "u" ON (("u"."id" = "co"."user_id")))
  WHERE ("u"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Consommateur voit ses commandes" ON "public"."commandes" FOR SELECT USING (("consommateur_id" IN ( SELECT "c"."id"
   FROM ("public"."consommateurs" "c"
     JOIN "public"."users" "u" ON (("u"."id" = "c"."user_id")))
  WHERE ("u"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Consommateur voit ses lignes de commande" ON "public"."commande_lignes" FOR SELECT USING (("commande_id" IN ( SELECT "c"."id"
   FROM (("public"."commandes" "c"
     JOIN "public"."consommateurs" "co" ON (("co"."id" = "c"."consommateur_id")))
     JOIN "public"."users" "u" ON (("u"."id" = "co"."user_id")))
  WHERE ("u"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Lecture publique des produits" ON "public"."produits" FOR SELECT USING (true);



CREATE POLICY "Lecture villes pour tous les authentifiés" ON "public"."villes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Lecture zones pour tous les authentifiés" ON "public"."zones_livraison" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."admins" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "admins_insert_audit_logs" ON "public"."audit_logs" FOR INSERT WITH CHECK (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_insert_credit_requests" ON "public"."credit_requests" FOR INSERT WITH CHECK (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_read_audit_logs" ON "public"."audit_logs" FOR SELECT USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_read_credit_requests" ON "public"."credit_requests" FOR SELECT USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_select_all_boutiquiers" ON "public"."boutiquiers" FOR SELECT USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_select_all_commandes" ON "public"."commandes" FOR SELECT USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_select_all_consommateurs" ON "public"."consommateurs" FOR SELECT USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_select_all_users" ON "public"."users" FOR SELECT USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_update_all_boutiquiers" ON "public"."boutiquiers" FOR UPDATE USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins"))) WITH CHECK (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



CREATE POLICY "admins_update_credit_requests" ON "public"."credit_requests" FOR UPDATE USING (("auth"."uid"() IN ( SELECT "admins"."auth_user_id"
   FROM "public"."admins")));



ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."boutiquiers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."commande_lignes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."commandes" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "consommateur_cree_son_profil" ON "public"."consommateurs" FOR INSERT WITH CHECK (("user_id" IN ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "consommateur_modifie_son_profil" ON "public"."consommateurs" FOR UPDATE USING (("user_id" IN ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"())))) WITH CHECK (("user_id" IN ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "consommateur_voit_son_profil" ON "public"."consommateurs" FOR SELECT USING (("user_id" IN ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



ALTER TABLE "public"."consommateurs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."credit_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."produits" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transactions_wallet" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_cree_son_propre_compte" ON "public"."users" FOR INSERT WITH CHECK (("auth"."uid"() = "auth_user_id"));



CREATE POLICY "user_modifie_son_propre_compte" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "auth_user_id")) WITH CHECK (("auth"."uid"() = "auth_user_id"));



CREATE POLICY "user_voit_son_propre_compte" ON "public"."users" FOR SELECT USING (("auth"."uid"() = "auth_user_id"));



ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."villes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."zones_livraison" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."confirm_commande_bnpl"("p_commande_id" "uuid", "p_boutiquier_id" "uuid", "p_montant" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."confirm_commande_bnpl"("p_commande_id" "uuid", "p_boutiquier_id" "uuid", "p_montant" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."confirm_commande_bnpl"("p_commande_id" "uuid", "p_boutiquier_id" "uuid", "p_montant" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_ajuster_credit_utilise"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_ajuster_credit_utilise"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_ajuster_credit_utilise"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON TABLE "public"."admins" TO "anon";
GRANT ALL ON TABLE "public"."admins" TO "authenticated";
GRANT ALL ON TABLE "public"."admins" TO "service_role";



GRANT ALL ON TABLE "public"."audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."boutiquiers" TO "anon";
GRANT ALL ON TABLE "public"."boutiquiers" TO "authenticated";
GRANT ALL ON TABLE "public"."boutiquiers" TO "service_role";



GRANT ALL ON TABLE "public"."commande_lignes" TO "anon";
GRANT ALL ON TABLE "public"."commande_lignes" TO "authenticated";
GRANT ALL ON TABLE "public"."commande_lignes" TO "service_role";



GRANT ALL ON TABLE "public"."commandes" TO "anon";
GRANT ALL ON TABLE "public"."commandes" TO "authenticated";
GRANT ALL ON TABLE "public"."commandes" TO "service_role";



GRANT ALL ON TABLE "public"."consommateurs" TO "anon";
GRANT ALL ON TABLE "public"."consommateurs" TO "authenticated";
GRANT ALL ON TABLE "public"."consommateurs" TO "service_role";



GRANT ALL ON TABLE "public"."credit_requests" TO "anon";
GRANT ALL ON TABLE "public"."credit_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."credit_requests" TO "service_role";



GRANT ALL ON TABLE "public"."produits" TO "anon";
GRANT ALL ON TABLE "public"."produits" TO "authenticated";
GRANT ALL ON TABLE "public"."produits" TO "service_role";



GRANT ALL ON TABLE "public"."transactions_wallet" TO "anon";
GRANT ALL ON TABLE "public"."transactions_wallet" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions_wallet" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."villes" TO "anon";
GRANT ALL ON TABLE "public"."villes" TO "authenticated";
GRANT ALL ON TABLE "public"."villes" TO "service_role";



GRANT ALL ON TABLE "public"."zones_livraison" TO "anon";
GRANT ALL ON TABLE "public"."zones_livraison" TO "authenticated";
GRANT ALL ON TABLE "public"."zones_livraison" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







