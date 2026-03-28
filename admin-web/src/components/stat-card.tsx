import type { DashboardMetric } from "@/lib/types";

type StatCardProps = {
  metric: DashboardMetric;
};

export function StatCard({ metric }: StatCardProps) {
  const accent = metric.tone === "accent";

  return (
    <article
      className={`rounded-[26px] border px-5 py-4 panel-shadow ${
        accent
          ? "border-[color:var(--accent)] bg-[linear-gradient(180deg,#ff7815_0%,#ff6500_100%)] text-white"
          : "border-[color:var(--line)] bg-[color:var(--surface)] text-[color:var(--foreground)]"
      }`}
    >
      <p
        className={`text-xs font-semibold uppercase tracking-[0.25em] ${
          accent ? "text-white/75" : "text-[color:var(--muted)]"
        }`}
      >
        {metric.label}
      </p>
      <p className="mt-4 font-display text-3xl font-semibold">{metric.value}</p>
      <p className={`mt-2 text-sm ${accent ? "text-white/80" : "text-[color:var(--muted)]"}`}>
        {metric.helper}
      </p>
    </article>
  );
}
