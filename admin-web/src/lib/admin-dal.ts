import type { User } from "@supabase/supabase-js";
import { cache } from "react";
import { requireAdminSession } from "@/lib/admin-session";
import {
  getAccessSource,
  getDisplayName,
  isAllowedAdminUser,
} from "@/lib/admin-access";
import { getAdminConfigurationWarnings } from "@/lib/env";
import {
  readQueryValue,
  toDateInputValue,
} from "@/lib/formatters";
import { getServiceSupabaseClient } from "@/lib/supabase";
import type {
  AdminSession,
  BookingListItem,
  BookingSummaryRow,
  DashboardMetric,
  HotelListItem,
  HotelPerformanceRow,
  MemberListItem,
  TrendPoint,
} from "@/lib/types";

type ProfileRow = {
  id: string;
  full_name: string | null;
  phone: string | null;
  avatar_url: string | null;
  auth_provider: string | null;
};

type RawBookingRow = {
  id: string;
  created_at: string;
  status: string;
  payment_status: string;
  first_name: string;
  last_name: string;
  email: string;
  guest_count: number;
  check_in_date: string;
  check_out_date: string;
  total: number;
  hotels: { name: string } | { name: string }[] | null;
  room_types: { name: string } | { name: string }[] | null;
};

type RawReportRow = {
  id: string;
  status: string;
  guest_count: number;
  total: number;
  check_in_date: string;
  first_name: string;
  last_name: string;
  hotels: { name: string; city: string } | { name: string; city: string }[] | null;
};

function unwrapRelation<T>(value: T | T[] | null | undefined) {
  if (Array.isArray(value)) {
    return value[0] ?? null;
  }

  return value ?? null;
}

function sum(values: number[]) {
  return values.reduce((total, value) => total + value, 0);
}

function getDateKey(date: Date) {
  return date.toISOString().slice(0, 10);
}

function getRecentDateRange(days: number) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  return Array.from({ length: days }, (_, index) => {
    const current = new Date(today);
    current.setDate(today.getDate() - (days - index - 1));
    return current;
  });
}

function getTrendData(bookings: Pick<BookingListItem, "createdAt" | "total">[]) {
  const dates = getRecentDateRange(7);
  const map = new Map(
    dates.map((date) => [getDateKey(date), { bookings: 0, revenue: 0 }]),
  );

  bookings.forEach((booking) => {
    const key = getDateKey(new Date(booking.createdAt));
    const bucket = map.get(key);

    if (!bucket) {
      return;
    }

    bucket.bookings += 1;
    bucket.revenue += booking.total;
  });

  return dates.map<TrendPoint>((date) => {
    const key = getDateKey(date);
    const bucket = map.get(key) ?? { bookings: 0, revenue: 0 };

    return {
      label: date.toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
      }),
      bookings: bucket.bookings,
      revenue: bucket.revenue,
    };
  });
}

function buildBookingList(rows: RawBookingRow[]) {
  return rows.map<BookingListItem>((row) => {
    const hotel = unwrapRelation(row.hotels);
    const roomType = unwrapRelation(row.room_types);

    return {
      id: row.id,
      createdAt: row.created_at,
      status: row.status,
      paymentStatus: row.payment_status,
      guestName: `${row.first_name} ${row.last_name}`.trim(),
      email: row.email,
      guestCount: Number(row.guest_count ?? 0),
      checkInDate: row.check_in_date,
      checkOutDate: row.check_out_date,
      hotelName: hotel?.name ?? "Unknown hotel",
      roomTypeName: roomType?.name ?? "Room",
      total: Number(row.total ?? 0),
    };
  });
}

function filterByQuery<T>(
  items: T[],
  query: string,
  pickers: Array<(item: T) => string | null | undefined>,
) {
  if (!query) {
    return items;
  }

  const normalized = query.toLowerCase();
  return items.filter((item) =>
    pickers.some((picker) => picker(item)?.toLowerCase().includes(normalized)),
  );
}

