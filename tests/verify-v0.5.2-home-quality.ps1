Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$script:failures = @()

function Add-Failure { param([string]$Message) $script:failures += $Message }
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
    if ($Source -notmatch $Pattern) { Add-Failure "Missing contract: $Contract" }
}
function Reject-Match {
    param([string]$Source, [string]$Pattern, [string]$Contract)
    if ($Source -match $Pattern) { Add-Failure "Forbidden path remains: $Contract" }
}

$homeBuilder = Read-RequiredSource "src/server/HomePrefabBuilder.luau"
Require-Match $homeBuilder '\bHomePrefabBuilder\.buildShell\s*\(' "HomePrefabBuilder.buildShell export"
foreach ($anchor in @("HomeFrontDoorAnchor", "HomePorchAnchor", "HomeGardenAnchor")) {
    Require-Match $homeBuilder ([regex]::Escape($anchor)) "named exterior anchor $anchor"
}
foreach ($field in @("frontDoorAnchor", "porchAnchor", "gardenAnchor", "homeCharmDisplay", "namePost")) {
    Require-Match $homeBuilder ('\b' + [regex]::Escape($field) + '\s*=') "buildShell return field $field"
}
foreach ($marker in @("TinyWorldArtRole", "TinyWorldPhysicalAffordance", "TinyWorldInteractionAnchor", "HomeCharmDisplay")) {
    Require-Match $homeBuilder ([regex]::Escape($marker)) "residential shell marker $marker"
}
foreach ($silhouette in @("HouseFacade", "Porch", "GableAccent", "FrontDoor")) {
    Require-Match $homeBuilder ([regex]::Escape($silhouette)) "home silhouette $silhouette"
}
foreach ($tierFeature in @("UpperFeature", "CabinChimney", "VillaTower")) {
    Require-Match $homeBuilder ([regex]::Escape($tierFeature)) "preserved tier feature $tierFeature"
}

$plotService = Read-RequiredSource "src/server/PlotService.luau"
Require-Match $plotService 'WaitForChild\("HomePrefabBuilder"\)' "PlotService loads HomePrefabBuilder"
Require-Match $plotService 'HomePrefabBuilder\.buildShell\s*\(\s*plot\.houseContainer\s*,\s*plot\.houseAnchor\s*,\s*profile\s*,\s*house\s*\)' "PlotService delegates residential shell"
Require-Match $plotService 'HomeService:buildInterior\s*\(\s*plot\s*,\s*profile\s*\)' "PlotService preserves interior build call"
Require-Match $plotService 'plot\.ownerLabel\.Text\s*=\s*string\.format' "PlotService preserves owner label behavior"
Reject-Match $plotService '\blocal function makeHousePart\b|"BackWall"|"VillaTower"' "inline residential shell construction"

$homeService = Read-RequiredSource "src/server/HomeService.luau"
foreach ($room in @("HomeRoom_Bedroom", "HomeRoom_Kitchen", "HomeRoom_Living", "HomeRoom_Bathroom", "HomeRoom_Storage", "HomeRoom_Garden")) {
    Require-Match $homeService ([regex]::Escape($room)) "hero-home room $room"
}
foreach ($prop in @(
    "HomeFurniture_BedsideLamp", "HomeFurniture_BedroomMirror", "HomeFurniture_BedroomShelf",
    "HomeFurniture_Fridge", "HomeFurniture_KitchenSink", "HomeFurniture_Cooker", "HomeFurniture_DiningTable", "HomeFurniture_DiningChair",
    "HomeFurniture_Sofa", "HomeFurniture_SideTable", "HomeFurniture_LivingRug", "HomeFurniture_BookToyShelf",
    "HomeFurniture_BathroomSink", "HomeFurniture_Toilet", "HomeFurniture_Shower",
    "HomeFurniture_StorageChest", "HomeGarden_PottingBench", "HomeGarden_FlowerArch"
)) {
    Require-Match $homeService ([regex]::Escape($prop)) "recognizable home prop $prop"
}
foreach ($action in @("KitchenUse", "LampToggle", "FridgeToggle", "SinkUse", "ShowerUse", "StorageView", "PottingUse")) {
    Require-Match $homeService ('"' + [regex]::Escape($action) + '"') "bounded ambient action $action"
}
Require-Match $homeService '\bfunction HomeService:_useAmbient\s*\(\s*player:\s*Player\s*,\s*plotIndex:\s*number\s*,\s*actionId:\s*string\s*,\s*target:\s*BasePart\s*\)' "bounded ambient handler signature"
Require-Match $homeService 'self:_useAmbient\s*\(\s*player\s*,\s*plot\.index\s*,\s*actionId\s*,\s*target\s*\)' "ambient prompts route through handler"
Require-Match $homeService 'prompt\.Name\s*=\s*"HomeAmbientPrompt_"\s*\.\.\s*actionId' "explicit ambient prompt naming"
Require-Match $homeService 'local\s+counter\s*=\s*makeFurniturePart\(kitchen,\s*"HomeFurniture_KitchenCounter"' "starter home always receives a kitchen counter"
Require-Match $homeService 'addAmbientPrompt\(\s*"KitchenUse"\s*,\s*counter' "starter kitchen has a playable free interaction"
foreach ($ownedItem in @("Bed", "KitchenCounter", "Wardrobe", "CreativeDesk")) {
    Require-Match $homeService ('addOwnedPrompt\(\s*"' + $ownedItem + '"') "owned HomeCatalog prompt $ownedItem"
}
$ambientSection = [regex]::Match($homeService, '(?s)function\s+HomeService:_useAmbient\b.*?function\s+HomeService:buildInterior\b').Value
if ($ambientSection -eq "") {
    Add-Failure "Missing contract: inspectable _useAmbient method body"
} else {
    Require-Match $ambientSection 'getOwnerForPlot\s*\(\s*plotIndex\s*\)' "ambient homeowner authorization"
    Require-Match $ambientSection 'target:IsDescendantOf\s*\(' "ambient target containment"
    Reject-Match $ambientSection 'ProfileStore\.(?:get|save)|PlayerStateService\.sync|HomeRules\.|Profession\.|profile\.(?:coins|xp|inventory|homeItems|houseTier|owns\w*)' "ambient economy, progression, inventory, or ownership mutation"
}

