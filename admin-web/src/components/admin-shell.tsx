import type { ReactNode } from "react";
import { AdminSidebar } from "@/components/admin-sidebar";
import type { AdminSession } from "@/lib/types";

type AdminShellProps = {
  session: AdminSession;
  children: ReactNode;
};

export function AdminShell({ session, children }: AdminShellProps) {
  return (
    <div className="min-h-screen px-3 py-3 lg:px-6 lg:py-6">
      <div className="mx-auto flex max-w-[1600px] flex-col gap-4 lg:flex-row">
        <AdminSidebar session={session} />
        <main className="min-w-0 flex-1">{children}</main>
      </div>
    </div>
  );
}
