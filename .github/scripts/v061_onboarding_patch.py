from __future__ import annotations

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


path = "src/client/Onboarding.client.luau"
text = read(path)
text = replace_once(text, 'panel.BackgroundColor3 = colors.ink', 'panel.BackgroundColor3 = colors.paper', "onboarding panel")
text = replace_once(text, 'label.TextColor3 = colors.warmLight', 'label.TextColor3 = colors.ink', "onboarding default label")
text = replace_once(text, 'title.Text = "Make your TinyWorld character"', 'title.Text = "Welcome to TinyWorld"', "onboarding title")
text = replace_once(
    text,
    'subtitle.Text = "Pick a name, avatar style, and one free starter outfit. Visual cards preview the free look before you confirm."',
    'subtitle.Text = "Choose a name and two TinyWorld style preferences. Your Roblox avatar stays intact while our character art is upgraded."',
    "onboarding subtitle",
)
text = replace_once(text, 'nameBox.BackgroundColor3 = colors.inkSoft', 'nameBox.BackgroundColor3 = colors.warmLight', "name box surface")
text = replace_once(text, 'nameBox.TextColor3 = colors.paper', 'nameBox.TextColor3 = colors.ink', "name box text")
text = replace_once(text, 'avatarLabel.Text = "Choose your avatar style"', 'avatarLabel.Text = "Choose a TinyWorld profile style"', "avatar label")
text = replace_once(text, 'card.BackgroundColor3 = colors.inkSoft', 'card.BackgroundColor3 = colors.warmLight', "avatar card surface")
text = replace_once(text, 'cardTitle.TextColor3 = colors.warmLight', 'cardTitle.TextColor3 = colors.ink', "avatar card title")
text = replace_once(text, 'outfitLabel.Text = "Pick a free starter outfit"', 'outfitLabel.Text = "Pick a TinyWorld colour mood"', "outfit label")
# Second card/title pair belongs to outfit cards.
text = replace_once(text, 'card.BackgroundColor3 = colors.inkSoft', 'card.BackgroundColor3 = colors.warmLight', "outfit card surface")
text = replace_once(text, 'cardTitle.TextColor3 = colors.warmLight', 'cardTitle.TextColor3 = colors.ink', "outfit card title")
text = replace_once(text, 'status.TextColor3 = colors.warmLight', 'status.TextColor3 = colors.inkSoft', "onboarding status color")
text = replace_once(
    text,
    'status.Text = "Pick a style and outfit to continue."',
    'status.Text = "Pick the preferences you like. Your Roblox avatar will stay intact."',
    "onboarding status",
)
text = replace_once(text, 'beginButton.BackgroundColor3 = colors.inkSoft', 'beginButton.BackgroundColor3 = colors.warmLight', "begin button surface")
text = replace_once(text, 'beginButton.TextColor3 = colors.metal', 'beginButton.TextColor3 = colors.inkSoft', "begin button disabled text")
text = replace_once(
    text,
    'card.BackgroundColor3 = if chosen then colors.skyDeep else colors.inkSoft',
    'card.BackgroundColor3 = if chosen then colors.sky else colors.warmLight',
    "avatar choice visual",
)
text = replace_once(
    text,
    'card.BackgroundColor3 = if chosen then colors.meadowDeep else colors.inkSoft',
    'card.BackgroundColor3 = if chosen then colors.meadow else colors.warmLight',
    "outfit choice visual",
)
text = replace_once(
    text,
    'status.Text = "Choose a valid name, style, and outfit."',
    'status.Text = "Choose a valid name and TinyWorld preferences."',
    "onboarding validation copy",
)
write(path, text)

path = "src/server/OnboardingService.luau"
text = read(path)
text = text.replace("Please choose a name, style, and outfit.", "Please choose a name and TinyWorld preferences.")
text = text.replace("Choose Boy or Girl to continue.", "Choose a TinyWorld profile style to continue.")
text = text.replace("Choose one of the three free outfits to continue.", "Choose one of the three TinyWorld colour moods to continue.")
write(path, text)

print("v0.6.1 onboarding visual rescue patch applied")
