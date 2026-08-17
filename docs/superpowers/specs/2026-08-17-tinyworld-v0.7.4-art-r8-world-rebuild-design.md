# TinyWorld v0.7.4 ART R8 Structural World Rebuild Design

Controlling issue: #26
Status: Approved product direction, written design pending user review
Date: 2026-08-17

## 1. Purpose

ART R8 replaces the visible village structure that failed ART R7 human acceptance. R8 is not another decoration layer. It preserves the working TinyWorld gameplay, persistence, activities, homes, transport, portal systems, server authority, release process and published-safe renderer while replacing the prototype-grade world those systems inhabit.

The success criterion is published-client perception: a player should see an authored Roblox village with coherent streets, homes, destinations, shoreline and social spaces rather than a collection of loose Parts on a large grass plane.

## 2. Chosen approach

Use structural replacement in-place.

Gameplay/service anchors remain compatible, but R8 owns visible map composition. Conflicting R6/R7 visual roots are retired rather than rendered underneath or beside R8. Existing services continue to use canonical locations and invisible interaction anchors where necessary.

Rejected approaches:
- full game rewrite: unnecessary regression risk;
- additive R7 polish: contradicted by published human evidence.

## 3. Architectural principles

1. One visible authority per concern. Ground, coast, village layout, player-home shell, each civic building and each activity destination have one R8 visual owner.
2. Preserve gameplay contracts. Profile schema remains 11 unless a genuinely unavoidable persistence change is discovered.
3. Retire replaced visuals. R8 must not stack a new façade, roof, road, shoreline or activity station over an older visual equivalent.
4. Gameplay anchors may be invisible. A functional anchor does not have to remain the visible object that originally hosted it.
5. Published runtime remains native-safe. No published EditableMesh or invented asset IDs.
6. Human evidence decides beauty. Source attributes and CI prove architecture, not visual quality.

## 4. R8 world layout authority

Introduce `R8VillageLayout.luau` as the deterministic server-side layout authority consumed by world, coast, destination, NPC and activity presentation code.

It defines:
- hero plaza and fountain centre;
- four residential neighbourhood clusters preserving the sixteen-home capacity;
- market street;
- garden lane/community garden;
- workshop court;
- harbour and fishing dock;
- road/path centre-lines and route widths;
- authoritative walkable ground elevation;
- shoreline edge, water level, safe shore recovery elevation and walkable shore bands;
- destination/NPC CFrames.

`VillageActivityLocations` becomes an adapter over this authority for existing R6 activity services so gameplay code does not duplicate R8 coordinates.

`WorldBuilder` must use R8 layout data for plot placement rather than keeping a separate visual grid. The sixteen-home admission contract remains unchanged, but the homes are arranged as neighbourhood clusters around real lanes rather than visually isolated plots.

The hub is intentionally compact. From the plaza, the player should see or reach a meaningful destination within a short walk rather than crossing a featureless field.

## 5. Ground, streets, water and shoreline

Introduce `R8GroundBuilder.luau` as the sole owner of visible village ground, roads, plazas and walkable land composition.

Introduce `R8CoastBuilder.luau` as the sole owner of water fill, seabed, shoreline transition, shore recovery CFrame and coast traversal geometry. It replaces `CoastBuilder` in `Main` rather than decorating its hill slabs.

`R8GroundBuilder` creates:
- a collision-safe village base at the authoritative layout elevation;
- continuous roads/lanes with deliberate intersections and edges;
- plazas/courtyards integrated into the route network;
- small elevation changes using clearly separated solid volumes, never near-coplanar wafer overlays;
- continuous residential garden edges;
- clean land-side interfaces for the coast builder.

`R8CoastBuilder` creates:
- Terrain water and seabed using the existing swim/water-belt gameplay intent;
- a designed grass-to-bank-to-beach-to-water transition;
- gentle walkable shore geometry without the old rotated 30x2 slab treatment;
- the fishing dock and harbour shoreline attachment points;
- `shorelineDistance`, `swimDistance`, `waterBelt`, `safeShoreCFrame` and `worldRecoveryCFrame` required by traversal services.

The R8 contract forbids the broad 0.04-stud overlay pattern, forbids multiple large coplanar Grass surfaces, and forbids the legacy `*HillSlope` coast slab pattern in the active runtime path.