$homeCatalog = Read-RequiredSource "src/shared/HomeCatalog.luau"
if ([regex]::Matches($homeCatalog, '\bid\s*=\s*"(?:Bed|KitchenCounter|Wardrobe|CreativeDesk)"').Count -ne 4) {
    Add-Failure "Missing contract: exactly four authoritative HomeCatalog essentials"
}

$bikeBuilder = Read-RequiredSource "src/server/BikeBuilder.luau"
foreach ($part in @("BikeWheelBack", "BikeWheelFront", "BikeFrameTopTube", "BikeFrameDownTube", "BikeSeat", "BikeHandlebars", "BikeBasket", "BikeFlagTop")) {
    Require-Match $bikeBuilder ([regex]::Escape($part)) "recognizable bike part $part"
}
foreach ($contract in @("rideable-bike", "TinyWorldRecognizableSilhouette", "TinyWorldMotionRole")) {
    Require-Match $bikeBuilder ([regex]::Escape($contract)) "bike production-object contract $contract"
}
Require-Match $bikeBuilder 'mountPrompt\s*=\s*makePrompt\([^\r\n]*"MountPrompt"' "preserved bike MountPrompt"
Require-Match $bikeBuilder 'dismountPrompt\s*=\s*makePrompt\([^\r\n]*"DismountPrompt"' "preserved bike DismountPrompt"
Require-Match $bikeBuilder '(?s)return\s*\{\s*model\s*=\s*model,\s*mountPart\s*=\s*seat,\s*mountPrompt\s*=\s*mountPrompt,\s*dismountPrompt\s*=\s*dismountPrompt,\s*parts\s*=' "preserved bike builder return shape"

$boatBuilder = Read-RequiredSource "src/server/BoatBuilder.luau"
foreach ($part in @("BoatHullKeel", "BoatBowPort", "BoatBowStarboard", "BoatSeat", "BoatTiller", "BoatMast", "BoatSail", "BoatWaterWake")) {
    Require-Match $boatBuilder ([regex]::Escape($part)) "recognizable boat part $part"
}
foreach ($contract in @("sailing-boat", "TinyWorldRecognizableSilhouette", "TinyWorldMotionRole")) {
    Require-Match $boatBuilder ([regex]::Escape($contract)) "boat production-object contract $contract"
}
Require-Match $boatBuilder 'mountPrompt\s*=\s*makePrompt\([^\r\n]*"MountPrompt"' "preserved boat MountPrompt"
Require-Match $boatBuilder 'returnPrompt\s*=\s*makePrompt\([^\r\n]*"ReturnPrompt"' "preserved boat ReturnPrompt"
Require-Match $boatBuilder '(?s)return\s*\{\s*model\s*=\s*model,\s*mountPart\s*=\s*seat,\s*mountPrompt\s*=\s*mountPrompt,\s*returnPrompt\s*=\s*returnPrompt\s*\}' "preserved boat builder return shape"

