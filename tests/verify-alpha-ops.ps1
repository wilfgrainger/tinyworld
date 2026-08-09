$root = Join-Path $PSScriptRoot ".."
$rules = Get-Content -Raw -LiteralPath (Join-Path $root "src\shared\AlphaOpsRules.luau")
$service = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\AlphaOpsService.luau")
$main = Get-Content -Raw -LiteralPath (Join-Path $root "src\server\Main.server.luau")
$client = Get-Content -Raw -LiteralPath (Join-Path $root "src\client\Main.client.luau")

foreach ($pattern in @('RELEASE_VERSION = "0.1.0"', 'CHANNEL = "INVITED_ALPHA"', 'RECOMMENDED_COHORT_SIZE = 8', 'healthState', 'aggregateState')) {
    if ($rules -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Alpha operations rules missing required contract: " + $pattern)
        exit 1
    }
}

foreach ($pattern in @('getDiagnostics', 'TinyWorldAlphaRecoveryRequired', 'TinyWorldAlphaQueueDepth', 'TinyWorldAlphaCohortState', 'TinyWorldAlphaDiagnosticsScope', 'HEALTH_POLL_SECONDS', 'PlayerStateService.message')) {
    if ($service -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Alpha operations service missing required contract: " + $pattern)
        exit 1
    }
}

foreach ($pattern in @('AlphaOpsService', 'alphaOpsService:setupPlayer', 'alphaOpsService:removePlayer', 'alphaOpsService:stop')) {
    if ($main -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Main missing invited-alpha wiring: " + $pattern)
        exit 1
    }
}

if ($client -notmatch 'v0\.1\.0 ALPHA' -or $client -notmatch 'INVITED ALPHA') {
    Write-Output "HUD must identify the v0.1.0 invited alpha candidate in readable title/eyebrow copy."
    exit 1
}

Write-Output "Invited alpha operations guard passed."
