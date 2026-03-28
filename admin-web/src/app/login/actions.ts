"use server";

import { redirect } from "next/navigation";
import { createAdminSession, clearAdminSession } from "@/lib/admin-session";
import { getDisplayName, isAllowedAdminUser } from "@/lib/admin-access";
import { getPublicSupabaseClient } from "@/lib/supabase";

export type LoginState = {
  error?: string;
};

export async function loginAction(
  _previousState: LoginState | undefined,
  formData: FormData,
) {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return {
      error: "Email and password are both required.",
    } satisfies LoginState;
  }

  const supabase = getPublicSupabaseClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error || !data.user) {
    return {
      error: "Unable to sign in with those credentials.",
    } satisfies LoginState;
  }

  if (!isAllowedAdminUser(data.user)) {
    return {
      error:
        "This account can sign in, but it has not been granted admin-panel access yet.",
    } satisfies LoginState;
  }

  await createAdminSession({
    userId: data.user.id,
    email: data.user.email ?? email,
    name: getDisplayName(
      typeof data.user.user_metadata?.full_name === "string"
        ? data.user.user_metadata.full_name
        : null,
      data.user.email ?? email,
    ),
  });

  redirect("/dashboard");
}

export async function logoutAction() {
  await clearAdminSession();
  redirect("/login");
}
