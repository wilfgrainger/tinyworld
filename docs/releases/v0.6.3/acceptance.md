# v0.6.3 Production Art & World Craft acceptance

**Release:** v0.6.3  
**Profile schema:** 11  
**Current visual revision:** ART R4 Production Asset Pivot  
**Status:** source/build green for the first ART R4 mesh candidate; exact-candidate Studio visual evidence required before visual acceptance.

## Release contract

- [x] canonical authority identifies v0.6.3 Production Art & World Craft;
- [x] schema remains 11 with no migration;
- [x] v0.6.2 gameplay/server-authority contracts remain intact;
- [x] v0.7.0 remains reserved for the family/girls review;
- [x] no fake Roblox asset ID, production credential or automatic LIVE publishing path is introduced;
- [x] ART R4 separates semantic gameplay roots from replaceable production visuals;
- [x] ART R4 DEV presentation uses true custom MeshPart geometry rather than visible hero `Part` recipes;
- [ ] exact ART R4 Studio screenshots pass the required route;
- [ ] device/performance rows pass or an explicit release exception is approved.

## Visual evidence history

### v0.6.2 post-merge evidence

Observed Studio result: **FAIL**.

The village read as a development/test map: slab-dominated buildings, cyan-panel windows, naked glowing practical lights, primitive market/civic geometry and broad green-board composition.

### v0.6.3 ART R1 / first corrective candidate

Observed Studio result: **FAIL**.

Additive craft improved source structure but kept too much legacy visual geometry. Civic roof planes overlapped, hero buildings remained rectangular masses, market structures still read as slabs, and the large-form composition remained weak.

### v0.6.3 ART R2

Observed Studio result: **FAIL**.

The shared roof/canopy geometry was corrected and candidate stamping improved, but the screenshots still read as a polished construction kit. Primitive visual language remained dominant.

### v0.6.3 ART R3

Observed Studio result: **FAIL**.

R3 replaced portal/fountain/nature/home mechanisms and fixed several large visual defects, but exact screenshots still exposed the ceiling of the runtime native-Part strategy: oversized street furniture, box-like trees/buildings/stalls, weak terrain integration and a home that still felt built from primitives rather than product art.

R3 also exposed a runtime `BasePart.Shape` crash against a `WedgePart`; that defect was fixed and regression-guarded. The architectural lesson is retained: broad visual post-processing increases runtime risk and must not be the finished hero-art strategy.

### v0.6.3 ART R4

Current candidate architecture: **production mesh/model art**.

R4 deliberately restarts the v0.6.3 visual implementation while preserving TinyWorld gameplay architecture.

- `art/specs/village-product-art.json` is the canonical original TinyWorld product-art source;
- nineteen production-art roles currently define 142 mesh components;
- `ProductionMeshFactory` creates actual polygon `EditableMesh` geometry and converts it to `MeshPart` instances for Studio/DEV;
- the same specification compiles deterministically to glTF 2.0 for permanent Roblox Model upload;
- `ProductionVisualService` mounts permanent approved Roblox assets when real manifest IDs exist, otherwise the same-spec MeshPart DEV preview is used;
- permanent asset IDs are never invented;
- the production manifest may truthfully remain ID-empty while the exact original art is being reviewed in Studio;
- R1-R3 civic/facade/portal/fountain/nature post-processing is no longer active in `Main.server.luau`;
- background landscape/ground composition remains only where it supports the product-art layer;
- gameplay prompts, collision foundations and server authority remain independent from visible art.

## ART R4 product-art source contract

Required current roles:

- Town Hall;
- starter home exterior;
- Village Shop;
- Home Store;
- Courier Depot;
- Workshop;
- two Market stalls;
- Daily Fountain;
- Clockwork portal family;
- three tree silhouettes;
- lantern;
- bench;
- planter;
- hedge;
- parcel/crate set;
- starter interior kit.

The current source vocabulary includes custom mesh bevelled forms, shaped roofs, tapered/frustum forms, faceted ellipsoids, arch segments, framed windows and curved water-arc meshes.

A required hero view still fails if the finished object reads as the primitive used to construct it before it reads as the intended object.

## Permanent asset publication boundary

`assets/manifests/assets.json` schema v3 is authoritative for Roblox-hosted production assets.

An asset record may enter only after Roblox returns a real positive asset ID and the record contains source SHA-256, owner, original-TinyWorld provenance, role, version, quality tier and DEV/LIVE approval state.

The manual uploader is credential-free in Git. Credentials come only from runtime environment variables and are never committed.

ART R4 Studio testing does **not** wait for permanent upload. The DEV preview uses true custom MeshParts generated from the same canonical product-art specification. Once an uploaded Model is approved, the semantic role switches to the hosted asset without changing gameplay authority.

## Current automated evidence

First fully green ART R4 implementation head before evidence-only documentation updates:

