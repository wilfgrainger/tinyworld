# TinyWorld v0.7.4 ART R8 Structural World Rebuild Design

Controlling issue: #26
Status: Revised asset-first design pending user review
Date: 2026-08-17

## 1. Purpose

ART R8 replaces the visible village structure that failed ART R7 human acceptance. It preserves working gameplay, persistence, activities, homes, transport, portal systems, server authority, release process and the published-safe renderer while replacing the prototype-grade world those systems inhabit.

R8 is also an authoring-model correction. Hero scenery will no longer be primarily generated at runtime by large Luau `Instance.new("Part")` builders. The target is a coherent authored Roblox village, not a decorated blockout.

## 2. Chosen approach

Use **structural replacement in-place with an authored-asset-first pipeline**.

Visible hero form is owned by version-controlled Roblox model assets. Luau owns deterministic layout, collision, gameplay anchors, spawning, validation, interaction and composition.

Rejected approaches:
- full game rewrite: unnecessary regression risk;
- additive R7 polish: contradicted by published human evidence;
- runtime primitive-Part hero construction: deterministic, but repeatedly prototype-grade as final art.

## 3. Research baseline

R8 adopts architectural patterns from reviewed open-source Roblox/Rojo projects:

### `rojo-rbx/desert-bus-2077` — MIT
- authored `.rbxmx` models live in a version-controlled `models/` tree;
- the model tree is mapped into the Rojo project;
- gameplay code consumes authored models rather than reconstructing all hero art at runtime.

### `MayGo/maze-world` — MIT
- authored models are separated into reusable categories including prefabs;
- place/terrain geometry is stored separately;
- Studio-authored Instances are exported to version-controlled `.rbxmx` files.

### Rojo / Roblox environment principles
- Roblox model files can be first-class filesystem assets in a Rojo project;
- modular kits separate art from gameplay code;
- blockout geometry should be replaced by final reusable architectural pieces rather than decorated indefinitely.

These are workflow baselines only. R8 does not copy distinctive art, layouts, characters, UI or expression from reference projects or commercial games.

## 4. Architectural principles

1. One visible authority per concern.
2. Art is data, not gameplay code.
3. Luau composes hero art but does not sculpt complete hero buildings from runtime primitive Parts.
4. Preserve gameplay contracts and Profile schema 11.
5. Retire replaced R6/R7 visuals instead of layering over them.
6. Gameplay anchors may be invisible and re-homed inside R8 prefabs.
7. Published runtime remains native-safe: no published EditableMesh and no invented Roblox asset IDs.
8. Human published-client evidence decides visual quality.

## 5. First-class authored asset tree

Add:

`assets/models/r8/`

Initial structure:

- `Architecture/` — roofs, gables, dormers, framed windows, doors, porches, chimneys, trim;
- `Homes/` — complete Tier 1–5 residential shells or coherent modular home assemblies;
- `Civic/` — market, garden shed, workshop, harbour building, compatible plaza/fountain pieces;
- `Activities/` — market displays, garden pieces, fishing dock/tackle pieces, harbour/delivery pieces, workshop-yard pieces;
- `StreetKit/` — benches, lamps, planters, bollards, low walls, gates, fences, signs, mailboxes;
- `Nature/` — authored trees, hedges, shrubs, planters and shoreline dressing where these improve quality over runtime primitives.

`default.project.json` maps this into a dedicated container such as `ReplicatedStorage.TinyWorldAssets.R8` so server composition code can clone approved prefabs deterministically.

Use `.rbxmx` by default because it is reviewable text in Git. `.rbxm` is allowed only when a concrete requirement justifies binary form.

## 6. Local-model manifest and provenance

Do **not** overload `assets/manifests/assets.json` for R8 local prefabs. That existing manifest is intentionally oriented around uploaded Roblox production assets and requires fields such as `robloxAssetId`.

Add a separate local-model manifest:

`assets/manifests/r8-models.json`

Each entry requires:
- `id`;
- repository-relative `path`;
- semantic `role`;
- `source` / author;
- `licenseOrProvenance`;
- file `sha256`;
- `version`;
- `status`;
- `qualityTier`;
- `devApproved`;
- `liveApproved`.

For original TinyWorld models, `source` identifies TinyWorld/original authorship and provenance records that the model was created for this repository. If third-party material is ever reused, its licence must explicitly permit reuse and provenance must be recorded before the model can enter the runtime path.

The existing `assets.json` remains authoritative for uploaded Roblox asset IDs. The two manifests have distinct concerns and CI contracts.

## 7. Authoring workflow

1. Create or edit a visual prefab as a Roblox model.
2. Store/export it as `.rbxmx` under `assets/models/r8/`.
3. Add/update its `r8-models.json` entry and SHA-256.
4. Review model and provenance in GitHub.
5. Rojo exposes the model under the R8 asset container.
6. Luau clones/places it using canonical R8 layout data.
7. Named anchors connect gameplay to the visual prefab.
8. CI validates required files, manifest hashes and required anchor names.
9. Published Roblox-client evidence decides visual acceptance.

