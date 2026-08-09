$root = Split-Path -Parent $PSScriptRoot
$world = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\WorldBuilder.luau")
$service = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\PhysicalItemService.luau")
$state = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\PlayerStateService.luau")
$garden = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\GardenService.luau")
$main = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\Main.server.luau")

foreach ($pattern in @("ItemChest", "InventoryDisplay", "itemChestPrompt", "gardenBeds")) {
    if ($world -notmatch [regex]::Escape($pattern)) {
        Write-Output ("World is missing physical item affordance: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("Carrot", "SugarCrystal", "MeadowSeed", "Seashell", "WoodToken", "refresh", "Item Chest:")) {
    if ($service -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Physical item service is missing: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("addSyncListener", "syncListeners")) {
    if ($state -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Profile sync does not refresh physical items: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("renderBed", "GardenCrop", "CARROT READY")) {
    if ($garden -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Garden has no physical crop state: " + $pattern)
        exit 1
    }
}
if ($main -notmatch "PhysicalItemService") {
    Write-Output "PhysicalItemService is not wired into the server composition root."
    exit 1
}

Write-Output "Physical item affordance guard passed."
