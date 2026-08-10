from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, content: str) -> None:
    (ROOT / path).write_text(content, encoding="utf-8")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected exactly one match, found {count}")
    return text.replace(old, new, 1)


def regex_once(text: str, pattern: str, replacement: str, label: str) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.S | re.M)
    if count != 1:
        raise RuntimeError(f"{label}: expected exactly one regex match, found {count}")
    return updated


SURFACE_LABEL_AUTHORED = '''local function makeSurfaceLabel(parent: BasePart, text: string): TextLabel
\tlocal gui = Instance.new("SurfaceGui")
\tgui.Name = "SignSurface"
\tgui.Face = Enum.NormalId.Front
\tgui.AlwaysOnTop = false
\tgui.LightInfluence = 1
\tgui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
\tgui.PixelsPerStud = 42
\tgui.Parent = parent

\tlocal label = Instance.new("TextLabel")
\tlabel.BackgroundTransparency = 1
\tlabel.Size = UDim2.fromScale(1, 1)
\tlabel.TextColor3 = VisualTheme.Colors.paper
\tlabel.TextWrapped = true
\tlabel.TextScaled = true
\tlabel.Font = Enum.Font.GothamBold
\tlabel.Text = text
\tlabel.Parent = gui
\tlocal constraint = Instance.new("UITextSizeConstraint")
\tconstraint.MinTextSize = 10
\tconstraint.MaxTextSize = 24
\tconstraint.Parent = label
\treturn label
end
'''

SURFACE_LABEL_WORLD = '''local function makeSurfaceLabel(parent: BasePart, text: string): TextLabel
\tlocal gui = Instance.new("SurfaceGui")
\tgui.Name = "SignSurface"
\tgui.Face = Enum.NormalId.Front
\tgui.AlwaysOnTop = false
\tgui.LightInfluence = 1
\tgui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
\tgui.PixelsPerStud = 42
\tgui.Parent = parent

\tlocal label = Instance.new("TextLabel")
\tlabel.BackgroundTransparency = 1
\tlabel.Size = UDim2.fromScale(1, 1)
\tlabel.TextColor3 = VisualTheme.Colors.paper
\tlabel.TextWrapped = true
\tlabel.TextScaled = true
\tlabel.Font = Enum.Font.GothamBold
\tlabel.Text = text
\tlabel.Parent = gui
\tlocal textConstraint = Instance.new("UITextSizeConstraint")
\ttextConstraint.MinTextSize = 10
\ttextConstraint.MaxTextSize = 24
\ttextConstraint.Parent = label
\treturn label
end
'''

# AuthoredPrefabBuilder: delete generic floating labels, retain one physical trade board.
path = "src/server/AuthoredPrefabBuilder.luau"
text = read(path)
text = regex_once(
    text,
    r'local function makeLabel\(parent: BasePart, text: string, width: number\?\): TextLabel\n.*?\nend\n',
    SURFACE_LABEL_AUTHORED,
    "AuthoredPrefabBuilder.makeLabel",
)
text = replace_once(
    text,
    'local statusLabel = makeLabel(sign, "TRADING POST\\nTwo players: join → choose item → confirm", 340)',
    'local statusLabel = makeSurfaceLabel(sign, "Trading Post")',
    "Trading Post surface label",
)
text = re.sub(r'^\s*makeLabel\([^\n]*\)\n', '', text, flags=re.M)
if "makeLabel(" in text or 'Instance.new("BillboardGui")' in text:
    raise RuntimeError("AuthoredPrefabBuilder still contains generic floating label code")
