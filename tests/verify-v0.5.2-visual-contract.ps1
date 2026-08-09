Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$script:failures = @()

function Add-ContractFailure {
    param([string]$Message)
    $script:failures += $Message
}

function Read-RequiredSource {
    param([string]$RelativePath)

    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-ContractFailure "Missing required file: $RelativePath"
        return ""
    }

    return Get-Content -LiteralPath $path -Raw
}

function Require-Match {
    param(
        [string]$Source,
        [string]$Pattern,
        [string]$Contract
    )

    if ($Source -notmatch $Pattern) {
        Add-ContractFailure "Missing contract: $Contract"
    }
}

function Reject-Match {
    param(
        [string]$Source,
        [string]$Pattern,
        [string]$Contract
    )

    if ($Source -match $Pattern) {
        Add-ContractFailure "Forbidden legacy path remains: $Contract"
    }
}

$qualityRules = Read-RequiredSource "src/shared/VisualQualityRules.luau"
Require-Match $qualityRules '\bMAX_RESIDENT_HOMES\s*=\s*16\b' "16-home visual cap"
Require-Match $qualityRules '\bTOAST_DURATION_SECONDS\s*=\s*3\b' "three-second toast duration"
Require-Match $qualityRules '\bNEIGHBOURHOOD_COUNT\s*=\s*4\b' "four-neighbourhood count"
Require-Match $qualityRules '\bisRecognizableObjectContract\b' "recognizable-object validator"

$layoutRules = Read-RequiredSource "src/shared/WorldLayoutRules.luau"
Require-Match $layoutRules '\bMAX_PLOTS\s*=\s*16\b' "WorldLayoutRules.MAX_PLOTS = 16"
Require-Match $layoutRules 'TerrainRules\.allBands\s*\(\)' "layout carries authored terrain bands"
foreach ($name in @("Meadow Lane", "Harbour Row", "Woodland Rise", "Orchard End")) {
    Require-Match $layoutRules ([regex]::Escape($name)) "neighbourhood $name"
}

$client = Read-RequiredSource "src/client/Main.client.luau"
foreach ($component in @("CoinChip", "LevelChip", "QuestChip", "JournalButton", "Toast", "JournalPanel")) {
    Require-Match $client ('\b' + [regex]::Escape($component) + '\b') "compact HUD component $component"
}
Require-Match $client 'RunService\s*:\s*IsStudio\s*\(' "Studio-only debug gate"

$playerFacingWorldSources = Get-ChildItem -LiteralPath (Join-Path $repoRoot "src/server") -Filter "*.luau" -File
foreach ($sourceFile in $playerFacingWorldSources) {
    $source = Get-Content -LiteralPath $sourceFile.FullName -Raw
    $relativePath = $sourceFile.FullName.Substring($repoRoot.Length + 1)
    Reject-Match $source '\bamenity\s*\(' "$relativePath generic amenity() world construction"
    Reject-Match $source '\bmakeInteractionMarker\s*\(' "$relativePath makeInteractionMarker() player-facing construction"
}

$authoredPrefabBuilder = Read-RequiredSource "src/server/AuthoredPrefabBuilder.luau"
foreach ($builder in @(
    "buildTownHall",
    "buildCourierDepot",
    "buildVillageShop",
    "buildTransportWorkshop",
    "buildMarket",
    "buildPlotAffordances"
)) {
    Require-Match $authoredPrefabBuilder ('\bAuthoredPrefabBuilder\.' + $builder + '\b') "AuthoredPrefabBuilder.$builder export"
}

$terrainRules = Read-RequiredSource "src/shared/TerrainRules.luau"
Require-Match $terrainRules '\bMeadowLaneBank\b' "Meadow Lane elevation band"
Require-Match $terrainRules '\bHarbourSlope\b' "Harbour Row elevation band"
Require-Match $terrainRules '\bWoodlandRise\b' "Woodland Rise elevation band"
Require-Match $terrainRules '\bOrchardTerrace\b' "Orchard End elevation band"
Require-Match $terrainRules 'heightRange\s*\(' "terrain height range contract"

$sceneryBuilder = Read-RequiredSource "src/server/VillageSceneryBuilder.luau"
Require-Match $sceneryBuilder 'function\s+buildTerrain\s*\(' "authored terrain geometry builder"
Require-Match $sceneryBuilder 'Instance\.new\("WedgePart"\)' "visible sloped terrain geometry"
Require-Match $sceneryBuilder 'TinyWorldTerrainHeight' "runtime terrain height evidence"
Require-Match $sceneryBuilder 'terrainBand\.CanCollide\s*=\s*false' "terrain bands remain visual-only over stable ground"
Require-Match $sceneryBuilder 'terrainBand\.CanQuery\s*=\s*false' "terrain bands do not interfere with world queries"
foreach ($marker in @("TinyWorldArtRole", "TinyWorldPhysicalAffordance", "TinyWorldInteractionAnchor")) {
    Require-Match $authoredPrefabBuilder ([regex]::Escape($marker)) "AuthoredPrefabBuilder.$marker marker"
}

$homePrefabBuilder = Read-RequiredSource "src/server/HomePrefabBuilder.luau"
Require-Match $homePrefabBuilder '\bHomePrefabBuilder\.buildShell\b' "HomePrefabBuilder.buildShell export"
Require-Match $homePrefabBuilder '\bHomeCharmDisplay\b' "HomePrefabBuilder.HomeCharmDisplay anchor"
foreach ($marker in @("TinyWorldArtRole", "TinyWorldPhysicalAffordance", "TinyWorldInteractionAnchor")) {
    Require-Match $homePrefabBuilder ([regex]::Escape($marker)) "HomePrefabBuilder.$marker marker"
}

$docsIndex = Read-RequiredSource "docs/README.md"
Require-Match $docsIndex 'docs/superpowers/' "historical Superpowers documentation pointer"
Require-Match $docsIndex '(?i)historical context' "historical-context authority label"
Require-Match $docsIndex 'releases/v0\.5\.2/acceptance\.md' "active v0.5.2 acceptance link"

foreach ($document in @(
    "docs/product/vision.md",
    "docs/product/experience-pillars.md",
    "docs/product/art-direction.md",
    "docs/product/village.md",
    "docs/product/homes.md",
    "docs/product/ui-ux.md",
    "docs/roadmap/roadmap.md",
    "docs/roadmap/v0.5.2-village-soul.md",
    "docs/engineering/architecture.md",
    "docs/engineering/world-content-pipeline.md",
    "docs/quality/definition-of-done.md",
    "docs/quality/visual-quality-bar.md",
    "docs/quality/playtesting.md",
    "docs/releases/v0.5.2/acceptance.md"
)) {
    [void](Read-RequiredSource $document)
}

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 visual contract: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "TinyWorld v0.5.2 visual contract: PASS" -ForegroundColor Green
