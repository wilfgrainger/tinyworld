# TinyWorld v0.6.3 Production Asset Pivot - design

**Status:** approved by the owner on 11 August 2026.  
**Release:** v0.6.3 Production Art & World Craft  
**Branch:** `release/v0.6.3-production-art-world-craft`  
**Visual revision:** ART R4  
**Profile schema:** 11, unchanged.  
**Gameplay scope:** frozen.  
**Implementation agent:** ChatGPT in the current conversation only. No Codex handoff.

## 1. Decision

v0.6.3 will stop treating runtime Roblox Part composition as the finished production-art medium for hero content.

The existing server-authoritative gameplay, persistence, interaction, UI and release architecture remains in place. The visual implementation changes from layered runtime craft passes to a production asset layer built from original TinyWorld-owned 3D models and meshes.

Hero content will use asset-backed Models/MeshParts wherever the visual tier requires it. Simple native Parts remain valid for invisible anchors, collision volumes, simple background scenery and secondary objects when they genuinely pass the visual bar.

This is a restart of the v0.6.3 art implementation, not a rewrite of TinyWorld.

## 2. Evidence behind the decision

ART R1-R3 Studio screenshots repeatedly exposed the same class of failure:

- building silhouettes still read as assembled rectangles even after facade and roof correction;
- lamps became oversized visual objects because primitive fixture geometry had to work too hard;
- trees moved from spheres to wedge/box masses rather than becoming convincing foliage;
- market stalls remained recognisable as slab recipes;
- the village still exposed the visual grammar of Roblox primitives before the intended noun;
- each additive pass fixed one symptom while revealing the next legacy/runtime-builder layer underneath;
- a runtime art pass introduced a `BasePart.Shape` crash against WedgePart terrain, demonstrating that broad post-processing also increases runtime risk.

The target-state blueprint already requires an approved production asset pipeline before v0.9 and explicitly states that TinyWorld must look intentional with labels hidden.

The existing asset pipeline contract already says native Part fallbacks are not a permanent excuse to avoid production art for hero objects.

The current production asset manifest is empty, so v0.6.3 has not yet actually crossed the production-asset boundary despite its release name.

## 3. Product-art outcome

When the player presses Play, the first normal camera view must look like a deliberately art-directed Roblox game.

The target is not photorealism. The target is a warm, tactile, stylised, family-friendly TinyWorld with:

- coherent low-poly silhouettes;
- bevelled/rounded/chamfered forms rather than raw cuboid dominance;
- readable architectural depth;
- soft material breakup;
- deliberately scaled props;
- attractive landscaping;
- distinct hero landmarks;
- restrained UI over a world worth looking at;
- fantasy portals that contrast with grounded village life.

The broad shorthand remains Brookhaven-level readability, Toca-style tactile warmth and Ready Player One-style wonder, expressed as original TinyWorld design rather than copied expression.

## 4. Core architecture

### 4.1 Preserve gameplay authority

The following remain authoritative and are not moved into asset code:

- economy and rewards;
- player progression;
- profile persistence;
- plot ownership;
- furniture ownership and final placement state;
- activity completion;
- courier routing;
- trade state;
- portal completion;
- server validation and RemoteGuard;
- DEV/LIVE environment separation.

### 4.2 Separate physical contracts from visual assets

Each hero destination becomes a semantic gameplay root with a replaceable visual child.

Example:

```text
TownHallRoot
|- interaction anchors
|- route/destination anchors
|- invisible/simple collision volumes where required
`- VisualRoot
   `- TinyWorld_TownHall_v1
```

The same pattern applies to homes, shops, courier depot, workshop, market, fountain, portals, furniture and vehicles.

Visual assets may be deleted, replaced or versioned without moving gameplay authority.

### 4.3 New production visual service

Introduce a focused `ProductionVisualService` or equivalent small module set that:

