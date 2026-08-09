Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$script:failures = @()

function Add-Failure { param([string]$Message) $script:failures += $Message }
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
    if ($Source -notmatch $Pattern) { Add-Failure "Missing contract: $Contract" }
}
function Reject-Match {
    param([string]$Source, [string]$Pattern, [string]$Contract)
    if ($Source -match $Pattern) { Add-Failure "Forbidden path remains: $Contract" }
}

$builder = Read-RequiredSource "src/server/AuthoredPrefabBuilder.luau"
Require-Match $builder 'model:SetAttribute\("TinyWorldArtRole",\s*artRole\)' "every returned prefab model receives an art role"
Require-Match $builder 'model:SetAttribute\("TinyWorldPhysicalAffordance",\s*"world-object"\)' "every returned prefab model receives a physical-affordance role"
Require-Match $builder 'anchor:SetAttribute\("TinyWorldInteractionAnchor",\s*true\)' "all prompt anchors are explicit"
Require-Match $builder 'anchor\.CanQuery\s*=\s*true' "prompt anchors are queryable"
Require-Match $builder 'part\.CanCollide\s*=\s*false[\s\S]*part\.CanTouch\s*=\s*false[\s\S]*part\.CanQuery\s*=\s*false' "decoration safety flags"

foreach ($role in @(
    "civic-town-hall",
    "civic-courier-depot",
    "shop-village",
    "transport-workshop",
    "market-table",
    "plot-affordances"
)) {
    Require-Match $builder ([regex]::Escape($role)) "distinct art role $role"
}

foreach ($anchor in @(
    "TownHallContributionAnchor",
    "CivicNoticeboard",
    "CourierPickupAnchor",
    "CourierDeliveryAnchor",
    "VillageShopDeliveryAnchor",
    "HomeSupplyCounterAnchor",
    "DecoratorCatalogueAnchor",
    "FurnishingShowroomAnchor",
    "TransportAnchor",
    "MarketJoinAnchorA",
    "MarketOfferAnchorA",
    "MarketConfirmAnchorA",
    "MarketJoinAnchorB",
    "MarketOfferAnchorB",
    "MarketConfirmAnchorB",
    "ArchitectDrawingBoardAnchor",
    "FrontDoorBellAnchor",
    "PlotGateAnchor",
    "PottingBenchAnchor"
)) {
    Require-Match $builder ([regex]::Escape($anchor)) "explicit prompt anchor $anchor"
}

$worldBuilder = Read-RequiredSource "src/server/WorldBuilder.luau"
Reject-Match $worldBuilder '\bmakeInteractionMarker\s*\(' "normal-play neon interaction rings"
$promptSources = $worldBuilder + "`n" + $builder
foreach ($promptCopy in @(
    "Contribute 50 Coins",
    "View Professions",
    "Take Parcel",
    "Deliver Parcel",
    "Buy Next Essential",
    "Change Home Style",
    "Collect Next Decor",
    "Buy / Toggle Bike",
    "Upgrade Home",
    "Change Privacy",
    "Enter Home",
    "Add Home Charm",
    "View Items",
    "Plant Carrot"
)) {
    Require-Match $promptSources ([regex]::Escape($promptCopy)) "preserved prompt copy $promptCopy"
}

foreach ($service in @(
    "DailyRewardService.luau",
    "VillageService.luau",
    "ProfessionService.luau",
    "JobService.luau",
    "HomeService.luau",
    "TransportService.luau",
    "TradeService.luau",
    "PlotService.luau",
    "GardenService.luau",
    "PhysicalItemService.luau"
)) {
    $source = Read-RequiredSource ("src/server/" + $service)
    Require-Match $source '\.Triggered\s*:\s*Connect\s*\(' "$service keeps prompt handling on the server"
}

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld physical-affordance invariant: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}

Write-Host "TinyWorld physical-affordance invariant: PASS" -ForegroundColor Green
