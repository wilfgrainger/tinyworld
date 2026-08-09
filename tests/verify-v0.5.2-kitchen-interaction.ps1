Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$homePath = Join-Path $repoRoot "src/server/HomeService.luau"
$source = Get-Content -LiteralPath $homePath -Raw
$failures = @()

function Require-Match {
    param([string]$Text, [string]$Pattern, [string]$Contract)
    if ($Text -notmatch $Pattern) {
        $script:failures += "Missing contract: $Contract"
    }
}

$useSection = [regex]::Match($source, '(?s)function\s+HomeService:_use\b.*?function\s+HomeService:_useAmbient\b').Value
if ($useSection -eq "") {
    $failures += "Missing contract: inspectable HomeService:_use implementation"
} else {
    $kitchenBranch = [regex]::Match($useSection, '(?s)elseif\s+itemId\s*==\s*"KitchenCounter"\s+then.*?elseif\s+itemId\s*==\s*"CreativeDesk"').Value
    if ($kitchenBranch -eq "") {
        $failures += "Missing contract: KitchenCounter behavior branch"
    } else {
        Require-Match $kitchenBranch 'FindFirstChild\s*\(\s*"HomeFurniture_Cooker"\s*\)' "KitchenCounter resolves the authored cooker"
        Require-Match $kitchenBranch 'FindFirstChild\s*\(\s*"HomeFurniture_CookerHob"\s*\)' "KitchenCounter resolves the cooker hob"
        Require-Match $kitchenBranch 'FindFirstChild\s*\(\s*"HomeFurniture_TableFood"\s*\)' "KitchenCounter resolves the visible food prop"
        Require-Match $kitchenBranch 'IsDescendantOf\s*\(\s*plot\.houseContainer\s*\)' "Kitchen visual targets stay inside the owned house"
        Require-Match $kitchenBranch 'TinyWorldKitchenCookerOn' "KitchenCounter publishes bounded cooker state"
        Require-Match $kitchenBranch 'TinyWorldKitchenFoodReady' "KitchenCounter publishes bounded food state"
        Require-Match $kitchenBranch 'cooker\.Material\s*=\s*if\s+kitchenActive' "KitchenCounter changes cooker presentation"
        Require-Match $kitchenBranch 'food\.Transparency\s*=\s*if\s+kitchenActive' "KitchenCounter changes food presentation"
    }

    Require-Match $useSection 'HomeRules\.use\s*\(\s*profile\s*,\s*itemId\s*\)' "KitchenCounter keeps HomeCatalog ownership/use rules"
    Require-Match $useSection 'ProfileStore\.save\s*\(\s*player\s*\)' "KitchenCounter keeps persisted home use"
}

$interiorSection = [regex]::Match($source, '(?s)function\s+HomeService:buildInterior\b.*?local\s+kitchenSink').Value
if ($interiorSection -eq "") {
    $failures += "Missing contract: inspectable starter-home interior build"
} else {
    Require-Match $interiorSection 'local\s+counter\s*=\s*makeFurniturePart\(kitchen,\s*"HomeFurniture_KitchenCounter"' "fresh profiles receive a physical kitchen counter"
    Require-Match $interiorSection 'addAmbientPrompt\(\s*"KitchenUse"\s*,\s*counter' "fresh profiles can use the starter kitchen"
}

if ($failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 kitchen interaction: FAIL" -ForegroundColor Red
    foreach ($failure in $failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}

Write-Host "TinyWorld v0.5.2 kitchen interaction: PASS" -ForegroundColor Green
