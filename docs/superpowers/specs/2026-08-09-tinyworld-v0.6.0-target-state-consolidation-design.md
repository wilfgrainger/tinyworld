# TinyWorld v0.6.0 Target-State Consolidation Design

**Status:** Approved for implementation
**Date:** 9 August 2026
**Release:** v0.6.0 Target-State Consolidation
**Source authority:** `docs/product/target-state-v1.md`, derived from the reviewed TinyWorld Target-State Upgrade Blueprint
**Implementation methods:** Superpowers + `brockmartin/roblox-game-skill` in offline mode

## 1. Goal

v0.6.0 consolidates the complete actionable repository upgrade blueprint into one release and one pull request. It preserves TinyWorld's existing server-authoritative architecture and current playable village while adding the scalable content, persistence, security, home-life, UI, analytics, performance, asset, social-safety and release foundations required by the v1 target state.

The release must not fabricate evidence. Roblox credentials, real DEV/LIVE place IDs, Studio screenshots, published-device performance numbers, family playtest results and production asset IDs remain fail-closed evidence/configuration gates. Repository-side code, contracts, tooling and test routes required to collect that evidence are included.

## 2. Architectural decisions

1. Keep `src/shared` for deterministic Roblox-service-free rules and definitions.
2. Keep `src/server` authoritative for economy, persistence, placement, trade, rewards, permissions and anti-exploit checks.
3. Keep `src/client` presentation/input only.
4. Do not migrate to Knit or React/Roact merely for fashion.
5. Do not introduce Wally until an approved external dependency exists.
6. Keep the custom leased ProfileStore. Improve it rather than replacing it because it already uses `UpdateAsync`, session leases, retries, fail-closed loading and `BindToClose`.
7. Add StyLua as the one immediately adopted formatting tool. Selene remains an evaluated follow-on until its signal-to-noise has been proved.
8. No fake Roblox IDs, credentials, gamepasses or developer products.

## 3. Profile schema v11

v11 is the compatibility bridge between the vertical slice and the scalable life sandbox.

It adds:

- `inventoryStacks: itemId -> quantity` for generic stackable items;
- `inventoryInstances: instanceUuid -> { itemId, metadata }` for unique items only where identity matters;
- `ownedFurniture: furnitureId -> quantity`;
- `furniturePlacements: placementId -> { furnitureId, instanceId?, x, y, z, rotation }`;
- `savedOutfits: outfitId -> { hair, top, bottom, shoes, accessory }`;
- `activeOutfitId`;
- `discoveredWorlds: worldId -> boolean`;
- `keepsakes: keepsakeId -> quantity`.

Legacy `inventory`, `homeItems`, profession, route, portal, transport and presentation fields remain in v11 so current runtime systems keep working while the generic model is adopted. Migration copies equivalent legacy values into new collections without deleting the old fields.

`ProfileMigrations.luau` owns an explicit ordered migration chain. It rejects unsupported future versions, migrates old/no-version data deterministically, and is idempotent at the current target version. ProfileStore migrates before normalization and fails closed if migration cannot safely complete.

## 4. Content definition layer

Create read-only shared definitions:

- `ItemDefinitions.luau`
- `FurnitureDefinitions.luau`
- `ActivityDefinitions.luau`
- `WorldDefinitions.luau`
- `ShopDefinitions.luau`
- `AppearanceDefinitions.luau`

Definitions own stable IDs, display metadata, categories, prices/rewards, acquisition rules, prefab roles, interaction verbs, analytics categories and mobile expectations. The server always looks up prices and rewards from definitions. Clients submit IDs/intents only.

The v0.6.0 catalogue satisfies the v1 content floor in definitions: at least 80 home/furnishing entries across bedroom, kitchen, bathroom, living, storage, garden, decoration and lighting; at least 20 meaningful interaction entries; at least four ordinary-life/career activities; four original portal worlds; at least 30 keepsakes; and multiple free appearance/outfit combinations.

## 5. Home placement

`FurniturePlacementRules.luau` handles pure validation: known/placeable ID, finite coordinates, 90-degree rotation snapping, placement count budget, ownership count and configured home bounds.

`FurniturePlacementService.luau` owns the network boundary and server-side world checks. The client sends only `itemInstanceId/furnitureId + requested transform`. The server verifies profile ownership, plot ownership, home bounds, collision/overlap, placement budget, request rate, allowed rotation and final canonical transform before persistence.

Supported mutations:

- place;
- move/rotate;
- store/remove;
- load placements on plot assignment/rebuild;
- replicate authoritative physical models to visitors.

Home shell/theme rebuilds remain separate. Furniture changes must mutate only the affected placed model rather than rebuilding the complete house.

`FurniturePrefabBuilder.luau` provides recognisable native-part fallback prefabs with semantic art roles and interaction anchors. It covers practical categories such as chairs, tables, lamps, shelves, plants, beds, kitchen fixtures, bathroom fixtures, storage and decorations. Authored meshes can later replace visuals without changing gameplay contracts.

## 6. Home interaction component model

Reusable interaction verbs cover the target set: sit, rest/sleep, open/close, switch on/off, store/retrieve, cook, wash, shower/bathe, plant, water, harvest, read/play, dress/change, display/collect, place/decorate and craft/create.

Not every catalogue item receives custom code. `FurnitureDefinitions` maps items to reusable verbs and prefab roles. Server-side interaction dispatch validates owner/guest policy and executes bounded state changes. Labels remain secondary; objects must remain visually recognisable.

## 7. Security

