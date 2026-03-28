import { redirect } from "next/navigation";
import { BrandMark } from "@/components/brand-mark";
import { LoginForm } from "@/components/login-form";
import { getAdminConfigurationWarnings } from "@/lib/env";
import { readAdminSession } from "@/lib/admin-session";

export default async function LoginPage() {
  const session = await readAdminSession();

  if (session) {
    redirect("/dashboard");
  }

  const warnings = getAdminConfigurationWarnings();

  return (
    <main className="flex min-h-screen items-center justify-center px-4 py-8">
      <div className="grid w-full max-w-6xl gap-6 xl:grid-cols-[1.05fr_0.95fr]">
        <section className="relative overflow-hidden rounded-[36px] bg-[linear-gradient(145deg,#ff7d1f_0%,#ff6200_100%)] px-8 py-10 text-white panel-shadow">
          <div className="absolute -right-14 top-8 h-48 w-48 rounded-full bg-white/10 blur-3xl" />
          <div className="absolute bottom-0 left-0 h-40 w-40 rounded-full bg-white/10 blur-3xl" />
          <div className="relative">
            <BrandMark />
            <p className="mt-12 text-xs font-semibold uppercase tracking-[0.3em] text-white/70">
              Welcome to Admin Panel
            </p>
            <h1 className="mt-3 max-w-xl font-display text-5xl font-semibold leading-tight text-balance">
              Manage hotels, bookings, members, and reports from one place.
            </h1>
            <p className="mt-5 max-w-xl text-base leading-7 text-white/85">
              This dashboard connects directly to your existing Supabase project so the
              admin experience stays in sync with the Flutter booking app.
            </p>
            <div className="mt-10 grid gap-4 sm:grid-cols-3">
              <div className="rounded-[24px] border border-white/15 bg-white/10 px-4 py-4 backdrop-blur">
                <p className="text-xs uppercase tracking-[0.22em] text-white/70">
                  Shared Data
                </p>
                <p className="mt-2 text-lg font-semibold">Hotels and bookings</p>
              </div>
              <div className="rounded-[24px] border border-white/15 bg-white/10 px-4 py-4 backdrop-blur">
                <p className="text-xs uppercase tracking-[0.22em] text-white/70">
                  Access
                </p>
                <p className="mt-2 text-lg font-semibold">Allowed admins only</p>
              </div>
              <div className="rounded-[24px] border border-white/15 bg-white/10 px-4 py-4 backdrop-blur">
                <p className="text-xs uppercase tracking-[0.22em] text-white/70">
                  Stack
                </p>
                <p className="mt-2 text-lg font-semibold">Next.js + Supabase</p>
              </div>
            </div>
          </div>
        </section>
        <section className="rounded-[36px] border border-[color:var(--line)] bg-[color:var(--surface)] px-6 py-8 panel-shadow sm:px-8">
          <BrandMark tone="accent" compact />
          <div className="mt-10">
            <p className="text-xs font-semibold uppercase tracking-[0.26em] text-[color:var(--muted)]">
              Sign in
            </p>
            <h2 className="mt-3 font-display text-4xl font-semibold text-[color:var(--foreground)]">
              Welcome back
            </h2>
            <p className="mt-2 text-sm leading-6 text-[color:var(--muted)]">
              Use an admin-approved Supabase account. Access is granted through
              `ADMIN_EMAILS` or `app_metadata.role = admin`.
            </p>
          </div>
          <div className="mt-8">
            <LoginForm />
          </div>
          {warnings.length > 0 ? (
            <div className="mt-8 rounded-[24px] border border-amber-200 bg-amber-50 px-4 py-4 text-sm text-amber-900">
              <p className="font-semibold uppercase tracking-[0.24em] text-amber-700">
                Setup reminders
              </p>
              <ul className="mt-3 space-y-2">
                {warnings.map((warning) => (
                  <li key={warning}>{warning}</li>
                ))}
              </ul>
            </div>
          ) : null}
        </section>
      </div>
    </main>
  );
}
