import { NextResponse } from "next/server";
import { readAdminSession } from "@/lib/admin-session";
import { getReportData } from "@/lib/admin-dal";
import { toBookingSummaryCsv, toHotelPerformanceCsv } from "@/lib/reporting";

export async function GET(request: Request) {
  const session = await readAdminSession();

  if (!session) {
    return new NextResponse("Unauthorized", { status: 401 });
  }

  const url = new URL(request.url);
  const params = Object.fromEntries(url.searchParams.entries());
  const report = await getReportData(params);

  const csv =
    report.filters.type === "hotel-performance"
      ? toHotelPerformanceCsv(report.hotelRows)
      : toBookingSummaryCsv(report.summaryRows);
  const filename =
    report.filters.type === "hotel-performance"
      ? "hotel-performance-report.csv"
      : "booking-summary-report.csv";

  return new NextResponse(csv, {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="${filename}"`,
      "Cache-Control": "no-store",
    },
  });
}
