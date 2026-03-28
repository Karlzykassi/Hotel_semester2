import type { ReactNode } from "react";
import { AdminShell } from "@/components/admin-shell";
import { getAdminProfileLabel, getAdminPageContext } from "@/lib/admin-dal";

export default async function AdminLayout({
  children,
}: {
  children: ReactNode;
}) {
  const { session } = await getAdminPageContext();
  const profileSession = await getAdminProfileLabel(session);

  return <AdminShell session={profileSession}>{children}</AdminShell>;
}
