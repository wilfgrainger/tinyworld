# TinyWorld runtime contracts

## Layering

### `src/shared`

Deterministic rules, definitions and validation that do not depend on Roblox services. These modules are executable under the Luau CLI and are the primary TDD surface.

### `src/server`

Authoritative adapters/services. Server responsibilities include persistence, currency, progression, item ownership, shop pricing, trade state, placement transforms, permissions, portal rewards, analytics emission and exploit validation.

### `src/client`

Presentation and input intent only. Clients may preview, animate, select and request; they do not mint state.

## Service boundaries

- ProfileStore: leased, fail-closed persistence.
- PlayerStateService: presentation mirrors/attributes.
- RemoteGuard: shared server-only remote validation/rate-limit adapter.
- HomeStoreService: server-priced furniture ownership.
- FurniturePlacementService: final home-local placement authority and physical replication.
- TradeService/TradeJournal: bounded low-value exchange plus durable transaction record.
- AppearanceService: safe free style-preference validation/persistence while preserving the Roblox avatar baseline when approved TinyWorld character art is absent.
- PortalService: authored world sessions and server rewards.
- AnalyticsService: bounded milestone events only.
- AmbientLifeService: small deterministic non-authoritative village ambience.

## Client-to-server contract

Every mutation follows:

1. validate payload shape/size;
2. rate-limit the action;
3. resolve IDs through server definitions;
4. obtain authoritative profile/context;
5. verify ownership/distance/privacy/unlock as relevant;
6. compute price/reward/final transform on the server;
7. mutate state;
8. update presentation mirrors;
9. persist/queue save;
10. emit bounded analytics after success.

A request that fails any step changes nothing economically meaningful.

## Lifecycle/cleanup

Every service that creates player-specific connections, sessions, rate windows, temporary world instances or analytics timing owns cleanup on PlayerRemoving. World-wide loops expose `stop()` for shutdown where applicable.

## Home mutation

Shell/theme changes may rebuild the authored home container. Furniture-only changes must add/move/remove the affected placed model rather than rebuilding the whole house. If a shell rebuild happens, persisted placements are re-rendered afterward.

Visitors observe the same server-replicated models. They do not receive a private client-only decoration state.

## World-content presentation contract

World builders return semantic contracts, not gameplay authority.

For ordinary village content:

- architecture/silhouette/material/props carry destination identity first;
- contextual `ProximityPrompt` text carries the nearby action;
- proper names may use small physical/diegetic signs;
- large always-on-top information panels are not a supported ordinary-world presentation primitive;
- dynamic world text that genuinely belongs in-scene is attached to a physical surface or exposed contextually.

A production mesh/model may replace a native fallback only when it preserves expected art role, interaction anchors, collision/query behaviour and performance constraints.

A native fallback is accepted by visual quality, not by the fact that a builder can construct it.

## Character presentation contract

Saved TinyWorld appearance data remains server validated/persisted. Visible application is deliberately separate from persistence.

When no approved TinyWorld character asset exists, runtime preserves the player's Roblox avatar/accessories/clothing rather than constructing primitive Part hair or shoe geometry. This is a presentation choice, not a schema or authority change.

## UI presentation contract

Normal play uses:

- compact `StatusCluster`;
- one shared `GameNav` for Journal/Home/Style;
- one modal owner;
- short toasts;
- contextual prompts.

Home/Wardrobe/Journal may remain separate feature modules, but they register into the same normal-play navigation surface rather than drawing competing standalone buttons.

## Runtime evidence

Static source checks cannot prove:

- recognisability;
- visual craft;
- FPS/memory;
- network behaviour;
- multi-client replication;
- input ergonomics;
- published-place behaviour.

Those are explicit Studio/device evidence gates in release acceptance.

For v0.6.1 player-facing work, required observed visual/device rows block merge-ready status until run against the exact candidate.