$transportService = Read-RequiredSource "src/server/TransportService.luau"
Reject-Match $transportService 'TINY BIKE\s*-\s*MOUNTED|TinyWorldBikeBadge|BillboardGui' "ordinary-play bike telemetry badge"
Require-Match $transportService 'TinyWorldRideState' "friendly replicated bike state"
Require-Match $transportService 'TinyWorldMotionPhase' "bike motion hook"
Require-Match $transportService 'motionSessions' "authoritative per-session bike motion state"
Require-Match $transportService 'motion\.phase\s*\+=\s*deltaTime\s*\*\s*8' "authoritative accumulated bike phase"
Require-Match $transportService 'SetAttribute\(\s*"TinyWorldMotionPhase"\s*,\s*motion\.phase\s*\)' "coarse snapshot publishes accumulated phase"
Reject-Match $transportService 'GetAttribute\(\s*"TinyWorldMotionPhase"\s*\)\s*or\s*0\s*\)\s*\+\s*\(deltaTime' "discarded unpublished bike phase"
Require-Match $transportService 'MOTION_REPLICATION_INTERVAL_SECONDS' "coarse motion replication interval"
Require-Match $transportService 'motion\.replicationElapsed\s*>=\s*MOTION_REPLICATION_INTERVAL_SECONDS' "throttled motion snapshot"
Reject-Match $transportService 'part:SetAttribute\(\s*"TinyWorldMotionPhase"' "per-part server motion replication churn"
$motionAnimator = Read-RequiredSource "src/client/MotionAnimator.client.luau"
Require-Match $motionAnimator 'TinyWorldMotionState' "client motion-state consumer"
Require-Match $motionAnimator 'TinyWorldMotionPhase' "client motion-phase consumer"
Require-Match $motionAnimator 'TinyWorldMotionRole' "client motion-role consumer"
Require-Match $motionAnimator 'wheel-spin' "client bike wheel animator"
Require-Match $motionAnimator 'flag-flutter' "client flag animator"
Require-Match $motionAnimator 'RunService\.Heartbeat' "client cosmetic animation loop"
$boatService = Read-RequiredSource "src/server/BoatService.luau"
Require-Match $boatService 'TinyWorldMotionState' "boat motion-state hook"
Require-Match $boatService 'BoatWaterWake' "boat water-motion hook"
Require-Match $boatService 'flagBaseLocalCFrame' "boat-local flag baseline"
Require-Match $boatService 'ToObjectSpace\(\s*flag\.CFrame\s*\)' "canonical flag baseline capture"
Require-Match $boatService 'flagBaseLocalCFrame\s*~=\s*nil\s*then\s*return' "flag baseline captured once"
Require-Match $boatService 'local flutter\s*=\s*if state == "sailing" then CFrame\.Angles' "canonical flag flutter rotation"
Require-Match $boatService 'GetPivot\(\)\s*\*\s*boat\.flagBaseLocalCFrame\s*\*\s*flutter' "local flag flutter reapplied after pivot"
Reject-Match $boatService '\.Orientation\s*=' "world-space boat flag rotation"
Reject-Match $boatService 'boat\.flagBaseCFrame\s*=|boat\.flagBaseLocalCFrame\s*=\s*flag\.CFrame' "recaptured world-space flag baseline"
Reject-Match $boatService '(?:flag|wake):SetAttribute\(\s*"TinyWorldMotionPhase"' "per-part boat motion replication churn"

$physicalItems = Read-RequiredSource "src/server/PhysicalItemService.luau"
foreach ($role in @("inventory-carrot", "inventory-seed", "inventory-seashell", "home-furniture-display")) {
    Require-Match $physicalItems ([regex]::Escape($role)) "physical-item art role $role"
}
Require-Match $physicalItems 'TinyWorldArtRole' "physical inventory art-role attribute"

$jobService = Read-RequiredSource "src/server/JobService.luau"
Require-Match $jobService 'courier-parcel' "carried parcel art role"
Require-Match $jobService 'Enum\.Material\.Cardboard' "parcel material treatment"
$gardenService = Read-RequiredSource "src/server/GardenService.luau"
Require-Match $gardenService 'garden-carrot-crop' "crop art role"
Require-Match $gardenService 'Enum\.Material\.Grass' "crop material treatment"
$authoredPrefabs = Read-RequiredSource "src/server/AuthoredPrefabBuilder.luau"
foreach ($role in @("market-offer-tray", "shop-visible-stock")) {
    Require-Match $authoredPrefabs ([regex]::Escape($role)) "touched prefab art role $role"
}

if ($script:failures.Count -gt 0) {
    Write-Host "TinyWorld v0.5.2 home quality: FAIL" -ForegroundColor Red
    foreach ($failure in $script:failures) { Write-Host " - $failure" -ForegroundColor Red }
    exit 1
}

Write-Host "TinyWorld v0.5.2 home quality: PASS" -ForegroundColor Green
