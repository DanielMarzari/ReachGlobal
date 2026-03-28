import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    // Verify caller is authenticated and is staff
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response("Unauthorized", { status: 401, headers: corsHeaders });

    // Admin client — uses service role key from Supabase env (never exposed to client)
    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { autoRefreshToken: false, persistSession: false } }
    );

    // Verify caller's role (must be super_admin or coordinator with can_add_staff)
    const callerClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );
    const { data: caller, error: callerErr } = await callerClient
      .from("profiles").select("id, role").single();
    if (callerErr || !caller) return new Response("Unauthorized", { status: 401, headers: corsHeaders });

    const allowedRoles = ["super_admin", "coordinator"];
    if (!allowedRoles.includes(caller.role)) {
      return new Response("Forbidden", { status: 403, headers: corsHeaders });
    }

    const body = await req.json();
    const { email, password, full_name, phone, role, disaster_id, permission_level, can_add_staff } = body;

    if (!email || !password || !full_name) {
      return new Response(JSON.stringify({ error: "email, password, full_name required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    // Create auth user
    const { data: newUser, error: createErr } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name, phone: phone ?? "", role: role ?? "coordinator" },
    });
    if (createErr || !newUser.user) {
      return new Response(JSON.stringify({ error: createErr?.message ?? "Failed to create user" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } });
    }

    const newUserId = newUser.user.id;

    // Set created_by
    await adminClient.from("profiles").update({ created_by: caller.id }).eq("id", newUserId);

    // Assign disaster permission if provided
    if (disaster_id) {
      await adminClient.from("staff_event_permissions").insert({
        user_id: newUserId,
        disaster_id,
        level: permission_level ?? "coordinator",
        can_add_staff: can_add_staff ?? false,
      });
    }

    return new Response(JSON.stringify({ user_id: newUserId }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } });

  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
  }
});
