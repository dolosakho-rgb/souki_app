import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// --- Constantes ---
const EMAIL_DOMAIN = "khaymia.internal";
const PIN_LENGTH = 6;
const MIN_NAME_LENGTH = 2;
const MAX_NAME_LENGTH = 60;
const LANGUES_AUTORISEES = ["fr", "ar", "pul", "snk", "wo"];
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function buildEmailFromPhone(telephone) {
  const clean = telephone.replace(/[^0-9]/g, "");
  return `${clean}@${EMAIL_DOMAIN}`;
}

// --- Format de reponse unifie ---
function jsonError(code, message, status, requestId) {
  return new Response(
    JSON.stringify({ success: false, code, error: message }),
    { status, headers: { ...corsHeaders, "Content-Type": "application/json", "X-Request-Id": requestId } },
  );
}

function jsonSuccess(payload, requestId) {
  return new Response(
    JSON.stringify({ success: true, ...payload }),
    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json", "X-Request-Id": requestId } },
  );
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const requestId = crypto.randomUUID();
  console.log(`[create-consumer][${requestId}] Nouvelle demande recue.`);

  try {
    const body = await req.json();
    const prenom = (body.prenom ?? "").trim();
    const nom = (body.nom ?? "").trim();
    const telephoneRaw = (body.telephone ?? "").trim();
    const pin = (body.pin ?? "").trim();
    const ville_id = body.ville_id ?? null;
    const langue_preferee = body.langue_preferee ?? "fr";

    if (!prenom || !nom || !telephoneRaw || !pin) {
      console.log(`[create-consumer][${requestId}] Champs manquants.`);
      return jsonError("MISSING_FIELDS", "Champs requis manquants (prenom, nom, telephone, pin).", 400, requestId);
    }

    if (prenom.length < MIN_NAME_LENGTH || prenom.length > MAX_NAME_LENGTH) {
      return jsonError("INVALID_PRENOM", `Le prenom doit contenir entre ${MIN_NAME_LENGTH} et ${MAX_NAME_LENGTH} caracteres.`, 400, requestId);
    }

    if (nom.length < MIN_NAME_LENGTH || nom.length > MAX_NAME_LENGTH) {
      return jsonError("INVALID_NOM", `Le nom doit contenir entre ${MIN_NAME_LENGTH} et ${MAX_NAME_LENGTH} caracteres.`, 400, requestId);
    }

    const telephoneClean = telephoneRaw.replace(/[^0-9]/g, "");
    if (telephoneClean.length === 0) {
      return jsonError("INVALID_PHONE", "Numero de telephone invalide.", 400, requestId);
    }

    if (!new RegExp(`^[0-9]{${PIN_LENGTH}}$`).test(pin)) {
      return jsonError("INVALID_PIN", `Le PIN doit contenir exactement ${PIN_LENGTH} chiffres.`, 400, requestId);
    }

    if (!LANGUES_AUTORISEES.includes(langue_preferee)) {
      return jsonError("INVALID_LANGUE", `langue_preferee doit etre l'une de: ${LANGUES_AUTORISEES.join(", ")}.`, 400, requestId);
    }

    if (ville_id !== null && !UUID_REGEX.test(ville_id)) {
      return jsonError("INVALID_VILLE_ID", "ville_id doit etre un UUID valide.", 400, requestId);
    }

    const email = buildEmailFromPhone(telephoneClean);

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL"),
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
      { auth: { autoRefreshToken: false, persistSession: false } },
    );

    console.log(`[create-consumer][${requestId}] Verification unicite telephone.`);
    const { data: existing, error: existingErr } = await supabaseAdmin
      .from("users")
      .select("id")
      .eq("telephone", telephoneClean)
      .maybeSingle();

    if (existingErr) {
      console.error(`[create-consumer][${requestId}] Erreur verification existence:`, existingErr.message);
      return jsonError("INTERNAL_ERROR", "Erreur verification existence: " + existingErr.message, 500, requestId);
    }
    if (existing) {
      console.log(`[create-consumer][${requestId}] Doublon detecte, arret avant creation.`);
      return jsonError("PHONE_ALREADY_EXISTS", "Un compte existe deja pour ce numero de telephone.", 409, requestId);
    }

    // --- Etape critique 1 : creation du compte Auth ---
    // Le PIN sert de mot de passe, l'email est fictif (telephone@khaymia.internal).
    // Compatible avec le mecanisme de login existant (signInWithPassword).
    console.log(`[create-consumer][${requestId}] Creation du compte Auth.`);
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password: pin,
      email_confirm: true,
      user_metadata: { prenom, nom, telephone: telephoneClean },
    });

    if (authError || !authData.user) {
      console.error(`[create-consumer][${requestId}] Erreur creation Auth:`, authError?.message ?? "inconnue");
      return jsonError("AUTH_CREATE_FAILED", "Erreur creation compte auth: " + (authError?.message ?? "inconnue"), 500, requestId);
    }
    console.log(`[create-consumer][${requestId}] Compte Auth cree, auth_user_id=` + authData.user.id);

    // --- Etape critique 2 : insertion dans la table centrale users ---
    // Table "users" = compte unifie (Option C). roles=[consommateur] pour ce flux.
    // Rollback complet du compte Auth en cas d'echec ici.
    console.log(`[create-consumer][${requestId}] Insertion table users.`);
    const { data: userRow, error: userInsertError } = await supabaseAdmin
      .from("users")
      .insert({
        auth_user_id: authData.user.id,
        telephone: telephoneClean,
        prenom,
        nom,
        langue_preferee,
        ville_id,
        roles: ["consommateur"],
      })
      .select()
      .single();

    if (userInsertError) {
      console.error(`[create-consumer][${requestId}] Erreur insertion users:`, userInsertError.message);
      const { error: rollbackErr } = await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
      if (rollbackErr) {
        console.error(`[create-consumer][${requestId}] ECHEC ROLLBACK Auth apres echec users. auth_user_id orphelin=` + authData.user.id, rollbackErr.message);
      } else {
        console.log(`[create-consumer][${requestId}] Rollback Auth reussi apres echec users.`);
      }
      return jsonError("USERS_INSERT_FAILED", "Erreur insertion users: " + userInsertError.message, 500, requestId);
    }
    console.log(`[create-consumer][${requestId}] users insere, user_id=` + userRow.id);

    // --- Etape critique 3 : insertion dans consommateurs (profil leger lie a users) ---
    // Rollback en cascade (users + Auth) en cas d'echec ici.
    console.log(`[create-consumer][${requestId}] Insertion table consommateurs.`);
    const { data: consommateur, error: consoInsertError } = await supabaseAdmin
      .from("consommateurs")
      .insert({ user_id: userRow.id })
      .select()
      .single();

    if (consoInsertError) {
      console.error(`[create-consumer][${requestId}] Erreur insertion consommateurs:`, consoInsertError.message);
      const { error: userRollbackErr } = await supabaseAdmin.from("users").delete().eq("id", userRow.id);
      if (userRollbackErr) {
        console.error(`[create-consumer][${requestId}] ECHEC ROLLBACK users. Ligne users orpheline, user_id=` + userRow.id, userRollbackErr.message);
      }
      const { error: authRollbackErr } = await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
      if (authRollbackErr) {
        console.error(`[create-consumer][${requestId}] ECHEC ROLLBACK Auth. auth_user_id orphelin=` + authData.user.id, authRollbackErr.message);
      }
      if (!userRollbackErr && !authRollbackErr) {
        console.log(`[create-consumer][${requestId}] Rollback complet reussi apres echec consommateurs.`);
      }
      return jsonError("CONSOMMATEURS_INSERT_FAILED", "Erreur insertion consommateurs: " + consoInsertError.message, 500, requestId);
    }

    console.log(`[create-consumer][${requestId}] Inscription terminee avec succes, user_id=` + userRow.id);
    return jsonSuccess({ user: userRow, consommateur }, requestId);
  } catch (e) {
    console.error(`[create-consumer][${requestId}] Erreur inattendue:`, e.message);
    return jsonError("UNEXPECTED_ERROR", "Erreur inattendue: " + e.message, 500, requestId);
  }
});