1. reads approved asset definitions;
2. loads approved Model assets through Roblox asset APIs;
3. caches one loaded template per asset ID;
4. clones templates into semantic `VisualRoot` containers;
5. applies deterministic transforms and approved variant colours/material settings;
6. removes or hides the legacy visual shell after the production asset is ready;
7. preserves existing prompt and service anchors;
8. fails visibly and safely in DEV if a required hero asset cannot load.

Do not turn this into a general framework.

## 5. Production asset source strategy

### 5.1 Original TinyWorld source art

Production models must be original TinyWorld-owned art.

For this release, source assets will be built from deterministic, repository-owned art specifications rather than copied Creator Store or reference-game assets.

The preferred source format is glTF 2.0 because Roblox Open Cloud accepts `.gltf`/`.glb` Model uploads and Studio supports glTF import.

The generator is an offline art compiler. It is not a generic runtime geometry builder. Each asset family has explicit authored profiles, proportions, contours, material assignments and mesh rules that are reviewed as product art.

### 5.2 Source-of-truth directories

Add:

```text
art/
  README.md
  specs/
    palette.json
    materials.json
    village-kit.json
    home-kit.json
    portal-kit.json
  generated/
    README.md
  previews/
    README.md

tools/art/
  build_asset_pack.py
  validate_asset_pack.py

scripts/
  upload-roblox-assets.py
  generate-production-asset-registry.py
```

The committed source of truth is the art specification plus generator code.

`art/generated/` is deterministic build output and is not committed apart from its explanatory README. `build_asset_pack.py` recreates the complete uploadable glTF pack locally or in CI. This prevents large generated blobs from becoming the editing surface while keeping regeneration reproducible.

The uploader always invokes or verifies a fresh deterministic generation before upload. CI runs the generator and validates stable metadata, bounds, counts and hashes from the same source specification.

### 5.3 Geometry principles

Meshes should use intentional low-poly forms rather than primitive substitution.

Use:

- bevelled/chamfered building edges;
- shaped roof profiles and eaves;
- recessed/inset window and door openings;
- tapered posts and legs;
- curved or faceted fountain basins;
- irregular foliage crowns;
- branch/trunk taper;
- cloth-like awning profiles;
- rounded furniture silhouettes;
- wheel/frame geometry that actually reads as a vehicle;
- portal arches with depth and layered profile.

Avoid:

- one cuboid per noun;
- giant signboards used to explain anonymous geometry;
- ball-on-stick flowers;
- cube-canopy trees;
- enormous lamp housings;
- slab market stalls;
- one-piece rectangular building shells with cosmetic trim as the only depth.

### 5.4 Material strategy

ART R4 should avoid depending on a large texture library.

Use a small original material palette first:

- warm painted plaster;
- timber and dark timber;
- slate/roof tile family;
- brick/stone;
- aged metal;
- glass;
- fabric/canvas;
- foliage;
- paving/stone;
- water.

Where texture maps are used, they are original TinyWorld source files and remain small/mobile-friendly. PBR is optional, not mandatory. Good silhouette and material hierarchy come before texture complexity.

## 6. Roblox asset publication pipeline

### 6.1 Open Cloud is the repeatable path

Roblox currently supports uploading Model assets from `.fbx`, `.gltf`, `.glb`, `.rbxm` and `.rbxmx` through the Open Cloud Assets API. A Model upload becomes a Roblox Model containing one or more MeshParts.

The repository will provide a credential-free uploader script. Credentials come only from environment variables or secret storage.

Required local environment variables:

```text
ROBLOX_OPEN_CLOUD_API_KEY
TINY_WORLD_ASSET_CREATOR_ID
TINY_WORLD_ASSET_CREATOR_TYPE=user|group
```

No key or credential is ever committed.

### 6.2 Upload behaviour

The upload tool must:

