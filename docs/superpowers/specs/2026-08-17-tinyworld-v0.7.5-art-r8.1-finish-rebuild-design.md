# TinyWorld v0.7.5 ART R8.1 Finish the Rebuild Design

Status: Approved design, reconciled onto published-recovery main
Date: 2026-08-17
Branch: `release/v0.7.5-art-r8.1-finish-rebuild`
Base: `main` at `1ec8072325c8f643c31e8a081f25b46561f83ba2`
Target: Roblox DEV only

## Purpose

ART R8.1 finishes the structural migration started by ART R8. A separate published-recovery commit landed on `main` while this design was being prepared. That recovery already migrated hero homes to authored R8 prefabs, placed authored civic prefabs, retired active R6/R7 village presentation layers, improved coastal recovery, and advanced the release to v0.7.5 / ART R8.1.

The remaining gap is now narrower and more important: village activities still use legacy perimeter-derived coordinates and several services still construct destination-defining prototype geometry at runtime. This release finishes that migration instead of redoing work already on main.

## Product outcome

A player should perceive one deliberate stylised village. Mara, Pip, Finn, Skye and Milo must occupy authored destinations that belong to the R8 world. Activities should happen at those places rather than on debug-like runtime slabs, frames and docks.

Visual quality is a release requirement. CI green does not prove that the game looks finished.

## Current baseline already accepted from main

The reconciled implementation preserves these existing v0.7.5 recovery improvements:

- authored `HomeTier1..5` runtime homes through `R8AssetLibrary`;
- active `R8CivicPrefabBuilder` for MarketHouse, GardenShed, Workshop and HarbourHut;
- removal of active `R6CivicPresentationBuilder`, `R7BuildingPolishBuilder` and `R7ActivityPresentationBuilder` calls from `Main.server.luau`;
- canonical R8 ground, coast and village composition;
- Profile schema 11 compatibility;
- free-only main-to-DEV publication boundary.

R8.1 Finish the Rebuild must not regress any of these.

## Remaining defects

`VillageActivityLocations.luau` still derives activity coordinates from `world.layout.perimeterHalfExtent` and an independent hard-coded position map.

Permanent destination geometry is still partly activity-owned:

- fishing constructs a runtime structural dock;
- Pip's village garden constructs three plain runtime beds;
- Milo's repair activity constructs an isolated board frame and posts;
- coastal delivery constructs its own structural buoy and beacon.

The authored civic builder places visual destinations but does not expose a typed runtime registry of their anchors to activity/NPC systems.

## Chosen architecture

Use surgical authority completion.

1. Add authored activity prefabs under `assets/models/r8/Activities/` for garden beds, fishing dock, repair station and delivery buoy.
2. Add `R8DestinationBuilder.luau` that composes existing civic prefabs and new activity prefabs into one destination registry attached to `world.r8Destinations`.
3. Convert `VillageActivityLocations` into a compatibility adapter over the R8 registry.
4. Keep gameplay state machines and rewards unchanged while moving permanent structural ownership out of activity services.
5. Strengthen CI so a future release cannot silently return to legacy coordinates or runtime destination sculpting.

## Destination registry

`world.r8Destinations` is created before `VillageActivityService` and `VillageNpcService` start.

Required role entries:

- `Trader`: market model, NPC anchor, prompt anchor;
- `Gardener`: garden shed, NPC anchor, prompt anchor, authored three-bed set;
- `Fisherman`: authored fishing dock, NPC anchor, prompt anchor, fishing origin;
- `BoatKeeper`: harbour hut, NPC anchor, prompt anchor, boat spawn anchor;
- `Builder`: workshop, NPC anchor, prompt anchor, authored repair boards;
- `CoastalDelivery`: authored delivery buoy and prompt anchor.

Missing required models or anchors fail loudly. No primitive hero fallback is allowed.

## Authored activity prefabs

Add:

