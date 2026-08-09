Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$script:failures = @()

function Add-Failure {
    param([string]$Message)
    $script:failures += $Message
}

function Read-RequiredSource {
    param([string]$RelativePath)

    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Failure "Missing required file: $RelativePath"
        return ""
    }
    return Get-Content -LiteralPath $path -Raw
}

function Require-Match {
    param([string]$Source, [string]$Pattern, [string]$Contract)
    if ($Source -notmatch $Pattern) {
        Add-Failure "Missing contract: $Contract"
    }
}

function Reject-Match {
    param([string]$Source, [string]$Pattern, [string]$Contract)
    if ($Source -match $Pattern) {
        Add-Failure "Forbidden presentation path remains: $Contract"
    }
}

$main = Read-RequiredSource "src/client/Main.client.luau"
$onboarding = Read-RequiredSource "src/client/Onboarding.client.luau"

foreach ($component in @("CoinChip", "LevelChip", "QuestChip", "JournalButton", "Toast", "JournalPanel")) {
    Require-Match $main ('\.Name\s*=\s*"' + [regex]::Escape($component) + '"') "normal HUD component $component"
}

foreach ($section in @("Today", "Bag", "Home", "Careers", "Collection")) {
    Require-Match $main ('\.Name\s*=\s*"' + [regex]::Escape($section) + 'Tab"') "journal tab $section"
    Require-Match $main ('\.Name\s*=\s*"' + [regex]::Escape($section) + 'Section"') "journal content $section"
}
Require-Match $main 'JournalPanel[\s\S]*\.Visible\s*=\s*false' "journal starts intentionally hidden"
Require-Match $main 'WaitForChild\("VisualQualityRules"\)' "shared toast-duration rules"
Require-Match $main 'game:GetService\("TweenService"\)' "animated HUD transitions"
Require-Match $main 'TinyWorldMessageNonce' "nonce-driven toast refresh"
Require-Match $main 'task\.delay\s*\(\s*VisualQualityRules\.TOAST_DURATION_SECONDS' "rule-driven toast expiry"
Require-Match $main 'toastToken[\s\S]*~=\s*toastToken' "stale toast timer protection"
Require-Match $main 'TweenService:Create\s*\(' "toast tweening"
Require-Match $main 'if\s+RunService:IsStudio\s*\(\s*\)\s+then[\s\S]*\.Name\s*=\s*"DebugButton"' "Studio-only debug button creation"
Require-Match $main 'if\s+RunService:IsStudio\s*\(\s*\)\s+then[\s\S]*\.Name\s*=\s*"DebugPanel"' "Studio-only raw telemetry drawer"
Require-Match $main 'Moonlit Meadow' "friendly portal name"
Require-Match $main 'Find the missing moon seeds' "friendly portal task copy"
Require-Match $main 'makeChip\(\s*"LevelChip"\s*,\s*UDim2\.new\(0,\s*136,\s*0,\s*12\)\s*,\s*UDim2\.new\(1,\s*-208,\s*0,\s*44\)\s*\)' "responsive level chip reserves journal space"

Reject-Match $main '\.Size\s*=\s*UDim2\.new\(0\.92,\s*0,\s*0,\s*480\)' "old 480px dashboard"
Reject-Match $main 'TINYWORLD\s*\|\s*v0\.5\.1\s+PHYSICAL WORLD' "raw build title"
Reject-Match $main 'Portals:\s*%d\s+completion\(s\)' "raw portal telemetry copy"
Reject-Match $main 'Mission finds\s*%d/3' "raw mission telemetry copy"
Reject-Match $main 'Return loop:' "raw route telemetry in normal HUD"
Reject-Match $main 'player:SetAttribute\s*\(' "client mutation of authoritative player state"
Reject-Match $main ':FireServer\s*\(' "normal HUD server mutation"

foreach ($card in @("BoyCard", "GirlCard", "MeadowCard", "HarborCard", "SunsetCard")) {
    Require-Match $onboarding ('\.Name\s*=\s*"' + [regex]::Escape($card) + '"') "visual onboarding card $card"
}
Require-Match $onboarding '\bMIN_TOUCH_TARGET\s*=\s*(?:[5-9][0-9]|[1-9][0-9]{2,})\b' "mobile-sized onboarding touch targets"
Require-Match $onboarding '\.Name\s*=\s*"AvatarPreview"' "avatar silhouette preview"
Require-Match $onboarding '\.Name\s*=\s*"ScenePreview"' "outfit scene preview"
Require-Match $onboarding '\.Name\s*=\s*"SelectionMark"' "selected-card visual state"
Require-Match $onboarding 'avatarGrid[\s\S]*FillDirectionMaxCells\s*=\s*1' "stacked avatar cards on narrow panels"
Require-Match $onboarding 'outfitGrid[\s\S]*FillDirectionMaxCells\s*=\s*1' "stacked outfit cards on narrow panels"
Require-Match $onboarding 'math\.max\(MIN_TOUCH_TARGET' "cards use the minimum touch target"
foreach ($scene in @("Meadow", "Harbor", "Sunset")) {
    Require-Match $onboarding ([regex]::Escape($scene) + '[\s\S]*scene') "described $scene scene card"
}

foreach ($key in @("displayName", "avatarStyle", "starterOutfit")) {
    Require-Match $onboarding ('\b' + [regex]::Escape($key) + '\s*=') "preserved onboarding payload key $key"
}
foreach ($value in @("Boy", "Girl", "Meadow", "Harbor", "Sunset")) {
    Require-Match $onboarding ('"' + [regex]::Escape($value) + '"') "preserved onboarding value $value"
}

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 client presentation: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "TinyWorld v0.5.2 client presentation: PASS" -ForegroundColor Green