Create server-only `src/server/security/RemoteGuard.luau` implementing:

- type/shape validation;
- finite number and integer/range validation;
- string length caps;
- ID allow-lists;
- per-player/per-action rate limits;
- distance and ownership helper checks;
- cleanup on player removal;
- structured security warnings without sensitive/free-form text.

All new remotes and onboarding use it. Every future shop, placement, career, portal, appearance and crafting mutation is server-priced/server-rewarded.

## 8. Persistence environments

Create `EnvironmentConfig.luau` with explicit `DEV` and `LIVE` DataStore namespaces. The default is DEV-safe. LIVE requires explicit runtime/release configuration. No DEV Studio run may write to the LIVE namespace.

The repository includes environment templates and release requirements but no real credentials or invented place IDs.

Persistence tests cover migration, future-version rejection, lease conflict, heartbeat/save retry contracts and malformed data handling where deterministic rules can be tested outside Studio.

## 9. Trading

Before unique/high-value items are tradable, add durable transaction semantics:

- transaction ID;
- immutable agreed offer snapshot;
- item lock representation;
- confirmation version;
- idempotent commit state;
- duplicate-completion protection;
- recovery/audit record shape;
- timeout/cancellation.

Legacy low-value stack trading may continue. Unique/high-value trading remains disabled until Studio/DataStore recovery evidence is recorded.

## 10. Village and portal depth

The village remains the primary life sandbox. Destination definitions formalise Town Hall, Village Shop, Home Store, Courier Depot, Workshop and Market/Trading Post roles, progression purpose and physical verbs.

Portal architecture expands to four original worlds. Existing Giant Kitchen and Moonlit Meadow stay and are deepened by contract. Two original worlds are added to definitions/runtime build paths, each with a distinctive visual rule, traversal/activity mechanic, secret, bounded objective, keepsake and return-home payoff. No client-supplied reward values are accepted.

## 11. Character expression

Appearance definitions expand beyond the initial Boy/Girl and three palettes into free presets for hair, tops, bottoms, shoes and simple accessories plus saved outfits. Character identity is not monetisation-gated. Any Roblox-hosted asset reference remains manifest-driven and must have provenance/approval before production use.

## 12. UI/input system

Keep the compact HUD and journal philosophy. Add small native reusable modules instead of a framework:

- `UiTokens.luau`
- `UiScaleRules.luau`
- `ButtonFactory.luau`
- `PanelFactory.luau`
- `ModalController.luau`
- `FocusController.luau`

Acceptance rules:

- touch, mouse and controller paths;
- minimum 44x44 effective touch targets;
- no hover-only critical interaction;
- safe-area handling;
- explicit small-phone/portrait/desktop breakpoints;
- deliberate controller focus order;
- loading/error/empty states;
- placement UX supports preview, rotate, confirm, cancel and store.

Journal target sections are Today, Bag, Home, Careers, Collection and Places. Permanent HUD telemetry does not expand.

## 13. Analytics and observability

Add a small stable analytics taxonomy for join, new/returning, onboarding, home entry, first home interaction, first earned currency, first purchase, first placement, career completion, portal enter/complete, visit, trade and session lifecycle.

No free-form player text is logged. Analytics are rate-conscious and answer defined product questions. Existing AlphaOps remains internal runtime health instrumentation rather than being relabelled as product analytics.

## 14. Performance and assets

Create hard budget docs and machine-readable shared budget constants consistent with the Roblox development skill's starting targets: 30 FPS minimum mobile, 60 FPS desktop target, ~500 MB mobile target, under 15 seconds mobile load target, no per-render-frame gameplay remotes, restrained part/particle/light budgets and real-device verification.

Add asset manifest/provenance contracts. Production asset records contain semantic ID/name, Roblox asset ID when known, owner, source, licence/provenance, prefab role, version and DEV/LIVE approval. Empty/unapproved IDs fail closed. Native-part prefabs remain the fallback, not the final-art excuse.

## 15. Tooling/testing

Pin StyLua through Rokit and add `stylua.toml` plus CI formatting check. Keep Luau CLI tests and `luau-analyze`. Add pure tests for definitions, migrations, placement, remote validation and trade transactions. Add fail-closed source guards for release authority and security boundaries.

Studio smoke, multi-client, phone/controller, performance and published-device routes are documented separately and cannot be marked passing from repository inspection.

## 16. Release engineering

v0.6.0 produces a traceable Rojo artifact and manifest using the existing credential-free pipeline. Documentation defines the future same-artifact flow `commit -> CI -> artifact -> DEV -> runtime/device evidence -> approval -> LIVE`, environment separation, rollback and last-known-good requirements.

No publishing secret or LIVE action is added in this PR.

## 17. Documentation authority

v0.6.0 updates canonical product, engineering, quality, roadmap, progress, AGENTS and README documents. Old v0.5.2/v0.5.3 acceptance files become historical evidence and are not rewritten to claim v0.6.0 behaviour.

The precedence becomes:

1. current release acceptance;
2. v1 target-state product contract;
3. durable engineering/quality contracts;
4. active release roadmap/spec/plan;
5. historical records.

## 18. Definition of done

Repository acceptance requires all deterministic tests, analysis, compilation, formatting, release-contract/build-contract checks and diff checks to pass in CI. Studio/multiplayer/device/published evidence remains explicitly pending until actually observed.

The release must leave a future Codex able to identify what source produced the candidate artifact, which evidence is automated, which evidence is human/Studio/device-gated, and what remains before DEV/LIVE promotion.