$root = Join-Path $PSScriptRoot ".."
$rules = Get-Content -Raw -LiteralPath (Join-Path $root "src\shared\PortalRules.luau")
$service = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\PortalService.luau")
$builder = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\WorldBuilder.luau")
$main = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\Main.server.luau")
$client = Get-Content -Raw -LiteralPath (Join-Path $root "src\client\Main.client.luau")

foreach ($pattern in @('WORLDS', 'GiantKitchen', 'MoonlitMeadow', 'completeWorld', 'collectibleCount', 'Moonlit Seed')) {
    if ($rules -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Portal rules missing reusable world contract: " + $pattern)
        exit 1
    }
}

foreach ($pattern in @('_connectWorld', 'self.worlds', 'world.kitchen', 'world.moonlitMeadow', 'TinyWorldPortalWorld', 'PortalRules.completeWorld')) {
    if ($service -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Portal service missing reusable pipeline wiring: " + $pattern)
        exit 1
    }
}

foreach ($pattern in @('buildMoonlitMeadow', 'MoonlitMeadowPortal', 'moonlitPortalPrompt', 'MoonlitSeed', 'moonlitMeadow')) {
    if ($builder -notmatch [regex]::Escape($pattern)) {
        Write-Output ("World builder missing second portal world: " + $pattern)
        exit 1
    }
}

if ($main -notmatch 'portalService:setupPlayer') {
    Write-Output "Main must initialise the generic portal state for every player."
    exit 1
}
if ($client -notmatch 'Mission finds' -or $client -notmatch 'TinyWorldPortalWorld') {
	Write-Output "HUD must preserve the generic portal mission state across releases."
    exit 1
}

Write-Output "Portal worlds guard passed."