1. generate and validate the asset pack from committed specifications;
2. upload only explicitly selected assets;
3. use deterministic display names such as `TinyWorld_TownHall_v1`;
4. poll the returned operation until success/failure;
5. capture real Roblox asset IDs only after successful creation;
6. update `assets/manifests/assets.json` with provenance and approval state;
7. never invent or guess an ID;
8. preserve an audit trail of source specification hash, generated content hash and generator version;
9. stop on moderation/upload failure rather than falling back silently.

### 6.3 Studio fallback upload path

If Open Cloud credentials are not yet configured, Studio's importer remains a supported manual DEV path for the same freshly generated glTF files.

Manual import is a credential gate, not an excuse to change the source art. Any returned asset IDs must still be recorded in the canonical manifest before the asset becomes release-authoritative.

## 7. Asset manifest v3

Upgrade `assets/manifests/assets.json` to `schemaVersion: 3` and make it the release authority for production visuals.

Every production asset record must contain:

| Field | Requirement |
| --- | --- |
| `id` | stable semantic TinyWorld asset ID |
| `robloxAssetId` | real positive ID returned by Roblox upload/import |
| `owner` | TinyWorld owner/group identity |
| `source` | committed art specification or generated source relationship |
| `sourceSha256` | hash of the generated upload content |
| `specSha256` | hash of the authoritative art specification input |
| `licenseOrProvenance` | original TinyWorld ownership/provenance statement |
| `prefabRole` | semantic runtime role |
| `version` | positive asset version |
| `status` | asset quality/approval state |
| `devApproved` | explicit DEV approval boolean |
| `liveApproved` | explicit LIVE approval boolean |
| `qualityTier` | hero, interactive-supporting or background |
| `triangleCount` | validated generated triangle count |
| `materialCount` | validated material-slot count |
| `expectedBounds` | expected asset bounds for runtime validation |

The manifest must never contain invented IDs.

A generated Luau registry consumed by runtime code is derived from this manifest and checked for drift in CI.

## 8. ART R4 hero asset set

### 8.1 P0 assets required before the next visual candidate

The next candidate must not wait for every future TinyWorld asset. It requires enough production art to transform the eight-view acceptance route.

P0 hero set:

1. `TinyWorld_TownHall_v1`
2. `TinyWorld_StarterHome_v1`
3. `TinyWorld_VillageShop_v1`
4. `TinyWorld_HomeStore_v1`
5. `TinyWorld_CourierDepot_v1`
6. `TinyWorld_Workshop_v1`
7. `TinyWorld_MarketStall_A_v1`
8. `TinyWorld_MarketStall_B_v1`
9. `TinyWorld_Fountain_v1`
10. `TinyWorld_Portal_Frame_v1`
11. `TinyWorld_Portal_Clockwork_Core_v1`
12. `TinyWorld_Tree_A_v1`
13. `TinyWorld_Tree_B_v1`
14. `TinyWorld_Tree_C_v1`
15. `TinyWorld_Lantern_v1`
16. `TinyWorld_Bench_v1`
17. `TinyWorld_Planter_v1`
18. `TinyWorld_HedgeSegment_v1`
19. `TinyWorld_ParcelCrateSet_v1`
20. `TinyWorld_StarterInteriorKit_v1`

The starter interior kit may be multiple Model assets behind one semantic kit ID if modularity improves reuse. The required visible categories are:

- sofa;
- coffee table;
- bed;
- bedside table;
- lamp;
- wardrobe;
- kitchen cabinet/counter;
- cooker;
- sink;
- dining table/chairs;
- bath/shower;
- shelving/storage;
- rug/curtain/decor group.

### 8.2 P1 after the first ART R4 screenshot pass

Only after the first production-asset candidate is observed:

- primary bike;
- additional home exterior variants;
- additional market stock;
- secondary trees/shrubs/flowers;
- richer portal-world props;
- distant/background asset variants.

Do not pre-build P1 art if the P0 screenshot route exposes a more important visual problem.

## 9. Building composition

Production art is not one giant mesh if modular composition gives better reuse, culling or colour variation.

