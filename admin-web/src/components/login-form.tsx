"use client";

import { useActionState, useState } from "react";
import { Eye, EyeOff, LockKeyhole, Mail } from "lucide-react";
import { loginAction, type LoginState } from "@/app/login/actions";

const initialState: LoginState = {};

export function LoginForm() {
  const [showPassword, setShowPassword] = useState(false);
  const [state, action, pending] = useActionState(loginAction, initialState);

  return (
    <form action={action} className="space-y-5">
      <label className="block space-y-2">
        <span className="text-sm font-medium text-[color:var(--muted)]">
          Email account
        </span>
        <span className="flex items-center gap-3 rounded-2xl border border-[color:var(--line)] bg-white px-4 py-3">
          <Mail className="h-4 w-4 text-[color:var(--accent)]" />
          <input
            required
            type="email"
            name="email"
            placeholder="admin@khmerhotel.com"
            className="w-full bg-transparent text-sm text-[color:var(--foreground)] placeholder:text-[color:var(--muted)] focus:outline-none"
          />
        </span>
      </label>
      <label className="block space-y-2">
        <span className="text-sm font-medium text-[color:var(--muted)]">
          Password
        </span>
        <span className="flex items-center gap-3 rounded-2xl border border-[color:var(--line)] bg-white px-4 py-3">
          <LockKeyhole className="h-4 w-4 text-[color:var(--accent)]" />
          <input
            required
            type={showPassword ? "text" : "password"}
            name="password"
            placeholder="Enter password"
            className="w-full bg-transparent text-sm text-[color:var(--foreground)] placeholder:text-[color:var(--muted)] focus:outline-none"
          />
          <button
            type="button"
            onClick={() => setShowPassword((value) => !value)}
            className="text-[color:var(--muted)] hover:text-[color:var(--accent)]"
            aria-label={showPassword ? "Hide password" : "Show password"}
          >
            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
        </span>
      </label>
      {state.error ? (
        <div className="rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          {state.error}
        </div>
      ) : null}
      <button
        type="submit"
        disabled={pending}
        className="w-full rounded-2xl bg-[linear-gradient(135deg,#ff7d1f_0%,#ff6200_100%)] px-4 py-3 text-sm font-semibold text-white panel-shadow hover:-translate-y-0.5 disabled:cursor-not-allowed disabled:opacity-70 disabled:hover:translate-y-0"
      >
        {pending ? "Signing in..." : "Log in"}
      </button>
    </form>
  );
}
