Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$script:failures = @()

function Add-Failure {
    param([string]$Message)
    $script:failures += $Message
}

function Read-RequiredSource {
    param([string]$RelativePath)
    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Failure "Missing required file: $RelativePath"
        return ""
    }
    return Get-Content -LiteralPath $path -Raw
}

function Require-Match {
    param([string]$Source, [string]$Pattern, [string]$Contract)
    if ($Source -notmatch $Pattern) {
        Add-Failure "Missing contract: $Contract"
    }
}

function Reject-Match {
    param([string]$Source, [string]$Pattern, [string]$Contract)
    if ($Source -match $Pattern) {
        Add-Failure "Forbidden contract: $Contract"
    }
}

$transport = Read-RequiredSource "src/server/TransportService.luau"
Require-Match $transport 'function\s+TransportService:_seatPlayer\s*\(\s*player:\s*Player\s*,\s*seat:\s*Seat\s*\)' "bike mount has a server-side seating helper"
Require-Match $transport 'seat:Sit\(\s*humanoid\s*\)' "bike mount explicitly seats the Humanoid"
Require-Match $transport 'bike\.model:PivotTo\([\s\S]*?\)\s*\n\s*if\s+not\s+self:_seatPlayer\(\s*player\s*,\s*bike\.mountPart\s*\)' "bike seats after vehicle positioning"
Require-Match $transport 'function\s+TransportService:_restorePlayerState\s*\(\s*player:\s*Player(?:\s*,\s*profile:\s*any\?)?\s*\)' "bike cleanup has a safe player-state restore helper"
Require-Match $transport 'humanoid\.Sit\s*=\s*false' "bike cleanup explicitly unseats the Humanoid"
Require-Match $transport 'self:_restorePlayerState\(\s*player(?:\s*,\s*profile)?\s*\)' "bike dismount/respawn cleanup restores player state"
Require-Match $transport 'MOTION_REPLICATION_INTERVAL_SECONDS' "bike motion keeps a coarse replication interval"
Require-Match $transport 'motion\.replicationElapsed\s*>=\s*MOTION_REPLICATION_INTERVAL_SECONDS' "bike motion snapshots remain throttled"
Reject-Match $transport 'GetAttribute\(\s*"TinyWorldMotionPhase"\s*\)\s*or\s*0\s*\)\s*\+\s*deltaTime' "bike motion does not reintroduce per-frame replication churn"
Require-Match $transport 'mountPrompt\.Triggered:Connect' "bike mount prompt contract remains server-bound"
Require-Match $transport 'triggeringPlayer\s*==\s*player' "bike prompt ownership check remains intact"

$boat = Read-RequiredSource "src/server/BoatService.luau"
Require-Match $boat 'function\s+BoatService:_seatPlayer\s*\(\s*player:\s*Player\s*,\s*seat:\s*Seat\s*\)' "boat mount has a server-side seating helper"
Require-Match $boat 'seat:Sit\(\s*humanoid\s*\)' "boat mount explicitly seats the Humanoid"
Require-Match $boat 'boat\.model:PivotTo\([\s\S]*?\)\s*\n\s*self:_setMotionState\([\s\S]*?\)\s*\n\s*teleport\(\s*player[\s\S]*?\)\s*\n\s*if\s+not\s+self:_seatPlayer\(\s*player\s*,\s*boat\.mountPart\s*\)' "boat seats after vehicle and character positioning"
Require-Match $boat 'function\s+BoatService:_restorePlayerState\s*\(\s*player:\s*Player\s*\)' "boat cleanup has a safe player-state restore helper"
Require-Match $boat 'humanoid\.Sit\s*=\s*false' "boat cleanup explicitly unseats the Humanoid"
Require-Match $boat 'self:_restorePlayerState\(\s*player\s*\)' "boat return/respawn cleanup restores player state"
Require-Match $boat 'mountPrompt\.Triggered:Connect' "boat mount prompt contract remains server-bound"
Require-Match $boat 'triggeringPlayer\s*==\s*player' "boat prompt ownership check remains intact"
Require-Match $boat 'TinyWorldMotionState' "boat motion state remains replicated through the existing model hook"
Reject-Match $boat 'Heartbeat|RenderStepped|Stepped' "boat mount does not add a per-frame server loop"

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 vehicle mounting: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "TinyWorld v0.5.2 vehicle mounting: PASS" -ForegroundColor Green
