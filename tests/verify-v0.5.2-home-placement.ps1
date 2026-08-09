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

$worldBuilder = Read-RequiredSource "src/server/WorldBuilder.luau"
$plotService = Read-RequiredSource "src/server/PlotService.luau"

Require-Match $worldBuilder 'slot\.rotation' "WorldBuilder consumes authored slot rotation"
Require-Match $worldBuilder 'slot\.setback' "WorldBuilder consumes authored slot setback"
Require-Match $worldBuilder 'function\s+makePlotPlacementCFrame\s*\(' "deterministic plot placement transform"
Require-Match $worldBuilder 'CFrame\.Angles\(0,\s*math\.rad\(rotation\),\s*0\)' "placement transform applies yaw"
Require-Match $worldBuilder 'CFrame\.new\(0,\s*0,\s*-setback\)' "placement transform applies setback away from the gate"
Require-Match $worldBuilder 'local\s+placement\s*=\s*makePlotPlacementCFrame\(origin,\s*slot\.rotation,\s*slot\.setback\)[\s\S]*buildPlot\(root,\s*index,\s*origin,\s*placement\)' "plot builder receives placement metadata"
Require-Match $worldBuilder 'PlotAffordances[\s\S]*PivotTo|PivotTo[\s\S]*PlotAffordances' "plot interaction affordances receive placement transform"
Require-Match $worldBuilder 'homeAnchorCFrame\s*=\s*' "plot exposes oriented home anchor CFrame"
Require-Match $worldBuilder 'insideCFrame\s*=\s*[^\n]*placement' "visit entry CFrame follows placement"
Require-Match $worldBuilder 'outsideCFrame\s*=\s*[^\n]*placement' "outside CFrame follows placement"

Require-Match $plotService 'HomePrefabBuilder\.buildShell\s*\(\s*plot\.houseContainer\s*,\s*plot\.houseAnchor' "existing shell build call is preserved"
Require-Match $plotService 'HomeService:buildInterior\s*\(\s*plot\s*,\s*profile\s*\)' "existing interior build call is preserved"
Require-Match $plotService 'houseContainer[\s\S]*PivotTo' "rebuilt home receives placement transform"
Require-Match $plotService 'homeAnchorCFrame' "home rotation is anchored at the deterministic home anchor"
Require-Match $plotService 'houseContainer:ClearAllChildren\(\)' "release/rebuild clears the existing home"
Require-Match $plotService 'insideCFrame' "visit behavior keeps the service-facing inside CFrame"

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 home placement: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "TinyWorld v0.5.2 home placement: PASS" -ForegroundColor Green
