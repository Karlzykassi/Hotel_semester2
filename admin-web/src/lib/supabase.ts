import { createClient } from "@supabase/supabase-js";
import { env, hasServiceRoleKey } from "@/lib/env";

export function getPublicSupabaseClient() {
  return createClient(env.supabaseUrl, env.supabaseAnonKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

export function getServiceSupabaseClient() {
  if (!hasServiceRoleKey()) {
    return null;
  }

  return createClient(env.supabaseUrl, env.supabaseServiceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
