type ConfigBannerProps = {
  warnings: string[];
};

export function ConfigBanner({ warnings }: ConfigBannerProps) {
  if (warnings.length === 0) {
    return null;
  }

  return (
    <div className="rounded-[28px] border border-amber-200 bg-amber-50 px-5 py-4 text-sm text-amber-900 panel-shadow">
      <p className="font-semibold uppercase tracking-[0.22em] text-amber-700">
        Setup Notes
      </p>
      <ul className="mt-2 space-y-1.5">
        {warnings.map((warning) => (
          <li key={warning}>{warning}</li>
        ))}
      </ul>
    </div>
  );
}
