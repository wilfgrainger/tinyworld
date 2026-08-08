$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$builderPath = Join-Path $root "src\server\BikeBuilder.luau"
$servicePath = Join-Path $root "src\server\TransportService.luau"
$statePath = Join-Path $root "src\server\PlayerStateService.luau"
$hudPath = Join-Path $root "src\client\Main.client.luau"

if (-not (Test-Path -LiteralPath $builderPath)) {
    throw "BikeBuilder.luau is missing."
}

$builder = Get-Content -Raw -LiteralPath $builderPath
$service = Get-Content -Raw -LiteralPath $servicePath
$state = Get-Content -Raw -LiteralPath $statePath
$hud = Get-Content -Raw -LiteralPath $hudPath

foreach ($name in @("BikeFrame", "BikeWheelFront", "BikeWheelBack", "BikeSeat", "BikeHandlebars", "BikePedals")) {
    if ($builder -notmatch [regex]::Escape($name)) {
        throw "BikeBuilder is missing $name."
    }
}

foreach ($contract in @("mountTinyBike", "dismountTinyBike")) {
    if ($service -notmatch [regex]::Escape($contract)) {
        throw "TransportService is missing the $contract contract."
    }
}
foreach ($promptText in @("Mount Bike", "Dismount Bike")) {
    if ($builder -notmatch [regex]::Escape($promptText)) {
        throw "BikeBuilder is missing the $promptText prompt."
    }
}
if ($state -notmatch "TinyWorldBikeState") {
    throw "PlayerStateService does not expose the authoritative bike state."
}

if ($hud -match "Tiny Bike ACTIVE") {
    throw "HUD still uses the misleading speed-only Tiny Bike ACTIVE label."
}
if ($hud -notmatch "TinyWorldBikeState") {
    throw "HUD does not render the authoritative bike state."
}

Write-Output "Rideable bike source contracts verified."
