import type { ReactNode } from "react";

type PanelCardProps = {
  title: string;
  subtitle?: string;
  action?: ReactNode;
  children: ReactNode;
  className?: string;
};

export function PanelCard({
  title,
  subtitle,
  action,
  children,
  className = "",
}: PanelCardProps) {
  return (
    <section
      className={`rounded-[28px] border border-[color:var(--line)] bg-[color:var(--surface)] p-5 panel-shadow ${className}`}
    >
      <div className="flex flex-col gap-3 border-b border-[color:var(--line)] pb-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h2 className="font-display text-xl font-semibold text-[color:var(--foreground)]">
            {title}
          </h2>
          {subtitle ? (
            <p className="mt-1 text-sm text-[color:var(--muted)]">{subtitle}</p>
          ) : null}
        </div>
        {action}
      </div>
      <div className="pt-4">{children}</div>
    </section>
  );
}
