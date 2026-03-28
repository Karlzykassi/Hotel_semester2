import type { User } from "@supabase/supabase-js";
import { env } from "@/lib/env";

export function normalizeEmail(value: string | null | undefined) {
  return value?.trim().toLowerCase() ?? "";
}

export function getAdminAllowlist() {
  return env.adminEmails
    .split(",")
    .map((value) => normalizeEmail(value))
    .filter(Boolean);
}

export function isAllowedAdminEmail(email: string | null | undefined) {
  const normalizedEmail = normalizeEmail(email);

  return getAdminAllowlist().includes(normalizedEmail);
}

export function hasAdminRole(user: Pick<User, "app_metadata">) {
  return user.app_metadata?.role === "admin";
}

export function isAllowedAdminUser(user: Pick<User, "email" | "app_metadata">) {
  return isAllowedAdminEmail(user.email) || hasAdminRole(user);
}

export function getAccessSource(user: Pick<User, "email" | "app_metadata">) {
  if (hasAdminRole(user)) {
    return "app_metadata.role";
  }

  if (isAllowedAdminEmail(user.email)) {
    return "ADMIN_EMAILS";
  }

  return "User";
}

export function getDisplayName(
  value: string | null | undefined,
  email: string | null | undefined,
) {
  if (value?.trim()) {
    return value.trim();
  }

  if (email?.includes("@")) {
    return email.split("@")[0] ?? "Admin";
  }

  return "Admin";
}