async function loadProfilesByIds(userIds: string[]) {
  const supabase = getServiceSupabaseClient();

  if (!supabase || userIds.length === 0) {
    return new Map<string, ProfileRow>();
  }

  const { data, error } = await supabase
    .from("profiles")
    .select("id, full_name, phone, avatar_url, auth_provider")
    .in("id", userIds);

  if (error || !data) {
    return new Map<string, ProfileRow>();
  }

  return new Map(data.map((row) => [row.id, row as ProfileRow]));
}

async function loadAuthUsers() {
  const supabase = getServiceSupabaseClient();

  if (!supabase) {
    return [];
  }

  const users: User[] = [];
  let page = 1;
  const perPage = 200;

  while (true) {
    const { data, error } = await supabase.auth.admin.listUsers({
      page,
      perPage,
    });

    if (error || !data?.users?.length) {
      break;
    }

    users.push(...data.users);

    if (data.users.length < perPage) {
      break;
    }

    page += 1;
  }

  return users;
}

function emptyDashboardMetrics() {
  return [
    { label: "Customers", value: "0", helper: "Profiles synced from Supabase auth" },
    { label: "Hotels", value: "0", helper: "Published hotel listings" },
    { label: "Bookings", value: "0", helper: "Reservations recorded so far" },
    {
      label: "Revenue",
      value: "$0",
      helper: "Gross booking value excluding cancelled stays",
      tone: "accent" as const,
    },
  ] satisfies DashboardMetric[];
}

function emptyOverviewSummary() {
  return [
    { label: "City", value: "0", helper: "Destinations in this dataset" },
    { label: "Hotel", value: "0", helper: "Listings currently available" },
    { label: "Booking", value: "0", helper: "Reservations captured in Supabase" },
    { label: "Rating", value: "0.0", helper: "Average property score" },
  ] satisfies DashboardMetric[];
}

export const getAdminPageContext = cache(async () => {
  const session = await requireAdminSession();

  return {
    session,
    configurationWarnings: getAdminConfigurationWarnings(),
  };
});

export async function getDashboardData(query: string) {
  const { session, configurationWarnings } = await getAdminPageContext();
  const supabase = getServiceSupabaseClient();

  if (!supabase) {
    return {
      session,
      configurationWarnings,
      metrics: emptyDashboardMetrics(),
      trend: [] as TrendPoint[],
      recentBookings: [] as BookingListItem[],
    };
  }

  const [
    hotelCountResponse,
    profileCountResponse,
    bookingCountResponse,
    bookingRowsResponse,
  ] = await Promise.all([
    supabase.from("hotels").select("*", { count: "exact", head: true }),
    supabase.from("profiles").select("*", { count: "exact", head: true }),
    supabase.from("bookings").select("*", { count: "exact", head: true }),
    supabase
      .from("bookings")
      .select(
        "id, created_at, status, payment_status, first_name, last_name, email, guest_count, check_in_date, check_out_date, total, hotels(name), room_types(name)",
      )
      .order("created_at", { ascending: false })
      .limit(80),
  ]);

  const bookingRows = buildBookingList((bookingRowsResponse.data ?? []) as RawBookingRow[]);
  const filteredBookings = filterByQuery(bookingRows, query, [
    (booking) => booking.hotelName,
    (booking) => booking.guestName,
    (booking) => booking.email,
    (booking) => booking.id,
  ]);

  const totalRevenue = sum(
    bookingRows
      .filter((booking) => booking.status !== "cancelled")
      .map((booking) => booking.total),
  );

  const metrics: DashboardMetric[] = [
    {
      label: "Customers",
      value: String(profileCountResponse.count ?? 0),
      helper: "Profiles synced from Supabase auth",
    },
    {
      label: "Hotels",
      value: String(hotelCountResponse.count ?? 0),
      helper: "Published hotel listings",
    },
    {
      label: "Bookings",
      value: String(bookingCountResponse.count ?? 0),
      helper: "Reservations recorded so far",
    },
    {
      label: "Revenue",
      value: `$${Math.round(totalRevenue).toLocaleString("en-US")}`,
      helper: "Gross booking value excluding cancelled stays",
      tone: "accent",
    },
  ];

  return {
    session,
    configurationWarnings,
    metrics,
    trend: getTrendData(bookingRows),
    recentBookings: filteredBookings.slice(0, 8),
  };
}

