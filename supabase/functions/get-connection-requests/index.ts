import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req) => {
  try {
    const { addressee_id } = await req.json();

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const { data, error } = await supabaseClient
      .from("connections")
      .select(
        `
        id,
        requester_id,
        addressee_id,
        addressee:profiles!connections_addressee_id_fkey (
          username
        ),
        requester:profiles!connections_requester_id_fkey (
          username
        )
      `
      )
      .eq("addressee_id", addressee_id)
      .eq("status", "pending");

    const responseData = data.map((connection) => ({
      id: connection.id,
      addressee_name: connection.addressee.username,
      requester_name: connection.requester.username,
      requester_id: connection.requester_id,
      addressee_id: connection.addressee_id,
    }));

    return new Response(JSON.stringify(responseData), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
