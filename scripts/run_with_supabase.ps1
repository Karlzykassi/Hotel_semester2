param(
  [string]$DeviceId
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$keysPath = Join-Path $projectRoot 'supabase\supabase_keys.json'

if (-not (Test-Path $keysPath)) {
  Write-Host 'Missing supabase\supabase_keys.json.' -ForegroundColor Red
  Write-Host 'Copy supabase\supabase_keys.example.json to supabase\supabase_keys.json and paste your real project values.' -ForegroundColor Yellow
  exit 1
}

$flutterArgs = @(
  'run'
  "--dart-define-from-file=$keysPath"
)

if ($DeviceId) {
  $flutterArgs += @('-d', $DeviceId)
}

Push-Location $projectRoot
try {
  flutter @flutterArgs
} finally {
  Pop-Location
}