noticeboard_marker = '''\tlocal noticeboard = makeAnchor(
\t\tmodel,
\t\t"CivicNoticeboard",
\t\tVector3.new(12, 6, 1),
\t\torigin + Vector3.new(-10, 4, 13),
\t\t"profession-noticeboard"
\t)
'''
noticeboard_replacement = noticeboard_marker + '''\tnoticeboard.Transparency = 0
\tnoticeboard.Color = VisualTheme.Colors.warmLight
\tnoticeboard.Material = Enum.Material.WoodPlanks
\tnoticeboard.CanCollide = false
'''
text = replace_once(text, noticeboard_marker, noticeboard_replacement, "physical jobs board")
jobs_cards = '''\tfor index, x in { -13, -10, -7 } do
\t\tmakeDecoration(
\t\t\tmodel,
\t\t\t"CivicJobCard" .. index,
\t\t\tVector3.new(2.2, 3.2, 0.2),
\t\t\torigin + Vector3.new(x, 4, 13.85),
\t\t\tif index % 2 == 0 then VisualTheme.Colors.sky else VisualTheme.Colors.paper,
\t\t\tEnum.Material.SmoothPlastic,
\t\t\t"profession-job-card"
\t\t)
\tend
'''
text = replace_once(
    text,
    '\treturn model, contributionAnchor, noticeboard\nend\n\nfunction AuthoredPrefabBuilder.buildCourierDepot',
    jobs_cards + '\treturn model, contributionAnchor, noticeboard\nend\n\nfunction AuthoredPrefabBuilder.buildCourierDepot',
    "jobs board cards",
)
write(path, text)

# BoundaryBuilder: convert the few useful names to physical signs and delete floating prose.
path = "src/server/BoundaryBuilder.luau"
text = read(path)
text = regex_once(
    text,
    r'local function makeLabel\(parent: BasePart, text: string, width: number\): TextLabel\n.*?\nend\n',
    SURFACE_LABEL_WORLD,
    "BoundaryBuilder.makeLabel",
)
text = replace_once(
    text,
    'makeLabel(shop, "TINY BOAT DOCK\\n600 coins • Tidepool Cove", 320)',
    'makeSurfaceLabel(shop, "Boat Dock")',
    "Boat Dock sign",
)
text = replace_once(
    text,
    'makeLabel(board, "BOUNDARY EXPLORER\\nVisit woods, cliffs, and sea", 300)',
    'makeSurfaceLabel(board, "Boundary Explorer")',
    "Boundary Explorer board",
)
text = re.sub(r'^\s*makeLabel\([^\n]*\)\n', '', text, flags=re.M)
if "makeLabel(" in text or 'Instance.new("BillboardGui")' in text:
    raise RuntimeError("BoundaryBuilder still contains floating label code")
write(path, text)

# LivingWorldBuilder: physical objects + local prompts are enough; remove floating labels entirely.
path = "src/server/LivingWorldBuilder.luau"
text = read(path)
text = re.sub(
    r'\nlocal function makeLabel\(parent: BasePart, text: string, width: number\?\): TextLabel\n.*?\nend\n',
    '\n',
    text,
    count=1,
    flags=re.S | re.M,
)
text = re.sub(r'^\s*makeLabel\([^\n]*\)\n', '', text, flags=re.M)
if "makeLabel(" in text or 'Instance.new("BillboardGui")' in text:
    raise RuntimeError("LivingWorldBuilder still contains floating label code")
write(path, text)

# HomePrefabBuilder: keep the proper house name on its physical sign; remove floating charm label.
path = "src/server/HomePrefabBuilder.luau"
text = read(path)
text = regex_once(
    text,
    r'local function makeLabel\(parent: BasePart, text: string\)\n.*?\nend\n',
    SURFACE_LABEL_AUTHORED,
    "HomePrefabBuilder.makeLabel",
)
text = replace_once(
    text,
    'makeLabel(namePost, if house then house.name else "TinyWorld Home")',
    'makeSurfaceLabel(namePost, if house then house.name else "TinyWorld Home")',
    "home proper-name sign",
)
text = re.sub(r'^\s*makeLabel\([^\n]*\)\n', '', text, flags=re.M)
if "makeLabel(" in text or 'Instance.new("BillboardGui")' in text:
    raise RuntimeError("HomePrefabBuilder still contains floating label code")
write(path, text)

