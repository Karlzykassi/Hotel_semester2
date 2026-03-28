import { AdminPage } from "@/components/admin-page";
import { ConfigBanner } from "@/components/config-banner";
import { PanelCard } from "@/components/panel-card";
import { StatCard } from "@/components/stat-card";
import {
  formatDateTime,
  formatNumber,
  getInitials,
  readQueryValue,
} from "@/lib/formatters";
import { getAdminAllowlist } from "@/lib/admin-access";
import { getAdminProfileLabel, getMemberDirectory } from "@/lib/admin-dal";
import type { SearchParams } from "@/lib/types";

export default async function AdminsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const params = await searchParams;
  const query = readQueryValue(params.query);
  const { session, configurationWarnings, admins } = await getMemberDirectory(query);
  const profileSession = await getAdminProfileLabel(session);
  const allowlist = getAdminAllowlist();

  const summary = [
    { label: "Admins", value: formatNumber(admins.length), helper: "Admin accounts currently visible" },
    { label: "Allowlist", value: formatNumber(allowlist.length), helper: "Emails in ADMIN_EMAILS" },
    {
      label: "Metadata role",
      value: formatNumber(
        admins.filter((admin) => admin.accessSource === "app_metadata.role").length,
      ),
      helper: "Admins granted through auth metadata",
    },
    {
      label: "Shared backend",
      value: "Supabase",
      helper: "Same project as the Flutter app",
      tone: "accent" as const,
    },
  ];

  return (
    <AdminPage
      title="Admins"
      subtitle="Who can open the panel and how their access is being granted."
      session={profileSession}
      search={{
        action: "/admins",
        value: query,
        placeholder: "Search admin name or email",
      }}
    >
      <ConfigBanner warnings={configurationWarnings} />
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {summary.map((metric) => (
          <StatCard key={metric.label} metric={metric} />
        ))}
      </section>
      <section className="grid gap-4 xl:grid-cols-[1.15fr_0.85fr]">
        <PanelCard
          title="Admin accounts"
          subtitle="Admin users are resolved from the allowlist or `app_metadata.role = admin`."
        >
          <div className="space-y-3">
            {admins.length === 0 ? (
              <p className="py-6 text-center text-sm text-[color:var(--muted)]">
                No admin accounts matched this filter yet.
              </p>
            ) : (
              admins.map((admin) => (
                <div
                  key={admin.id}
                  className="flex items-center justify-between gap-3 rounded-[22px] border border-[color:var(--line)] bg-white px-4 py-4"
                >
                  <div className="flex min-w-0 items-center gap-3">
                    <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[color:var(--accent-soft)] text-sm font-semibold text-[color:var(--accent)]">
                      {getInitials(admin.fullName)}
                    </div>
                    <div className="min-w-0">
                      <p className="truncate font-semibold text-[color:var(--foreground)]">
                        {admin.fullName}
                      </p>
                      <p className="truncate text-sm text-[color:var(--muted)]">{admin.email}</p>
                    </div>
                  </div>
                  <div className="text-right text-xs text-[color:var(--muted)]">
                    <p className="font-semibold text-[color:var(--foreground)]">
                      {admin.accessSource}
                    </p>
                    <p>{formatDateTime(admin.lastSignInAt)}</p>
                  </div>
                </div>
              ))
            )}
          </div>
        </PanelCard>
        <PanelCard
          title="Configured allowlist"
          subtitle="Comma-separated emails read from `ADMIN_EMAILS`."
        >
          <div className="space-y-3">
            {allowlist.length === 0 ? (
              <p className="rounded-[22px] bg-[color:var(--surface-soft)] px-4 py-4 text-sm text-[color:var(--muted)]">
                No emails are configured yet. Add `ADMIN_EMAILS` in `.env.local` to grant access.
              </p>
            ) : (
              allowlist.map((email) => (
                <div
                  key={email}
                  className="flex items-center justify-between rounded-[22px] bg-[color:var(--surface-soft)] px-4 py-3"
                >
                  <span className="font-medium text-[color:var(--foreground)]">{email}</span>
                  <span className="text-xs uppercase tracking-[0.18em] text-[color:var(--muted)]">
                    Allowlisted
                  </span>
                </div>
              ))
            )}
          </div>
        </PanelCard>
      </section>
    </AdminPage>
  );
}
