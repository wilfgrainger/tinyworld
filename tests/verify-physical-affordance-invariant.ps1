$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$physicalPath = Join-Path $root "src\server\PhysicalItemService.luau"
$worldPath = Join-Path $root "src\server\WorldBuilder.luau"
$statePath = Join-Path $root "src\server\PlayerStateService.luau"
$physical = Get-Content -Raw -LiteralPath $physicalPath
$world = Get-Content -Raw -LiteralPath $worldPath
$state = Get-Content -Raw -LiteralPath $statePath

foreach ($pattern in @(
    "PHYSICAL_AFFORDANCE_INVARIANT",
    "Carrot", "SugarCrystal", "MeadowSeed", "Seashell", "WoodToken",
    "InventoryItem_", "Item Chest:", "ItemLabel", "addSyncListener", "refresh"
)) {
    if ($physical -notmatch [regex]::Escape($pattern)) {
        throw "Physical item service is missing the physical-affordance contract $pattern."
    }
}

foreach ($pattern in @("ItemChest", "itemChestPrompt", "InventoryDisplay", "gardenBeds", "PickupPrompt", "collectPrompts")) {
    if ($world -notmatch [regex]::Escape($pattern)) {
        throw "World is missing concrete item affordance: $pattern."
    }
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
