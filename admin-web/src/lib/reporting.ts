import type {
  BookingSummaryRow,
  HotelPerformanceRow,
} from "@/lib/types";
import { formatCurrency } from "@/lib/formatters";

export function toBookingSummaryCsv(rows: BookingSummaryRow[]) {
  const lines = [
    ["Date", "Booking ID", "Hotel", "Guest", "Guests", "Revenue", "Status"],
    ...rows.map((row) => [
      row.date,
      row.bookingId,
      row.hotelName,
      row.guestName,
      String(row.guests),
      formatCurrency(row.revenue),
      row.status,
    ]),
  ];

  return lines
    .map((line) => line.map(escapeCsvValue).join(","))
    .join("\n");
}

export function toHotelPerformanceCsv(rows: HotelPerformanceRow[]) {
  const lines = [
    ["Hotel", "City", "Bookings", "Guests", "Revenue"],
    ...rows.map((row) => [
      row.hotelName,
      row.city,
      String(row.bookings),
      String(row.guests),
      formatCurrency(row.revenue),
    ]),
  ];

  return lines
    .map((line) => line.map(escapeCsvValue).join(","))
    .join("\n");
}

function escapeCsvValue(value: string) {
  const escaped = value.replaceAll('"', '""');
  return `"${escaped}"`;
}