Ground, shore visuals and traversal recovery use the same elevation constants from `R8VillageLayout`. This addresses the published waist-deep avatar failure structurally rather than by nudging one object.

`VillageGroundRebuildBuilder`, `CoastBuilder` and conflicting visible R7 map composition are retired from `Main` once R8 is active.

## 6. Village composition

Introduce `R8VillageCompositionBuilder.luau` for streetscape and non-building composition only.

It adds:
- coherent tree groups and hedges placed along streets/edges instead of scattered across fields;
- planters, benches, lamps and low walls defining social spaces;
- small courtyards and gateways;
- visual framing between neighbourhoods;
- compact wayfinding using physical landmarks rather than large signs.

It does not own ground, coast, complete buildings or activity props.

All decorative parts are anchored, non-touch, non-query and non-colliding unless they are explicitly meant to be physical boundaries.

## 7. Houses and civic prefabs

### Player homes

`HomePrefabBuilder.buildShell` is structurally rebuilt instead of receiving another post-build charm layer.

Every tier retains:
- `ResidentialShell` model contract;
- `FrontDoor`/interaction anchor semantics required by plot/home services;
- interior compatibility;
- tier/theme metadata;
- ownership and persistence behavior.

Visible form changes to:
- coherent full wall volumes rather than façade panels floating over a shell;
- pitched or hipped roof assemblies sized to the building footprint;
- real eaves and gable hierarchy;
- recessed/framed windows;
- doors integrated into porches;
- chimneys/dormers/bays only where they improve tier silhouette;
- small garden/fence/mailbox details built as part of the prefab.

`R7BuildingPolishBuilder.decorateHomeShell` is removed from `PlotService` after equivalent R8 detail exists.

### Civic buildings

Introduce `R8CivicPrefabBuilder.luau` for the complete visible market building/stall, garden shed, workshop and harbour hut. These are complete destination prefabs, not identity façades placed near legacy structures.

`R8CivicPrefabBuilder` owns the building volume only. `R8ActivityDestinationBuilder` owns the surrounding yard, props and activity staging. This prevents two builders from creating competing versions of the same structure.

The existing `HeroFountainBuilder` may be reused directly if its published-client form remains coherent, but R8 does not call `R6CivicPresentationBuilder`. The fountain is placed by the R8 layout/plaza composition, not through the R6 wrapper.

Each building must be readable by silhouette and approach before signage.

## 8. Activity destinations

Introduce `R8ActivityDestinationBuilder.luau` and remove `R7ActivityPresentationBuilder` from the runtime composition.

The builder creates the spaces around the complete civic prefabs:
- Mara: compact market square/street frontage, goods display and market approach;
- Pip: enclosed community garden with beds, shed/tool nook and connected path;
- Finn: fishing dock physically attached to the R8 shore, tackle storage and water-facing activity position;
- Skye: harbour launch/delivery yard connected to the water and Tiny Boat route;
- Milo: workshop court with workbench, timber/material zone and repair area.

Existing `VillageActivityService` handlers, rewards, ownership arbitration and player state remain unchanged unless a locator compatibility change is required.

## 9. NPC integration

Keep the ART R7 native character builder as the baseline unless published screenshots after the structural rebuild reveal a specific character defect.

R8 changes NPC integration rather than rebuilding characters again:
- NPC origin comes from `R8VillageLayout` through `VillageActivityLocations`;
- characters stand naturally inside their destination;
- floating nameplates are reduced in size/distance and remain secondary to destination context;
- prompts remain reachable and unobstructed;
- role props remain published-safe.

This avoids spending R8 effort on character geometry while the world structure is the primary blocker.

## 10. Mobile HUD reduction

Update the existing client UI rather than adding a new HUD framework.

`Main.client.luau`, `GameNav.luau`, UI factories/tokens and `BuildStamp.client.luau` are modified so:
- coins and level use a compact top-left status row;
- Today is collapsed by default to a compact quest/task affordance with expansion on demand;
- Journal is a compact touch-safe button, not a wide mostly-empty pill;
- the DEV stamp is a small corner tag with exact `v0.7.4 · ART R8` identity;
- world visibility on phone is materially increased.

No essential gameplay state is removed.

