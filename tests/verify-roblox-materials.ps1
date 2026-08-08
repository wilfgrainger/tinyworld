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

Write-Output ("Roblox material references verified: " + ($usedMaterials -join ", "))