export async function getHomeOverviewData(query: string) {
  const { session, configurationWarnings } = await getAdminPageContext();
  const supabase = getServiceSupabaseClient();

  if (!supabase) {
    return {
      session,
      configurationWarnings,
      summary: emptyOverviewSummary(),
      recentMembers: [] as MemberListItem[],
      activeHotels: [] as HotelListItem[],
    };
  }

  const [hotelsResponse, bookingsCountResponse, memberDirectory] = await Promise.all([
    supabase
      .from("hotels")
      .select("id, name, city, rating, review_count, price_from")
      .order("created_at", { ascending: false })
      .limit(60),
    supabase.from("bookings").select("*", { count: "exact", head: true }),
    getMemberDirectory(query, 8),
  ]);

  const hotels = (hotelsResponse.data ?? []).map<HotelListItem>((hotel) => ({
    id: hotel.id,
    name: hotel.name,
    city: hotel.city,
    rating: Number(hotel.rating ?? 0),
    reviewCount: Number(hotel.review_count ?? 0),
    priceFrom: Number(hotel.price_from ?? 0),
  }));

  const filteredHotels = filterByQuery(hotels, query, [
    (hotel) => hotel.name,
    (hotel) => hotel.city,
  ]);

  const cityCount = new Set(hotels.map((hotel) => hotel.city)).size;
  const averageRating =
    hotels.length === 0
      ? 0
      : hotels.reduce((total, hotel) => total + hotel.rating, 0) / hotels.length;

  return {
    session,
    configurationWarnings,
    summary: [
      { label: "City", value: String(cityCount), helper: "Destinations in this dataset" },
      { label: "Hotel", value: String(hotels.length), helper: "Listings currently available" },
      {
        label: "Booking",
        value: String(bookingsCountResponse.count ?? 0),
        helper: "Reservations captured in Supabase",
      },
      {
        label: "Rating",
        value: averageRating.toFixed(1),
        helper: "Average property score",
      },
    ] satisfies DashboardMetric[],
    recentMembers: memberDirectory.members.slice(0, 8),
    activeHotels: filteredHotels.slice(0, 8),
  };
}

export async function getBookingsPageData(query: string) {
  const { session, configurationWarnings } = await getAdminPageContext();
  const supabase = getServiceSupabaseClient();

  if (!supabase) {
    return {
      session,
      configurationWarnings,
      bookings: [] as BookingListItem[],
    };
  }

  const { data } = await supabase
    .from("bookings")
    .select(
      "id, created_at, status, payment_status, first_name, last_name, email, guest_count, check_in_date, check_out_date, total, hotels(name), room_types(name)",
    )
    .order("created_at", { ascending: false })
    .limit(120);

  const bookings = filterByQuery(buildBookingList((data ?? []) as RawBookingRow[]), query, [
    (booking) => booking.hotelName,
    (booking) => booking.guestName,
    (booking) => booking.email,
    (booking) => booking.id,
    (booking) => booking.status,
  ]);

  return {
    session,
    configurationWarnings,
    bookings,
  };
}

export async function getMemberDirectory(query: string, limit?: number) {
  const { session, configurationWarnings } = await getAdminPageContext();
  const users = await loadAuthUsers();

  if (users.length === 0) {
    return {
      session,
      configurationWarnings,
      members: [] as MemberListItem[],
      admins: [] as MemberListItem[],
    };
  }

  const profiles = await loadProfilesByIds(users.map((user) => user.id));

  const members = users
    .map<MemberListItem>((user) => {
      const profile = profiles.get(user.id);
      const provider =
        typeof user.app_metadata?.provider === "string"
          ? user.app_metadata.provider
          : profile?.auth_provider || "email";
      const fullName = getDisplayName(
        profile?.full_name ??
          (typeof user.user_metadata?.full_name === "string"
            ? user.user_metadata.full_name
            : null),
        user.email,
      );

      return {
        id: user.id,
        email: user.email ?? "",
        fullName,
        phone: profile?.phone ?? null,
        provider,
        createdAt: user.created_at,
        lastSignInAt: user.last_sign_in_at ?? null,
        avatarUrl: profile?.avatar_url ?? null,
        isAdmin: isAllowedAdminUser(user),
        accessSource: getAccessSource(user),
      };
    })
    .sort((left, right) =>
      new Date(right.createdAt).getTime() - new Date(left.createdAt).getTime(),
    );

  const filteredMembers = filterByQuery(members, query, [
    (member) => member.fullName,
    (member) => member.email,
    (member) => member.provider,
    (member) => member.phone,
  ]);

  const trimmedMembers =
    typeof limit === "number" ? filteredMembers.slice(0, limit) : filteredMembers;

  return {
    session,
    configurationWarnings,
    members: trimmedMembers,
    admins: filteredMembers.filter((member) => member.isAdmin),
  };
}