Studio export or Rojo syncback may be used when available, but GitHub remains the source of truth. Unsaved Studio-only art is not a production asset.

## 8. Prefab assembly contract

Hero prefabs expose stable named anchors where relevant, for example:
- `FrontDoorAnchor`;
- `NpcAnchor`;
- `PromptAnchor`;
- `ActivityOrigin`;
- `DockBoardingAnchor`;
- `BoatSpawnAnchor`;
- `FishingOrigin`;
- `DeliveryOrigin`.

R8 placement code may clone, pivot, apply explicitly-supported variants, connect prompts/services, and add invisible safety/collision volumes.

It must not rebuild a visible hero prefab because an anchor is inconvenient, place a legacy visual shell underneath it, hide weak art with giant primitives, or silently fall back to a prototype box in published DEV.

A missing required hero asset or anchor is a release-contract failure.

## 9. R8 world layout authority

Introduce `R8VillageLayout.luau` as the deterministic layout authority for:
- hero plaza/fountain;
- four residential neighbourhood clusters preserving sixteen-home capacity;
- market street;
- garden lane/community garden;
- workshop court;
- harbour and fishing dock;
- roads/path centre-lines and widths;
- walkable ground elevation;
- shoreline/water/safe-recovery elevations;
- destination and NPC CFrames.

`VillageActivityLocations` becomes an adapter over R8 layout data. `WorldBuilder` uses R8 placement data rather than maintaining an independent visual grid.

The hub is intentionally compact. Important destinations must occur frequently enough that normal views are not dominated by empty grass.

## 10. Ground, streets, water and shoreline

Ground/traversal safety remain code-owned because deterministic elevation and collision are valuable here.

Introduce `R8GroundBuilder.luau` as sole owner of village ground, continuous roads, plazas and walkable land.

Introduce `R8CoastBuilder.luau` as sole owner of water fill, seabed, shoreline transition, shore recovery and coast traversal geometry. It replaces `CoastBuilder` in `Main` rather than decorating its old slope slabs.

Rules:
- one authoritative walkable base elevation;
- no near-coplanar 0.04-stud surface overlays;
- no multiple large coplanar Grass surfaces;
- no active legacy `*HillSlope` coast slabs;
- continuous roads and deliberate intersections;
- designed grass-to-bank-to-beach-to-water transition;
- safe shore CFrame and visible shore derive from the same R8 constants;
- authored dock/harbour pieces attach to canonical shore anchors.

This structurally addresses the published waist-deep avatar failure.

## 11. Village composition

`R8VillageCompositionBuilder.luau` is an assembler, not a sculptor. It clones `StreetKit` and `Nature` prefabs and places them along canonical routes/edges to create coherent tree groups, hedges, planters, benches, lamps, low walls, courtyards and gateways.

It does not own ground, coast, complete buildings or activity gameplay.

## 12. Player homes and civic prefabs

### Player homes

`HomePrefabBuilder` becomes a prefab selector/assembler.

Every tier retains:
- `ResidentialShell` contract;
- front-door interaction semantics;
- interior compatibility;
- tier/theme metadata;
- ownership and persistence behavior.

Visible homes come from `assets/models/r8/Homes/` and/or approved modular assemblies under `Architecture/`.

Each tier requires a complete silhouette, proportionate roof assembly, recessed/framed windows, integrated door/porch composition, coherent frontage/garden and safe front-door standing space.

`R7BuildingPolishBuilder.decorateHomeShell` is removed from `PlotService`. R8 does not decorate the old shell after the fact.

### Civic buildings

`R8CivicPrefabBuilder.luau` clones complete authored market, garden shed, workshop and harbour structures from `assets/models/r8/Civic/` and places them using `R8VillageLayout`.

The civic builder owns building placement only. Activity destination code owns surrounding activity staging.

The existing hero fountain may be retained only if published R8 evidence shows it remains coherent with the new plaza. R8 does not call `R6CivicPresentationBuilder`.

## 13. Activity destinations

`R8ActivityDestinationBuilder.luau` assembles complete destinations from approved models and canonical layout:
- Mara: compact market street frontage, coherent market structure and goods display;
- Pip: enclosed community garden, authored beds, shed/tool nook and path;
- Finn: authored dock attached physically to the R8 shoreline;
- Skye: coherent harbour launch/delivery yard connected to water and Tiny Boat progression;
- Milo: workshop court with complete frontage, workbench and material/repair zones.

R6 activity handlers, rewards, ownership arbitration and player state remain intact except for locator adapters where required.

## 14. NPC integration

Keep the R7 native character builder as the baseline unless the rebuilt-world screenshots expose a specific character defect.

NPC origins come from `R8VillageLayout` through `VillageActivityLocations`; characters stand naturally inside destinations; nameplates are reduced; prompts remain reachable; role props remain published-safe.

