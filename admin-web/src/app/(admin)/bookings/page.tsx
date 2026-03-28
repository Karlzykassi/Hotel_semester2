import { AdminPage } from "@/components/admin-page";
import { ConfigBanner } from "@/components/config-banner";
import { PanelCard } from "@/components/panel-card";
import { StatCard } from "@/components/stat-card";
import {
  updateBookingStatusAction,
  updatePaymentStatusAction,
} from "@/app/(admin)/bookings/actions";
import {
  formatCurrency,
  formatDate,
  formatNumber,
  getStatusClasses,
  readQueryValue,
} from "@/lib/formatters";
import { getAdminProfileLabel, getBookingsPageData } from "@/lib/admin-dal";
import type { BookingListItem, SearchParams } from "@/lib/types";

function BookingActionButtons({
  booking,
  query,
}: {
  booking: BookingListItem;
  query: string;
}) {
  return (
    <div className="flex flex-wrap gap-2">
      {booking.status === "pending" ? (
        <form action={updateBookingStatusAction}>
          <input type="hidden" name="bookingId" value={booking.id} />
          <input type="hidden" name="nextStatus" value="confirmed" />
          <input type="hidden" name="query" value={query} />
          <button
            type="submit"
            className="rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700 hover:bg-emerald-200"
          >
            Confirm
          </button>
        </form>
      ) : null}
      {booking.status === "confirmed" ? (
        <form action={updateBookingStatusAction}>
          <input type="hidden" name="bookingId" value={booking.id} />
          <input type="hidden" name="nextStatus" value="completed" />
          <input type="hidden" name="query" value={query} />
          <button
            type="submit"
            className="rounded-full bg-sky-100 px-3 py-1 text-xs font-semibold text-sky-700 hover:bg-sky-200"
          >
            Complete
          </button>
        </form>
      ) : null}
      {booking.status !== "cancelled" && booking.status !== "completed" ? (
        <form action={updateBookingStatusAction}>
          <input type="hidden" name="bookingId" value={booking.id} />
          <input type="hidden" name="nextStatus" value="cancelled" />
          <input type="hidden" name="query" value={query} />
          <button
            type="submit"
            className="rounded-full bg-rose-100 px-3 py-1 text-xs font-semibold text-rose-700 hover:bg-rose-200"
          >
            Cancel
          </button>
        </form>
      ) : null}
      {booking.paymentStatus !== "paid" && booking.status !== "cancelled" ? (
        <form action={updatePaymentStatusAction}>
          <input type="hidden" name="bookingId" value={booking.id} />
          <input type="hidden" name="nextPaymentStatus" value="paid" />
          <input type="hidden" name="query" value={query} />
          <button
            type="submit"
            className="rounded-full bg-amber-100 px-3 py-1 text-xs font-semibold text-amber-700 hover:bg-amber-200"
          >
            Mark paid
          </button>
        </form>
      ) : null}
    </div>
  );
}

export default async function BookingsPage({
  searchParams,
}: {
  searchParams: SearchParams;
}) {
  const params = await searchParams;
  const query = readQueryValue(params.query);
  const notice = readQueryValue(params.notice);
  const error = readQueryValue(params.error);
  const { session, configurationWarnings, bookings } = await getBookingsPageData(query);
  const profileSession = await getAdminProfileLabel(session);

  const confirmedCount = bookings.filter((booking) => booking.status === "confirmed").length;
  const pendingCount = bookings.filter((booking) => booking.status === "pending").length;
  const revenue = bookings
    .filter((booking) => booking.status !== "cancelled")
    .reduce((total, booking) => total + booking.total, 0);

  const summary = [
    { label: "Rows", value: formatNumber(bookings.length), helper: "Filtered booking records" },
    { label: "Confirmed", value: formatNumber(confirmedCount), helper: "Reservations approved" },
    { label: "Pending", value: formatNumber(pendingCount), helper: "Bookings awaiting action" },
    {
      label: "Revenue",
      value: formatCurrency(revenue),
      helper: "Gross booking value in this table",
      tone: "accent" as const,
    },
  ];

  return (
    <AdminPage
      title="Bookings"
      subtitle="Full reservation log with live guest, stay, payment, and admin confirmation actions."
      session={profileSession}
      search={{
        action: "/bookings",
        value: query,
        placeholder: "Search booking ID, guest, status, or hotel",
      }}
    >
      <ConfigBanner warnings={configurationWarnings} />
      {notice ? (
        <div className="rounded-[24px] border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700 panel-shadow">
          {notice}
        </div>
      ) : null}
      {error ? (
        <div className="rounded-[24px] border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700 panel-shadow">
          {error}
        </div>
      ) : null}
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {summary.map((metric) => (
          <StatCard key={metric.label} metric={metric} />
        ))}
      </section>
      <PanelCard
        title="Bookings"
        subtitle="Use this page as the hotel-owner confirmation workflow while you do not have a separate owner portal."
      >
        <div className="overflow-x-auto scrollbar-thin">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="border-b border-[color:var(--line)] text-left text-xs uppercase tracking-[0.18em] text-[color:var(--muted)]">
                <th className="pb-3 pr-4">Guest</th>
                <th className="pb-3 pr-4">Hotel</th>
                <th className="pb-3 pr-4">Check in</th>
                <th className="pb-3 pr-4">Check out</th>
                <th className="pb-3 pr-4">Guests</th>
                <th className="pb-3 pr-4">Status</th>
                <th className="pb-3 pr-4">Total</th>
                <th className="pb-3 pr-4">Actions</th>
              </tr>
            </thead>
            <tbody>
              {bookings.length === 0 ? (
                <tr>
                  <td
                    colSpan={8}
                    className="py-10 text-center text-[color:var(--muted)]"
                  >
                    No bookings matched this filter.
                  </td>
                </tr>
              ) : (
                bookings.map((booking) => (
                  <tr
                    key={booking.id}
                    className="border-b border-[color:var(--line)]/70 last:border-none"
                  >
                    <td className="py-4 pr-4">
                      <p className="font-semibold text-[color:var(--foreground)]">
                        {booking.guestName}
                      </p>
                      <p className="text-xs text-[color:var(--muted)]">
                        {booking.email} | {booking.id.slice(0, 8)}
                      </p>
                    </td>
                    <td className="py-4 pr-4">
                      <p className="font-medium text-[color:var(--foreground)]">
                        {booking.hotelName}
                      </p>
                      <p className="text-xs text-[color:var(--muted)]">
                        {booking.roomTypeName}
                      </p>
                    </td>
                    <td className="py-4 pr-4 text-[color:var(--muted)]">
                      {formatDate(booking.checkInDate)}
                    </td>
                    <td className="py-4 pr-4 text-[color:var(--muted)]">
                      {formatDate(booking.checkOutDate)}
                    </td>
                    <td className="py-4 pr-4 text-[color:var(--foreground)]">
                      {booking.guestCount}
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
                    <td className="py-4 pr-4">
                      <BookingActionButtons booking={booking} query={query} />
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
