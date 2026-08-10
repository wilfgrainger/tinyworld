# v0.6.0 Target-State Consolidation acceptance

**Release:** v0.6.0  
**Profile schema:** 11  
**Status:** merged historical evidence record. This file preserves what v0.6.0 proved and left unobserved at merge time; it is not current release authority. Current acceptance is `../v0.6.1/acceptance.md`.

## Repository/product contract at v0.6.0 merge

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

## Authority/security at v0.6.0 merge

- [x] Economy/progression/shop/reward state remains server-authoritative.
- [x] Server-only `RemoteGuard` and pure validation rules exist.
- [x] Onboarding is rate-limited and string-length checked before filtering.
- [x] Home Store accepts IDs only and prices server-side.
- [x] Furniture placement validates ownership, finite transforms, complete-footprint home bounds, existing-placement overlap, structural collision, rotation and count budget server-side.
- [x] DEV/LIVE DataStore namespaces are separate and Studio defaults to DEV.
- [x] ProfileStore migrates before normalize and fails closed on unsupported future data.
- [x] Durable trade transaction IDs/snapshots/journal/idempotent state exist.
- [x] High-value/unique trading remains disabled pending recovery evidence.

## Home/player-facing source foundation at v0.6.0 merge

- [x] Physical placed furniture persists as canonical home-local transforms.
- [x] Furniture-only mutation does not require a complete house rebuild.
- [x] House rebuilds re-render persisted placements.
- [x] Native-part furniture prefab source fallback exists.
- [x] Responsive Home catalogue and placement UI source exists.
- [x] Placement preview is client-local and red/green using shared pure ownership/budget/bounds/overlap rules; the server independently revalidates and adds structural collision checks before persistence.
- [x] Confirm sends one bounded mutation request rather than streaming placement transforms.
- [x] Touch targets/controller placement bindings are explicit in source.
- [x] Wardrobe UI and persisted free appearance selection source exists.
- [x] Asset-free character-expression fallback source was wired without fabricated Roblox asset IDs.
- [x] Portal completion creates a physical keepsake display back at the resident home.

**Historical correction:** the first screenshots observed after merge showed that several of those player-facing source mechanisms did not meet the intended visual craft bar. In particular, the native character fallback and large ordinary-world information panels were visually unacceptable. v0.6.1 corrects them. Their source presence above is not retroactive proof of visual quality.

## World/operations foundation at v0.6.0 merge

- [x] Giant Kitchen and Moonlit Meadow retained.
- [x] Cloudpost Observatory authored with post office/observatory/wind-route physical identity.
- [x] Clockwork Orchard authored with orchard/clock/gear physical identity.
- [x] All four portal worlds require their authored physical mechanic as well as their collectible objective; each also has an optional secret.
- [x] Small deterministic ambient bird/cat life exists.
- [x] Stable analytics event taxonomy and Roblox AnalyticsService adapter exist.
- [x] Performance budgets are machine-readable and documented.
- [x] Asset manifest rejects invented IDs and requires provenance for production entries.
- [x] Gameplay server capacity is tied to the sixteen resident plots and fails closed on overflow/configuration drift.

## Automated gates recorded for v0.6.0

The implementation source SHA and PR synthetic merge SHA proved by the workflows are recorded in `automated-evidence.json`. The committed record remains the historical automated evidence for that release.

| Gate | Status | Evidence |
|---|---|---|
| Pure Luau tests | PASS | `automated-evidence.json` |
| Shared Luau analysis | PASS | `automated-evidence.json` |
| StyLua check | PASS | `automated-evidence.json` |
| Recursive server/client compile | PASS | `automated-evidence.json` |
| v0.6.0 release authority/contract | PASS | `automated-evidence.json` |
| Rojo candidate build | PASS | `automated-evidence.json` |
| Traceability manifest/artifact | PASS | `automated-evidence.json` |

## Studio single-client evidence at merge

**NOT RUN / PENDING.** The implementation/review environment did not provide Roblox Studio runtime evidence before merge. Required route had included:

- profile load/rejoin/migration;
- first 2/10/30 minute route;
- Home Store purchase;
- place/rotate/store furniture;
- home rebuild retains placements;
- wardrobe/character presentation;
- careers/garden/transport;
- all four portal worlds, mechanics, secrets and home keepsakes;
- 16-player resident-cap route and deliberate overflow-misconfiguration rejection;
- Output review.

The later screenshots that motivated v0.6.1 are useful evidence of visual failures, but they do not retroactively turn this whole historical route into PASS.

## Multiplayer evidence at merge

**NOT RUN / PENDING.** Required Server & Clients route had included:

- visitors see authoritative placed furniture;
- guests cannot mutate owner furniture;
- Open/Friends/Private home access;
- trade happy path, timeout, stale confirmation and disconnect/recovery;
- hostile/malformed placement/shop/onboarding remotes are rejected;
- portal mechanics remain correct with concurrent players.

## Device/accessibility/performance evidence at merge

**NOT RUN / PENDING.** Required evidence had included:

- phone portrait/landscape touch flow;
- controller focus and placement;
- labels-off object recognition;
- >=30 FPS target mobile route;
- <=500 MB target mobile memory;
- <=15 second target load/useful-spawn route;
- desktop 60 FPS target where practical;
- Developer Console network behaviour.

## Published DEV / LIVE at merge

**NOT RUN / PENDING BY DESIGN.** DEV/LIVE config files remained unconfigured and credential-free. No LIVE promotion occurred through this release record.

## Historical evidence honesty

A green v0.6.0 CI build did not prove its Studio, multiplayer, device or published rows. Those rows remain historical PENDING/NOT RUN rather than being edited into PASS after the fact.

v0.6.1 changes the forward process: required player-facing visual evidence now blocks merge-ready status for the corrective visual release.