## 15. Mobile HUD reduction

Update existing UI rather than adding another framework:
- compact coins/level status;
- Today collapsed by default to a small quest affordance;
- compact Journal button;
- tiny DEV corner tag with exact `v0.7.4 · ART R8` identity;
- materially more world visible on phone.

No essential gameplay state is removed.

## 16. Runtime composition and legacy retirement

Active R8 order:
1. R8 layout/base gameplay anchors;
2. R8 coast/boundary data;
3. production cleanup;
4. R8 ground/roads/plaza;
5. authored R8 village/street composition;
6. authored R8 civic/home placement and direct fountain placement if retained;
7. authored R8 activity destinations;
8. portal/impossible-world/spawn systems;
9. services.

The active runtime does not call:
- `CoastBuilder.build`;
- `VillageGroundRebuildBuilder.apply`;
- `R6CivicPresentationBuilder.apply`;
- `R7WorldCompositionBuilder.apply`;
- `R7BuildingPolishBuilder.apply`;
- `R7ActivityPresentationBuilder.apply`.

Legacy files may remain for rollback/history but may not render simultaneously with R8.

## 17. Collision and traversal safety

Visible prefab geometry and authoritative movement safety are separate concerns.

- decorative prefab descendants are non-colliding unless intentional;
- ground/roads/shore own deliberate collision;
- hero prefabs may have designated collision shells;
- gameplay must not depend on arbitrary decorative descendants for safety;
- fences/walls have intentional gaps;
- prompts are not buried in collision;
- spawn, home entrance, plaza, activities, shore recovery and boat launch all have explicit safe standing surfaces;
- traversal recovery positions derive from R8 layout.

Contracts fail if safe-shore and ground heights drift, legacy coast slabs are active, or R7 map roots render alongside R8.

## 18. Release identity and implementation order

Release identity:
- version `0.7.4`;
- `ART R8`;
- `Structural World Rebuild`;
- artifact `TinyWorld-v0.7.4.rbxlx`.

Single free-only workflow remains authoritative.

Implementation/TDD order:
1. map authored asset tree into Rojo;
2. add `r8-models.json`, SHA/provenance validation and R8 source contract to create deliberate RED;
3. land a minimum architecture/street-kit asset set and prove Rojo builds the model files;
4. implement R8 layout/ground/coast and collision contracts;
5. replace home shells with authored home prefabs;
6. replace civic/activity structures with authored prefabs;
7. integrate NPC locations;
8. reduce HUD;
9. full exact-head verification;
10. merge exact reviewed head;
11. post-merge DEV publication and Roblox version verification.

## 19. Automated acceptance

At minimum:
- all existing 41+ Luau specs pass;
- analysis and StyLua pass;
- server/client runtime compile passes;
- R8 source contract passes;
- release/build/publish contracts pass;
- R5/R6 published-safe renderer contract remains intact;
- R6 activity reward/ownership/multiplayer safety remains intact;
- one free-only Actions workflow remains;
- exact PR head green;
- retained artifacts = 0.

R8-specific checks include:
- `default.project.json` maps the R8 model tree;
- `r8-models.json` validates and every listed SHA-256 matches the model file;
- required hero model files exist;
- required named anchors are present/validated;
- hero home/civic/activity code clones approved models instead of runtime-sculpting complete visible structures;
- `Main` uses R8 and not retired R6/R7 visual paths;
- one `R8VillageLayout` feeds WorldBuilder integration, ground/coast and activity locations;
- no legacy coplanar grass or hill-slope pattern is active;
- safe-shore and walkable ground share elevation authority;
- PlotService no longer applies R7 home charm overlay;
- five activity destinations use canonical locations;
- published EditableMesh remains forbidden.

## 20. Human acceptance

After DEV publication capture normal mobile published-client views of:
1. spawn/village centre;
2. residential lane/home entrance;
3. plaza/fountain;
4. Mara market;
5. Pip garden;
6. Finn dock;
7. Skye harbour;
8. Milo workshop;
9. shoreline while standing/walking at water edge;
10. ordinary HUD.

Human acceptance fails if any hero view shows:
- exploded/intersecting entrance geometry;
- avatar sinking;
- giant empty grass plane dominating composition;
- disconnected rectangular path patches;
- crude slab shoreline;
- old/new visual layers overlapping;
- a destination that reads as loose prototype Parts;
- a missing hero asset replaced by a primitive fallback;
- purple/checkerboard runtime corruption.

R8 is complete only after published-client evidence meets this bar.

## 21. Non-goals

R8 does not add major gameplay loops, new worlds, new vehicles, economy redesign, profile migration or LIVE publishing.

R8 also does not require a full Blender/DCC pipeline or Roblox cloud Packages. The immediate durable step is to separate authored visual assets from gameplay code while keeping GitHub/Rojo authoritative.