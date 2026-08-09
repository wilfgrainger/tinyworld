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

$theme = Read-RequiredSource "src/server/VisualTheme.luau"
$ambientCaps = @{
    "MAX_CHIMNEY_SMOKE_EMITTERS" = 3
    "MAX_WARM_WINDOW_LIGHTS" = 4
    "MAX_WATER_HIGHLIGHTS" = 4
    "MAX_FOLIAGE_HOOKS" = 6
    "MAX_BIRD_HOOKS" = 3
    "MAX_BUTTERFLY_HOOKS" = 4
    "MAX_TOTAL_EFFECTS" = 24
    "SMOKE_RATE" = 1
}
foreach ($entry in $ambientCaps.GetEnumerator()) {
    Require-Match $theme ('\b' + $entry.Key + '\s*=\s*' + $entry.Value + '\b') "bounded ambient cap $($entry.Key) = $($entry.Value)"
}

$scenery = Read-RequiredSource "src/server/VillageSceneryBuilder.luau"
Require-Match $scenery '\bfunction\s+VillageSceneryBuilder\.buildAmbientLife\s*\(' "bounded ambient builder export"
Require-Match $scenery '\bfunction\s+VillageSceneryBuilder\.bindHomeAmbient\s*\(' "home-bound ambient builder export"
Require-Match $scenery '\bfunction\s+VillageSceneryBuilder\.releaseHomeAmbient\s*\(' "home ambient release path"
Require-Match $scenery 'math\.min\s*\(\s*layout\.budgets\.visual\.seededDressing\s*,\s*VisualTheme\.Ambient\.MAX_TOTAL_EFFECTS\s*\)' "ambient effects consume the seeded dressing budget"
Require-Match $scenery '\bauthoredVariant\s*\(\s*layout\.artSeed\b' "ambient placement uses the authored seed"
foreach ($hook in @(
    "ChimneySmokeEmitter",
    "WarmWindowLight",
    "WaterHighlightHook",
    "FoliageSwayHook",
    "BirdMotionHook",
    "ButterflyMotionHook"
)) {
    Require-Match $scenery ([regex]::Escape($hook)) "ambient hook $hook"
}
Require-Match $scenery 'Instance\.new\("ParticleEmitter"\)' "real chimney smoke particle emitter"
Require-Match $scenery 'emitter\.Rate\s*=\s*VisualTheme\.Ambient\.SMOKE_RATE' "smoke uses the shared capped rate"
Require-Match $scenery 'Instance\.new\("PointLight"\)' "real warm window light"
Require-Match $scenery 'HomeWarmWindowLight' "warm light is attached to a residential window"
Require-Match $scenery 'HomeChimneySmokeEmitter' "smoke is attached to a residential chimney"
Require-Match $scenery 'homeBindings' "residential ambient bindings are tracked"
Require-Match $scenery 'TinyWorldAmbientEffect' "ambient art-role marker"
Require-Match $scenery 'CanCollide\s*=\s*false[\s\S]*CanTouch\s*=\s*false[\s\S]*CanQuery\s*=\s*false' "ambient decoration physical safety"

$ambientImplementationRegion = [regex]::Match($scenery, '(?s)local\s+function\s+makeAmbientDecoration\b.*?\nend\s*\n\s*VillageSceneryBuilder\.rotateOffset').Value
if ($ambientImplementationRegion -eq "") {
    Add-Failure "Missing contract: inspectable ambient implementation region"
} else {
    Reject-Match $ambientImplementationRegion 'GetService\("Players"\)|PlayerAdded|PlayerRemoving|\bPlayer\b' "player-scoped ambient allocation"
    Reject-Match $ambientImplementationRegion '\bwhile\s+true\b|RenderStepped|Heartbeat|Stepped' "unbounded server ambient loop"
}

$worldBuilder = Read-RequiredSource "src/server/WorldBuilder.luau"
Require-Match $worldBuilder 'local\s+ambientLife\s*=\s*VillageSceneryBuilder\.buildAmbientLife\s*\(\s*root\s*,\s*layout\s*,\s*\{' "WorldBuilder creates ambient life once per world"
$ambientBuilderInvocations = [regex]::Matches($worldBuilder, '(?m)^(?!\s*function\b)(?!\s*--).*VillageSceneryBuilder\.buildAmbientLife\s*\(').Count
if ($ambientBuilderInvocations -ne 1) {
    Add-Failure "WorldBuilder must contain exactly one non-definition VillageSceneryBuilder.buildAmbientLife invocation; found $ambientBuilderInvocations"
}
Require-Match $worldBuilder '\bambientLife\s*=\s*ambientLife\b' "WorldBuilder returns ambient evidence without changing existing fields"
Require-Match $worldBuilder 'TinyWorldAmbientEffectCount' "world exposes the bounded ambient count"

