# v0.6.0 Target-State Consolidation acceptance

**Release:** v0.6.0
**Profile schema:** 11
**Status:** release candidate; evidence updated from CI/observed routes only.

## Repository/product contract

- [x] Canonical v1 target-state document exists.
- [x] Core loop, content catalogue and safety/social contracts exist.
- [x] Profile v11 adds generic stack/instance/furniture/outfit/discovery state while retaining v10 compatibility fields.
- [x] Explicit deterministic profile migration registry exists and rejects future versions.
- [x] 80+ furniture/home definitions span bedroom, kitchen, bathroom, living, storage, garden, decoration and lighting.
- [x] 20+ furniture definitions have meaningful interaction verbs.
- [x] Four ordinary-life activity definitions exist.
- [x] Four authored impossible-world definitions exist.
- [x] 30+ keepsake definitions exist.
- [x] Free character-expression definitions exist.

## Authority/security

- [x] Economy/progression/shop/reward state remains server-authoritative.
- [x] Server-only `RemoteGuard` and pure validation rules exist.
- [x] Onboarding is rate-limited and string-length checked before filtering.
- [x] Home Store accepts IDs only and prices server-side.
- [x] Furniture placement validates ownership, finite transforms, home bounds, overlap, rotation and count budget server-side.
- [x] DEV/LIVE DataStore namespaces are separate and Studio defaults to DEV.
- [x] ProfileStore migrates before normalize and fails closed on unsupported future data.
- [x] Durable trade transaction IDs/snapshots/journal/idempotent state exist.
- [x] High-value/unique trading remains disabled pending recovery evidence.

## Home/player-facing foundation

- [x] Physical placed furniture persists as canonical home-local transforms.
- [x] Furniture-only mutation does not require a complete house rebuild.
- [x] House rebuilds re-render persisted placements.
- [x] Recognisable native-part furniture prefab fallback exists.
- [x] Responsive Home catalogue and placement UI exists.
- [x] Placement preview is client-local; confirm sends one mutation request.
- [x] Touch targets/controller placement bindings are explicit.
- [x] Wardrobe UI and persisted free appearance selection exist.

## World/operations foundation

- [x] Giant Kitchen and Moonlit Meadow retained.
- [x] Cloudpost Observatory authored with post office/observatory/wind-route physical identity.
- [x] Clockwork Orchard authored with orchard/clock/gear physical identity.
- [x] Small deterministic ambient bird/cat life exists.
- [x] Stable analytics event taxonomy and Roblox AnalyticsService adapter exist.
- [x] Performance budgets are machine-readable and documented.
- [x] Asset manifest rejects invented IDs and requires provenance for production entries.

## Automated gates

These rows are updated only from the current PR head workflow result.

| Gate | Status | Evidence |
|---|---|---|
| Pure Luau tests | PENDING | GitHub Actions `Luau tests` |
| Shared Luau analysis | PENDING | GitHub Actions `Luau tests` |
| StyLua check | PENDING | GitHub Actions `Luau tests` |
| Recursive server/client compile | PENDING | GitHub Actions `Luau tests` |
| v0.6.0 release contract | PENDING | GitHub Actions `Rojo build` |
| Rojo candidate build | PENDING | GitHub Actions `Rojo build` |
| Traceability manifest/artifact | PENDING | GitHub Actions artifact |

## Studio single-client evidence

**PENDING.** This review/implementation session has no Roblox Studio MCP/runtime access. Required route:

- profile load/rejoin/migration;
- first 2/10/30 minute route;
- Home Store purchase;
- place/rotate/store furniture;
- home rebuild retains placements;
- wardrobe changes;
- careers/garden/transport;
- all four portal worlds;
- Output contains no critical errors.

## Multiplayer evidence

**PENDING.** Required Server & Clients route:

- visitors see authoritative placed furniture;
- guests cannot mutate owner furniture;
- Open/Friends/Private home access;
- trade happy path, timeout, stale confirmation and disconnect;
- hostile/malformed placement/shop/onboarding remotes are rejected.

## Device/accessibility/performance evidence

**PENDING.** Required real-device evidence:

- phone portrait/landscape touch flow;
- controller focus and placement;
- labels-off object recognition;
- >=30 FPS target mobile route;
- <=500 MB target mobile memory;
- <=15 second target load/useful-spawn route;
- desktop 60 FPS target where practical;
- Developer Console network behaviour.

## Published DEV / LIVE

**PENDING BY DESIGN.** DEV/LIVE config files remain unconfigured and credential-free. No LIVE promotion is permitted until an exact v0.6.0 artifact passes DEV/runtime/device evidence and receives explicit human approval.

## Evidence honesty

A green CI build does not convert the Studio, multiplayer, device or published rows to PASS.