import type { TrendPoint } from "@/lib/types";
import { formatCompactCurrency } from "@/lib/formatters";

type TrendChartProps = {
  data: TrendPoint[];
};

export function TrendChart({ data }: TrendChartProps) {
  const bookingMax = Math.max(...data.map((point) => point.bookings), 1);
  const revenueMax = Math.max(...data.map((point) => point.revenue), 1);
  const width = 620;
  const height = 260;
  const chartHeight = 180;
  const barWidth = 42;
  const gap = 34;

  const polyline = data
    .map((point, index) => {
      const x = 44 + index * (barWidth + gap) + barWidth / 2;
      const y = 28 + chartHeight - (point.revenue / revenueMax) * chartHeight;
      return `${x},${y}`;
    })
    .join(" ");

  return (
    <div className="rounded-[28px] border border-[color:var(--line)] bg-[color:var(--surface)] p-5 panel-shadow">
      <div className="flex flex-col gap-3 border-b border-[color:var(--line)] pb-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h2 className="font-display text-xl font-semibold text-[color:var(--foreground)]">
            Booking Activity
          </h2>
          <p className="mt-1 text-sm text-[color:var(--muted)]">
            Reservation volume and gross booking value over the last 7 days.
          </p>
        </div>
        <div className="flex gap-3 text-xs font-semibold uppercase tracking-[0.2em] text-[color:var(--muted)]">
          <span className="flex items-center gap-2">
            <span className="h-2.5 w-2.5 rounded-full bg-[color:var(--accent)]" />
            Bookings
          </span>
          <span className="flex items-center gap-2">
            <span className="h-2.5 w-2.5 rounded-full bg-sky-400" />
            Revenue
          </span>
        </div>
      </div>
      {data.length === 0 ? (
        <div className="flex h-[260px] items-center justify-center text-sm text-[color:var(--muted)]">
          Add the service role key to load live chart data.
        </div>
      ) : (
        <div className="mt-4 overflow-x-auto scrollbar-thin">
          <svg viewBox={`0 0 ${width} ${height}`} className="min-w-[620px]">
            {[0, 1, 2, 3].map((line) => {
              const y = 28 + (chartHeight / 3) * line;
              return (
                <line
                  key={line}
                  x1="28"
                  x2={width - 24}
                  y1={y}
                  y2={y}
                  stroke="rgba(127,108,96,0.18)"
                  strokeWidth="1"
                />
              );
            })}
            {data.map((point, index) => {
              const x = 44 + index * (barWidth + gap);
              const barHeight = Math.max(
                (point.bookings / bookingMax) * chartHeight,
                10,
              );
              const y = 28 + chartHeight - barHeight;

              return (
                <g key={point.label}>
                  <rect
                    x={x}
                    y={y}
                    rx="12"
                    width={barWidth}
                    height={barHeight}
                    fill="rgba(255,107,0,0.88)"
                  />
                  <text
                    x={x + barWidth / 2}
                    y={height - 16}
                    textAnchor="middle"
                    fontSize="13"
                    fill="rgba(127,108,96,0.9)"
                  >
                    {point.label}
                  </text>
                </g>
              );
            })}
            <polyline
              fill="none"
              stroke="#55a8ff"
              strokeWidth="4"
              strokeLinejoin="round"
              strokeLinecap="round"
              points={polyline}
            />
            {data.map((point, index) => {
              const x = 44 + index * (barWidth + gap) + barWidth / 2;
              const y = 28 + chartHeight - (point.revenue / revenueMax) * chartHeight;

              return (
                <g key={`${point.label}-dot`}>
                  <circle cx={x} cy={y} r="6" fill="#55a8ff" />
                  <circle cx={x} cy={y} r="11" fill="rgba(85,168,255,0.18)" />
                </g>
              );
            })}
          </svg>
          <div className="mt-3 grid gap-3 sm:grid-cols-3">
            {data.slice(-3).map((point) => (
              <div
                key={`${point.label}-summary`}
                className="rounded-2xl bg-[color:var(--surface-soft)] px-4 py-3"
              >
                <p className="text-xs font-semibold uppercase tracking-[0.2em] text-[color:var(--muted)]">
                  {point.label}
                </p>
                <p className="mt-2 text-lg font-semibold text-[color:var(--foreground)]">
                  {point.bookings} bookings
                </p>
                <p className="text-sm text-[color:var(--muted)]">
                  {formatCompactCurrency(point.revenue)}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
