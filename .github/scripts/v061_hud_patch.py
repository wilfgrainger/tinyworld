from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding="utf-8")


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


# Main HUD: compact fixed-width status cluster + shared navigation registration.
path = "src/client/Main.client.luau"
text = read(path)
text = replace_once(
    text,
    'local ModalController = require(script.Parent:WaitForChild("ModalController"))\nlocal modalController = ModalController.new()',
    'local ModalController = require(script.Parent:WaitForChild("ModalController"))\nlocal GameNav = require(script.Parent:WaitForChild("GameNav"))\nlocal modalController = ModalController.new()',
    "Main GameNav require",
)
text = replace_once(text, 'label.TextColor3 = colors.paper', 'label.TextColor3 = colors.ink', "Main default label color")

hud_block = '''local function makeChip(name: string, position: UDim2, size: UDim2): Frame
\tlocal chip = Instance.new("Frame")
\tchip.Name = name
\tchip.Position = position
\tchip.Size = size
\tchip.BackgroundColor3 = colors.paper
\tchip.BackgroundTransparency = 0.05
\tchip.BorderSizePixel = 0
\tchip.Parent = statusCluster
\taddCorner(chip, 11)
\taddStroke(chip, colors.inkSoft, 0.78)
\treturn chip
end

local statusCluster = Instance.new("Frame")
statusCluster.Name = "StatusCluster"
statusCluster.Position = UDim2.fromOffset(12, 12)
statusCluster.Size = UDim2.fromOffset(252, 104)
statusCluster.BackgroundTransparency = 1
statusCluster.Parent = gui

local coinChip = makeChip("CoinChip", UDim2.fromOffset(0, 0), UDim2.fromOffset(96, 40))
local coinIcon = makeLabel(coinChip, "Icon", 18, true)
coinIcon.Position = UDim2.fromOffset(10, 0)
coinIcon.Size = UDim2.fromOffset(20, 40)
coinIcon.Text = "●"
coinIcon.TextColor3 = colors.gold
coinIcon.TextXAlignment = Enum.TextXAlignment.Center
local coinValue = makeLabel(coinChip, "Value", 16, true)
coinValue.Position = UDim2.fromOffset(34, 0)
coinValue.Size = UDim2.new(1, -42, 1, 0)
coinValue.TextColor3 = colors.ink

local levelChip = makeChip("LevelChip", UDim2.fromOffset(102, 0), UDim2.fromOffset(150, 40))
local levelText = makeLabel(levelChip, "Level", 12, true)
levelText.Position = UDim2.fromOffset(10, 0)
levelText.Size = UDim2.new(1, -20, 0, 25)
local levelTrack = Instance.new("Frame")
levelTrack.Name = "ProgressTrack"
levelTrack.Position = UDim2.fromOffset(10, 28)
levelTrack.Size = UDim2.new(1, -20, 0, 5)
levelTrack.BackgroundColor3 = colors.warmLight
levelTrack.BorderSizePixel = 0
levelTrack.Parent = levelChip
addCorner(levelTrack, 3)
local levelProgress = Instance.new("Frame")
levelProgress.Name = "Progress"
levelProgress.Size = UDim2.fromScale(0, 1)
levelProgress.BackgroundColor3 = colors.gold
levelProgress.BorderSizePixel = 0
levelProgress.Parent = levelTrack
addCorner(levelProgress, 3)

local questChip = makeChip("QuestChip", UDim2.fromOffset(0, 46), UDim2.fromOffset(252, 56))
local questIcon = makeLabel(questChip, "Icon", 18, true)
questIcon.Position = UDim2.fromOffset(10, 0)
questIcon.Size = UDim2.fromOffset(24, 56)
questIcon.Text = "✦"
questIcon.TextColor3 = colors.gold
questIcon.TextXAlignment = Enum.TextXAlignment.Center
local questTitle = makeLabel(questChip, "Title", 13, true)
questTitle.Position = UDim2.fromOffset(42, 4)
questTitle.Size = UDim2.new(1, -50, 0, 23)
questTitle.TextColor3 = colors.ink
local questDetail = makeLabel(questChip, "Detail", 11, false)
questDetail.Position = UDim2.fromOffset(42, 25)
questDetail.Size = UDim2.new(1, -50, 0, 26)
questDetail.TextColor3 = colors.inkSoft
'''

text = regex_once(
    text,
    r'local function makeChip\(name: string, position: UDim2, size: UDim2\): Frame\n.*?addStroke\(journalButton, colors\.gold, 0\.55\)\n',
    # statusCluster must exist before makeChip refers to it; reorder after replacement below
    hud_block,
    "Main old HUD block",
)
# Correct order: statusCluster must be declared before makeChip. Swap local function block with cluster declaration.
cluster_decl = '''local statusCluster = Instance.new("Frame")
statusCluster.Name = "StatusCluster"
statusCluster.Position = UDim2.fromOffset(12, 12)
statusCluster.Size = UDim2.fromOffset(252, 104)
statusCluster.BackgroundTransparency = 1
statusCluster.Parent = gui

'''
function_block = '''local function makeChip(name: string, position: UDim2, size: UDim2): Frame
\tlocal chip = Instance.new("Frame")
\tchip.Name = name
\tchip.Position = position
\tchip.Size = size
\tchip.BackgroundColor3 = colors.paper
\tchip.BackgroundTransparency = 0.05
\tchip.BorderSizePixel = 0
\tchip.Parent = statusCluster
\taddCorner(chip, 11)
\taddStroke(chip, colors.inkSoft, 0.78)
\treturn chip
end

'''
text = replace_once(text, function_block + cluster_decl, cluster_decl + function_block, "Main status cluster declaration order")

