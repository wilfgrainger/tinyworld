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

1. One visible authority per concern. Ground, village layout, player-home shell, each civic destination and each activity destination have one R8 visual owner.
2. Preserve gameplay contracts. Profile schema remains 11 unless a genuinely unavoidable persistence change is discovered.
3. Retire replaced visuals. R8 must not stack a new façade, roof, road or activity station over an older visual equivalent.
4. Gameplay anchors may be invisible. A functional anchor does not have to remain the visible object that originally hosted it.
5. Published runtime remains native-safe. No published EditableMesh or invented asset IDs.
6. Human evidence decides beauty. Source attributes and CI prove architecture, not visual quality.

## 4. R8 world layout authority

Introduce `R8VillageLayout.luau` as the deterministic layout authority consumed by world, destination, NPC and activity presentation code.

It defines:
- hero plaza and fountain centre;
- four residential neighbourhood clusters preserving the sixteen-home capacity;
- market street;
- garden lane/community garden;
- workshop court;
- harbour and fishing dock;
- road/path centre-lines and route widths;
- shoreline edge, safe shore recovery point and walkable elevation bands;
- destination/NPC CFrames.

`VillageActivityLocations` becomes an adapter over this authority for existing R6 activity services so gameplay code does not duplicate R8 coordinates.

The hub is intentionally compact. From the plaza, the player should see or reach a meaningful destination within a short walk rather than crossing a featureless field.

## 5. Ground, streets and shoreline

Introduce `R8GroundBuilder.luau` as the sole R8 owner of the visible village ground composition.

It creates:
- a collision-safe village base at one authoritative elevation;
- continuous roads/lanes with deliberate intersections and edges;
- plazas/courtyards integrated into the route network;
- small elevation changes using clearly separated solid volumes, never near-coplanar wafer overlays;
- continuous residential garden edges;
- a designed shoreline transition with beach/stone/grass bands and a physical dock connection.

The R8 contract forbids the broad 0.04-stud overlay pattern and forbids multiple large coplanar Grass surfaces.

The shoreline and recovery geometry must use the same height authority. A source contract checks that safe shore CFrame, visual shore elevation and walkable ground elevation are derived from the same constants. This addresses the published waist-deep avatar failure structurally rather than by nudging one object.

`VillageGroundRebuildBuilder` and conflicting visible R7 map composition are retired from `Main` once R8 ground is active.

## 6. Village composition

Introduce `R8VillageCompositionBuilder.luau` for streetscape and non-building composition only.

It adds:
- coherent tree groups and hedges placed along streets/edges instead of scattered across fields;
- planters, benches, lamps and low walls defining social spaces;
- small courtyards and gateways;
- visual framing between neighbourhoods;
- compact wayfinding using physical landmarks rather than large signs.

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

Introduce `R8CivicPrefabBuilder.luau` for market, garden shed, workshop and harbour hut/building. These are complete destination prefabs, not identity façades placed near legacy structures.

Each building must be readable by silhouette and approach before signage.

## 8. Activity destinations

Introduce `R8ActivityDestinationBuilder.luau` and remove `R7ActivityPresentationBuilder` from the runtime composition.

The builder creates complete environments around the existing activities:
- Mara: compact market square with one coherent stall/shop frontage, goods and street edge;
- Pip: enclosed community garden with beds, shed/tool nook and connected path;
- Finn: fishing dock physically attached to shore, tackle storage and water-facing activity position;
- Skye: harbour launch/delivery yard connected to the water and Tiny Boat route;
- Milo: workshop court with building frontage, workbench, timber/material zone and repair area.

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
1. base world/gameplay anchors;
2. coast/boundary data needed by services;
3. production cleanup;
4. R8 ground/layout;
5. R8 village composition;
6. R8 civic/home-compatible prefabs;
7. R8 activity destinations;
8. portal/impossible-world/spawn systems;
9. services.

The following runtime visual layers are removed or bypassed when R8 is active:
- `VillageGroundRebuildBuilder.apply`;
- `R6CivicPresentationBuilder.apply` where R8 has a complete equivalent;
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

A deterministic/source contract must fail if ground and safe-shore heights drift apart or if R7 ground/shore visual roots are active alongside R8.

## 13. Release identity and CI

Release identity:
- product version: `0.7.4`;
- art revision: `ART R8`;
- release name: `Structural World Rebuild`;
- artifact: `TinyWorld-v0.7.4.rbxlx`.

The single free-only workflow remains authoritative.

TDD order:
1. wire the R8 source contract and release identity expectations to create a deliberate RED run;
2. implement layout/ground until map and collision contracts pass;
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
- Main composes R8 and does not apply R7 visual builders;
- one authoritative R8 layout module is consumed by ground and activity-location adapter;
- no legacy coplanar grass overlay pattern;
- safe-shore/ground elevation constants share one authority;
- player homes are rebuilt directly and PlotService no longer applies R7 home charm overlay;
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