const DEFAULT_SUPABASE_URL = "https://iqhlnrtobqjuihxagrmw.supabase.co";
const DEFAULT_SUPABASE_ANON_KEY = "sb_publishable_P79tXpzOlg5qqddS6PPO3A_0t0GHkbp";

export const env = {
  supabaseUrl:
    process.env.NEXT_PUBLIC_SUPABASE_URL?.trim() || DEFAULT_SUPABASE_URL,
  supabaseAnonKey:
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.trim() ||
    DEFAULT_SUPABASE_ANON_KEY,
  supabaseServiceRoleKey:
    process.env.SUPABASE_SERVICE_ROLE_KEY?.trim() || "",
  adminSessionSecret:
    process.env.ADMIN_SESSION_SECRET?.trim() ||
    "replace-this-local-admin-session-secret",
  adminEmails: process.env.ADMIN_EMAILS?.trim() || "",
};

export function hasServiceRoleKey() {
  return env.supabaseServiceRoleKey.length > 0;
}

export function getAdminConfigurationWarnings() {
  const warnings: string[] = [];

  if (!hasServiceRoleKey()) {
    warnings.push(
      "SUPABASE_SERVICE_ROLE_KEY is missing, so live admin data and member management cannot load yet.",
    );
  }

  if (!env.adminEmails) {
    warnings.push(
      "ADMIN_EMAILS is empty. Only accounts with app_metadata.role set to admin can sign in.",
    );
  }

  if (env.adminSessionSecret === "replace-this-local-admin-session-secret") {
    warnings.push(
      "ADMIN_SESSION_SECRET is using the starter value. Replace it before deployment.",
    );
  }

  return warnings;
}
