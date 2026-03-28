"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { requireAdminSession } from "@/lib/admin-session";
import { getServiceSupabaseClient } from "@/lib/supabase";

const bookingStatuses = new Set([
  "pending",
  "confirmed",
  "completed",
  "cancelled",
  "saved",
]);

const paymentStatuses = new Set([
  "unpaid",
  "pending",
  "paid",
  "failed",
  "refunded",
]);

function buildBookingsHref(
  query: string,
  options?: {
    notice?: string;
    error?: string;
  },
) {
  const params = new URLSearchParams();

  if (query) {
    params.set("query", query);
  }

  if (options?.notice) {
    params.set("notice", options.notice);
  }

  if (options?.error) {
    params.set("error", options.error);
  }

  const search = params.toString();
  return search ? `/bookings?${search}` : "/bookings";
}

function revalidateAdminViews() {
  revalidatePath("/bookings");
  revalidatePath("/dashboard");
  revalidatePath("/reports");
}

export async function updateBookingStatusAction(formData: FormData) {
  await requireAdminSession();

  const bookingId = String(formData.get("bookingId") ?? "").trim();
  const nextStatus = String(formData.get("nextStatus") ?? "").trim();
  const query = String(formData.get("query") ?? "").trim();

  if (!bookingId || !bookingStatuses.has(nextStatus)) {
    redirect(
      buildBookingsHref(query, {
        error: "Invalid booking action.",
      }),
    );
  }

  const supabase = getServiceSupabaseClient();

  if (!supabase) {
    redirect(
      buildBookingsHref(query, {
        error: "Missing service role key for admin updates.",
      }),
    );
  }

  const { error } = await supabase
    .from("bookings")
    .update({ status: nextStatus })
    .eq("id", bookingId);

  if (error) {
    redirect(
      buildBookingsHref(query, {
        error: error.message,
      }),
    );
  }

  revalidateAdminViews();

  redirect(
    buildBookingsHref(query, {
      notice: `Booking updated to ${nextStatus}.`,
    }),
  );
}

export async function updatePaymentStatusAction(formData: FormData) {
  await requireAdminSession();

  const bookingId = String(formData.get("bookingId") ?? "").trim();
  const nextPaymentStatus = String(formData.get("nextPaymentStatus") ?? "").trim();
  const query = String(formData.get("query") ?? "").trim();

  if (!bookingId || !paymentStatuses.has(nextPaymentStatus)) {
    redirect(
      buildBookingsHref(query, {
        error: "Invalid payment action.",
      }),
    );
  }

  const supabase = getServiceSupabaseClient();

  if (!supabase) {
    redirect(
      buildBookingsHref(query, {
        error: "Missing service role key for admin updates.",
      }),
    );
  }

  const { error } = await supabase
    .from("bookings")
    .update({ payment_status: nextPaymentStatus })
    .eq("id", bookingId);

  if (error) {
    redirect(
      buildBookingsHref(query, {
        error: error.message,
      }),
    );
  }

  revalidateAdminViews();

  redirect(
    buildBookingsHref(query, {
      notice: `Payment updated to ${nextPaymentStatus}.`,
    }),
  );
}
