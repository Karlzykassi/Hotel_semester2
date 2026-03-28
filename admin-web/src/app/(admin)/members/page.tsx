import { AdminPage } from "@/components/admin-page";
import { ConfigBanner } from "@/components/config-banner";
import { PanelCard } from "@/components/panel-card";
import { StatCard } from "@/components/stat-card";
import {
  formatDateTime,
  formatNumber,
  getInitials,
  getStatusClasses,
  readQueryValue,
} from "@/lib/formatters";
import { getAdminProfileLabel, getMemberDirectory } from "@/lib/admin-dal";
import type { SearchParams } from "@/lib/types";

function countRecentMembers(createdAtValues: string[]) {
  const thirtyDaysAgo = Date.now() - 30 * 24 * 60 * 60 * 1000;

  return createdAtValues.filter((createdAt) => {
    const joined = new Date(createdAt).getTime();
    return joined >= thirtyDaysAgo;
  }).length;
}

export default async function MembersPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const params = await searchParams;
  const query = readQueryValue(params.query);
  const { session, configurationWarnings, members, admins } =
    await getMemberDirectory(query);
  const profileSession = await getAdminProfileLabel(session);

  const providerCount = new Set(members.map((member) => member.provider)).size;
  const recentCount = countRecentMembers(members.map((member) => member.createdAt));

  const summary = [
    { label: "Members", value: formatNumber(members.length), helper: "Accounts in the directory" },
    { label: "Admins", value: formatNumber(admins.length), helper: "Members with admin access" },
    { label: "Providers", value: formatNumber(providerCount), helper: "Authentication providers in use" },
    {
      label: "New 30 days",
      value: formatNumber(recentCount),
      helper: "Recent signups",
      tone: "accent" as const,
    },
  ];

  return (
    <AdminPage
      title="Members"
      subtitle="Supabase-authenticated accounts using the hotel booking platform."
      session={profileSession}
      search={{
        action: "/members",
        value: query,
        placeholder: "Search member name, email, or provider",
      }}
    >
      <ConfigBanner warnings={configurationWarnings} />
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {summary.map((metric) => (
          <StatCard key={metric.label} metric={metric} />
        ))}
      </section>
      <PanelCard
        title="Member directory"
        subtitle="Joined auth and profile data from the shared Supabase project."
      >
        <div className="overflow-x-auto scrollbar-thin">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b border-[color:var(--line)] text-left text-xs uppercase tracking-[0.18em] text-[color:var(--muted)]">
                <th className="pb-3 pr-4">Member</th>
                <th className="pb-3 pr-4">Provider</th>
                <th className="pb-3 pr-4">Joined</th>
                <th className="pb-3 pr-4">Last sign in</th>
                <th className="pb-3 pr-4">Access</th>
              </tr>
            </thead>
            <tbody>
              {members.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-10 text-center text-[color:var(--muted)]">
                    No members matched this filter.
                  </td>
                </tr>
              ) : (
                members.map((member) => (
                  <tr
                    key={member.id}
                    className="border-b border-[color:var(--line)]/70 last:border-none"
                  >
                    <td className="py-4 pr-4">
                      <div className="flex items-center gap-3">
                        <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[color:var(--accent-soft)] text-sm font-semibold text-[color:var(--accent)]">
                          {getInitials(member.fullName)}
                        </div>
                        <div>
                          <p className="font-semibold text-[color:var(--foreground)]">
                            {member.fullName}
                          </p>
                          <p className="text-xs text-[color:var(--muted)]">
                            {member.email}
                            {member.phone ? ` • ${member.phone}` : ""}
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 pr-4 text-[color:var(--foreground)]">
                      {member.provider}
                    </td>
                    <td className="py-4 pr-4 text-[color:var(--muted)]">
                      {formatDateTime(member.createdAt)}
                    </td>
                    <td className="py-4 pr-4 text-[color:var(--muted)]">
                      {formatDateTime(member.lastSignInAt)}
                    </td>
                    <td className="py-4 pr-4">
                      <div className="flex flex-wrap gap-2">
                        <span
                          className={`rounded-full px-3 py-1 text-xs font-semibold ${getStatusClasses(
                            member.isAdmin ? "active" : "pending",
                          )}`}
                        >
                          {member.isAdmin ? "Admin" : "Member"}
                        </span>
                        <span className="rounded-full bg-[color:var(--surface-soft)] px-3 py-1 text-xs font-semibold text-[color:var(--muted)]">
                          {member.accessSource}
                        </span>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </PanelCard>
    </AdminPage>
  );
}
