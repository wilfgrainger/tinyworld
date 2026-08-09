$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$rulesPath = Join-Path $root "src\shared\TraversalRules.luau"
$profilePath = Join-Path $root "src\shared\ProfileSchema.luau"
$builderPath = Join-Path $root "src\server\BoatBuilder.luau"
$boundaryPath = Join-Path $root "src\server\BoundaryBuilder.luau"
$servicePath = Join-Path $root "src\server\BoatService.luau"
$statePath = Join-Path $root "src\server\PlayerStateService.luau"
$mainPath = Join-Path $root "src\server\Main.server.luau"
$hudPath = Join-Path $root "src\client\Main.client.luau"

foreach ($path in @($rulesPath, $profilePath, $builderPath, $boundaryPath, $servicePath, $statePath, $mainPath, $hudPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Traversal source contract is missing: $path"
    }
}

$rules = Get-Content -Raw -LiteralPath $rulesPath
$profile = Get-Content -Raw -LiteralPath $profilePath
$builder = Get-Content -Raw -LiteralPath $builderPath
$boundary = Get-Content -Raw -LiteralPath $boundaryPath
$service = Get-Content -Raw -LiteralPath $servicePath
$state = Get-Content -Raw -LiteralPath $statePath
$main = Get-Content -Raw -LiteralPath $mainPath
$hud = Get-Content -Raw -LiteralPath $hudPath

foreach ($pattern in @("TINY_BOAT_PRICE", "buyTinyBoat", "mountTinyBoat", "returnTinyBoat")) {
    if ($rules -notmatch [regex]::Escape($pattern)) {
        throw "TraversalRules is missing $pattern."
    }
}

foreach ($pattern in @("version = 10", "ownsTinyBoat", "boatActive")) {
    if ($profile -notmatch [regex]::Escape($pattern)) {
        throw "ProfileSchema is missing v10 boat state: $pattern."
    }
}

foreach ($pattern in @("TinyBoat", "BoatHull", "BoatSeat", "BoatMast", "Board Tiny Boat", "Return to Sea Dock", "TinyWorldPhysicalBoat")) {
    if ($builder -notmatch [regex]::Escape($pattern)) {
        throw "BoatBuilder is missing the physical contract $pattern."
    }
}

foreach ($pattern in @("TidepoolCove", "TidepoolCoveIsland", "TidepoolCoveDock", "TidepoolCoveBeacon", "TinyBoatDock", "TinyBoatShop", "boatShopPrompt", "boatDockCFrame", "coveBoatCFrame", "coveArrivalCFrame", "villageReturnCFrame")) {
    if ($boundary -notmatch [regex]::Escape($pattern)) {
        throw "BoundaryBuilder is missing the physical traversal contract $pattern."
    }
}

foreach ($pattern in @("BoatService", "TraversalRules", "ProfileStore.get", "PlayerStateService.sync", "PlayerStateService.message", "ProfileStore.save", "boatActive = false", "PivotTo", "teleport")) {
    if ($service -notmatch [regex]::Escape($pattern)) {
        throw "BoatService is missing authoritative travel contract $pattern."
    }
}

foreach ($pattern in @("TinyWorldOwnsBoat", "TinyWorldBoatActive", "TinyWorldBoatState")) {
    if ($state -notmatch [regex]::Escape($pattern) -or $hud -notmatch [regex]::Escape($pattern)) {
        throw "Boat state is not replicated and rendered: $pattern."
    }
}

if ($main -notmatch "BoatService") {
    throw "BoatService is not wired into Main.server.luau."
}

Write-Output "Traversal source contracts verified."
