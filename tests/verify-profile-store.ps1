$path = Join-Path $PSScriptRoot "..\src\server\ProfileStore.luau"
$source = Get-Content -Raw -LiteralPath $path
foreach ($pattern in @('UpdateAsync', 'GenerateGUID', 'SESSION_LEASE_SECONDS', 'SAVE_DEBOUNCE_SECONDS', 'task.delay', 'saveNow', 'getDiagnostics')) {
    if ($source -notmatch [regex]::Escape($pattern)) {
        Write-Output ("ProfileStore missing required hardening contract: " + $pattern)
        exit 1
    }
}
if ($source -match 'store:GetAsync') {
    Write-Output "ProfileStore must acquire the session and load the profile through UpdateAsync."
    exit 1
}
$main = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\Main.server.luau")
if ($main -notmatch 'ProfileStore\.shutdown') {
    Write-Output "Main must use the bounded ProfileStore shutdown path."
    exit 1
}
Write-Output "ProfileStore hardening guard passed."