# WorldBuilder: dynamic text survives only where it belongs on a physical surface.
path = "src/server/WorldBuilder.luau"
text = read(path)
text = regex_once(
    text,
    r'local function makeLabel\(parent: BasePart, text: string, width: number\?, maxDistance: number\?\): TextLabel\n.*?\nend\n',
    SURFACE_LABEL_WORLD,
    "WorldBuilder.makeLabel",
)
text = text.replace('makeLabel(sign, "Available Plot", 180, 55)', 'makeSurfaceLabel(sign, "Available")')
text = text.replace(
    'makeLabel(sign, "VILLAGE MEETUP\\nJoin a Village Walk\\nVisit homes and trade safely together", 320, 32)',
    'makeSurfaceLabel(sign, "Village Walk")',
)
text = text.replace('makeLabel(tableTop, "THE GIANT KITCHEN\\nCollect all 3 Sugar Crystals", 380)', 'makeSurfaceLabel(tableTop, "Giant Kitchen")')
text = text.replace('makeLabel(sign, "MOONLIT MEADOW\\nFind 3 Moonlit Seeds", 340)', 'makeSurfaceLabel(sign, "Moonlit Meadow")')
text = replace_once(
    text,
    'local itemChestLabel = makeLabel(itemChest, "ITEM CHEST\\nYour collected things", 190, 55)\n',
    '',
    "remove item chest billboard",
)
text = replace_once(
    text,
    '\tlocal fundLabel = makeLabel(contributionAnchor, "Village Fund: 0 coins", 250)\n\tmakeLabel(noticeboard, "PROFESSION BOARD\\nCourier • Farmer • Designer", 330)\n\tlocal professionPrompt = makePrompt(noticeboard, "View Professions", "Profession Board")',
    '\tmakeSurfaceLabel(noticeboard, "Village Jobs")\n\tlocal professionPrompt = makePrompt(noticeboard, "Choose a Job", "Village Jobs")',
    "fund/jobs board cleanup",
)
text = replace_once(
    text,
    '\tlocal homeSupplyLabel = makeLabel(supplyAnchor, "HOME SUPPLY\\nFurniture and essentials", 340)\n\tlocal homeSupplyPrompt = makePrompt(supplyAnchor, "Buy Next Essential", "Home Supply")\n\tlocal homeStyleLabel = makeLabel(styleAnchor, "HOME STYLE\\nMeadow • Harbor • Sunset", 340)\n\tlocal homeStylePrompt = makePrompt(styleAnchor, "Change Home Style", "Home Style")\n\tlocal homeDecorLabel = makeLabel(galleryAnchor, "HOME GALLERY\\nSix authored pieces", 340)\n\tlocal homeDecorPrompt = makePrompt(galleryAnchor, "Collect Next Decor", "Home Gallery")',
    '\tlocal homeSupplyPrompt = makePrompt(supplyAnchor, "Buy Next Essential", "Home Store")\n\tlocal homeStylePrompt = makePrompt(styleAnchor, "Change Home Style", "Home Store")\n\tlocal homeDecorPrompt = makePrompt(galleryAnchor, "Browse Home Decor", "Home Store")',
    "Home Store billboard cleanup",
)
for line in (
    '\t\titemChestLabel = itemChestLabel,\n',
    '\t\tfundLabel = fundLabel,\n',
    '\t\thomeSupplyLabel = homeSupplyLabel,\n',
    '\t\thomeStyleLabel = homeStyleLabel,\n',
    '\t\thomeDecorLabel = homeDecorLabel,\n',
):
    text = text.replace(line, '')
if "makeLabel(" in text or 'Instance.new("BillboardGui")' in text:
    raise RuntimeError("WorldBuilder still contains generic floating label code")
write(path, text)

# PhysicalItemService: objects and chest prompt carry the information locally.
path = "src/server/PhysicalItemService.luau"
text = read(path)
text = re.sub(r'\nlocal function makeLabel\(parent: BasePart, text: string\)\n.*?\nend\n', '\n', text, count=1, flags=re.S | re.M)
text = re.sub(r'^\s*makeLabel\([^\n]*\)\n', '', text, flags=re.M)
text = replace_once(
    text,
    '\tplot.itemChestLabel.Text = "ITEM CHEST\\n"\n\t\t.. (if visible == 0 then "Nothing collected" else string.format("%d kinds on display", visible))',
    '\tplot.itemChestPrompt.ObjectText = if visible == 0 then "Item Chest • Empty" else string.format("Item Chest • %d kinds", visible)',
    "item chest contextual count",
)
if "makeLabel(" in text or 'Instance.new("BillboardGui")' in text or "itemChestLabel" in text:
    raise RuntimeError("PhysicalItemService still depends on item billboards")
