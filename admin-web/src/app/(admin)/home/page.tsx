import { AdminPage } from "@/components/admin-page";
import { ConfigBanner } from "@/components/config-banner";
import { PanelCard } from "@/components/panel-card";
import { StatCard } from "@/components/stat-card";
import {
  formatCurrency,
  formatDateTime,
  getInitials,
  readQueryValue,
} from "@/lib/formatters";
import { getAdminProfileLabel, getHomeOverviewData } from "@/lib/admin-dal";
import type { SearchParams } from "@/lib/types";

export default async function HomePage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const params = await searchParams;
  const query = readQueryValue(params.query);
  const { session, configurationWarnings, summary, recentMembers, activeHotels } =
    await getHomeOverviewData(query);
  const profileSession = await getAdminProfileLabel(session);

  return (
    <AdminPage
      title="Home"
      subtitle="Operational overview of destinations, members, and active hotel listings."
      session={profileSession}
      search={{
        action: "/home",
        value: query,
        placeholder: "Search members or hotel listings",
      }}
    >
      <ConfigBanner warnings={configurationWarnings} />
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {summary.map((metric) => (
          <StatCard key={metric.label} metric={metric} />
        ))}
      </section>
      <section className="grid gap-4 xl:grid-cols-2">
        <PanelCard
          title="Recent members"
          subtitle="Newest accounts created through Supabase authentication."
        >
          <div className="space-y-3">
            {recentMembers.length === 0 ? (
              <p className="py-6 text-center text-sm text-[color:var(--muted)]">
                No member records are available.
              </p>
            ) : (
              recentMembers.map((member) => (
                <div
                  key={member.id}
                  className="flex items-center justify-between gap-3 rounded-[22px] bg-[color:var(--surface-soft)] px-4 py-3"
                >
                  <div className="flex min-w-0 items-center gap-3">
                    <div className="flex h-11 w-11 items-center justify-center rounded-full bg-white text-sm font-semibold text-[color:var(--accent)]">
                      {getInitials(member.fullName)}
                    </div>
                    <div className="min-w-0">
                      <p className="truncate font-semibold text-[color:var(--foreground)]">
                        {member.fullName}
                      </p>
                      <p className="truncate text-sm text-[color:var(--muted)]">
                        {member.email}
                      </p>
                    </div>
                  </div>
                  <div className="text-right text-xs text-[color:var(--muted)]">
                    <p>{member.provider}</p>
                    <p>{formatDateTime(member.createdAt)}</p>
                  </div>
                </div>
              ))
            )}
          </div>
        </PanelCard>
        <PanelCard
          title="Active listings"
          subtitle="Live hotel cards sourced from the shared booking inventory."
        >
          <div className="space-y-3">
            {activeHotels.length === 0 ? (
              <p className="py-6 text-center text-sm text-[color:var(--muted)]">
                No hotels matched this search.
              </p>
            ) : (
              activeHotels.map((hotel) => (
                <div
                  key={hotel.id}
                  className="rounded-[22px] border border-[color:var(--line)] bg-white px-4 py-4"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold text-[color:var(--foreground)]">
                        {hotel.name}
                      </p>
                      <p className="mt-1 text-sm text-[color:var(--muted)]">{hotel.city}</p>
                    </div>
                    <span className="rounded-full bg-[color:var(--accent-soft)] px-3 py-1 text-xs font-semibold text-[color:var(--accent)]">
                      {hotel.rating.toFixed(1)} rating
                    </span>
                  </div>
                  <div className="mt-4 flex items-center justify-between text-sm">
                    <span className="text-[color:var(--muted)]">
                      {hotel.reviewCount} reviews
                    </span>
                    <span className="font-semibold text-[color:var(--foreground)]">
                      From {formatCurrency(hotel.priceFrom)}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        </PanelCard>
      </section>
    </AdminPage>
  );
}
