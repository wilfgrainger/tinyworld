$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$physical = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\PhysicalItemService.luau")
$state = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\PlayerStateService.luau")
$world = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\WorldBuilder.luau")
$main = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\Main.server.luau")

foreach ($pattern in @(
    "Carrot", "SugarCrystal", "MeadowSeed", "Seashell", "WoodToken",
    "InventoryItem_", "Item Chest:", "addSyncListener", "refresh"
)) {
    if ($physical -notmatch [regex]::Escape($pattern)) {
        throw "Physical item service is missing the $pattern contract."
    }
}

foreach ($pattern in @("syncListeners", "TinyWorldCarrots", "TinyWorldSugarCrystals", "TinyWorldMeadowSeeds", "TinyWorldSeashells", "TinyWorldWoodTokens")) {
    if ($state -notmatch [regex]::Escape($pattern)) {
        throw "Player state is missing inventory sync contract: $pattern."
    }
}

foreach ($pattern in @("ItemChest", "itemChestPrompt", "InventoryDisplay", "gardenBeds")) {
    if ($world -notmatch [regex]::Escape($pattern)) {
        throw "World is missing concrete item affordance: $pattern."
    }
}

$rewardPaths = @{
    "DailyRewardService" = @("PlayerStateService.sync(player, profile)", "Daily reward claimed:", "Carrot")
    "GardenService" = @("PlayerStateService.sync(player, profile)", "Carrot harvested:", "GardenCrop")
    "LivingWorldService" = @("PlayerStateService.sync(player, profile)", "Found a ", "DISPLAY_NAMES")
    "PortalService" = @("PlayerStateService.sync(player, profile)", "completionMessage", "PortalRules.completeWorld")
    "TradeService" = @("PlayerStateService.sync(a, profileA)", "PlayerStateService.sync(b, profileB)", "Trade complete:")
}

foreach ($entry in $rewardPaths.GetEnumerator()) {
    $path = Join-Path $root ("src\server\" + $entry.Key + ".luau")
    $source = Get-Content -Raw -LiteralPath $path
    foreach ($pattern in $entry.Value) {
        if ($source -notmatch [regex]::Escape($pattern)) {
            throw ("{0} does not prove an inventory-reward sync/popup contract: {1}." -f $entry.Key, $pattern)
        }
    }
}

if ($main -notmatch "PhysicalItemService") {
    throw "PhysicalItemService is not wired into Main.server.luau."
}

Write-Output "Item reward physical-affordance contract passed."