text = replace_once(text, 'journalPanel.BackgroundColor3 = colors.ink', 'journalPanel.BackgroundColor3 = colors.paper', "journal panel surface")
text = replace_once(text, 'journalHeading.TextColor3 = colors.warmLight', 'journalHeading.TextColor3 = colors.ink', "journal heading color")
text = replace_once(text, 'journalClose.BackgroundColor3 = colors.inkSoft', 'journalClose.BackgroundColor3 = colors.warmLight', "journal close surface")
text = replace_once(text, 'journalClose.TextColor3 = colors.paper', 'journalClose.TextColor3 = colors.ink', "journal close text")
text = replace_once(text, 'content.BackgroundColor3 = colors.inkSoft', 'content.BackgroundColor3 = colors.warmLight', "journal content surface")
text = replace_once(text, 'content.BackgroundTransparency = 0.28', 'content.BackgroundTransparency = 0.16', "journal content transparency")
text = replace_once(text, 'button.BackgroundColor3 = colors.inkSoft', 'button.BackgroundColor3 = colors.warmLight', "journal tab surface")
text = replace_once(text, 'button.TextColor3 = colors.paper', 'button.TextColor3 = colors.ink', "journal tab text")
text = replace_once(
    text,
    'entry.button.BackgroundColor3 = if selected then colors.gold else colors.inkSoft\n\t\tentry.button.TextColor3 = if selected then colors.ink else colors.paper',
    'entry.button.BackgroundColor3 = if selected then colors.gold else colors.warmLight\n\t\tentry.button.TextColor3 = colors.ink',
    "journal selected tab colors",
)

text = replace_once(
    text,
    '''journalButton.Activated:Connect(function()
\tif journalPanel.Visible then
\t\tmodalController:close(journalPanel)
\telse
\t\tmodalController:open(journalPanel, journalClose)
\tend
end)
journalClose.Activated:Connect(function()
\tmodalController:close(journalPanel)
end)''',
    '''GameNav.register("Journal", "Journal", 1, function()
\tif journalPanel.Visible then
\t\tmodalController:close(journalPanel)
\telse
\t\tmodalController:open(journalPanel, journalClose)
\tend
end)
journalClose.Activated:Connect(function()
\tmodalController:close(journalPanel)
end)''',
    "Main Journal GameNav registration",
)

if "journalButton" in text:
    raise RuntimeError("Main still contains legacy journalButton")
if "UDim2.new(1, -208, 0, 44)" in text:
    raise RuntimeError("Main still contains full-width level bar")
if 'Name = "StatusCluster"' not in text or 'GameNav.register("Journal"' not in text:
    raise RuntimeError("Main compact HUD/nav registration missing")
write(path, text)

# Appearance: remove standalone Style button and register with shared GameNav.
path = "src/client/Appearance.client.luau"
text = read(path)
text = replace_once(
    text,
    'local ModalController = require(script.Parent:WaitForChild("ModalController"))',
    'local ModalController = require(script.Parent:WaitForChild("ModalController"))\nlocal GameNav = require(script.Parent:WaitForChild("GameNav"))',
    "Appearance GameNav require",
)
text = regex_once(
    text,
    r'\nlocal wardrobeButton = Instance\.new\("TextButton"\).*?buttonCorner\.Parent = wardrobeButton\n',
    '\n',
    "Appearance legacy wardrobe button",
)
text = replace_once(
    text,
    'wardrobeButton.Activated:Connect(openWardrobe)\n',
    'GameNav.register("Style", "Style", 3, openWardrobe)\n',
    "Appearance GameNav registration",
)
if "wardrobeButton" in text:
    raise RuntimeError("Appearance still contains legacy wardrobeButton")
write(path, text)

# Furniture/Home: remove standalone Home button and use shared GameNav; hide whole nav in placement mode.
path = "src/client/FurniturePlacement.client.luau"
text = read(path)
text = replace_once(
    text,
    'local FocusController = require(script.Parent:WaitForChild("FocusController"))',
    'local FocusController = require(script.Parent:WaitForChild("FocusController"))\nlocal GameNav = require(script.Parent:WaitForChild("GameNav"))',
    "Furniture GameNav require",
)
text = regex_once(
    text,
    r'\nlocal homeButton = Instance\.new\("TextButton"\).*?homeCorner\.Parent = homeButton\n',
    '\n',
    "Furniture legacy home button",
)
text = replace_once(text, '\thomeButton.Visible = false', '\tGameNav.setVisible(false)', "hide nav during placement")
text = replace_once(text, '\thomeButton.Visible = true', '\tGameNav.setVisible(true)', "restore nav after placement")
text = replace_once(
    text,
    'homeButton.Activated:Connect(openHome)',
    'GameNav.register("Home", "Home", 2, openHome)',
    "Furniture GameNav registration",
)
if "homeButton" in text:
    raise RuntimeError("Furniture still contains legacy homeButton")
write(path, text)

print("v0.6.1 HUD patch applied")
