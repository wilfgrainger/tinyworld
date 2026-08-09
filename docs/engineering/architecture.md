# Architecture

## Authority boundaries

TinyWorld remains server-authoritative. Server services own profile loading/migration, coins, XP, inventory, furniture ownership/placement, plot ownership, privacy, trades, appearance persistence, vehicles, portals, activity rewards, analytics emission and saves. Client code observes replicated state, renders local previews and submits bounded intents; it does not validate or mint authoritative outcomes.

Git is authoritative for source and the `default.project.json` Rojo assembly boundary. Roblox remains authoritative for published places, DataStores, permissions, platform assets and live runtime state. Studio supports visual authoring/playtesting but is not an undocumented release master.

## Layers

| Layer | Responsibility | Must not own |
| --- | --- | --- |
| `src/shared` | Deterministic rules, content definitions, schemas, migrations and validators | Roblox runtime services or mutable global authority |
| `src/server` services | Validation, state transitions, persistence, security, analytics and orchestration | Client-trusted authority |
| `src/server/security` | Server-only remote adapters/rate state | Replicated secrets or client authority |
| `src/server` builders | Named models, art roles, physical affordances and prompt anchors | Rewards, prices, ownership or persistence decisions |
| `src/client` | HUD/journal/modal/catalogue/wardrobe/placement preview/input intent | Economy, progression, ownership or final placement mutation |

## Scalable content boundary

v0.6.0 introduces shared definition modules for items, furniture, activities, worlds, shops and appearance. Definitions contain stable IDs/static metadata. Profiles store player-owned state rather than duplicating display names/prices/art metadata.

Server services resolve client IDs through those definitions before any mutation. Prices/rewards/unlocks are never accepted from RemoteEvent payloads.

## Profile/persistence boundary

Profile schema **v11** is an explicit compatibility bridge.

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

## Trade architecture

Low-value stack trading remains compatible. `TradeTransactionRules` adds immutable offer snapshots/idempotent states and `TradeJournal` records transaction state before mutation. Unique/high-value trading remains disabled until recovery/multiplayer evidence exists.

## World/content architecture

`WorldBuilder` remains the deterministic village baseline. Independent builders may extend the world behind semantic contracts rather than growing one monolith; v0.6.0 uses `ImpossibleWorldBuilder` for two additional worlds and `AmbientLifeService` for a small deterministic ambience layer.

Production assets may replace native fallback prefabs only behind the same semantic builder/art-role/anchor/performance contract and with manifest provenance.

## UI architecture

TinyWorld keeps native Luau UI components instead of adopting a framework without measured need. `UiTokens`, `UiScaleRules`, `ButtonFactory`, `PanelFactory`, `ModalController` and `FocusController` centralize touch/controller/responsive behaviour.

Placement preview runs locally every frame. Only confirmed placement/move/store intents cross the network.

## Runtime evidence

Source analysis can verify boundaries and deterministic rules. It cannot prove visual recognisability, FPS/memory/network quality, controller/touch ergonomics, multi-client correctness or published-place behaviour. Those remain separate acceptance gates.