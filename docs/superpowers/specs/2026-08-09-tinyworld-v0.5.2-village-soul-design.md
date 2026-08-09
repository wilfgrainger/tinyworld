# TinyWorld v0.5.2 — Village Soul & Presentation Reset

## Status

Approved for implementation on 9 August 2026. This release is a presentation and world-content reset on top of the existing server-authoritative v0.5.1 contracts. It does not add a new economy, monetisation gate, combat system, or persistence schema.

## Goal

Make TinyWorld read as a warm, recognisable Roblox life game during ordinary play: a child should understand the world when labels are hidden, the HUD should support the fantasy rather than expose database state, and the village should feel authored rather than generated.

## Product decisions

1. **The visual residency cap is 16 homes per village.** Roblox server capacity does not determine visible residential scale. Players beyond the residential cap remain visitors until a future multi-village membership design exists.
2. **Normal play is visually quiet.** The permanent 480px telemetry panel is removed. Coins, level, one current task, contextual Roblox prompts, and short-lived toasts remain visible. Inventory, careers, collections, home detail, social state, and diagnostics open intentionally.
3. **The visual invariant is stronger than physical existence.** A key player-facing object must be recognisable with its label disabled. A label supplements an object; it never substitutes for one.
4. **Gameplay authority is preserved.** Existing services continue to own coins, XP, inventory, plot ownership, privacy, trade, home progression, vehicles, portals, and saves. New presentation code only binds prompts, art anchors, and visible feedback to those services.
5. **Content is placed through a prefab boundary.** WorldBuilder and PlotService request named authored models from focused builders. The first implementation uses Roblox-native parts because the repository has no approved mesh asset bundle; each model is tagged with its art role and physical-affordance contract so a future asset replacement does not change gameplay wiring.
6. **0.5.2 has one hero home, not five shallow rebuilds.** The starter/Cosy home receives the strongest interior pass. Higher tiers retain their progression silhouettes and gain the same interaction-safe interior foundation without pretending to be the 1.0 catalogue.
7. **No cosmetic economy until desirability is evidenced.** The existing fair cosmetic gate remains deferred to v0.6.0.

## Experience design

### Compact HUD

The in-play layer contains:

- a coin chip with an icon and value;
- compact level text and a progress bar;
- one current activity/task chip;
- a small journal button;
- a toast with an icon, one sentence, and an automatic three-second expiry;
- Roblox ProximityPrompt interactions supplied by the world only when relevant.

The journal contains friendly sections for Today, Bag, Home, Careers, and Collection. It translates database language into player language: Moonlit Meadow / Find the missing moon seeds / ● ● ○, not Portals: 3 completion(s) | Mission finds 0/3.

If the client is running in Studio, a separate opt-in debug drawer may expose raw replicated attributes. The drawer is never present in a published experience and is not part of the normal visual hierarchy.

### Onboarding

Avatar style and starter outfit choices become visual cards. Boy/Girl and Meadow/Harbor/Sunset remain the server-validated values, but each choice shows a colour, silhouette, and short fantasy description. The player sees what Harbor means before selecting it.

### Village composition

The village centre contains the Town Hall, fountain, general shop, home shop, courier depot, transport workshop, market, and the first portal landmarks. Residential plots are grouped into four seeded neighbourhoods:

- Meadow Lane — four homes, gardens, stream, bridge, and meadow planting;
- Harbour Row — four homes, descending paths, dock views, boats, and fishing clutter;
- Woodland Rise — four homes, tree canopy, rocks, fireflies, and narrower paths;
- Orchard End — four homes, orchard trees, vegetable beds, and a nursery green.

The layout is deterministic and art-directed. Four to six authored variants are selected from a fixed seed for fences, trees, flower beds, lamps, benches, rocks, setbacks, and house rotations. No unseeded math.random() is used.

### World and objects

The village adds visible elevation cues, grass banks, stream channels, bridges, retaining walls, curved path segments, dead-end shortcuts, uneven boundaries, and landmarks that remain visible above rooftops. The stable ground and plot surfaces remain the collision foundation.

Each civic destination gets a distinct silhouette:

- Town Hall: clock/bell, steps, noticeboard, and civic landscaping;
- Courier Depot: loading awning, parcel shelving, handcart, and delivery counter;
- Village Shop/Home Store: shopfront windows, shelves, awning, and visible stock;
- Transport Workshop: open garage, bike stand, tools, and wheel signage;
- Market: one physical table with two visible offer trays rather than coloured trade pads.