$plotService = Read-RequiredSource "src/server/PlotService.luau"
Require-Match $plotService 'VillageSceneryBuilder\.releaseHomeAmbient\s*\(\s*self\.world\.ambientLife' "PlotService releases previous home ambience"
Require-Match $plotService 'VillageSceneryBuilder\.bindHomeAmbient\s*\(\s*self\.world\.ambientLife\s*,\s*plot\.houseContainer' "PlotService binds ambience to the built home prefab"

$studioRoute = Read-RequiredSource "docs/v0.5.2-village-soul-test.md"
foreach ($routeItem in @(
    "Onboarding",
    "Compact HUD",
    "Journal",
    "Neighbourhood walk",
    "Labels-off child-recognition test",
    "Hero-home interactions",
    "Bike and boat",
    "Portal",
    "Trade",
    "Persistence",
    "Output review"
)) {
    Require-Match $studioRoute ([regex]::Escape($routeItem)) "Studio route item $routeItem"
}
foreach ($evidenceClass in @(
    "Local source evidence",
    "Studio evidence",
    "Published-place evidence",
    "Device evidence"
)) {
    Require-Match $studioRoute ([regex]::Escape($evidenceClass)) "separate evidence class $evidenceClass"
}
Require-Match $studioRoute '(?i)source evidence.*(?:does not|cannot).*Studio|Studio.*(?:does not|cannot).*source evidence' "local evidence is not represented as Studio evidence"

$readme = Read-RequiredSource "README.md"
$docsIndex = Read-RequiredSource "docs/README.md"
$progress = Read-RequiredSource "docs/progress.md"
$artDirection = Read-RequiredSource "docs/product/art-direction.md"
$qualityBar = Read-RequiredSource "docs/quality/visual-quality-bar.md"
$acceptance = Read-RequiredSource "docs/releases/v0.5.2/acceptance.md"

foreach ($pair in @(
    @{ Source = $readme; Name = "README" },
    @{ Source = $docsIndex; Name = "documentation index" },
    @{ Source = $progress; Name = "progress" },
    @{ Source = $acceptance; Name = "acceptance" }
)) {
    Require-Match $pair.Source 'v0\.5\.2-village-soul-test\.md' "$($pair.Name) links the exact Studio route"
    Require-Match $pair.Source 'verify-v0\.5\.2-ambient-acceptance\.ps1' "$($pair.Name) links the ambient acceptance guard"
}

$premiumDocuments = @(
    @{ Source = $artDirection; Name = "art direction" },
    @{ Source = $qualityBar; Name = "visual quality bar" },
    @{ Source = $acceptance; Name = "acceptance" },
    @{ Source = $studioRoute; Name = "Studio route" }
)
foreach ($document in $premiumDocuments) {
    Require-Match $document.Source '(?i)premium(?:-feel)? quality gate' "$($document.Name) names the premium-feel quality gate"
    foreach ($observable in @(
        "authored silhouettes",
        "quality materials",
        "composed lighting",
        "tactile feedback",
        "restrained UI",
        "arbitrary coloured cubes",
        "telemetry walls",
        "labels-off child-recognition test"
    )) {
        Require-Match $document.Source ([regex]::Escape($observable)) "$($document.Name) premium check: $observable"
    }
    Require-Match $document.Source '(?i)(?:pass|fail)' "$($document.Name) gives the premium gate an observable result"
}
Require-Match $acceptance '(?i)not monetisation|no monetisation' "premium-feel gate is not a monetisation system"

foreach ($evidenceStatus in @(
    "Local source and pure tests",
    "One-player Studio",
    "Two-client Studio",
    "Published place",
    "Mobile/controller devices"
)) {
    Require-Match $acceptance ([regex]::Escape($evidenceStatus)) "acceptance evidence status $evidenceStatus"
}

Require-Match $docsIndex 'docs/superpowers/' "historical Superpowers documentation pointer remains"
Require-Match $docsIndex '(?i)historical context' "historical-context authority label remains"

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 ambient acceptance: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "TinyWorld v0.5.2 ambient acceptance: PASS" -ForegroundColor Green
