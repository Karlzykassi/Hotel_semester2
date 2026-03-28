import { redirect } from "next/navigation";
import { readAdminSession } from "@/lib/admin-session";

export default async function Home() {
  const session = await readAdminSession();

  redirect(session ? "/dashboard" : "/login");
}
