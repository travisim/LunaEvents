import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
      global: { headers: { Authorization: req.headers.get("Authorization")! } },
    });

    const {
      data: { user },
    } = await supabase.auth.getUser();

    const { data: connections, error } = await supabase
      .from("connections")
      .select("requester_id, addressee_id")
      .in("status", ["accepted"])
      .or(`requester_id.eq.${user.id},addressee_id.eq.${user.id}`);

    const friendIds = [
      ...new Set(
        connections
          .flatMap((c) => [c.requester_id, c.addressee_id])
          .filter((id) => id !== user.id)
      ),
    ];

    const { data: profiles, error: profilesError } = await supabase
      .from("profiles")
      .select("*")
      .in("id", friendIds);

    return new Response(JSON.stringify(profiles), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
