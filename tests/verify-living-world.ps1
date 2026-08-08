$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$builderPath = Join-Path $root "src\server\LivingWorldBuilder.luau"
$servicePath = Join-Path $root "src\server\LivingWorldService.luau"
$rulesPath = Join-Path $root "src\shared\LivingWorldRules.luau"
$worldBuilderPath = Join-Path $root "src\server\WorldBuilder.luau"
$mainPath = Join-Path $root "src\server\Main.server.luau"
$builder = if (Test-Path -LiteralPath $builderPath) { Get-Content -Raw -LiteralPath $builderPath } else { "" }
$service = if (Test-Path -LiteralPath $servicePath) { Get-Content -Raw -LiteralPath $servicePath } else { "" }
$rules = Get-Content -Raw -LiteralPath $rulesPath
$worldBuilder = Get-Content -Raw -LiteralPath $worldBuilderPath
$main = Get-Content -Raw -LiteralPath $mainPath

if ([string]::IsNullOrWhiteSpace($builder)) {
    throw "LivingWorldBuilder.luau is missing."
}
if ([string]::IsNullOrWhiteSpace($service)) {
    throw "LivingWorldService.luau is missing."
}

foreach ($name in @("Cabin", "Nursery", "FlowerPatch", "Planter")) {
    if ($builder -notmatch [regex]::Escape($name)) {
        throw "LivingWorldBuilder is missing $name."
    }
}
foreach ($property in @("CanCollide = false", "CanTouch = false", "CanQuery = false")) {
    if ($builder -notmatch [regex]::Escape($property)) {
        throw "LivingWorldBuilder does not explicitly disable $property for decorations."
    }
}
if ($builder -notmatch 'itemName \.\. "Pickup"') {
    throw "LivingWorldBuilder does not create named item pickup carriers."
}
if ($builder -notmatch 'makePrompt\(pickup, "PickupPrompt", "Collect " \.\. itemName, "Village Find"\)') {
    throw "LivingWorldBuilder pickup prompts must pass name, action text, and object text explicitly."
}
foreach ($contract in @("LivingWorldRules", "collect", "MeadowSeed", "Seashell", "WoodToken")) {
    if ($service -notmatch [regex]::Escape($contract)) {
        throw "LivingWorldService is missing the $contract contract."
    }
}
if ($rules -notmatch "livingCollectionDay") {
    throw "LivingWorldRules does not use the daily collection state."
}
if ($worldBuilder -notmatch "LivingWorldBuilder") {
    throw "WorldBuilder does not compose the living-world builder."
}
if ($main -notmatch "LivingWorldService") {
    throw "Main.server.luau does not construct LivingWorldService."
}

Write-Output "Living-world source contracts verified."