Plot verbs attach to real objects:

| Existing affordance | v0.5.2 object |
| --- | --- |
| Upgrade Home | Architect's drawing board |
| Change Privacy | Front-door bell / gate sign |
| Visit Home | Actual gate/front door |
| Add Home Charm | Garden potting bench / flower arch |
| Home Supply | Homewares shop counter |
| Home Style | Decorator catalogue |
| Home Gallery | Furnishing showroom |
| Transport | Bike workshop |
| Available plot | Small estate/garden sign |

Neon interaction rings are removed from normal play. Prompts stay on queryable anchor parts.

### Hero home

The starter/Cosy home presents a small believable life:

- bedroom: bed, lamp, wardrobe, mirror, shelf;
- kitchen: counter, sink, fridge, cooker, table, chairs, simple food prop;
- living area: sofa, side table, rug, book/toy shelf;
- bathroom: sink, toilet, and shower/bath silhouette;
- storage: physical chest linked to the existing item chest contract;
- garden: beds, watering/planting, potting bench, and visible growth state.

Interactions remain bounded and safe. Existing owned home items keep their server rules; ambient home actions provide visible feedback and do not mint economy state. A successful interaction changes a light, opens a simple lid/door state, or gives a physical animation cue wherever practical.

### Vehicles and touched objects

Bike and boat models retain their existing ownership and travel services but receive recognizable silhouettes, safer names, visible seats/handles/controls, and lightweight visual motion hooks. Labels are not required to identify them. Parcels, crops, seeds, shells, furniture, trade trays, and shop stock receive named art roles, material treatment, readable scale, and prompt/pickup feedback.

### Ambient life

The seeded world adds bounded non-economic ambience: chimney smoke, warm windows, water highlights, foliage clusters, birds/butterflies, lantern glow, and subtle village sound hooks where the runtime supports them. Effects are capped by the visual budget and never become unbounded per-player emitters.

## Architecture

### Shared rules

WorldLayoutRules owns the 16-home cap, neighbourhood plot slots, deterministic art seed, landmark anchors, and visual budgets. It remains Roblox-service-free and is covered by pure tests.

### Presentation

Main.client.luau owns the compact HUD, journal, toast lifecycle, friendly copy, and Studio-only debug drawer. It observes replicated attributes but never mutates authoritative state.

### Art boundary

AuthoredPrefabBuilder.luau owns civic, market, plot-affordance, terrain dressing, and ambient model recipes. HomePrefabBuilder.luau owns the residential shell and hero-home visual anchors. World and services consume returned anchors/prompts rather than constructing semantic art inline.

### Compatibility

No profile migration is required. Existing v0.5.1 profiles, profile version 10, inventory, home state, transport ownership, boat state, privacy, route state, and all service contracts remain valid. Players.MaxPlayers may exceed 16, but layout creation always returns at most 16 residential slots.

## Error handling and safety

- Existing fail-closed profile loading remains unchanged.
- Existing server-side ownership checks remain authoritative.
- Any missing optional visual asset falls back to the repository's bounded native prefab, never to an arbitrary coloured interaction cube.
- Studio-only debug UI is gated by RunService:IsStudio().
- Toast rendering ignores stale message timers by using a nonce/token.
- Visual builders set decoration parts non-collidable, non-touching, and non-queryable; only explicit prompt anchors are queryable.

## Acceptance

The release is accepted only when:

1. Pure layout tests prove the cap is 16, neighbourhood metadata is deterministic, plots do not overlap, and budgets remain within limits.
2. Source guards prove the old permanent telemetry panel, generic amenity() path, plot interaction markers, and raw database copy are absent from normal UI.
3. Source guards prove the prefab boundary, named civic silhouettes, real plot affordances, hero-home rooms, ambient cap, recognizable vehicle markers, and Studio-only debug gate.
4. Luau tests, Luau analysis, server/client compilation, material safety, physical-affordance, home, traversal, and existing regression guards pass where the tools are available.
5. A fresh Studio screenshot shows the compact HUD, a non-symmetrical village centre, four neighbourhood identities, and at least one recognisable home/civic destination with labels disabled.
6. The one-player route verifies onboarding, home entry, bed/kitchen/wardrobe/desk plus ambient home interactions, garden growth, plot privacy, bike, boat, portal, trade setup, and persistence.
7. Two-client and published-place evidence is either captured or explicitly marked as a human gate; source and local tests are never represented as live Studio evidence.
