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
        Add-Failure "Forbidden legacy path remains: $Contract"
    }
}

function Require-OrderedWiring {
    param([string]$Source, [string]$Pattern, [string]$Contract)
    if ($Source -notmatch $Pattern) {
        Add-Failure "Missing ordered builder wiring: $Contract"
    }
}

$builder = Read-RequiredSource "src/server/AuthoredPrefabBuilder.luau"

$knownMaterialNames = @(
    "Air",
    "Asphalt",
    "Basalt",
    "Brick",
    "Cobblestone",
    "Concrete",
    "CorrodedMetal",
    "CrackedLava",
    "DiamondPlate",
    "Fabric",
    "Foil",
    "ForceField",
    "Glass",
    "Glacier",
    "Granite",
    "Grass",
    "Ground",
    "Ice",
    "LeafyGrass",
    "Limestone",
    "Marble",
    "Metal",
    "Mud",
    "Neon",
    "Pavement",
    "Pebble",
    "Plastic",
    "Rock",
    "Salt",
    "Sand",
    "Sandstone",
    "Slate",
    "SmoothPlastic",
    "Snow",
    "Wood",
    "WoodPlanks"
)
foreach ($match in [regex]::Matches($builder, 'Enum\.Material\.([A-Za-z]+)')) {
    if ($knownMaterialNames -notcontains $match.Groups[1].Value) {
        Add-Failure "Invalid Roblox material enum name: $($match.Groups[1].Value)"
    }
}

foreach ($name in @(
    "buildTownHall",
    "buildCourierDepot",
    "buildVillageShop",
    "buildTransportWorkshop",
    "buildMarket",
    "buildPlotAffordances",
    "buildDailyFountain",
    "buildPortalFrame",
    "buildWorldPortal",
    "buildSugarCrystal",
    "buildMoonlitSeed"
)) {
    Require-Match $builder ('function\s+AuthoredPrefabBuilder\.' + $name + '\s*\(') "distinct $name builder"
}

foreach ($marker in @(
    "TinyWorldArtRole",
    "TinyWorldPhysicalAffordance",
    "TinyWorldInteractionAnchor"
)) {
    Require-Match $builder ([regex]::Escape($marker)) "prefab marker $marker"
}

foreach ($silhouettePart in @(
    "TownHallClock",
    "TownHallBell",
    "TownHallSteps",
    "CivicNoticeboard",
    "CourierLoadingAwning",
    "CourierParcelShelf",
    "CourierHandcart",
    "CourierDeliveryCounter",
    "ShopfrontWindow",
    "ShopStockShelf",
    "ShopAwning",
    "HomeSupplyCounterAnchor",
    "DecoratorCatalogueAnchor",
    "FurnishingShowroomAnchor",
    "WorkshopGarage",
    "WorkshopBikeStand",
    "WorkshopToolRack",
    "WorkshopWheelSign",
    "MarketTable",
    "TradeOfferTrayA",
    "TradeOfferTrayB",
    "ArchitectDrawingBoard",
    "FrontDoorBell",
    "PlotGate",
    "PottingBench",
    "FlowerArch"
)) {
    Require-Match $builder ([regex]::Escape($silhouettePart)) "authored silhouette part $silhouettePart"
}

foreach ($silhouettePart in @(
    "FountainBasin",
    "FountainPedestal",
    "FountainWater",
    "PortalLens",
    "PortalArchLeft",
    "PortalArchRight",
    "PortalCrown"
)) {
    Require-Match $builder ([regex]::Escape($silhouettePart)) "named civic/world silhouette part $silhouettePart"
}

foreach ($collectiblePart in @(
    "SugarCrystalPedestal",
    "SugarCrystalCore",
    "SugarCrystalFacetLeft",
    "SugarCrystalFacetRight",
    "MoonlitSeedPedestal",
    "MoonlitSeedBody",
    "MoonlitSeedStem",
    "MoonlitSeedLeafLeft",
    "MoonlitSeedLeafRight"
)) {
    Require-Match $builder ([regex]::Escape($collectiblePart)) "authored collectible silhouette part $collectiblePart"
}

