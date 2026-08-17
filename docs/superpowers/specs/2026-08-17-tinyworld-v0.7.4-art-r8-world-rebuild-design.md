# TinyWorld v0.7.4 ART R8 Structural World Rebuild Design

Controlling issue: #26
Status: Revised asset-first design pending user review
Date: 2026-08-17

## 1. Purpose

ART R8 replaces the visible village structure that failed ART R7 human acceptance. R8 is not another decoration layer. It preserves working gameplay, persistence, activities, homes, transport, portal systems, server authority, release process and the published-safe renderer while replacing the prototype-grade world those systems inhabit.

The success criterion is published-client perception: a player should see an authored Roblox village with coherent streets, homes, destinations, shoreline and social spaces rather than loose primitive Parts on a large grass plane.

R8 also corrects the visual-authoring model that contributed to R6/R7 failure. Hero scenery will no longer be primarily generated at runtime by large Luau `Instance.new("Part")` builders.

## 2. Chosen approach

Use **structural replacement in-place with an authored-asset-first pipeline**.

Gameplay/service anchors remain compatible, but R8 owns visible map composition. Conflicting R6/R7 visual roots are retired rather than rendered underneath or beside R8.

Visible hero form is owned by version-controlled Roblox model assets. Luau owns deterministic layout, collision, gameplay anchors, spawning, validation, interaction and composition.

Rejected approaches:
- full game rewrite: unnecessary regression risk;
- additive R7 polish: contradicted by published human evidence;
- runtime primitive-Part hero construction: repeatably deterministic, but has produced prototype-grade final art.

## 3. Research baseline and design rationale

R8 adopts patterns observed in established open-source Roblox/Rojo projects rather than inventing a bespoke asset pipeline.

Useful baselines reviewed before this revision:

### `rojo-rbx/desert-bus-2077` — MIT
- keeps authored Roblox models such as `Bus.rbxmx`, `Lobby.rbxmx` and `RoadSegment.rbxmx` under a version-controlled `models/` tree;
- maps that model tree into the Rojo project;
- gameplay code consumes authored models rather than reconstructing every hero object from primitive Parts.

### `MayGo/maze-world` — MIT
- separates authored model categories under `models/`, including reusable prefabs;
- stores place/terrain geometry separately;
- uses a Studio-to-model-file workflow to export authored Roblox Instances to version-controlled `.rbxmx` files.

### Rojo / Roblox environment-authoring principles
- Roblox model files can be first-class filesystem assets in a Rojo project;
- authored modular kits separate art from gameplay code;
- blockout geometry should be replaced by final reusable architectural pieces rather than decorated indefinitely;
- reusable prefab/package patterns are preferable to re-creating the same visual object procedurally in many places.

R8 uses these as architectural patterns only. It does not copy distinctive assets, layouts, characters, UI or expression from reference projects or commercial games.

## 4. Architectural principles

1. **One visible authority per concern.** Ground, coast, village layout, player-home shell, each civic building and each activity destination have one R8 visual owner.
2. **Art is data, not gameplay code.** Hero buildings, destination structures and reusable street pieces are version-controlled Roblox model assets.
3. **Luau composes, it does not sculpt hero art.** Runtime code may create invisible anchors, collision primitives, debug geometry and small utilitarian effects, but not complete hero buildings from dozens of runtime Parts.
4. **Preserve gameplay contracts.** Profile schema remains 11 unless an unavoidable persistence change is discovered.
5. **Retire replaced visuals.** R8 must not stack a new façade, roof, road, shoreline or activity station over an older equivalent.
6. **Gameplay anchors may be invisible.** A functional anchor does not have to remain the visible object that originally hosted it.
7. **Published runtime remains native-safe.** No published EditableMesh and no invented Roblox asset IDs.
8. **Human evidence decides beauty.** Source attributes and CI prove architecture, not visual quality.

## 5. First-class authored asset tree

Add a version-controlled R8 model tree under:

`assets/models/r8/`

Initial structure:

- `Architecture/`
  - reusable roof, gable, dormer, framed-window, door, porch, chimney and trim assemblies;
- `Homes/`
  - complete Tier 1–5 residential exterior shells or coherent modular house assemblies;
- `Civic/`
  - market structure, garden shed, workshop building, harbour hut and compatible fountain/plaza pieces;
