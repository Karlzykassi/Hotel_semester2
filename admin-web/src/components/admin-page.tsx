import type { ReactNode } from "react";
import { Search } from "lucide-react";
import { getInitials } from "@/lib/formatters";
import type { AdminSession } from "@/lib/types";

type SearchConfig = {
  action: string;
  value: string;
  placeholder: string;
  hiddenInputs?: Record<string, string>;
};

type AdminPageProps = {
  title: string;
  subtitle: string;
  session: AdminSession;
  search?: SearchConfig;
  children: ReactNode;
};

export function AdminPage({
  title,
  subtitle,
  session,
  search,
  children,
}: AdminPageProps) {
  return (
    <div className="space-y-4">
      <header className="rounded-[30px] bg-[linear-gradient(135deg,#ff7d1f_0%,#ff6500_100%)] px-5 py-5 text-white panel-shadow">
        <div className="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.28em] text-white/70">
              Khmer Hotel Admin
            </p>
            <h1 className="mt-2 font-display text-3xl font-semibold">{title}</h1>
            <p className="mt-1 max-w-2xl text-sm text-white/85">{subtitle}</p>
          </div>
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            {search ? (
              <form
                action={search.action}
                className="flex items-center gap-3 rounded-full border border-white/20 bg-white/10 px-4 py-3 backdrop-blur"
              >
                <Search className="h-4 w-4 text-white/80" />
                <input
                  type="search"
                  name="query"
                  defaultValue={search.value}
                  placeholder={search.placeholder}
                  className="min-w-[180px] bg-transparent text-sm text-white placeholder:text-white/65 focus:outline-none"
                />
                {Object.entries(search.hiddenInputs ?? {}).map(([key, value]) => (
                  <input key={key} type="hidden" name={key} value={value} />
                ))}
              </form>
            ) : null}
            <div className="flex items-center gap-3 rounded-full border border-white/15 bg-white/10 px-3 py-2 backdrop-blur">
              <div className="flex h-11 w-11 items-center justify-center rounded-full bg-white text-sm font-semibold text-[color:var(--accent)]">
                {getInitials(session.name)}
              </div>
              <div>
                <p className="text-sm font-semibold">{session.name}</p>
                <p className="text-xs text-white/75">{session.email}</p>
              </div>
            </div>
          </div>
        </div>
      </header>
      {children}
    </div>
  );
}
