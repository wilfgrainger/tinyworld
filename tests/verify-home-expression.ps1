$root = Split-Path -Parent $PSScriptRoot
$rules = Get-Content -Raw -LiteralPath (Join-Path $root "src\shared\HomeExpressionRules.luau")
$schema = Get-Content -Raw -LiteralPath (Join-Path $root "src\shared\ProfileSchema.luau")
$service = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\HomeService.luau")
$plot = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\PlotService.luau")
$world = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\WorldBuilder.luau")
$client = Get-Content -Raw -LiteralPath (Join-Path $root "src\client\Main.client.luau")

foreach ($pattern in @("LanternNook", "StoryBookStack", "MeadowSeedShelf", "SeashellDisplay", "WoodlandBench", "PortalPainting", "acquire", "cycleTheme", "showcase")) {
    if ($rules -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home expression rules missing: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("VERSION = 10", "homeTheme", "homeDecor", "homeShowcaseCount")) {
    if ($schema -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home expression schema missing: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("homeDecorPrompt", "homeStylePrompt", "_acquireNextDecoration", "_cycleStyle", "_showcase", "HomeRoomRest", "HomeRoomMake", "HomeRoomShowcase", "HomeShowcasePlaque", "HomeDecor_")) {
    if ($service -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home expression service missing: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("HomeExpressionRules", "HomeStyleAccent", "profile.homeTheme")) {
    if ($plot -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home expression exterior wiring missing: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("HomeStyleBoard", "HomeGallery", "Change Home Style", "Collect Next Decor")) {
    if ($world -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home expression world wiring missing: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("Decor %d/6", "TinyWorldHomeTheme", "TinyWorldHomeDecorCount", "TinyWorldHomeShowcaseCount")) {
    if ($client -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Home expression HUD missing: " + $pattern)
        exit 1
    }
}
if ($client -notmatch "v0\.5\.1 PHYSICAL WORLD") {
    Write-Output "Current HUD is missing the v0.5.1 physical-world candidate label."
    exit 1
}

Write-Output "Home expression guard passed."