- `Activities/`
  - market display, garden beds/tool nook, fishing dock/tackle pieces, harbour launch/delivery pieces and workshop yard pieces;
- `StreetKit/`
  - benches, lamps, planters, bollards, low walls, gates, fences, signs and mailbox variants;
- `Nature/`
  - authored tree, hedge, shrub, flower/planter and shoreline-dressing variants where these improve quality over runtime primitives.

`default.project.json` will map this tree into a dedicated model container such as `ReplicatedStorage.TinyWorldAssets.R8` so server-side composition code can clone approved prefabs deterministically.

Model files are `.rbxmx` by default because they remain reviewable text in Git. Binary `.rbxm` is allowed only where there is a concrete reason.

## 6. Asset provenance and quality contract

Every R8 authored model must have an entry in the existing asset manifest or a dedicated R8 manifest referenced by it.

Required metadata:
- model path;
- semantic purpose;
- author/source;
- licence;
- provenance note;
- version/revision;
- approval state;
- whether it is original TinyWorld work, adapted from an allowed source, or generated from approved primitive/native Roblox geometry.

R8 should prefer original TinyWorld assets. Open-source references are architectural baselines, not a pool of art to copy casually.

If any third-party model is reused, its licence must explicitly permit it and the provenance must be recorded before the model enters the runtime path.

## 7. Authoring workflow

R8 establishes a durable hybrid workflow:

1. create or edit the visual prefab as a Roblox model;
2. store/export it as `.rbxmx` under `assets/models/r8/`;
3. review the model diff and provenance in GitHub;
4. Rojo makes the model available under the R8 asset container;
5. Luau clones and places the prefab using canonical R8 layout data;
6. gameplay anchors are connected using named invisible anchors or well-known attachment points;
7. CI checks that required model files, semantic anchors and manifest entries exist;
8. the actual published Roblox client decides visual acceptance.

Studio `syncback`/export may be used when available for authored visual work, but the repository remains the source of truth. A Studio-only unsaved model is not a production asset.

## 8. R8 model assembly contract

Hero prefabs should expose stable named anchors rather than requiring gameplay code to inspect arbitrary descendants.

Examples:
- `FrontDoorAnchor`;
- `NpcAnchor`;
- `PromptAnchor`;
- `ActivityOrigin`;
- `DockBoardingAnchor`;
- `BoatSpawnAnchor`;
- `FishingOrigin`;
- `DeliveryOrigin`.

Anchors may be invisible Parts or Attachments as appropriate.

R8 placement code may:
- clone a prefab;
- pivot it to a canonical CFrame;
- apply approved colour/material variants where the prefab was explicitly designed for them;
- attach gameplay prompts/services to named anchors;
- add invisible collision or safety volumes where required.

R8 placement code must not:
- rebuild the visible prefab from scratch because an anchor is inconvenient;
- place an old visual shell underneath the new prefab;
- use giant decorative primitives to hide a weak prefab;
- silently fall back to a prototype hero object in published DEV.

Missing required hero assets are a release-contract failure, not a reason to publish a box.

## 9. R8 world layout authority

Introduce `R8VillageLayout.luau` as the deterministic server-side layout authority consumed by world, coast, prefab placement, NPC and activity presentation code.

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

`WorldBuilder` uses R8 layout data for plot placement rather than maintaining a visually separate grid. The sixteen-home admission contract remains unchanged, but homes are arranged as neighbourhood clusters around real lanes rather than isolated plots.

The hub is intentionally compact. From the plaza, the player should see or reach a meaningful destination within a short walk rather than crossing a featureless field.

## 10. Ground, streets, water and shoreline

Ground and traversal safety remain code-owned because deterministic elevation/collision is valuable here.

Introduce `R8GroundBuilder.luau` as the sole owner of visible village ground, roads, plazas and walkable land composition.

Introduce `R8CoastBuilder.luau` as the sole owner of water fill, seabed, shoreline transition, shore recovery CFrame and coast traversal geometry. It replaces `CoastBuilder` in `Main` rather than decorating its hill slabs.

