$validMaterials = @(
    "Plastic",
    "SmoothPlastic",
    "Neon",
    "Wood",
    "WoodPlanks",
    "Marble",
    "Basalt",
    "Slate",
    "CrackedLava",
    "Concrete",
    "Limestone",
    "Granite",
    "Pavement",
    "Brick",
    "Pebble",
    "Cobblestone",
    "Rock",
    "Sandstone",
    "CorrodedMetal",
    "DiamondPlate",
    "Foil",
    "Metal",
    "Grass",
    "LeafyGrass",
    "Sand",
    "Fabric",
    "Snow",
    "Mud",
    "Ground",
    "Asphalt",
    "Salt",
    "Ice",
    "Glacier",
    "Glass",
    "ForceField",
    "Air",
    "Water",
    "Cardboard",
    "Carpet",
    "CeramicTiles",
    "ClayRoofTiles",
    "RoofShingles",
    "Leather",
    "Plaster",
    "Rubber"
)

$usedMaterials = @(
    Get-ChildItem -Path (Join-Path $PSScriptRoot "..\src") -Recurse -File -Filter *.luau |
        ForEach-Object {
            $source = Get-Content -Raw -LiteralPath $_.FullName
            [regex]::Matches($source, "Enum\.Material\.([A-Za-z0-9_]+)") |
                ForEach-Object { $_.Groups[1].Value }
        } |
        Sort-Object -Unique
)

$invalidMaterials = @($usedMaterials | Where-Object { $_ -notin $validMaterials })
if ($invalidMaterials.Count -gt 0) {
    Write-Output ("Invalid Roblox Enum.Material references: " + ($invalidMaterials -join ", "))
    exit 1
}

$unsafeStudioWrites = @(
    Get-ChildItem -Path (Join-Path $PSScriptRoot "..\src") -Recurse -File -Filter *.luau |
        Select-String -Pattern "Lighting\.Technology\s*="
)
if ($unsafeStudioWrites.Count -gt 0) {
    Write-Output "Unsafe Play-session write detected: Lighting.Technology is Studio-only in the Roblox runtime."
    $unsafeStudioWrites | ForEach-Object { Write-Output (" - " + $_.Path + ":" + $_.LineNumber) }
    exit 1
}

$worldBuilder = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\WorldBuilder.luau")
if ($worldBuilder -notmatch "gui\.MaxDistance\s*=\s*maxDistance\s+or\s+80" -or
    $worldBuilder -notmatch "math\.min\(width or 200, 200\)" -or
    $worldBuilder -notmatch "UITextSizeConstraint" -or
    $worldBuilder -notmatch '"Available Plot", 180, 55') {
    Write-Output "World landmark labels must have a bounded size and viewing distance."
    exit 1
}

if ($worldBuilder -match '"VillageGround".*Enum\.Material\.Grass' -or
    $worldBuilder -match '"PlotBase".*Enum\.Material\.Grass' -or
    $worldBuilder -notmatch '"VillageGround".*Enum\.Material\.Ground' -or
    $worldBuilder -notmatch '"PlotBase".*Enum\.Material\.Ground' -or
    $worldBuilder -notmatch 'Workspace:FindFirstChild\("Baseplate"\)' -or
    $worldBuilder -notmatch 'baseplate:Destroy\(\)' -or
    $worldBuilder -notmatch 'makeStoneBorder\(model, "PlotBorder", origin \+ Vector3\.new\(0, 0\.08, 0\)' -or
    $worldBuilder -notmatch 'WorldLayoutRules\.create\(maxPlayers\)' -or
    $worldBuilder -notmatch 'BoundaryBuilder\.build\(root, layout\)') {
    Write-Output "Village ground and plot borders must use separated stable surfaces, remove the legacy Baseplate, and use the capacity-aware boundary builder."
    exit 1
}

$sceneryPath = Join-Path $PSScriptRoot "..\src\server\VillageSceneryBuilder.luau"
if (-not (Test-Path -LiteralPath $sceneryPath)) {
    Write-Output "The v0.0.4 civic scenery builder is missing."
    exit 1
}

