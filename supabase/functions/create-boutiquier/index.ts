import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const EMAIL_DOMAIN = "khaymia.internal";

function buildEmailFromPhone(telephone) {
  const clean = telephone.replace(/[^0-9]/g, "");
  return `${clean}@${EMAIL_DOMAIN}`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { nom, boutique_nom, telephone, adresse, pin, ville_id } = await req.json();

    if (!nom || !boutique_nom || !telephone || !pin) {
      return new Response(
        JSON.stringify({ error: "Champs requis manquants (nom, boutique_nom, telephone, pin)." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
    if (!/^[0-9]{6}$/.test(pin)) {
      return new Response(
        JSON.stringify({ error: "Le PIN doit contenir exactement 6 chiffres." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const telephoneClean = telephone.replace(/[^0-9]/g, "");
    const email = buildEmailFromPhone(telephoneClean);

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL"),
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
      { auth: { autoRefreshToken: false, persistSession: false } },
    );

    const { data: existing, error: existingErr } = await supabaseAdmin
      .from("boutiquiers")
      .select("id")
      .eq("telephone", telephoneClean)
      .maybeSingle();

    if (existingErr) {
      return new Response(
        JSON.stringify({ error: "Erreur vérification existence: " + existingErr.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
    if (existing) {
      return new Response(
        JSON.stringify({ error: "Un compte existe déjà pour ce numéro de téléphone." }),
        { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password: pin,
      email_confirm: true,
      user_metadata: { nom, boutique_nom, telephone: telephoneClean },
    });

    if (authError || !authData.user) {
      return new Response(
        JSON.stringify({ error: "Erreur création compte auth: " + (authError?.message ?? "inconnue") }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const { data: boutiquier, error: insertError } = await supabaseAdmin
      .from("boutiquiers")
      .insert({
        auth_user_id: authData.user.id,
        nom,
        boutique_nom,
        telephone: telephoneClean,
        adresse: adresse ?? null,
      ville_id: ville_id ?? null,
      })
      .select()
      .single();

    if (insertError) {
      await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
      return new Response(
        JSON.stringify({ error: "Erreur insertion boutiquier: " + insertError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ success: true, boutiquier }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: "Erreur inattendue: " + e.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
