import { AdminPage } from "@/components/admin-page";
import { ConfigBanner } from "@/components/config-banner";
import { PanelCard } from "@/components/panel-card";
import { StatCard } from "@/components/stat-card";
import { TrendChart } from "@/components/trend-chart";
import { formatCurrency, formatDate, getStatusClasses, readQueryValue } from "@/lib/formatters";
import { getAdminProfileLabel, getDashboardData } from "@/lib/admin-dal";
import type { SearchParams } from "@/lib/types";

export default async function DashboardPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const params = await searchParams;
  const query = readQueryValue(params.query);
  const { session, configurationWarnings, metrics, trend, recentBookings } =
    await getDashboardData(query);
  const profileSession = await getAdminProfileLabel(session);

  return (
    <AdminPage
      title="Dashboard"
      subtitle="A live operating snapshot of the hotel-booking platform."
      session={profileSession}
      search={{
        action: "/dashboard",
        value: query,
        placeholder: "Search bookings, guests, or hotels",
      }}
    >
      <ConfigBanner warnings={configurationWarnings} />
      <section className="grid gap-4 2xl:grid-cols-[1.65fr_1fr]">
        <TrendChart data={trend} />
        <div className="grid gap-4 sm:grid-cols-2">
          {metrics.map((metric, index) => (
            <div key={metric.label} className={index === 3 ? "sm:col-span-2" : ""}>
              <StatCard metric={metric} />
            </div>
          ))}
        </div>
      </section>
      <PanelCard
        title="Latest bookings"
        subtitle="Recently created reservations flowing in from the mobile app."
      >
        <div className="overflow-x-auto scrollbar-thin">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b border-[color:var(--line)] text-left text-xs uppercase tracking-[0.18em] text-[color:var(--muted)]">
                <th className="pb-3 pr-4">Booking</th>
                <th className="pb-3 pr-4">Guest</th>
                <th className="pb-3 pr-4">Stay</th>
                <th className="pb-3 pr-4">Status</th>
                <th className="pb-3 pr-4">Total</th>
              </tr>
            </thead>
            <tbody>
              {recentBookings.length === 0 ? (
                <tr>
                  <td
                    colSpan={5}
                    className="py-10 text-center text-[color:var(--muted)]"
                  >
                    No booking data is available yet.
                  </td>
                </tr>
              ) : (
                recentBookings.map((booking) => (
                  <tr
                    key={booking.id}
                    className="border-b border-[color:var(--line)]/70 last:border-none"
                  >
                    <td className="py-4 pr-4">
                      <p className="font-semibold text-[color:var(--foreground)]">
                        {booking.hotelName}
                      </p>
                      <p className="text-xs text-[color:var(--muted)]">
                        {booking.id.slice(0, 8)} • {formatDate(booking.createdAt)}
                      </p>
                    </td>
                    <td className="py-4 pr-4">
                      <p className="font-medium text-[color:var(--foreground)]">
                        {booking.guestName}
                      </p>
                      <p className="text-xs text-[color:var(--muted)]">{booking.email}</p>
                    </td>
                    <td className="py-4 pr-4 text-[color:var(--muted)]">
                      {formatDate(booking.checkInDate)} to {formatDate(booking.checkOutDate)}
                    </td>
                    <td className="py-4 pr-4">
                      <div className="flex flex-wrap gap-2">
                        <span
                          className={`rounded-full px-3 py-1 text-xs font-semibold ${getStatusClasses(
                            booking.status,
                          )}`}
                        >
                          {booking.status}
                        </span>
                        <span
                          className={`rounded-full px-3 py-1 text-xs font-semibold ${getStatusClasses(
                            booking.paymentStatus,
                          )}`}
                        >
                          {booking.paymentStatus}
                        </span>
                      </div>
                    </td>
                    <td className="py-4 pr-4 font-semibold text-[color:var(--foreground)]">
                      {formatCurrency(booking.total)}
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