export async function getReportData(
  rawSearchParams: Record<string, string | string[] | undefined>,
) {
  const { session, configurationWarnings } = await getAdminPageContext();
  const supabase = getServiceSupabaseClient();

  const today = new Date();
  const thirtyDaysAgo = new Date(today);
  thirtyDaysAgo.setDate(today.getDate() - 30);

  const type = readQueryValue(rawSearchParams.type, "booking-summary");
  const query = readQueryValue(rawSearchParams.query, "");
  const startDate = readQueryValue(
    rawSearchParams.startDate,
    toDateInputValue(thirtyDaysAgo),
  );
  const endDate = readQueryValue(rawSearchParams.endDate, toDateInputValue(today));

  if (!supabase) {
    return {
      session,
      configurationWarnings,
      filters: { type, query, startDate, endDate },
      summaryRows: [] as BookingSummaryRow[],
      hotelRows: [] as HotelPerformanceRow[],
    };
  }

  const { data } = await supabase
    .from("bookings")
    .select(
      "id, status, guest_count, total, check_in_date, first_name, last_name, hotels(name, city)",
    )
    .gte("check_in_date", startDate)
    .lte("check_in_date", endDate)
    .order("check_in_date", { ascending: false })
    .limit(240);

  const bookingRows = (data ?? []).map<BookingSummaryRow>((row) => {
    const hotel = unwrapRelation((row as RawReportRow).hotels);

    return {
      date: row.check_in_date,
      bookingId: row.id,
      hotelName: hotel?.name ?? "Unknown hotel",
      guestName: `${row.first_name} ${row.last_name}`.trim(),
      guests: Number(row.guest_count ?? 0),
      revenue: Number(row.total ?? 0),
      status: row.status,
    };
  });

  const filteredSummaryRows = filterByQuery(bookingRows, query, [
    (row) => row.hotelName,
    (row) => row.guestName,
    (row) => row.bookingId,
    (row) => row.status,
  ]);

  const hotelMap = new Map<string, HotelPerformanceRow>();
  (data ?? []).forEach((row) => {
    const hotel = unwrapRelation((row as RawReportRow).hotels);
    const hotelName = hotel?.name ?? "Unknown hotel";
    const current = hotelMap.get(hotelName) ?? {
      hotelName,
      city: hotel?.city ?? "Cambodia",
      bookings: 0,
      guests: 0,
      revenue: 0,
    };

    current.bookings += 1;
    current.guests += Number(row.guest_count ?? 0);
    current.revenue += Number(row.total ?? 0);
    hotelMap.set(hotelName, current);
  });

  const hotelRows = filterByQuery(Array.from(hotelMap.values()), query, [
    (row) => row.hotelName,
    (row) => row.city,
  ]).sort((left, right) => right.revenue - left.revenue);

  return {
    session,
    configurationWarnings,
    filters: { type, query, startDate, endDate },
    summaryRows: filteredSummaryRows,
    hotelRows,
  };
}

export async function getAdminProfileLabel(session: AdminSession) {
  const supabase = getServiceSupabaseClient();

  if (!supabase) {
    return session;
  }

  const { data } = await supabase
    .from("profiles")
    .select("full_name")
    .eq("id", session.userId)
    .maybeSingle();

  return {
    ...session,
    name: data?.full_name?.trim() || session.name,
  };
}
