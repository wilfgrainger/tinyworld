# TinyWorld v0.0.4 Living-World Expansion Design

Date: 2026-08-08  
Status: Approved for implementation  
Parent scope: `docs/superpowers/specs/2026-08-08-tinyworld-v0.0.4-mvp-design.md`

## Intent

The original v0.0.4 MVP scope remains intact: a playable, multiplayer-testable village with stable plot surfaces, capacity-aware streets, civic landmarks, woods/cliffs/sea boundaries, readable plots, and a child-friendly daily-life loop.

This amendment adds the missing lived-in layer. TinyWorld should feel colourful, varied, and imaginative without becoming a combat or high-fantasy game. The target is a balanced MVP: a small number of real interactions surrounded by much richer, grounded world dressing.

The current “Tiny Bike” is explicitly corrected. It is currently only a `WalkSpeed` toggle; v0.0.4 will make it a visible, rideable mount.

## Product contract

### 1. Rideable Tiny Bike

- The existing 300-coin ownership contract remains unchanged.
- An owned player receives a visible bicycle model at the transport stand and, when assigned, at their plot.
- `Mount Bike` seats the player on the bicycle and enables the faster movement speed.
- `Dismount Bike` returns the player to normal movement and leaves the bicycle parked near the player’s plot or stand.
- The bike is server-authoritative. A player can only mount their own bike; another player cannot buy, mount, or mutate it.
- Ownership persists. The mounted state is session state and is reset to dismounted on join or respawn.
- The first model is deliberately reliable rather than physics-heavy: frame, two wheels, seat, handlebars, pedals, and a colour accent. No wheel simulation, acceleration model, or new currency is required for this slice.
- The HUD must say `Tiny Bike MOUNTED`, `Tiny Bike PARKED`, or `Tiny Bike not owned`; it must not call a speed-only state “active”.

### 2. Meaningful small item set

Add three grounded, persistent items to the existing inventory contract:

| Item | Source | v0.0.4 use |
| --- | --- | --- |
| `MeadowSeed` | village nursery / meadow pickup | contributes to the first home garden charm |
| `Seashell` | Sea Dock pickup | contributes to the first home garden charm |
| `WoodToken` | Woodland Clearing pickup | contributes to the first home garden charm |

- Each pickup is server-validated and can be collected once per player per daily route, using a day key and a three-bit collection mask. This prevents infinite farming and prevents one player from consuming a global pickup for everyone else.
- Items are persisted through the existing profile schema and shown in the HUD as a compact `Life kit` line.
- Collecting one of each unlocks a single `Add Home Charm` interaction. The charm consumes the three items once and persists as a home decoration flag.
- No new currency, monetisation, weapon, combat, or pay-to-win system is introduced.

### 3. Plants and garden life

- Existing Carrot planting, watering, growth, harvesting, XP, and persistence remain unchanged.
- Add visible decorative plant language around the village and plots: seedling clusters, flower patches, planters, window boxes, and mature garden groupings. These are generated as stable, non-colliding decorations with explicit vertical separation from ground and borders.
- The home charm adds a small planter and flower cluster to the owner’s plot. This gives the new item loop a visible result without destabilising the existing three-bed carrot loop.
- The village nursery provides a clear visual explanation for MeadowSeed, while the garden remains understandable to a child who has not collected the new items.

### 4. Cabins and richer homes

- Add a small cluster of non-player cabins at the village edge, placed inside the existing layout budget and outside player plot ownership.
- Each cabin is built from a bounded reusable kit: floor, walls, roof, window panes, window boxes, porch, door, chimney, lantern, fence, and a small planting patch.
- Existing player house tiers remain the authoritative progression. Rebuilds gain more readable visual differentiation:
  - Tier 1: Starter Nook with window, porch, flower box, and lamp.
  - Tier 2: Cosy Cottage with cabin trim, chimney, and richer garden edge.
  - Tier 3+: larger upper feature, additional windows, and a stronger roof/porch silhouette.
  - Home charm: planter, flower cluster, and a warm window/lantern accent.
- All added house and cabin decorations are anchored and non-collidable unless intentionally part of a floor, porch, or step. No decorations share a rendering plane with ground, plot borders, or other overlays.

### 5. Village atmosphere

Add a dedicated, bounded living-world dressing builder rather than growing `WorldBuilder` indefinitely. It owns:

- the nursery and seed displays;
- the cabin cluster;
- parked bike stands and simple bike showcases;
- benches, crates, baskets, signposts, planter boxes, flower clusters, window accents, and small market objects;
- grounded playful colour accents such as painted trims, oversized flowers, warm lanterns, and friendly noticeboards.