$visualTheme = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\VisualTheme.luau")
$hud = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\client\Main.client.luau")
$sceneryBuilder = Get-Content -Raw -LiteralPath $sceneryPath
if ($visualTheme -notmatch 'TinyWorldColorGrade' -or
    $visualTheme -notmatch 'TinyWorldAtmosphere' -or
    $hud -notmatch 'STORYBOOK' -or
    $hud -notmatch 'UIGradient' -or
    $sceneryBuilder -notmatch 'VillagePlanter' -or
    $sceneryBuilder -notmatch 'MarketBanner') {
    Write-Output "The v0.0.5 storybook presentation contract is incomplete."
    exit 1
}
if ($sceneryBuilder -notmatch 'Enum\.Material\.Asphalt' -or
    $sceneryBuilder -notmatch 'Enum\.Material\.Cobblestone' -or
    $sceneryBuilder -notmatch 'VillageSquare' -or
    $sceneryBuilder -notmatch 'RoadNorth' -or
    $sceneryBuilder -notmatch 'RoadSouth' -or
    $sceneryBuilder -notmatch 'RoadEast' -or
    $sceneryBuilder -notmatch 'RoadWest' -or
    $sceneryBuilder -notmatch 'MarketStall' -or
    $sceneryBuilder -notmatch 'Lantern') {
    Write-Output "The v0.0.4 civic scenery builder must contain stable roads, kerbs, market stalls, and lanterns."
    exit 1
}

$plotService = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\PlotService.luau")
$stateService = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\PlayerStateService.luau")
$hud = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\client\Main.client.luau")
if ($worldBuilder -notmatch 'PlotHedge' -or
    $worldBuilder -notmatch 'PlotGate' -or
    $worldBuilder -notmatch 'GardenApproach' -or
    $plotService -notmatch 'HouseFacade' -or
    $plotService -notmatch 'HouseName') {
    Write-Output "Plots must have separated hedge/gate approaches and an explicit readable house facade."
    exit 1
}

if ($worldBuilder -notmatch 'HomeCharmPrompt' -or
    $plotService -notmatch 'homeCharmApplied' -or
    $plotService -notmatch 'HomePlanter' -or
    $plotService -notmatch 'HomeFlowerCluster' -or
    $plotService -notmatch 'HomeLantern' -or
    $plotService -notmatch 'HouseWindow' -or
    $stateService -notmatch 'TinyWorldLifeKitCount' -or
    $hud -notmatch 'Life kit') {
    Write-Output "Plots, homes, and HUD must expose the persistent Home Charm and life-kit result."
    exit 1
}

if ($worldBuilder -match 'for side, offset in \{\s*\{ name = "North"' -or
    $worldBuilder -match 'for side, x in \{\{name = "West"') {
    Write-Output "WorldBuilder side-dressing loops must iterate records through one loop variable."
    exit 1
}

$boundaryBuilder = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\BoundaryBuilder.luau")
if ($boundaryBuilder -notmatch 'Enum\.Material\.Water' -or
    $boundaryBuilder -notmatch 'Enum\.Material\.Sand' -or
    $boundaryBuilder -notmatch 'Enum\.Material\.Rock' -or
    $boundaryBuilder -notmatch 'Enum\.Material\.Basalt' -or
    $boundaryBuilder -notmatch 'VillageBoundary' -or
    $boundaryBuilder -notmatch 'layout\.budgets\.boundaryTrees' -or
    $boundaryBuilder -notmatch 'WoodlandClearing' -or
    $boundaryBuilder -notmatch 'WoodlandShrub' -or
    $boundaryBuilder -notmatch 'WoodlandTrail' -or
    $boundaryBuilder -notmatch 'CliffLookout' -or
    $boundaryBuilder -notmatch 'SeaDock') {
    Write-Output "The shared boundary must contain scalable sea, sand, cliffs, woods, and all three landmarks."
    exit 1
}

$layoutSource = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\shared\WorldLayoutRules.luau")
if ($layoutSource -notmatch 'visual = VisualBudgetRules\.forPlayers' -or
    $worldBuilder -notmatch 'TinyWorldPlotCapacity' -or
    $worldBuilder -notmatch 'TinyWorldVisualBudget') {
    Write-Output "The capacity/visual budget contract is incomplete."
    exit 1
}

Write-Output ("Roblox material references verified: " + ($usedMaterials -join ", "))