$collectibleImplementation = [regex]::Match($builder, '(?s)function\s+AuthoredPrefabBuilder\.buildSugarCrystal\b.*?function\s+AuthoredPrefabBuilder\.buildDailyFountain').Value
if ($collectibleImplementation -eq "") {
    Add-Failure "Missing contract: inspectable portal collectible implementation region"
} else {
    Reject-Match $collectibleImplementation 'Enum\.Material\.Neon' "portal collectibles are not neon-only placeholders"
    Require-Match $collectibleImplementation 'TinyWorldCollectible' "portal collectibles retain item identity"
    Require-Match $collectibleImplementation 'makePrompt\(' "portal collectibles retain contextual interaction"
}

Require-Match $builder 'part\.CanCollide\s*=\s*false[\s\S]*part\.CanTouch\s*=\s*false[\s\S]*part\.CanQuery\s*=\s*false' "decoration parts are non-collidable, non-touching, and non-queryable"
Require-Match $builder 'anchor\.CanQuery\s*=\s*true' "prompt anchors remain queryable"

$worldBuilder = Read-RequiredSource "src/server/WorldBuilder.luau"
Require-Match $worldBuilder 'WaitForChild\("AuthoredPrefabBuilder"\)' "WorldBuilder requires AuthoredPrefabBuilder"
foreach ($name in @(
    "buildTownHall",
    "buildCourierDepot",
    "buildVillageShop",
    "buildTransportWorkshop",
    "buildMarket",
    "buildPlotAffordances"
)) {
    Require-Match $worldBuilder ('AuthoredPrefabBuilder\.' + $name + '\s*\(') "WorldBuilder consumes $name"
}

Require-Match $worldBuilder 'AuthoredPrefabBuilder\.buildDailyFountain\s*\(' "WorldBuilder consumes buildDailyFountain"
Require-Match $worldBuilder 'AuthoredPrefabBuilder\.buildPortalFrame\s*\(' "WorldBuilder consumes buildPortalFrame"
Require-Match $worldBuilder 'AuthoredPrefabBuilder\.buildWorldPortal\s*\(' "WorldBuilder consumes buildWorldPortal"
Require-Match $worldBuilder 'AuthoredPrefabBuilder\.buildSugarCrystal\s*\(' "WorldBuilder consumes buildSugarCrystal"
Require-Match $worldBuilder 'AuthoredPrefabBuilder\.buildMoonlitSeed\s*\(' "WorldBuilder consumes buildMoonlitSeed"

Require-OrderedWiring $worldBuilder '(?m)^\s*local\s+_townHall\s*,\s*contributionAnchor\s*,\s*noticeboard\s*=\s*AuthoredPrefabBuilder\.buildTownHall\s*\(' "buildTownHall -> model, contributionAnchor, noticeboard"
Require-OrderedWiring $worldBuilder '(?m)^\s*local\s+_courierDepot\s*,\s*courierPickupAnchor\s*,\s*_courierDeliveryAnchor\s*=\s*AuthoredPrefabBuilder\.buildCourierDepot\s*\(' "buildCourierDepot -> model, pickupAnchor, deliveryAnchor"
Require-OrderedWiring $worldBuilder '(?m)^\s*local\s+_villageShop\s*,\s*shopDeliveryAnchor\s*,\s*supplyAnchor\s*,\s*styleAnchor\s*,\s*galleryAnchor\s*=\s*AuthoredPrefabBuilder\.buildVillageShop\s*\(' "buildVillageShop -> model, deliveryAnchor, supplyAnchor, styleAnchor, galleryAnchor"
Require-OrderedWiring $worldBuilder '(?m)^\s*local\s+_transportWorkshop\s*,\s*transportAnchor\s*=\s*AuthoredPrefabBuilder\.buildTransportWorkshop\s*\(' "buildTransportWorkshop -> model, transportAnchor"
Require-OrderedWiring $worldBuilder '(?m)^\s*local\s+_market\s*,\s*tradeSides\s*,\s*tradeStatusLabel\s*=\s*AuthoredPrefabBuilder\.buildMarket\s*\(' "buildMarket -> model, sides, statusLabel"
Require-OrderedWiring $worldBuilder '(?m)^\s*local\s+upgradePrompt\s*,\s*privacyPrompt\s*,\s*visitPrompt\s*,\s*homeCharmPrompt\s*=\s*AuthoredPrefabBuilder\.buildPlotAffordances\s*\(' "buildPlotAffordances -> upgradePrompt, privacyPrompt, visitPrompt, homeCharmPrompt"

