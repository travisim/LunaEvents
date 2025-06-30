import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const { user_id, friend_id } = await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const { data: user_profile, error: user_error } = await supabase
      .from("profiles")
      .select("last_latitude, last_longitude")
      .eq("id", user_id)
      .single();

    const { data: friend_profile, error: friend_error } = await supabase
      .from("profiles")
      .select("last_latitude, last_longitude")
      .eq("id", friend_id)
      .single();

    const mid_lat =
      (user_profile.last_latitude + friend_profile.last_latitude) / 2;
    const mid_lon =
      (user_profile.last_longitude + friend_profile.last_longitude) / 2;

    const data = {
      midpoint_lat: mid_lat,
      midpoint_lon: mid_lon,
    };

    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(String(error?.message ?? error), { status: 500 });
  }
});
