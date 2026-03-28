const currencyFormatter = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
});

const compactCurrencyFormatter = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  notation: "compact",
  maximumFractionDigits: 1,
});

const dateFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
});

const dateTimeFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
  year: "numeric",
  hour: "numeric",
  minute: "2-digit",
});

export function formatCurrency(value: number) {
  return currencyFormatter.format(Number.isFinite(value) ? value : 0);
}

export function formatCompactCurrency(value: number) {
  return compactCurrencyFormatter.format(Number.isFinite(value) ? value : 0);
}

export function formatNumber(value: number) {
  return new Intl.NumberFormat("en-US").format(Number.isFinite(value) ? value : 0);
}

export function formatDate(value: string | null | undefined) {
  if (!value) {
    return "N/A";
  }

  return dateFormatter.format(new Date(value));
}

export function formatDateTime(value: string | null | undefined) {
  if (!value) {
    return "Never";
  }

  return dateTimeFormatter.format(new Date(value));
}

export function getInitials(value: string) {
  const parts = value
    .split(" ")
    .map((part) => part.trim())
    .filter(Boolean)
    .slice(0, 2);

  if (parts.length === 0) {
    return "AD";
  }

  return parts.map((part) => part[0]?.toUpperCase() ?? "").join("");
}

export function toDateInputValue(date: Date) {
  return date.toISOString().slice(0, 10);
}

export function readQueryValue(
  value: string | string[] | undefined,
  fallback = "",
) {
  if (Array.isArray(value)) {
    return value[0] ?? fallback;
  }

  return value ?? fallback;
}

export function getStatusClasses(status: string) {
  switch (status.toLowerCase()) {
    case "confirmed":
    case "paid":
    case "active":
      return "bg-emerald-100 text-emerald-700";
    case "pending":
    case "unpaid":
      return "bg-amber-100 text-amber-700";
    case "completed":
      return "bg-sky-100 text-sky-700";
    case "cancelled":
    case "failed":
      return "bg-rose-100 text-rose-700";
    default:
      return "bg-stone-200 text-stone-700";
  }
}