write(path, text)

# GardenService: the bed prompt already says when a carrot can be harvested.
path = "src/server/GardenService.luau"
text = read(path)
text = re.sub(
    r'\n\t\tlocal gui = Instance.new\("BillboardGui"\).*?\n\t\tlabel.Parent = gui',
    '',
    text,
    count=1,
    flags=re.S,
)
if 'Instance.new("BillboardGui")' in text or "CARROT READY" in text:
    raise RuntimeError("GardenService still contains ready-crop billboard")
write(path, text)

# VillageService: expose the total only when the player is near the civic prompt.
path = "src/server/VillageService.luau"
text = read(path)
text = replace_once(
    text,
    '\tworld.contributionPrompt.Triggered:Connect(function(player)\n\t\tself:_contribute(player)\n\tend)\n',
    '\tworld.contributionPrompt.ObjectText = "Community Pot • 0 coins"\n\tworld.contributionPrompt.Triggered:Connect(function(player)\n\t\tself:_contribute(player)\n\tend)\n',
    "VillageService initial prompt",
)
text = replace_once(
    text,
    '\tself.fund += 50\n\tself.world.fundLabel.Text = string.format("Village Fund: %d coins\\nFuture public works live here", self.fund)',
    '\tself.fund += 50\n\tself.world.contributionPrompt.ObjectText = string.format("Community Pot • %d coins", self.fund)',
    "VillageService contextual total",
)
write(path, text)

# HomeService: delete the permanent store/status text wall; prompts stay contextual.
path = "src/server/HomeService.luau"
text = read(path)
text = regex_once(
    text,
    r'function HomeService:_updateSupplyLabel\(\)\n.*?\nend\n',
    '''function HomeService:_updateSupplyLabel()
\tself.world.homeSupplyPrompt.ActionText = "Buy Next Essential"
\tself.world.homeSupplyPrompt.ObjectText = "Home Store"
\tself.world.homeStylePrompt.ActionText = "Change Home Style"
\tself.world.homeStylePrompt.ObjectText = "Home Store"
\tself.world.homeDecorPrompt.ActionText = "Browse Home Decor"
\tself.world.homeDecorPrompt.ObjectText = "Home Store"
end
''',
    "HomeService._updateSupplyLabel",
)
text = text.replace("Buy this home item at the Home Supply counter first.", "Buy this home item at the Home Store first.")
write(path, text)

# Remaining prototype terms are removed from active runtime copy.
for source in (ROOT / "src/server").rglob("*.luau"):
    text = source.read_text(encoding="utf-8")
    replacements = {
        "HOME GATE": "FRONT GATE",
        "HOME STYLE": "HOME LOOKS",
        "HOME SUPPLY": "HOME STORE",
        "DAILY FOUNTAIN": "VILLAGE FOUNTAIN",
        "VILLAGE FUND": "COMMUNITY POT",
        "PROFESSION BOARD": "VILLAGE JOBS",
        "Home Supply": "Home Store",
        "Village Fund": "Community Pot",
        "Profession Board": "Village Jobs",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    source.write_text(text, encoding="utf-8")

# Final source invariants for this checkpoint.
for source in (ROOT / "src/server").rglob("*.luau"):
    text = source.read_text(encoding="utf-8")
    if source.name in {
        "AuthoredPrefabBuilder.luau",
        "BoundaryBuilder.luau",
        "LivingWorldBuilder.luau",
        "HomePrefabBuilder.luau",
        "WorldBuilder.luau",
    } and "AlwaysOnTop = true" in text:
        raise RuntimeError(f"ordinary world builder still has AlwaysOnTop=true: {source}")

print("visual rescue patch applied")
