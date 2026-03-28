type BrandMarkProps = {
  tone?: "light" | "accent";
  compact?: boolean;
};

export function BrandMark({
  tone = "light",
  compact = false,
}: BrandMarkProps) {
  const textClass =
    tone === "light" ? "text-white" : "text-[color:var(--accent)]";
  const mutedClass =
    tone === "light" ? "text-white/75" : "text-[color:var(--muted)]";
  const frameClass =
    tone === "light"
      ? "bg-white/12 ring-white/20"
      : "bg-[color:var(--accent-soft)] ring-[color:var(--accent)]/10";
  const barClass = tone === "light" ? "bg-white" : "bg-[color:var(--accent)]";
  const topBarClass =
    tone === "light" ? "bg-white/45" : "bg-[color:var(--accent)]/35";

  return (
    <div className="flex items-center gap-3">
      <div
        className={`relative flex h-11 w-11 items-end justify-center rounded-2xl ring-1 ${frameClass}`}
      >
        <span className={`absolute inset-x-2 top-2 h-1 rounded-full ${topBarClass}`} />
        <span className={`mb-2 h-6 w-1 rounded-full ${barClass}`} />
        <span className={`mb-2 ml-1 h-8 w-1 rounded-full ${barClass}`} />
        <span className={`mb-2 ml-1 h-10 w-1 rounded-full ${barClass}`} />
        <span className={`mb-2 ml-1 h-7 w-1 rounded-full ${barClass}`} />
      </div>
      <div>
        <p className={`font-display text-[0.72rem] uppercase tracking-[0.34em] ${mutedClass}`}>
          Khmer Hotel
        </p>
        {!compact ? (
          <p className={`text-sm font-semibold ${textClass}`}>Admin Suite</p>
        ) : null}
      </div>
    </div>
  );
}
