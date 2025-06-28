import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey",
};

Deno.serve(async (req) => {
  console.log("--- New Request ---");
  console.log("get-friends function invoked at:", new Date().toISOString());
  console.log("Request method:", req.method);
  console.log("Authorization Header:", req.headers.get("Authorization"));

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    console.log("Supabase URL loaded:", supabaseUrl ? "Yes" : "No");
    console.log("Supabase Anon Key loaded:", supabaseAnonKey ? "Yes" : "No");

    console.log("Creating Supabase client");
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: req.headers.get("Authorization")! } },
    });

    console.log("Getting user");
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      console.log("User not found");
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 401,
      });
    }
    console.log("User found:", user.id);

    console.log("Fetching connections");
    const { data: connections, error } = await supabase
      .from("connections")
      .select("requester_id, addressee_id")
      .in("status", ["accepted"])
      .or(`requester_id.eq.${user.id},addressee_id.eq.${user.id}`);

    if (error) {
      console.error("Error fetching connections:", error);
      throw error;
    }
    console.log("Connections found:", connections);

    const friendIds = [
      ...new Set(
        connections
          .flatMap((c) => [c.requester_id, c.addressee_id])
          .filter((id) => id !== user.id)
      ),
    ];
    console.log("Friend IDs:", friendIds);

    console.log("Fetching profiles");
    const { data: profiles, error: profilesError } = await supabase
      .from("profiles")
      .select("*")
      .in("id", friendIds);

    if (profilesError) {
      console.error("Error fetching profiles:", profilesError);
      throw profilesError;
    }
    console.log("Profiles found:", profiles);

    console.log("--- Request Succeeded ---");
    return new Response(JSON.stringify(profiles), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("--- Request Failed ---");
    console.error("Caught error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
