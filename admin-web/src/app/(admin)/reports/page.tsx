import Link from "next/link";
import { AdminPage } from "@/components/admin-page";
import { ConfigBanner } from "@/components/config-banner";
import { PanelCard } from "@/components/panel-card";
import { StatCard } from "@/components/stat-card";
import {
  formatCurrency,
  formatDate,
  formatNumber,
  getStatusClasses,
} from "@/lib/formatters";
import { getAdminProfileLabel, getReportData } from "@/lib/admin-dal";
import type { SearchParams } from "@/lib/types";

export default async function ReportsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const params = await searchParams;
  const { session, configurationWarnings, filters, summaryRows, hotelRows } =
    await getReportData(params);
  const profileSession = await getAdminProfileLabel(session);

  const totalRevenue =
    filters.type === "hotel-performance"
      ? hotelRows.reduce((total, row) => total + row.revenue, 0)
      : summaryRows.reduce((total, row) => total + row.revenue, 0);
  const totalGuests =
    filters.type === "hotel-performance"
      ? hotelRows.reduce((total, row) => total + row.guests, 0)
      : summaryRows.reduce((total, row) => total + row.guests, 0);
  const totalRows =
    filters.type === "hotel-performance" ? hotelRows.length : summaryRows.length;

  const exportHref = `/api/reports/export?type=${encodeURIComponent(filters.type)}&startDate=${encodeURIComponent(filters.startDate)}&endDate=${encodeURIComponent(filters.endDate)}&query=${encodeURIComponent(filters.query)}`;

  const summary = [
    { label: "Rows", value: formatNumber(totalRows), helper: "Rows in the active report" },
    { label: "Guests", value: formatNumber(totalGuests), helper: "Guest volume in range" },
    { label: "Revenue", value: formatCurrency(totalRevenue), helper: "Gross value in range" },
    {
      label: "Window",
      value: `${formatDate(filters.startDate)} to ${formatDate(filters.endDate)}`,
      helper: "Report date range",
      tone: "accent" as const,
    },
  ];

  return (
    <AdminPage
      title="Report & Save"
      subtitle="Generate booking summaries or hotel-performance rollups from the shared booking data."
      session={profileSession}
      search={{
        action: "/reports",
        value: filters.query,
        placeholder: "Search booking, guest, or hotel in this report",
        hiddenInputs: {
          type: filters.type,
          startDate: filters.startDate,
          endDate: filters.endDate,
        },
      }}
    >
      <ConfigBanner warnings={configurationWarnings} />
      <PanelCard
        title="Controls"
        subtitle="Choose the report type and date window, then export the filtered result to CSV."
      >
        <form action="/reports" className="grid gap-3 lg:grid-cols-[1.3fr_1fr_1fr_auto_auto]">
          <input type="hidden" name="query" value={filters.query} />
          <label className="space-y-2">
            <span className="text-xs font-semibold uppercase tracking-[0.2em] text-[color:var(--muted)]">
              Report type
            </span>
            <select
              name="type"
              defaultValue={filters.type}
              className="w-full rounded-2xl border border-[color:var(--line)] bg-white px-4 py-3 text-sm text-[color:var(--foreground)] focus:outline-none"
            >
              <option value="booking-summary">Booking summary</option>
              <option value="hotel-performance">Hotel performance</option>
            </select>
          </label>
          <label className="space-y-2">
            <span className="text-xs font-semibold uppercase tracking-[0.2em] text-[color:var(--muted)]">
              Start date
            </span>
            <input
              type="date"
              name="startDate"
              defaultValue={filters.startDate}
              className="w-full rounded-2xl border border-[color:var(--line)] bg-white px-4 py-3 text-sm text-[color:var(--foreground)] focus:outline-none"
            />
          </label>
          <label className="space-y-2">
            <span className="text-xs font-semibold uppercase tracking-[0.2em] text-[color:var(--muted)]">
              End date
            </span>
            <input
              type="date"
              name="endDate"
              defaultValue={filters.endDate}
              className="w-full rounded-2xl border border-[color:var(--line)] bg-white px-4 py-3 text-sm text-[color:var(--foreground)] focus:outline-none"
            />
          </label>
          <button
            type="submit"
            className="self-end rounded-2xl bg-[color:var(--accent)] px-5 py-3 text-sm font-semibold text-white hover:bg-[color:var(--accent-strong)]"
          >
            Generate
          </button>
          <Link
            href={exportHref}
            className="self-end rounded-2xl border border-[color:var(--line)] bg-white px-5 py-3 text-sm font-semibold text-[color:var(--foreground)] hover:border-[color:var(--accent)] hover:text-[color:var(--accent)]"
          >
            Export CSV
          </Link>
        </form>
      </PanelCard>
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {summary.map((metric) => (
          <StatCard key={metric.label} metric={metric} />
        ))}
      </section>
      <PanelCard
        title={filters.type === "hotel-performance" ? "Hotel performance" : "Detailed booking data"}
        subtitle={
          filters.type === "hotel-performance"
            ? "Revenue and guest totals grouped by hotel."
            : "Reservation-level rows in the selected date range."
        }
      >
        <div className="overflow-x-auto scrollbar-thin">
          {filters.type === "hotel-performance" ? (
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b border-[color:var(--line)] text-left text-xs uppercase tracking-[0.18em] text-[color:var(--muted)]">
                  <th className="pb-3 pr-4">Hotel</th>
                  <th className="pb-3 pr-4">City</th>
                  <th className="pb-3 pr-4">Bookings</th>
                  <th className="pb-3 pr-4">Guests</th>
                  <th className="pb-3 pr-4">Revenue</th>
                </tr>
              </thead>
              <tbody>
                {hotelRows.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-10 text-center text-[color:var(--muted)]">
                      No report rows matched this filter.
                    </td>
                  </tr>
                ) : (
                  hotelRows.map((row) => (
                    <tr
                      key={row.hotelName}
                      className="border-b border-[color:var(--line)]/70 last:border-none"
                    >
                      <td className="py-4 pr-4 font-semibold text-[color:var(--foreground)]">
                        {row.hotelName}
                      </td>
                      <td className="py-4 pr-4 text-[color:var(--muted)]">{row.city}</td>
                      <td className="py-4 pr-4 text-[color:var(--foreground)]">{row.bookings}</td>
                      <td className="py-4 pr-4 text-[color:var(--foreground)]">{row.guests}</td>
                      <td className="py-4 pr-4 font-semibold text-[color:var(--foreground)]">
                        {formatCurrency(row.revenue)}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          ) : (
            <table className="min-w-full text-sm">
              <thead>
                <tr className="border-b border-[color:var(--line)] text-left text-xs uppercase tracking-[0.18em] text-[color:var(--muted)]">
                  <th className="pb-3 pr-4">Date</th>
                  <th className="pb-3 pr-4">Booking ID</th>
                  <th className="pb-3 pr-4">Hotel</th>
                  <th className="pb-3 pr-4">Guest</th>
                  <th className="pb-3 pr-4">Guests</th>
                  <th className="pb-3 pr-4">Revenue</th>
                  <th className="pb-3 pr-4">Status</th>
                </tr>
              </thead>
              <tbody>
                {summaryRows.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="py-10 text-center text-[color:var(--muted)]">
                      No report rows matched this filter.
                    </td>
                  </tr>
                ) : (
                  summaryRows.map((row) => (
                    <tr
                      key={row.bookingId}
                      className="border-b border-[color:var(--line)]/70 last:border-none"
                    >
                      <td className="py-4 pr-4 text-[color:var(--muted)]">{formatDate(row.date)}</td>
                      <td className="py-4 pr-4 font-medium text-[color:var(--foreground)]">
                        {row.bookingId.slice(0, 8)}
                      </td>
                      <td className="py-4 pr-4 text-[color:var(--foreground)]">{row.hotelName}</td>
                      <td className="py-4 pr-4 text-[color:var(--foreground)]">{row.guestName}</td>
                      <td className="py-4 pr-4 text-[color:var(--foreground)]">{row.guests}</td>
                      <td className="py-4 pr-4 font-semibold text-[color:var(--foreground)]">
                        {formatCurrency(row.revenue)}
                      </td>
                      <td className="py-4 pr-4">
                        <span
                          className={`rounded-full px-3 py-1 text-xs font-semibold ${getStatusClasses(
                            row.status,
                          )}`}
                        >
                          {row.status}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          )}
        </div>
      </PanelCard>
    </AdminPage>
  );
}