A hero building may be a Model containing several MeshParts, for example:

```text
TinyWorld_TownHall_v1
|- Body
|- Roof
|- ClockTower
|- Portico
|- WindowSet
|- DoorSet
|- Trim
`- DecorativeProps
```

The final asset must still behave as one visual unit and arrive with consistent pivot/bounds conventions.

## 10. Pivots, scale and coordinate contracts

All production models use a documented convention:

- Y-up Roblox-compatible orientation;
- front faces +Z in TinyWorld builder coordinates unless an existing semantic root requires another documented convention;
- model pivot at ground-centre for buildings and large props;
- model pivot at physical interaction centre for small props only when appropriate;
- one source unit maps consistently to one Roblox stud;
- expected bounds recorded in the manifest or art spec;
- no hidden giant geometry or off-origin vertices.

Runtime adapters position assets from semantic anchors rather than duplicating hard-coded world coordinates inside the asset itself.

## 11. Collision and interaction

Hero visual meshes do not automatically become gameplay collision.

Default policy:

- production MeshParts: `CanTouch=false`, `CanQuery=false` unless explicitly needed;
- visual collision disabled for complex shapes where invisible/simple collision shells already exist;
- gameplay anchors remain simple Parts with clear ownership;
- prompts stay on semantic anchors, not imported model scripts;
- imported models contain no executable scripts.

This keeps the server-authoritative and security model boring and auditable.

## 12. Runtime loading and failure behaviour

Use `AssetService:LoadAssetAsync()` for approved creator-owned Model assets.

Requirements:

- load on the server;
- wrap every load in `pcall`;
- cache loaded templates;
- clone templates after successful load;
- strip or reject unexpected scripts defensively even though uploaded TinyWorld models should contain none;
- validate expected Model/MeshPart content and bounds before use;
- emit a clear DEV error when a required production asset fails;
- do not silently present a known-bad ART R1-R3 hero shell and call the candidate production-ready.

A fallback may exist for engineering continuity, but a required hero fallback sets `TinyWorldProductionArtDegraded=true` on the world root and fails the ART R4 visual candidate.

## 13. Retiring ART R1-R3 layering

Once a production asset family replaces a hero visual, the corresponding runtime craft pass must stop producing visible competing geometry.

The goal is to simplify `Main.server.luau`, not add ART R4 as another post-processing step.

Target startup order:

```text
1. WorldBuilder.build() creates semantic roots, anchors and safe physical baseline.
2. ProductionVisualService.preload() loads/caches approved village production templates.
3. ProductionVisualService.applyVillage(world) installs home/civic/landscape hero visuals and hides replaced legacy visuals.
4. ImpossibleWorldBuilder.extend(world) creates existing impossible-world semantic/runtime content.
5. PortalMechanicBuilder.extend(world) creates existing portal mechanic anchors.
6. ProductionVisualService.applyPortals(world) installs the approved village-side portal visual family around those anchors.
7. Runtime services start.
```

ART R4 must reduce the visible builder stack. A hero asset may not be overlaid on top of still-visible ART R1-R3 hero geometry.

Legacy builders may remain temporarily only for:

- simple physical foundations;
- fallback collision;
- non-hero background content;
- semantic anchor creation.

The following R1-R3 modules must be reviewed for deletion, shrinking or conversion to non-visible support responsibilities:

- `CivicCraftBuilder`
- `CivicHeroRebuildBuilder`
- `CivicFacadePolishBuilder`
- `VillageArrivalPolishBuilder`
- `HeroFountainBuilder`
- `HeroPortalBuilder`
- `OrganicNatureBuilder`
- visual portions of `ArchitecturalDetailBuilder`
- visual portions of `HomePrefabBuilder`
- visual portions of `HomeStoreDestinationBuilder`

Do not delete semantic or interaction behaviour by filename association. Remove only after the production replacement preserves the contract.

## 14. Starter home redesign

The starter home becomes the first complete hero environment and quality benchmark.

Exterior requirements:

- cottage-like but original TinyWorld silhouette;
- believable roof mass with modest eaves;
- visible foundation/base;
- recessed framed windows;
- clear front door and porch;
- chimney integrated with roof;
- warm practical lantern at avatar scale;
- small garden/path/planter composition;
- no giant blank side wall in common player routes.

Interior requirements:

- fully enclosed shell with no sky leaks;
- camera-safe ceiling and wall heights;
- clear living, kitchen, sleep, bathroom and storage zones;
- generous traversal path around an avatar;
- furniture scale tested against the normal Roblox avatar;
- coherent warm lighting;
- no overlapping furniture/camera trap;
- interaction targets preserved through hidden/simple anchors;
- the player should want to decorate and return to the home.

## 15. Civic square redesign

The visual hierarchy is fixed:

1. Town Hall and fountain form the centre;
2. shops frame ordinary-life activity;
3. courier/workshop/market create useful peripheral destinations;
4. portal mystery is visible but does not visually shout over the grounded village.

Street furniture supports landmarks rather than competing with them.

Lamp scale target: approximately avatar shoulder-to-head-height fixture centres for pedestrian lamps unless a larger civic fixture has a clear architectural reason.

The square needs fewer, better props rather than more simultaneous objects.

## 16. Landscape and foliage

ART R4 replaces the runtime primitive-to-primitive nature conversion.

Use a small mesh kit with deliberate variation:

- 3 primary tree silhouettes;
- 2 shrub/hedge families;
- 2-3 flower/ground-cover clusters;
- rocks/retaining pieces only where they strengthen neighbourhood identity.

Use rotation/scale/material tint variation within restrained ranges to avoid repetition without generating visual noise.

The underlying physical ground may remain simple. Production visual ground treatment should use landscape composition, material zones and bounded elevation changes rather than a single exposed baseplate field.

## 17. Performance budgets

Product art must remain mobile-first.

Initial ART R4 budgets:

- hero building visual: target <= 25k triangles, hard review at > 40k;
- repeated tree: target <= 2.5k triangles;
- repeated street prop: target <= 1.5k triangles;
- furniture item: target <= 2.5k triangles, lower for repeated sets;
- material slots: keep small and reusable;
- texture resolution: default 256-512 for ordinary repeated assets, larger only with evidence;
- use `RenderFidelity.Automatic` where appropriate;
- visual collision disabled unless needed;
- no per-frame mesh generation;
- no published runtime dependency on EditableMesh for static village art.

These are starting budgets and must be adjusted from measured Studio/device evidence rather than defended as doctrine.

## 18. Lighting

Do not tune lighting to disguise weak geometry.

After the production assets are in place:

- readable daylight;
- soft shadows;
- slightly warm exposure/colour balance;
- practical lanterns with bounded PointLights;
- warm interior window cues;
- restrained bloom;
- stronger glow reserved for portals/impossible worlds.

## 19. Version identity

Keep the current top-left DEV stamp.

ART R4 screenshots must visibly show:

```text
TinyWorld DEV · v0.6.3 · PR #8 · ART R4
```

If multiple R4 asset iterations are necessary, extend the art revision rather than losing exact-candidate identity, for example `ART R4.1`.

## 20. Testing and evidence

### 20.1 Source/build gates

CI must prove:

- asset manifest schema and provenance fields;
- no invented IDs;
- generated registry matches manifest;
- deterministic art-pack generation/validation succeeds;
- required P0 asset IDs exist before production-art mode can be release-ready;
- production visual loader compiles;
- gameplay tests remain green;
- StyLua remains green;
- runtime Luau compile remains green;
- Rojo build remains green;
- release authority remains green;
- legacy visible hero passes are not simultaneously active after replacement.

### 20.2 Runtime failure tests

Add deterministic/source tests for:

- missing asset entry;
- zero/invalid asset ID;
- failed load path;
- unexpected loaded hierarchy;
- fallback/degraded flag;
- template cache behaviour where testable without Roblox services.

### 20.3 Studio visual route

The same eight-view v0.6.3 route remains authoritative:

1. elevated village overview;
2. civic centre at avatar height;
3. starter-home exterior;
4. Town Hall/fountain approach;
5. Village Shop + Home Store;
6. Courier Depot + Workshop + Market;
7. starter-home interior;
8. normal HUD over the world.

The first five screenshots additionally used during ART R3 remain direct failure evidence and should be compared qualitatively.

### 20.4 Product-art pass rule

A screenshot passes only if the dominant first impression is the intended place/object, not the primitive or construction technique used to build it.

A required hero view fails if a reasonable reviewer would describe it as:

- prototype;
- construction kit;
- blockout;
- decorated rectangles;
- test map;
- placeholder art.

No amount of green CI can override that visual result.

## 21. Asset ownership, provenance and IP

Every ART R4 asset is original TinyWorld expression unless a separately approved asset has explicit legal provenance.

Do not copy models, textures, layouts or distinctive expression from reference games or films.

Do not use random Creator Store production assets merely to accelerate the screenshot.

If any third-party input is ever introduced, record source, licence, owner and modification history before use.

## 22. Security

Uploaded models are data/presentation only.

- no scripts in production art assets;
- runtime-loaded models are treated as untrusted data and descendants are validated before cloning into the world;
- no asset can own economy/progression logic;
- no API key in source, place, plugin or asset;
- asset upload is explicit and auditable;
- third-party asset loading remains disabled for normal TinyWorld production art.

## 23. Delivery sequence

Implementation proceeds in this order:

1. add ART R4 source/manifest contracts and CI guard;
2. add deterministic art-source generator and validation tooling;
3. build the P0 modular environment/prop asset pack;
4. add safe upload workflow and manifest update path;
5. generate the runtime asset registry;
6. add production visual loader/adapter;
7. replace Town Hall + fountain + starter-home exterior first;
8. replace Village Shop + Home Store;
9. replace Courier + Workshop + Market;
10. replace portal village-side landmarks;
11. replace core trees/lamps/benches/planters;
12. replace starter-home interior kit;
13. remove/deactivate competing R1-R3 visible hero passes;
14. run full source/build verification;
15. take ART R4 Studio screenshots;
16. only then decide the next bounded art correction.

## 24. Human/credential gate

The implementation can create all source art, tooling, upload automation, runtime adapters and validation without Roblox credentials.

Creating the real Roblox-hosted Model IDs requires one of:

- a local Open Cloud API key supplied outside Git;
- explicit Studio import/upload using the logged-in creator.

This is the only expected external credential/manual gate in the production-asset pivot.

The codebase must be ready before that gate so the manual action is narrowly: generate, upload, record returned IDs, resync, play.

## 25. Acceptance

ART R4 is accepted only when:

- the production manifest contains real approved DEV asset IDs for the required P0 set;
- runtime play uses the production asset-backed visuals;
- no required hero view is being visually supplied by a known R1-R3 primitive fallback;
- all automated gates are green on the exact candidate;
- Studio produces the eight required screenshots;
- the village no longer reads as a procedural construction demo;
- the starter home looks like a desirable place to own and decorate;
- Town Hall/fountain/shop/market/portal hierarchy is immediately readable;
- labels are not required to identify hero objects;
- the DEV badge proves the exact ART R4 candidate;
- no merge occurs until the owner explicitly approves the visual result.

## 26. Non-goals

ART R4 does not add:

- new careers;
- new economy;
- new portal mechanics;
- new trade functionality;
- monetisation;
- schema migration;
- new UI framework;
- NPC simulation framework;
- automatic LIVE publishing;
- a dependency on Codex;
- a dependency on runtime AI generation.

The release fixes the art layer so the existing game finally presents itself as the product it already intends to be.