The builder must derive placement from `WorldLayoutRules`, respect geometry budgets, and remain safe for the configured maximum player count. Decorative parts must be non-collidable, non-touching, and non-queryable. Rebuilding the world must destroy and recreate the owned model as one unit, so Studio syncs cannot leave stale overlays behind.

## Architecture

### Shared rules

- Extend `ProfileSchema` and `Inventory` with the three life-kit items, daily collection state, and a one-time home-charm flag. Existing profiles migrate by normalisation with safe empty defaults.
- Add a small pure `LivingWorldRules` module for supported item names, collection-mask operations, item-to-charm validation, and bounded plant/prop catalog data.
- Keep `TransportRules` responsible for purchase ownership and add pure mount-state transitions where useful; do not put Roblox instances or physics in shared rules.
- Keep `GardenRules` responsible for the existing carrot lifecycle. Decorative plants do not become a second untested crop economy in this slice.

### Server services and builders

- `TransportService` owns the bike lifecycle, mount/dismount authority, respawn reset, movement speed, HUD attributes, and cleanup.
- A focused server bike builder creates the model and seat parts with stable names and explicit offsets. It must not edit Studio manually or depend on a saved place asset.
- A focused `LivingWorldBuilder` creates cabins, nursery displays, pickups, planters, signs, and decorative object groups. It returns prompt references and model ownership to a focused service.
- `LivingWorldService` validates daily item collection and home-charm redemption, updates the profile, syncs player attributes, and saves successful state transitions.
- `PlotService` remains the owner of plot assignment, privacy, house upgrades, and house rebuilds. It receives the home-charm visual flag but does not own item collection.

### Data flow

1. `Main.server.luau` builds the original world and bounded living-world decorations once.
2. `ProfileStore` loads and normalises an existing or new profile.
3. `PlotService` assigns the plot and rebuilds the house from the profile tier/charm state.
4. `LivingWorldService` connects prompts and validates item/charm transitions on the server.
5. `TransportService` creates the owned bike, restores ownership as parked, and binds mount/dismount to the player’s current character.
6. `PlayerStateService.sync` exposes only display-safe attributes to the HUD.
7. On leave, services clean up bike models and connections before profile release.

## Reliability and safety

- Missing profiles fail closed: prompts do nothing and the player is not granted items, mounts, or upgrades.
- Every item, bike, and charm transition validates ownership, inventory, plot ownership where applicable, and current profile state on the server.
- Daily masks are idempotent. Re-triggering a pickup or reconnecting cannot duplicate an item.
- Dismount and respawn paths always restore normal movement speed and remove stale seat/model connections.
- Generated decorative surfaces use separated heights and a single owning model to avoid the grass/plot-border flicker class already fixed in v0.0.4.
- Counts are bounded from `WorldLayoutRules`; no per-player decorative duplication is allowed for static scenery.

## Verification contract

### Pure and static gates

- Existing Luau rule suite remains green, with new tests for inventory migration, daily item masks, charm redemption, and bike mount transitions.
- Luau analysis and server/client compilation pass.
- The Roblox material/geometry guard verifies the new builder, supported materials, explicit decoration flags, stable surface separation, and no malformed numeric loops.
- Rojo builds a fresh `.rbxlx` from `default.project.json`.
- `git diff --check` passes.

### Studio smoke route

1. Start from the published TinyWorld Dev place with the Rojo plugin connected.
2. Press Play and verify the v0.0.4 HUD, onboarding/persistence, clean Output, and stable grass/plot borders while moving.
3. Visit the transport stand, buy the Tiny Bike when eligible, mount it, move, dismount, and verify the HUD and visible model.
4. Rejoin and verify bike ownership persists while the player starts parked.
5. Collect the nursery, woodland, and sea items; verify each collection is credited once.
6. Redeem the Home Charm at the owned plot and verify the planter/flower/window/lantern result survives a rebuild.
7. Visit the cabin cluster, streets, market, gardens, woods, cliffs, and sea; verify the route reads visually and no decorations flicker during movement.
8. Run Studio Server & Clients with at least two clients. Verify each player owns only their own bike/plot state, item collection is per-player, and the existing trade/job/garden interactions remain available.

### Evidence boundaries

The v0.0.4 claim is a controlled Studio MVP slice, not a public-launch guarantee. A clean local build, a single-player session, a Studio multi-client run, a successful publish, and remote-device play are separate evidence states and must be recorded separately in the release log.

## Explicit non-goals

- full vehicle physics;
- open-world streaming or infinite procedural generation;
- combat, weapons, enemies, or a magic progression system;
- real-money monetisation implementation;
- replacing Roblox avatar clothing with a custom inventory system;
- manual Studio edits outside the Rojo-synced source tree.