`873f061dcf017218516424164bfb27845d6811fc`

| Gate | Status | Evidence |
| --- | --- | --- |
| Pure Luau specs | PASS | 36 specs |
| Deterministic shared analysis | PASS | Luau analyser gate |
| ART R4 runtime-art spec syntax | PASS | `luau-compile` |
| StyLua | PASS | current source, with only canonical generated art-data mirror ignored via `.styluaignore` |
| Recursive runtime compile | PASS | server/client syntax compilation |
| Release authority | PASS | run 400 on implementation head |
| v0.6.3 source contract | PASS | ART R4 is current visual authority |
| ART R4 production asset contract | PASS | 19 roles / 142 components |
| ART R4 deterministic glTF generation | PASS | repeated builds produce identical tree digest |
| Production registry drift check | PASS | generated registry matches manifest |
| Repository/current-authority audit | PASS | ART R4 visual path required, R1-R3 active path forbidden |
| Shell build contract | PASS | v0.6.3 Rojo candidate contract |
| Release contract | PASS | manifest schema v3 and credential boundary |
| Rojo candidate build | PASS | run 500 on implementation head |

Automated PASS never satisfies the visual rows below.

## Candidate identity contract

Required visible Studio/DEV stamp:

`TinyWorld DEV · v0.6.3 · PR #8 · ART R4`

The stamp is small, non-interactive and sourced from shared `ReleaseInfo`.

Do not assess an R4 screenshot if the stamp identifies an older revision.

## Exact-candidate Studio views

Use `docs/v0.6.3-production-art-world-craft-test.md`.

| View | Status | Architecture | Lighting | Landscape/composition | Labels-off | Prototype reading | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Elevated village overview | NOT RUN | | | | | | ART R4 screenshot required |
| Civic centre at avatar height | NOT RUN | | | | | | ART R4 screenshot required |
| Starter/hero home exterior | NOT RUN | | | | | | ART R4 screenshot required |
| Town Hall + fountain approach | NOT RUN | | | | | | ART R4 screenshot required |
| Village Shop + Home Store | NOT RUN | | | | | | ART R4 screenshot required |
| Courier Depot + Workshop + Market | NOT RUN | | | | | | ART R4 screenshot required |
| Starter-home interior | NOT RUN | | | | | | ART R4 screenshot required |
| Phone normal HUD over world | NOT RUN | | | | | | ART R4 screenshot required |

A required view fails if `prototype reading` is FAIL even when every source/build gate is green.

## ART R4 visual acceptance bar

### First camera / civic centre

- Town Hall and fountain own the hierarchy;
- street lanterns support rather than dominate the scene;
- shops/courier/workshop/market are recognisable before labels;
- visible hero geometry reads as shaped product models rather than decorated blocks;
- broad green-board reading is materially reduced;
- no Roblox spawn marker is visible.

### Starter home

- exterior reads as a charming original TinyWorld cottage rather than a generated shell;
- roof, porch, recessed windows, chimney and side elevations form one coherent model language;
- interior is fully enclosed;
- living, kitchen, sleep, bathroom and storage zones are readable and traversable;
- furniture silhouettes are scaled around the Roblox avatar;
- interaction anchors remain functional even though they are visually hidden.

### Portal

- reads as a deliberate landmark with depth and a clear threshold;
- entry is unobstructed;
- no giant translucent rectangle/billboard composition dominates the player route;
- ordinary village remains visually grounded so portal fantasy has contrast.

### Nature and street furniture

- trees use irregular/tapered/faceted custom mesh silhouettes rather than sphere/cube canopies;
- fewer, better planters replace carpets of ball-on-stick flowers;
- pedestrian lamps remain avatar-scaled;
- benches/hedges/props support composition rather than becoming visual clutter.

## Hero-home interaction route

- [ ] exterior reads as a believable charming home;
- [ ] entrance/porch/window/light hierarchy is understandable without explanatory floating text;
- [ ] bedroom, kitchen, living, bathroom and storage zones are visually distinct enough to navigate;
- [ ] bedside lamp interaction remains functional through a hidden semantic anchor;
- [ ] kitchen/sink/shower/storage interactions retain existing behavior;
- [ ] furniture placement/persistence behavior is unchanged.

## Device/performance evidence

- [ ] phone portrait HUD/panels remain usable;
- [ ] phone landscape HUD/panels remain usable;
- [ ] effective touch targets remain >=44x44 pixels;
- [ ] controller routes used by the golden route remain usable;
- [ ] sustained mobile target >=30 FPS or recorded FAIL;
- [ ] memory target <=500 MB or recorded FAIL;
- [ ] useful spawn target <=15 seconds or recorded FAIL.

## Merge-ready rule

A green PR is source/build green only. v0.6.3 remains draft and unmerged while required ART R4 Studio/device views are NOT RUN or FAIL unless an explicit exception is separately approved.

No merge is authorised by this file.