foreach ($field in @(
    "contributionPrompt",
    "fundLabel",
    "professionPrompt",
    "deliveryStartPrompt",
    "deliveryEndPrompt",
    "homeSupplyPrompt",
    "homeSupplyLabel",
    "homeStylePrompt",
    "homeStyleLabel",
    "homeDecorPrompt",
    "homeDecorLabel",
    "transportPrompt",
    "trade",
    "upgradePrompt",
    "privacyPrompt",
    "visitPrompt",
    "homeCharmPrompt",
    "itemChestPrompt",
    "gardenBeds",
    "gardenPrompts"
)) {
    Require-Match $worldBuilder ('\b' + [regex]::Escape($field) + '\b') "preserved service-facing field $field"
}

Reject-Match $worldBuilder '\bamenity\s*\(' "generic amenity() construction"
Reject-Match $worldBuilder '\bmakeInteractionMarker\s*\(' "normal-play interaction rings"
Reject-Match $worldBuilder '\bmakePortalFrame\s*\(' "inline portal-frame construction"
Reject-Match $worldBuilder 'makePart\s*\([^\r\n]*"SugarCrystal' "inline Sugar Crystal construction"
Reject-Match $worldBuilder 'makeShapeDecoration\s*\([^\r\n]*"MoonlitSeed' "inline Moonlit Seed construction"
Reject-Match $worldBuilder '\bPremiumPreview\b|PREMIUM PREVIEW' "ordinary-play premium preview sign"
Reject-Match $worldBuilder 'makePart\s*\(\s*root\s*,\s*"DailyFountain"' "inline daily fountain construction"
foreach ($legacyName in @("UpgradeKiosk", "PrivacyKiosk", "VisitKiosk", "HomeCharmKiosk", "TransportKiosk")) {
    Reject-Match $worldBuilder ([regex]::Escape($legacyName)) "generic box $legacyName"
}

$livingWorldBuilder = Read-RequiredSource "src/server/LivingWorldBuilder.luau"
Reject-Match $livingWorldBuilder '\bmakeBikeShowcase\s*\(' "duplicate generic bike showcase"
Require-Match $livingWorldBuilder '\bfunction\s+makePhysicalPickup\s*\(' "named physical pickup builder"
foreach ($pickupPart in @("MeadowSeedLeaf", "SeashellRidge", "WoodTokenGrain")) {
    Require-Match $livingWorldBuilder ([regex]::Escape($pickupPart)) "pickup silhouette part $pickupPart"
}
foreach ($marker in @("TinyWorldArtRole", "TinyWorldPhysicalAffordance", "TinyWorldInteractionAnchor")) {
    Require-Match $livingWorldBuilder ([regex]::Escape($marker)) "pickup marker $marker"
}
Require-Match $livingWorldBuilder 'makePhysicalPickup\s*\(model,\s*"MeadowSeed"' "Meadow Seed uses named pickup builder"
Require-Match $livingWorldBuilder 'makePhysicalPickup\s*\(model,\s*"Seashell"' "Seashell uses named pickup builder"
Require-Match $livingWorldBuilder 'makePhysicalPickup\s*\(model,\s*"WoodToken"' "Wood Token uses named pickup builder"
$pickupImplementation = [regex]::Match($livingWorldBuilder, '(?s)local\s+function\s+makePhysicalPickup\b.*?\nend\s*\n\s*function\s+LivingWorldBuilder\.build').Value
Reject-Match $pickupImplementation 'Enum\.Material\.Neon' "neon-only pickup representation"

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 authored prefabs: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "TinyWorld v0.5.2 authored prefabs: PASS" -ForegroundColor Green
