$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$physicalPath = Join-Path $root "src\server\PhysicalItemService.luau"
$worldPath = Join-Path $root "src\server\WorldBuilder.luau"
$livingWorldPath = Join-Path $root "src\server\LivingWorldBuilder.luau"
$statePath = Join-Path $root "src\server\PlayerStateService.luau"
$rulesPath = Join-Path $root "src\shared\PhysicalAffordanceRules.luau"
$plotPath = Join-Path $root "src\server\PlotService.luau"
$villagePath = Join-Path $root "src\server\VillageService.luau"
$gardenPath = Join-Path $root "src\server\GardenService.luau"
$jobPath = Join-Path $root "src\server\JobService.luau"
$homePath = Join-Path $root "src\server\HomeService.luau"
$bikePath = Join-Path $root "src\server\BikeBuilder.luau"
$boatPath = Join-Path $root "src\server\BoatBuilder.luau"
$physical = Get-Content -Raw -LiteralPath $physicalPath
$world = Get-Content -Raw -LiteralPath $worldPath
$livingWorld = Get-Content -Raw -LiteralPath $livingWorldPath
$state = Get-Content -Raw -LiteralPath $statePath
$rules = Get-Content -Raw -LiteralPath $rulesPath
$plot = Get-Content -Raw -LiteralPath $plotPath
$village = Get-Content -Raw -LiteralPath $villagePath
$garden = Get-Content -Raw -LiteralPath $gardenPath
$job = Get-Content -Raw -LiteralPath $jobPath
$homeService = Get-Content -Raw -LiteralPath $homePath
$bike = Get-Content -Raw -LiteralPath $bikePath
$boat = Get-Content -Raw -LiteralPath $boatPath

foreach ($pattern in @("INVARIANT", "inventoryItems", "isInventoryItem", "displayName", "hasEvidence")) {
    if ($rules -notmatch [regex]::Escape($pattern)) {
        throw "Physical affordance rules are missing the shared contract $pattern."
    }
}

foreach ($pattern in @(
    "PHYSICAL_AFFORDANCE_INVARIANT",
    "Carrot", "SugarCrystal", "MeadowSeed", "Seashell", "WoodToken",
    "InventoryItem_", "Item Chest:", "ItemLabel", "addSyncListener", "refresh"
)) {
    if ($physical -notmatch [regex]::Escape($pattern)) {
        throw "Physical item service is missing the physical-affordance contract $pattern."
    }
}

foreach ($pattern in @("ItemChest", "itemChestPrompt", "InventoryDisplay", "gardenBeds", "collectPrompts")) {
    if ($world -notmatch [regex]::Escape($pattern)) {
        throw "World is missing concrete item affordance: $pattern."
    }
}

if ($livingWorld -notmatch "PickupPrompt" -or $livingWorld -notmatch "TinyWorldItem") {
    throw "LivingWorldBuilder is missing a physical pickup contract."
}

$physicalObjectContracts = @{
    "GardenService" = @{ source = $garden; patterns = @("TinyWorldGardenStage", "TinyWorldItem", "TinyWorldPhysicalAffordance") }
    "JobService" = @{ source = $job; patterns = @("TinyWorldCourierParcel", "TinyWorldPhysicalAffordance") }
    "HomeService" = @{ source = $homeService; patterns = @("makeFurniturePart", "TinyWorldPhysicalAffordance") }
    "BikeBuilder" = @{ source = $bike; patterns = @("BikeModel", "TinyWorldPhysicalAffordance") }
    "BoatBuilder" = @{ source = $boat; patterns = @("TinyBoat", "TinyWorldPhysicalAffordance") }
}

foreach ($entry in $physicalObjectContracts.GetEnumerator()) {
    foreach ($pattern in $entry.Value.patterns) {
        if ($entry.Value.source -notmatch [regex]::Escape($pattern)) {
            throw ("{0} is missing physical-world marker: {1}." -f $entry.Key, $pattern)
        }
    }
}

if ($plot -notmatch "HomeCharmDisplay" -or $plot -notmatch "HOME CHARM") {
    throw "PlotService is missing a visible Home Charm object."
}

$upgradeBlock = [regex]::Match($plot, "function PlotService:_upgrade(?s:.*?)(?=function PlotService:_cyclePrivacy)").Value
if ($upgradeBlock -notmatch "ProfileStore\.save\(player\)") {
    throw "A successful house upgrade must queue a profile save."
}

$contributionBlock = [regex]::Match($village, "function VillageService:_contribute(?s:.*?)(?=return VillageService)").Value
if ($contributionBlock -notmatch "ProfileStore\.save\(player\)") {
    throw "A successful Village Fund contribution must queue a profile save."
}

foreach ($pattern in @("TinyWorldCarrots", "TinyWorldSugarCrystals", "TinyWorldMeadowSeeds", "TinyWorldSeashells", "TinyWorldWoodTokens", "syncListeners")) {
    if ($state -notmatch [regex]::Escape($pattern)) {
        throw "Player state is missing inventory sync contract: $pattern."
    }
}

$rewardPaths = @{
    "DailyRewardService" = @("PlayerStateService.sync(player, profile)", "Daily reward claimed:", "Carrot")
    "GardenService" = @("PlayerStateService.sync(player, profile)", "Carrot harvested:", "GardenCrop")
    "LivingWorldService" = @("PlayerStateService.sync(player, profile)", "Found a ", "DISPLAY_NAMES")
    "PortalService" = @("PlayerStateService.sync(player, profile)", "completionMessage", "PortalRules.completeWorld")
    "TradeService" = @("PlayerStateService.sync(a, profileA)", "PlayerStateService.sync(b, profileB)", "Trade complete:")
    "HomeService" = @("PlayerStateService.sync(player, profile)", "HomeDecor_", "Designer XP")
}

foreach ($entry in $rewardPaths.GetEnumerator()) {
    $path = Join-Path $root ("src\server\" + $entry.Key + ".luau")
    $source = Get-Content -Raw -LiteralPath $path
    foreach ($pattern in $entry.Value) {
        if ($source -notmatch [regex]::Escape($pattern)) {
            throw ("{0} does not prove a physical/popup reward contract: {1}." -f $entry.Key, $pattern)
        }
    }
}

Write-Output "Physical item-affordance invariant verified."