`R8GroundBuilder` creates:
- one collision-safe village base at the authoritative layout elevation;
- continuous roads/lanes with deliberate intersections and edges;
- plazas/courtyards integrated into the route network;
- small elevation changes using clearly separated solid volumes, never near-coplanar wafer overlays;
- continuous residential garden edges;
- clean land-side interfaces for the coast builder.

`R8CoastBuilder` creates:
- Terrain water and seabed using the existing swim/water-belt gameplay intent;
- a designed grass-to-bank-to-beach-to-water transition;
- gentle walkable shore geometry without the old rotated 30x2 slab treatment;
- authored dock/harbour prefab attachment points;
- `shorelineDistance`, `swimDistance`, `waterBelt`, `safeShoreCFrame` and `worldRecoveryCFrame` required by traversal services.

The R8 contract forbids the broad 0.04-stud overlay pattern, multiple large coplanar Grass surfaces and the legacy `*HillSlope` coast slab pattern in the active runtime path.

Ground, shore visuals and traversal recovery use the same elevation constants from `R8VillageLayout`. This addresses the published waist-deep avatar failure structurally rather than by nudging one object.

`VillageGroundRebuildBuilder`, `CoastBuilder` and conflicting visible R7 map composition are retired from `Main` once R8 is active.

## 11. Village composition

Introduce `R8VillageCompositionBuilder.luau` as an **assembler** for streetscape and non-building composition.

It clones approved R8 `StreetKit` and `Nature` prefabs and places them along canonical routes/edges to create:
- coherent tree groups and hedges;
- planters, benches, lamps and low walls defining social spaces;
- small courtyards and gateways;
- visual framing between neighbourhoods;
- compact wayfinding using physical landmarks rather than large signs.

It does not construct hero street furniture from scratch if an approved prefab exists.

Decorative assets are non-touch, non-query and non-colliding unless they are explicitly intended as physical boundaries.

## 12. Houses and civic prefabs

### Player homes

`HomePrefabBuilder` changes from a sculpting builder to a prefab selector/assembler.

Every tier retains:
- `ResidentialShell` model contract;
- `FrontDoor`/interaction anchor semantics required by plot/home services;
- interior compatibility;
- tier/theme metadata;
- ownership and persistence behavior.

Visible homes come from approved assets under `assets/models/r8/Homes/` or coherent reusable architecture assemblies under `Architecture/`.

Each tier must provide:
- a recognisable complete building silhouette;
- roof assembly scaled to the footprint, never one oversized dominant slab;
- genuine window depth/frame hierarchy;
- integrated door and porch composition;
- a coherent garden/frontage treatment;
- safe front-door standing space;
- theme variation without destroying silhouette quality.

`R7BuildingPolishBuilder.decorateHomeShell` is removed from `PlotService`. R8 does not decorate the old shell after the fact.

### Civic buildings

Introduce `R8CivicPrefabBuilder.luau` as a placement/anchor adapter for complete authored market, garden shed, workshop and harbour structures.

It clones complete assets from `assets/models/r8/Civic/` and places them using `R8VillageLayout`.

`R8CivicPrefabBuilder` owns building placement only. `R8ActivityDestinationBuilder` owns surrounding yard/activity staging so two systems do not compete for the same visual object.

The existing hero fountain may be retained only if published R8 client evidence shows it remains coherent with the new plaza. R8 does not call `R6CivicPresentationBuilder`.

## 13. Activity destinations

Introduce `R8ActivityDestinationBuilder.luau` as a prefab assembler and remove `R7ActivityPresentationBuilder` from active runtime composition.

It builds complete destinations from approved assets:
- Mara: compact market square/street frontage, coherent market structure, goods displays and approach;
- Pip: enclosed community garden, authored beds, shed/tool nook and connected path;
- Finn: authored fishing dock physically attached to the R8 shore, tackle storage and water-facing activity position;
- Skye: harbour launch/delivery yard physically connected to water and the Tiny Boat route;
- Milo: workshop court with complete workshop frontage, workbench, timber/material zone and repair area.

Existing `VillageActivityService` handlers, rewards, ownership arbitration and player state remain unchanged unless locator compatibility requires an adapter.

## 14. NPC integration

Keep the ART R7 native character builder as the baseline unless published screenshots after the structural rebuild reveal a specific character defect.