## 11. Runtime composition and legacy retirement

`Main.server.luau` changes from additive visual stacking to an explicit R8 path.

R8 runtime order:
1. R8 layout and base gameplay/world anchors;
2. R8 coast/boundary data;
3. production cleanup;
4. R8 ground/roads/plaza;
5. R8 village composition;
6. R8 civic prefabs and direct fountain placement;
7. R8 activity destinations;
8. portal/impossible-world/spawn systems;
9. services.

The active R8 runtime does not call:
- `CoastBuilder.build`;
- `VillageGroundRebuildBuilder.apply`;
- `R6CivicPresentationBuilder.apply`;
- `R7WorldCompositionBuilder.apply`;
- `R7BuildingPolishBuilder.apply`;
- `R7ActivityPresentationBuilder.apply`.

Legacy files may remain temporarily for history/rollback, but must not render simultaneously with R8.

## 12. Collision and traversal safety

R8 explicitly distinguishes decorative geometry from gameplay collision.

Rules:
- decorative dressing is non-colliding;
- authoritative ground/roads/shore have deliberate collision;
- low fences/walls collide only where intended and have clear gaps;
- prompts are not hidden inside collision volumes;
- spawn, home entrances, plaza, activity stations, shore recovery and boat launch have testable safe standing surfaces;
- traversal recovery uses R8 layout-derived positions.

A deterministic/source contract must fail if ground and safe-shore heights drift apart, if old CoastBuilder hill-slope geometry is active, or if R7 ground/shore visual roots are active alongside R8.

## 13. Release identity and CI

Release identity:
- product version: `0.7.4`;
- art revision: `ART R8`;
- release name: `Structural World Rebuild`;
- artifact: `TinyWorld-v0.7.4.rbxlx`.

The single free-only workflow remains authoritative.

TDD order:
1. wire the R8 source contract and release identity expectations to create a deliberate RED run;
2. implement layout/ground/coast until map and collision contracts pass;
3. rebuild houses/civic prefabs;
4. rebuild activity destinations;
5. integrate NPC locations;
6. reduce HUD;
7. run full exact-head verification;
8. merge exact reviewed head;
9. verify post-merge main workflow and Roblox DEV version.

## 14. Automated acceptance

At minimum:
- all existing 41+ Luau specs pass;
- analysis and StyLua pass;
- runtime server/client Luau compile passes;
- R8 source contract passes;
- release/build/publish contracts pass;
- R5/R6 published-safe renderer contract remains intact;
- R6 activity ownership/reward/multiplayer safety remains intact;
- only one Actions workflow exists and no retained artifact/cache action is introduced;
- exact PR head is green;
- retained artifacts = 0.

R8 source-contract checks include:
- `Main` composes R8 and does not call the retired Coast/R6/R7 visual builders;
- one authoritative `R8VillageLayout` is consumed by WorldBuilder integration, R8 ground/coast and the activity-location adapter;
- no legacy coplanar grass overlay pattern;
- no active CoastBuilder hill-slope slab pattern;
- safe-shore/ground elevation constants share one authority;
- player homes are rebuilt directly and PlotService no longer applies the R7 home charm overlay;
- five activity destination markers exist and use canonical locations;
- published EditableMesh remains forbidden.

## 15. Human acceptance

After DEV publication, request published-client screenshots from normal mobile gameplay:
1. spawn/village-centre hero view;
2. residential lane and player home entrance;
3. plaza/fountain;
4. Mara market;
5. Pip garden;
6. Finn dock;
7. Skye harbour;
8. Milo workshop;
9. shoreline while standing/walking at water edge;
10. HUD in ordinary gameplay.

Human acceptance fails if any hero view shows:
- exploded/intersecting entrance geometry;
- avatar sinking into ground;
- giant empty grass plane dominating composition;
- disconnected rectangular path patches;
- crude slab shoreline;
- old and new visual layers visibly overlapping;
- a destination that still reads as loose prototype Parts;
- purple/checkerboard runtime mesh corruption.

R8 is complete only after published-client evidence meets this bar.

## 16. Non-goals

R8 does not add major gameplay loops, new worlds, new vehicles, economy redesign, profile-schema migration or LIVE publishing. Its job is to make the existing village worthy of the game built inside it.