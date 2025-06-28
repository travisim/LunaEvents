import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.31.0";
import { GoogleGenerativeAI } from "npm:@google/generative-ai@0.11.3";
import { corsHeaders } from "../_shared/cors.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
if (!GEMINI_API_KEY) {
  console.error(
    "GEMINI_API_KEY environment variable not set for get-issue-embedding."
  );
}

const genAI = GEMINI_API_KEY ? new GoogleGenerativeAI(GEMINI_API_KEY) : null;
// As per plan, using "embedding-001" or "textembedding-gecko-001".
// The SDK typically refers to it as "embedding-001" for the general text embedding model.
const embeddingModelName = "embedding-001";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (!genAI) {
    return new Response(
      JSON.stringify({
        error:
          "Gemini AI client not initialized for embeddings. API key might be missing.",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }

  try {
    const { record } = await req.json();
    const { id, preferred_event_types } = record;

    if (
      !preferred_event_types ||
      !Array.isArray(preferred_event_types) ||
      preferred_event_types.length === 0
    ) {
      return new Response(
        JSON.stringify({
          error: "preferred_event_types (non-empty array) is required.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        }
      );
    }

    const model = genAI.getGenerativeModel({ model: embeddingModelName });
    const result = await model.embedContent(preferred_event_types.join(", "));
    const embedding = result.embedding;

    if (!embedding || !embedding.values) {
      console.error(
        "Failed to generate embedding, or embedding values are missing. Result:",
        result
      );
      return new Response(
        JSON.stringify({
          error: "Failed to generate embedding or embedding values missing.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 500,
        }
      );
    }

    await supabase
      .from("profiles")
      .update({ embedding: embedding.values })
      .eq("id", id);

    return new Response("OK");
  } catch (error) {
    console.error("Error in generate-profile-embedding function:", error);
    const errorMessage =
      error instanceof Error
        ? error.message
        : "An unexpected error occurred while generating embedding.";
    return new Response(JSON.stringify({ error: errorMessage }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