R8 changes NPC integration rather than spending the release rebuilding characters again:
- NPC origin comes from `R8VillageLayout` through `VillageActivityLocations`;
- characters stand naturally inside their destination;
- floating nameplates are reduced in size/distance and remain secondary to destination context;
- prompts remain reachable and unobstructed;
- role props remain published-safe.

## 15. Mobile HUD reduction

Update the existing client UI rather than adding a new HUD framework.

`Main.client.luau`, `GameNav.luau`, UI factories/tokens and `BuildStamp.client.luau` are modified so:
- coins and level use a compact top-left status row;
- Today is collapsed by default to a compact quest/task affordance with expansion on demand;
- Journal is a compact touch-safe button, not a wide mostly-empty pill;
- the DEV stamp is a small corner tag with exact `v0.7.4 · ART R8` identity;
- world visibility on phone is materially increased.

No essential gameplay state is removed.

## 16. Runtime composition and legacy retirement

`Main.server.luau` changes from additive visual stacking to an explicit R8 path.

R8 runtime order:
1. R8 layout and base gameplay/world anchors;
2. R8 coast/boundary data;
3. production cleanup;
4. R8 ground/roads/plaza;
5. authored R8 village/street prefab composition;
6. authored R8 civic/home prefab placement and direct fountain placement if retained;
7. authored R8 activity destinations;
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

## 17. Collision and traversal safety

R8 explicitly separates visible prefab geometry from authoritative movement safety.

Rules:
- decorative prefab descendants are non-colliding unless collision is intentional;
- authoritative ground/roads/shore have deliberate collision;
- hero prefabs may include designated collision shells, but gameplay code must not depend on arbitrary decorative descendants for safety;
- low fences/walls collide only where intended and have clear gaps;
- prompts are not hidden inside collision volumes;
- spawn, home entrances, plaza, activity stations, shore recovery and boat launch have testable safe standing surfaces;
- traversal recovery uses R8 layout-derived positions.

A deterministic/source contract fails if ground and safe-shore heights drift apart, if old CoastBuilder hill-slope geometry is active, or if R7 ground/shore visual roots are active alongside R8.

## 18. Release identity and CI

Release identity:
- product version: `0.7.4`;
- art revision: `ART R8`;
- release name: `Structural World Rebuild`;
- artifact: `TinyWorld-v0.7.4.rbxlx`.

The single free-only workflow remains authoritative.

TDD/implementation order:
1. add authored asset tree mapping, manifest rules and R8 source contract to create an intentional RED state;
2. land the minimum reusable architecture/street kit and verify Rojo composes model files correctly;
3. implement R8 layout/ground/coast and collision contracts;
4. replace home shells with authored R8 home prefabs;
5. replace civic/activity structures with authored prefabs;
6. integrate NPC locations;
7. reduce HUD;
8. run full exact-head verification;
9. merge the exact reviewed head;
10. verify post-merge `main` workflow and Roblox DEV version.

## 19. Automated acceptance

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
- `default.project.json` maps the R8 authored model tree;
- required R8 hero model files and manifest entries exist;
- hero home/civic/activity code clones approved models instead of building complete visible structures from runtime primitive Parts;
- required named prefab anchors exist or are validated during composition;
- `Main` composes R8 and does not call retired Coast/R6/R7 visual builders;
- one authoritative `R8VillageLayout` is consumed by WorldBuilder integration, R8 ground/coast and the activity-location adapter;
- no legacy coplanar grass overlay pattern;
- no active CoastBuilder hill-slope slab pattern;
- safe-shore/ground elevation constants share one authority;
- PlotService no longer applies the R7 home charm overlay;
- five activity destination markers use canonical locations;
- published EditableMesh remains forbidden.

## 20. Human acceptance

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
- a missing hero asset silently replaced by primitive fallback geometry;
- purple/checkerboard runtime mesh corruption.

R8 is complete only after published-client evidence meets this bar.

## 21. Non-goals

R8 does not add major gameplay loops, new worlds, new vehicles, economy redesign, profile-schema migration or LIVE publishing.

R8 also does not attempt to introduce a full external DCC/Blender production pipeline or Roblox cloud Packages as a prerequisite. The immediate goal is the smallest durable step that separates visual assets from gameplay code while keeping GitHub/Rojo authoritative.

Its job is to make the existing village worthy of the game built inside it.