import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.31.0";
import { GoogleGenerativeAI } from "npm:@google/generative-ai@0.11.3";
import { corsHeaders } from "../_shared/cors.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
const genAI = GEMINI_API_KEY ? new GoogleGenerativeAI(GEMINI_API_KEY) : null;
const embeddingModelName = "embedding-001";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { record } = await req.json();
    const { id, preferred_event_types } = record;

    const model = genAI.getGenerativeModel({ model: embeddingModelName });
    const result = await model.embedContent(preferred_event_types.join(", "));
    const embedding = result.embedding;

    await supabase
      .from("profiles")
      .update({ embedding: embedding.values })
      .eq("id", id);

    return new Response("OK");
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
