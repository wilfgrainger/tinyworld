# Architecture

## Authority boundaries

TinyWorld remains server-authoritative. Server services own profile loading/migration, coins, XP, inventory, furniture ownership/placement, plot ownership, privacy, trades, appearance preference persistence, vehicles, portals, activity rewards, analytics emission and saves. Client code observes replicated state, renders local previews and submits bounded intents; it does not validate or mint authoritative outcomes.

Git is authoritative for source and the `default.project.json` Rojo assembly boundary. Roblox remains authoritative for published places, DataStores, permissions, platform assets and live runtime state. Studio supports visual authoring/playtesting but is not an undocumented release master.

v0.6.1 changes presentation, not these authority boundaries.

## Layers

| Layer | Responsibility | Must not own |
| --- | --- | --- |
| `src/shared` | Deterministic rules, content definitions, schemas, migrations and validators | Roblox runtime services or mutable global authority |
| `src/server` services | Validation, state transitions, persistence, security, analytics and orchestration | Client-trusted authority |
| `src/server/security` | Server-only remote adapters/rate state | Replicated secrets or client authority |
| `src/server` builders | Named models, art roles, physical affordances and prompt anchors | Rewards, prices, ownership or persistence decisions |
| `src/client` | HUD/journal/modal/catalogue/wardrobe/placement preview/input intent | Economy, progression, ownership or final placement mutation |

## Presentation boundary

v0.6.1 makes the visual responsibility explicit:

- server builders own physical world composition and semantic interaction anchors;
- clients own screen-space presentation and local previews;
- services continue to own authoritative game state;
- text/UI may explain detail but may not substitute for an unclear physical object;
- large always-on-top ordinary-world information panels are not a supported builder primitive;
- the player's normal Roblox avatar is the safe visual baseline when an approved TinyWorld character asset does not exist.

Deleting a low-quality fallback is allowed when preserving Roblox-native presentation is visibly better and no gameplay contract depends on the fallback geometry.

## Scalable content boundary

v0.6.0 introduced shared definition modules for items, furniture, activities, worlds, shops and appearance. v0.6.1 keeps that model unchanged. Definitions contain stable IDs/static metadata. Profiles store player-owned/preference state rather than duplicating display names/prices/art metadata.

Server services resolve client IDs through those definitions before any mutation. Prices/rewards/unlocks are never accepted from RemoteEvent payloads.

Appearance definitions may preserve future-facing style preferences even when v0.6.1 deliberately does not render a low-quality primitive hair/shoe fallback.

## Profile/persistence boundary

Profile schema **v11** remains the active compatibility bridge.

`ProfileMigrations` runs before `ProfileSchema.normalize()`. Unsupported future versions fail closed. v11 adds generic stacks, unique instances, furniture ownership/placements, saved outfits and discovery/keepsakes while retaining the legacy five-resource inventory and four original home-item fields until all existing consumers migrate.

ProfileStore retains:

- `UpdateAsync` writes;
- leased session ownership/heartbeat;
- retry/dirty-state handling;
- `BindToClose` shutdown;
- refusal to overwrite lease-conflicted, unreadable or future-version data.

DEV and LIVE use separate DataStore namespaces through `EnvironmentConfig`.

## Remote/security boundary

`RemoteGuardRules` contains pure type/range/string/allow-list/rate-window logic. Server-only `RemoteGuard` owns per-player action windows, context/distance helpers and sanitized rejection warnings.

New mutating remotes follow the sequence documented in `runtime-contracts.md` and `remote-security.md`.

## Home architecture

`HomeService` preserves the original home-life slice. `HomeStoreService` owns server-priced scalable furniture acquisition. `FurniturePlacementService` owns canonical home-local transforms and physical replication. `FurniturePrefabBuilder` owns replaceable fallback visuals/interaction anchors.

Furniture-only mutations add/move/remove one placed model. Shell/theme/tier rebuilds may rebuild the house, after which persisted placements are re-rendered. Visitors observe the same server-replicated models and are read-only unless an interaction is explicitly guest-safe.

Visual rescue may improve or replace builder output without changing those service-facing anchors or moving price/ownership authority into art code.

## Trade architecture

Low-value stack trading remains compatible. `TradeTransactionRules` provides immutable offer snapshots/idempotent states and `TradeJournal` records transaction state before mutation. Unique/high-value trading remains disabled until recovery/multiplayer evidence exists.

Trade state may be rendered on a physical board or contextual UI, but presentation does not own transaction state.

## World/content architecture

`WorldBuilder` remains the deterministic village baseline. Independent builders may extend the world behind semantic contracts rather than growing one monolith. `ImpossibleWorldBuilder` owns the additional world construction path and `AmbientLifeService` owns a small deterministic ambience layer.

Production assets may replace native prefabs only behind the same semantic builder/art-role/anchor/performance contract and with manifest provenance.

A native fallback is acceptable only when the resulting player-facing object itself meets its quality tier. Hero objects have a stricter craft requirement than background scenery. Semantic metadata cannot make anonymous geometry release-ready.

## UI architecture

TinyWorld keeps native Luau UI components instead of adopting a framework without measured need. `UiTokens`, `UiScaleRules`, `ButtonFactory`, `PanelFactory`, `ModalController` and `FocusController` centralize touch/controller/responsive behaviour.

v0.6.1 keeps those boundaries and reduces the normal-play presentation surface:

- compact status cluster;
- one coherent compact game-navigation surface;
- one modal owner;
- warm/light ordinary panels by default;
- contextual prompts rather than permanent system dashboards.

Placement preview runs locally every frame. Only confirmed placement/move/store intents cross the network.

## Runtime evidence

Source analysis can verify boundaries and deterministic rules. It cannot prove visual recognisability, FPS/memory/network quality, controller/touch ergonomics, multi-client correctness or published-place behaviour.

For v0.6.1 player-facing visual work, the relevant Studio/device rows may remain NOT RUN while the PR is draft but block merge-ready status until observed against the exact candidate.