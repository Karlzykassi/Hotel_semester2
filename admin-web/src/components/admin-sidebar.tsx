"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  CalendarRange,
  FileText,
  Home,
  LayoutDashboard,
  LogOut,
  ShieldCheck,
  Users,
} from "lucide-react";
import { logoutAction } from "@/app/login/actions";
import { BrandMark } from "@/components/brand-mark";
import type { AdminSession } from "@/lib/types";

type AdminSidebarProps = {
  session: AdminSession;
};

const navItems = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/home", label: "Home", icon: Home },
  { href: "/bookings", label: "Bookings", icon: CalendarRange },
  { href: "/reports", label: "Report & Save", icon: FileText },
  { href: "/members", label: "Members", icon: Users },
  { href: "/admins", label: "Admins", icon: ShieldCheck },
];

export function AdminSidebar({ session }: AdminSidebarProps) {
  const pathname = usePathname();

  return (
    <aside className="rounded-[32px] bg-[linear-gradient(180deg,#ff7d1f_0%,#ff6200_100%)] text-white panel-shadow lg:sticky lg:top-6 lg:h-[calc(100vh-3rem)] lg:w-[270px] lg:flex-none">
      <div className="flex h-full flex-col px-4 py-5">
        <BrandMark />
        <div className="mt-5 rounded-[24px] bg-white/10 px-4 py-3">
          <p className="text-xs uppercase tracking-[0.24em] text-white/70">
            Signed in
          </p>
          <p className="mt-2 text-lg font-semibold">{session.name}</p>
          <p className="text-sm text-white/75">{session.email}</p>
        </div>
        <nav className="mt-5 grid grid-cols-2 gap-2 lg:grid-cols-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const active = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center gap-3 rounded-2xl px-4 py-3 text-sm font-medium ${
                  active
                    ? "bg-white text-[color:var(--accent)]"
                    : "bg-white/0 text-white/85 hover:bg-white/12 hover:text-white"
                }`}
              >
                <Icon className="h-4 w-4" />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>
        <div className="mt-5 rounded-[24px] border border-white/15 bg-white/8 px-4 py-4 text-sm text-white/80">
          <p className="font-semibold uppercase tracking-[0.22em] text-white/65">
            Workspace
          </p>
          <p className="mt-2">Shared with the Flutter booking app and Supabase backend.</p>
        </div>
        <form action={logoutAction} className="mt-auto pt-5">
          <button
            type="submit"
            className="flex w-full items-center justify-center gap-2 rounded-2xl border border-white/20 bg-white/10 px-4 py-3 text-sm font-semibold text-white hover:bg-white/18"
          >
            <LogOut className="h-4 w-4" />
            Log out
          </button>
        </form>
      </div>
    </aside>
  );
}
