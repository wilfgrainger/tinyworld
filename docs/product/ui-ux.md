# UI and UX

## Normal play

The permanent telemetry dashboard is replaced by a quiet in-play layer:

- `CoinChip`: icon and current coin value;
- `LevelChip`: compact level text and progress bar;
- `QuestChip`: one current activity in friendly language;
- `JournalButton`: intentional access to deeper information;
- `Toast`: icon and one sentence, dismissed automatically after three seconds;
- contextual Roblox `ProximityPrompt` interactions supplied by the world.

The hidden `JournalPanel` contains Today, Bag, Home, Careers, and Collection sections. Copy translates replicated state into player language and avoids exposing raw field names or database-style status lines.

## Feedback and authority

The client observes replicated attributes and never mutates coins, XP, inventory, ownership, or completion state. Toast timers use a message nonce so an older timer cannot hide a newer message. UI confirms an authoritative result only after replicated server state or a server message reflects it.

## Debugging

Raw attributes may appear only in a separate opt-in drawer guarded by `RunService:IsStudio()`. The debug control is absent from published experiences and is not part of the normal visual hierarchy.

## Onboarding and access

Existing Boy/Girl and Meadow/Harbor/Sunset values remain server-validated. The client presents them as visual cards with silhouette, colour, description, selected state, and mobile-sized touch targets. Friendly labels do not change the payload contract.
