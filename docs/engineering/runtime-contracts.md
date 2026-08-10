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
- AppearanceService: safe free preset selection/persistence.
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

## World content

World builders return semantic contracts, not gameplay authority. A production mesh/model may replace a native fallback only when it preserves expected art role, interaction anchors, collision/query behaviour and performance constraints.

## Runtime evidence

Static source checks cannot prove:

- recognisability;
- FPS/memory;
- network behaviour;
- multi-client replication;
- input ergonomics;
- published-place behaviour.

Those are explicit Studio/device evidence gates in release acceptance.