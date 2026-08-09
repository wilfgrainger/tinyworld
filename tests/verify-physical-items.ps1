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
foreach ($itemPart in @(
    "CourierParcelShelf",
    "CourierParcelBox",
    "CourierHandcart",
    "ShopStockShelf",
    "ShopStockBasket",
    "WorkshopBikeStand",
    "WorkshopBikeWheel",
    "TradeOfferTrayA",
    "TradeOfferTrayB",
    "MarketCrate"
)) {
    Require-Match $builder ([regex]::Escape($itemPart)) "recognizable physical item $itemPart"
}
Reject-Match $builder 'TradeJoinPad|TradeOfferPad|TradeConfirmPad' "generic trade pads"

$worldBuilder = Read-RequiredSource "src/server/WorldBuilder.luau"
foreach ($plotPart in @(
    "EstateSign",
    "EstateSignPost",
    "ItemChest",
    "ItemChestLid",
    "ItemChestHandle",
    "InventoryDisplay",
    "GardenBed1",
    "GardenBed2",
    "GardenBed3"
)) {
    Require-Match $worldBuilder ([regex]::Escape($plotPart)) "authored plot item $plotPart"
}
foreach ($field in @("itemChest", "itemChestLabel", "itemChestPrompt", "itemDisplay", "gardenBeds", "gardenPrompts")) {
    Require-Match $worldBuilder ('\b' + [regex]::Escape($field) + '\b') "preserved physical-item field $field"
}

$physicalItems = Read-RequiredSource "src/server/PhysicalItemService.luau"
foreach ($contract in @("TinyWorldItem", "TinyWorldItemCount", "TinyWorldPhysicalAffordance", "InventoryItem_")) {
    Require-Match $physicalItems ([regex]::Escape($contract)) "inventory world-object contract $contract"
}
Require-Match $physicalItems 'plot\.itemChestPrompt\.Triggered\s*:\s*Connect\s*\(' "item chest remains server-authoritative"

$livingWorld = Read-RequiredSource "src/server/LivingWorldBuilder.luau"
foreach ($pickup in @("MeadowSeed", "Seashell", "WoodToken")) {
    Require-Match $livingWorld ([regex]::Escape($pickup)) "physical village pickup $pickup"
}
Require-Match $livingWorld 'itemName\s*\.\.\s*"Object"' "pickup object naming contract"
Require-Match $livingWorld 'item:SetAttribute\("TinyWorldPhysicalAffordance",\s*"world-object"\)' "living pickups retain physical-affordance tagging"

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld physical items: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}

Write-Host "TinyWorld physical items: PASS" -ForegroundColor Green
