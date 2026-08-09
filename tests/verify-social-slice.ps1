$rules = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\shared\SocialRules.luau")
$service = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\SocialService.luau")
$plot = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\PlotService.luau")
$trade = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\TradeService.luau")
$tradeRules = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\shared\TradeRules.luau")
$world = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\WorldBuilder.luau")

foreach ($pattern in @("privacyAllows", "MAX_PARTY_SIZE", "joinParty", "canShareActivity")) {
    if ($rules -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Social rules missing required contract: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("Village Walk", "recordVisit", "recordTrade", "PartyMember", "SharedActivityCount")) {
    if ($service -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Social service missing required contract: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("SocialRules.privacyAllows", "SocialService:recordVisit", "ProfileStore.save")) {
    if ($plot -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Plot visit/privacy integration missing required contract: " + $pattern)
        exit 1
    }
}
foreach ($pattern in @("TRADE_TIMEOUT_SECONDS", "_pruneExpired", "SocialService:recordTrade")) {
    $tradeContract = $trade
    if ($tradeContract -notmatch [regex]::Escape($pattern)) {
        Write-Output ("Trade safety integration missing required contract: " + $pattern)
        exit 1
    }
}
if ($tradeRules -notmatch [regex]::Escape("canExchange")) {
    Write-Output "Trade rules missing the preflight canExchange contract."
    exit 1
}
foreach ($pattern in @("buildSocialBoard", "VillageMeetupSign", "VillageWalkJoin", "VillageWalkLeave")) {
    if ($world -notmatch [regex]::Escape($pattern)) {
        Write-Output ("World social board missing required contract: " + $pattern)
        exit 1
    }
}

Write-Output "Social slice guard passed."
