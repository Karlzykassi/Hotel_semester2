export type SearchParams = Promise<Record<string, string | string[] | undefined>>;

export type AdminSession = {
  userId: string;
  email: string;
  name: string;
};

export type TrendPoint = {
  label: string;
  bookings: number;
  revenue: number;
};

export type DashboardMetric = {
  label: string;
  value: string;
  helper: string;
  tone?: "accent" | "default";
};

export type BookingListItem = {
  id: string;
  createdAt: string;
  status: string;
  paymentStatus: string;
  guestName: string;
  email: string;
  guestCount: number;
  checkInDate: string;
  checkOutDate: string;
  hotelName: string;
  roomTypeName: string;
  total: number;
};

export type MemberListItem = {
  id: string;
  email: string;
  fullName: string;
  phone: string | null;
  provider: string;
  createdAt: string;
  lastSignInAt: string | null;
  avatarUrl: string | null;
  isAdmin: boolean;
  accessSource: string;
};

export type HotelListItem = {
  id: string;
  name: string;
  city: string;
  rating: number;
  reviewCount: number;
  priceFrom: number;
};

export type BookingSummaryRow = {
  date: string;
  bookingId: string;
  hotelName: string;
  guestName: string;
  guests: number;
  revenue: number;
  status: string;
};

export type HotelPerformanceRow = {
  hotelName: string;
  city: string;
  bookings: number;
  guests: number;
  revenue: number;
};
