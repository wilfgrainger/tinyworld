$catalog = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\shared\HomeCatalog.luau")
$rules = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\shared\HomeRules.luau")
$schema = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\shared\ProfileSchema.luau")
$service = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\HomeService.luau")
$plot = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\PlotService.luau")
$world = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\WorldBuilder.luau")
$client = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\client\Main.client.luau")

foreach ($pattern in @("Bed", "KitchenCounter", "Wardrobe", "CreativeDesk")) {
    if ($catalog -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home catalog missing concrete item: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("nextItem", "HomeRules.buy", "HomeRules.use")) {
    if ($rules -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home rules missing required contract: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("homeItems", "homeUseCount", "version = 7")) {
    if ($schema -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home profile migration missing required contract: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("HomeSupplyCounter", "HomeFurniture_Bed", "HomeFurniture_KitchenCounter", "HomeFurniture_Wardrobe", "HomeFurniture_CreativeDesk", "buildInterior", "ProfileStore.save")) {
    if (($service + $plot + $world) -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Functional home wiring missing required contract: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("Items %d/4", "TinyWorldHomeOwnedCount", "TinyWorldHomeUseCount")) {
    if ($client -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home HUD missing required contract: " + $pattern)
        exit 1
    }
}

Write-Output "Functional home slice guard passed."
