# Architecture

## Authority boundaries

TinyWorld remains server-authoritative. Server services own profile loading, coins, XP, inventory, plot ownership, privacy, trades, home progression, vehicles, portals, daily state, and saves. Client code observes replicated state and presents requests; it does not validate or mint authoritative outcomes.

## Layers

| Layer | Responsibility | Must not own |
| --- | --- | --- |
| `src/shared` | Deterministic Roblox-service-free rules and contracts | Runtime services or mutable global state |
| `src/server` services | Validation, state transitions, persistence, service orchestration | Client-trusted authority |
| `src/server` builders | Named models, art roles, physical affordances, prompt anchors | Rewards, ownership, or persistence decisions |
| `src/client` | Compact HUD, journal, onboarding, toasts, Studio debug view | Economy or progression mutation |

## v0.5.2 boundaries

`VisualQualityRules` owns release-wide visual constants and the recognizable-object contract. `WorldLayoutRules` owns the sixteen-slot deterministic layout and neighbourhood metadata. `AuthoredPrefabBuilder` owns civic, market, plot-affordance, terrain-dressing, and ambient recipes. `HomePrefabBuilder` owns residential shells and hero-home visual anchors.

World and plot construction consume named builder results. Existing services continue binding and handling the returned prompts. This preserves gameplay authority while allowing future approved art assets to replace native-part recipes.

## Compatibility and failure behavior

Profile version 10, existing inventory, house, transport, boat, privacy, route, profession, portal, trade, and save contracts remain valid. No profile migration is needed. Profile loading continues to fail closed; optional visual failures fall back to bounded native prefabs and never to arbitrary interaction cubes.