- `Activities/GardenBeds.rbxmx` with `GardenBed1`, `GardenBed2`, `GardenBed3`, `PromptAnchor`;
- `Activities/FishingDock.rbxmx` with `Deck`, rails/supports, `NpcAnchor`, `PromptAnchor`, `FishingOrigin`;
- `Activities/RepairStation.rbxmx` with `RepairBoard1..3`, workbench/frame details and `PromptAnchor`;
- `Activities/DeliveryBuoy.rbxmx` with readable buoy body/banding, beacon and `PromptAnchor`.

Use native anchored Roblox Parts only. No external mesh, texture or audio IDs are required. Each prefab is registered in `assets/manifests/r8-models.json` with exact SHA-256 and `devApproved=true`.

## Activity service responsibility split

World/prefab code owns permanent structure. Activity services own prompts, state, timing, transient props and rewards.

- Mara keeps request/inventory logic and uses the authored market.
- Pip binds dry/tended state and prompts to the authored garden beds.
- Finn binds the pull prompt to the authored dock and keeps only the transient bobber.
- Skye keeps player parcel logic; the harbour and outer delivery target are authored world content.
- Milo binds damaged/secured/repaired state to authored repair boards rather than creating a new frame.

Existing server authority, reward values, XP, profession XP and anti-duplicate-completion behavior remain unchanged.

## Canonical locations

`VillageActivityLocations` must no longer use `perimeterHalf(world)` or its own role coordinate map. It resolves named anchors from `world.r8Destinations`.

Add a canonical coastal-delivery point to R8 layout rules so the outer target remains owned by the R8 coast/layout authority rather than `perimeterHalf + 65` arithmetic.

## Visual quality gate

The release must be reviewed against Roblox-specific quality guidance, including gameplay discoverability, interaction clarity, mobile readability, destination completeness, traversal safety, prompt density, performance sanity and publish readiness.

After DEV publication, capture normal player-camera evidence for spawn, plaza, residential lane, Tier 1 and higher-tier homes, Mara, Pip, Finn, Skye/Tiny Boat, Milo, shoreline/swimming, mobile HUD and a wide traversal view.

Visual acceptance fails for duplicate old/new scenery, primitive hero fallbacks, giant dead grass views, checkerboard corruption, grass flicker, avatar sinking, floating/intersecting architecture, unreachable prompts, NPC/scenery collisions, debug-station activity areas, excessive HUD obstruction or incoherent scale/materials.

## Automated acceptance

A v0.7.5 ART R8.1 source contract must fail if:

- active R6/R7 presentation calls return;
- authored homes stop being consumed at runtime;
- authored civic placement disappears;
- activity locations return to perimeter-derived coordinates;
- fishing recreates a structural runtime dock;
- Pip recreates destination-defining runtime beds;
- Milo recreates the isolated runtime repair frame;
- coastal delivery recreates the structural runtime buoy;
- required activity prefabs/anchors are absent;
- any DEV-approved R8 model SHA is stale;
- published EditableMesh safety is weakened;
- release/build identity is inconsistent.

All existing unit tests, analysis, StyLua, Luau compile, release contracts and deterministic build remain required.

## Release identity

Keep semantic version `0.7.5` and art revision `ART R8.1`; this is a completion patch to the already-published recovery candidate. Normalize the release name to `Finish the Rebuild` and keep artifact `TinyWorld-v0.7.5.rbxlx`.

## Non-goals

No profile migration, combat, monetisation redesign, fish catalogue, new world, new vehicle class, global events or automatic LIVE publishing.

## Definition of done

R8.1 Finish the Rebuild is complete only when:

1. authored R8 destinations and canonical anchors own all five village activity locations;
2. permanent activity structures are no longer created by the four affected services;
3. exact-head CI is fully green;
4. the Roblox-specific quality audit has no release-blocking code/architecture findings;
5. main publishes DEV successfully and logs a numeric Roblox place version;
6. published-client screenshot/playtest evidence passes the visual matrix.
