$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$schema = Get-Content -Raw -LiteralPath (Join-Path $root "src\shared\ProfileSchema.luau")
$rules = Get-Content -Raw -LiteralPath (Join-Path $root "src\shared\Profession.luau")
$world = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\WorldBuilder.luau")
$servicePath = Join-Path $root "src\server\ProfessionService.luau"
$service = if (Test-Path -LiteralPath $servicePath) { Get-Content -Raw -LiteralPath $servicePath } else { "" }
$main = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\Main.server.luau")
$garden = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\GardenService.luau")
$homeSource = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\HomeService.luau")
$state = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\PlayerStateService.luau")
$client = Get-Content -Raw -LiteralPath (Join-Path $root "src\client\Main.client.luau")

foreach ($pattern in @("ProfileSchema.VERSION = 10", "farmerLevel", "farmerXp", "designerLevel", "designerXp")) {
    if (($schema + $rules) -notmatch [regex]::Escape($pattern)) {
        throw "Profession schema/rules contract is missing: $pattern."
    }
}
foreach ($pattern in @("ProfessionBoard", "professionPrompt", "PROFESSION BOARD")) {
    if ($world -notmatch [regex]::Escape($pattern)) {
        throw "World is missing physical profession board contract: $pattern."
    }
}
foreach ($pattern in @("ProfessionService", "Profession Board:", "PlayerStateService.message")) {
    if ($service -notmatch [regex]::Escape($pattern)) {
        throw "Profession service is missing: $pattern."
    }
}
if ($main -notmatch "ProfessionService") {
    throw "Main.server.luau does not wire ProfessionService."
}
foreach ($pattern in @('Profession.addXp(profile, "Farmer"', "Farmer XP")) {
    if ($garden -notmatch [regex]::Escape($pattern)) {
        throw "Garden is missing Farmer progression contract: $pattern."
    }
}
foreach ($pattern in @('Profession.addXp(profile, "Designer"', "Designer XP")) {
    if ($homeSource -notmatch [regex]::Escape($pattern)) {
        throw "Home is missing Designer progression contract: $pattern."
    }
}
foreach ($pattern in @("TinyWorldFarmerLevel", "TinyWorldDesignerLevel", "Careers:")) {
    if (($state + $client) -notmatch [regex]::Escape($pattern)) {
        throw "Career HUD/state contract is missing: $pattern."
    }
}

Write-Output "Profession expansion source guard passed."
