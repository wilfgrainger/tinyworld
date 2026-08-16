# TinyWorld v0.6.3 Production Art & World Craft Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the ordinary TinyWorld village visibly approach the approved concept-board art language by replacing slabby hero architecture, naked glowing practical lights, cyan pasted-on windows and sparse test-map composition while preserving v0.6.2 gameplay authority.

**Architecture:** Keep services/gameplay state unchanged. Introduce two focused visual helpers, `ArchitecturalDetailBuilder` for reusable production-intentional building/fixture elements and `VillageLandscapeBuilder` for deterministic clustered landscaping/street composition, then migrate the existing home/civic builders behind the same semantic anchors. Use release/source guards to reject the exact v0.6.2 failure recipes, while Studio screenshots remain the only authority for whether the result actually looks good.

**Tech Stack:** Roblox Luau, Rojo 7.7.0, Luau 0.732 CI, StyLua 2.5.2, Rokit 1.2.0, schema 11.

## Global Constraints

- Release is exactly `0.6.3` named `Production Art & World Craft`.
- Profile schema remains `11`; no migration.
- Preserve all v0.6.2 server-authoritative gameplay, economy, trade, visit, home-placement and activity contracts.
- No new profession, economy, portal world/mechanic, trading capability, monetisation system or NPC framework.
- No Knit, React/Roact, Wally, ECS or other runtime framework/dependency.
- No invented Roblox asset IDs or production credentials.
- Preserve the player's Roblox avatar; no primitive TinyWorld character fallback.
- No large ordinary-world always-on-top information walls.
- No Part-built ambient birds/cats/butterflies presented as finished characters.
- Ordinary practical lights require a physical fixture plus bounded light; a naked Neon sphere is not an ordinary lamp.
- Hero homes/civic buildings may not use one oversized flat roof slab as their dominant silhouette.
- Windows require frame/depth/material hierarchy and may not read as flat bright-cyan pasted rectangles.
- The concept board is reference-only and never counts as release evidence.
- v0.7.0 remains reserved for the family/girls review.

---

### Task 1: Move documentation and release authority to v0.6.3

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `docs/README.md`
- Modify: `docs/progress.md`
- Modify: `docs/product/vision.md`
- Modify: `docs/product/art-direction.md`
- Modify: `docs/product/village.md`
- Modify: `docs/product/homes.md`
- Modify: `docs/product/core-loop.md`
- Modify: `docs/product/ui-ux.md`
- Modify: `docs/product/content-catalog.md`
- Modify: `docs/product/target-state-v1.md`
- Modify: `docs/engineering/architecture.md`
- Modify: `docs/engineering/data-model.md`
- Modify: `docs/engineering/asset-pipeline.md`
- Modify: `docs/engineering/production-engineering.md`
- Modify: `docs/engineering/tooling.md`
- Modify: `docs/engineering/world-content-pipeline.md`
- Modify: `docs/quality/definition-of-done.md`
- Modify: `docs/quality/visual-quality-bar.md`
- Modify: `docs/quality/playtesting.md`
- Modify: `docs/roadmap/roadmap.md`
- Create: `docs/roadmap/v0.6.3-production-art-world-craft.md`
- Modify: `docs/roadmap/v0.6.2-village-life-visual-craft.md`
- Modify: `docs/roadmap/v0.7.0-village-life.md`
- Modify: `docs/roadmap/v0.8.0-impossible-worlds.md`
- Modify: `docs/roadmap/v0.9.0-production-beta.md`
- Modify: `docs/roadmap/v1.0.0-launch.md`
- Create: `docs/releases/v0.6.3/acceptance.md`
- Modify: `docs/releases/v0.6.2/acceptance.md`
- Create: `docs/v0.6.3-production-art-world-craft-test.md`
- Modify: `config/release.json`
- Modify: `.github/workflows/rojo-build.yml`
- Modify: `.github/workflows/release-authority.yml`
- Modify: `scripts/verify-release-contract.sh`
- Modify: `tests/build-contract.sh`
- Modify: `tests/build-contract.ps1`
- Modify: `tests/verify-release-authority.sh`
- Create: `tests/verify-v0.6.3-source-contract.sh`
- Create: `tests/verify-v0.6.3-repository-audit.sh`

**Interfaces:**
- Canonical release metadata becomes `0.6.3 / Production Art & World Craft / schema 11 / TinyWorld-v0.6.3.rbxlx`.
- Durable docs stop embedding obsolete “v0.6.1 current” / “v0.6.2 current” wording.
- v0.6.2 acceptance records the post-merge screenshot review without changing its historical automated evidence.

- [ ] **Step 1: Create the v0.6.3 source/repository guards first so CI is deliberately RED.**

The source contract must initially require files/mechanisms not yet implemented:

```bash
grep -Fq '"productVersion": "0.6.3"' config/release.json
grep -Fq 'ArchitecturalDetailBuilder' src/server/HomePrefabBuilder.luau
grep -Fq 'ArchitecturalDetailBuilder' src/server/HomeStoreDestinationBuilder.luau
grep -Fq 'VillageLandscapeBuilder' src/server/WorldBuilder.luau
! grep -Eq 'PorchLamp.*Enum.Material.Neon|PorchLamp.*Enum.PartType.Ball' src/server/HomePrefabBuilder.luau
! grep -Eq 'BirdAmbient|ButterflyAmbient|makeBirdHook|makeButterflyHook' src/server/VillageSceneryBuilder.luau
```

The guard must scope ordinary-world prohibitions to ordinary-world files so portal/fantasy glow remains legal.

- [ ] **Step 2: Commit the failing guard and observe Release Authority RED for the expected missing v0.6.3 authority/art mechanisms.**

- [ ] **Step 3: Update all current authority and durable docs.**

Durable docs should state durable rules rather than “v0.6.1 currently...”. Historical release docs remain historical.

- [ ] **Step 4: Record v0.6.2 post-merge screenshot evidence honestly.**

Add a section to v0.6.2 acceptance:

```text
Post-merge visual review: 11 August 2026
Avatar primitive-add-on check: PASS
Compact normal HUD check: PASS
Elevated village production-art/composition: FAIL
Civic-centre production-art/composition: FAIL
Starter-home exterior production-art/composition: FAIL
Reason: slab roofs, pasted cyan windows, naked glowing practical lights, flat/grid-like spatial composition and primitive hero geometry remain visible.
```

Do not mark unobserved interaction/device rows PASS.

- [ ] **Step 5: Move release/build authority to 0.6.3 and run all guards until authority/build metadata is green except for the intentionally missing runtime art requirements.**

Commit message:

```text
chore: establish v0.6.3 production art authority
```

---

### Task 2: Add reusable architectural craft primitives

**Files:**
- Create: `src/server/ArchitecturalDetailBuilder.luau`
- Modify: `tests/verify-v0.6.3-source-contract.sh`

**Interfaces:**
- `ArchitecturalDetailBuilder.addPitchedRoof(parent, spec) -> Model`
- `ArchitecturalDetailBuilder.addWindow(parent, spec) -> Model`
- `ArchitecturalDetailBuilder.addDoor(parent, spec) -> Model`
- `ArchitecturalDetailBuilder.addPorch(parent, spec) -> Model`
- `ArchitecturalDetailBuilder.addChimney(parent, spec) -> Model`
- `ArchitecturalDetailBuilder.addLantern(parent, spec) -> Model`
- Decorative descendants are anchored/non-touch/non-query unless the caller explicitly supplies/creates an interaction anchor.

- [ ] **Step 1: Extend the source guard to require the helper and reject naked ordinary lamp spheres/slab-only hero roofs. Verify RED.**

- [ ] **Step 2: Implement a small helper, not an art framework.**

`addLantern` must create recognisable housing/frame plus a small emissive pane/core and `PointLight` with bounded values such as:

```lua
light.Brightness = 0.65
light.Range = 11
light.Shadows = false
```

`addWindow` uses restrained glass colour (paper/ink/sky mixed through an explicit theme colour), frame, sill and mullion/depth parts rather than one bright cyan pane.

`addPitchedRoof` creates two sloped roof planes/wedges, ridge and optional gable trim with eaves no more than a small fraction of building width/depth. It must not hide another giant flat slab below it.

- [ ] **Step 3: Run StyLua/recursive compile/source guard and commit.**

Commit message:

```text
feat: add production architectural detail primitives
```

---

### Task 3: Rebuild the residential hero-home exterior

**Files:**
- Modify: `src/server/HomePrefabBuilder.luau`
- Modify: `src/server/VillageSceneryBuilder.luau` home ambient binding if window/light names change
- Modify: `tests/verify-v0.6.3-source-contract.sh`

**Interfaces:**
- `HomePrefabBuilder.buildShell(...)` returns the same semantic fields (`model`, `facade`, `gable`, `frontDoor`, `frontDoorAnchor`, `porch`, `porchAnchor`, `gardenAnchor`, `homeCharmDisplay`, `namePost`).
- Existing plot/home services remain unchanged.

- [ ] **Step 1: Make the source guard reject the old roof/light/window recipes and verify RED.**

Reject in `HomePrefabBuilder.luau`:

```text
"Roof" + Vector3.new(width + 2, 1, depth + 2)
"UpperRoof" as a single rectangular slab
HouseWindowGlow using Neon as pasted facade rectangle
PorchLamp Ball + Neon
HomeLantern Ball + Neon
```

- [ ] **Step 2: Rebuild the shell with `ArchitecturalDetailBuilder`.**

Required visual structure:

- pitched/layered roof with believable eaves;
- optional tier-specific cross-gable/upper-storey roof rather than slab;
- framed windows with restrained glass and warm interior light where budgeted;
- physically distinct door/frame/threshold;
- porch with columns/canopy/steps;
- brick/stone foundation/plinth;
- chimney with cap;
- proper wall-mounted lantern;
- tier/theme accent via trim/planter/awning rather than large flat colour bar;
- front garden relationship retained.

- [ ] **Step 3: Preserve all semantic anchors and plot rebuild behavior.**

- [ ] **Step 4: Run compile/source tests and commit.**

Commit message:

```text
feat: rebuild hero home exterior
```

---

### Task 4: Rebuild Home Store and civic architecture behind existing anchors

**Files:**
- Modify: `src/server/HomeStoreDestinationBuilder.luau`
- Modify: `src/server/AuthoredPrefabBuilder.luau`
- Modify: `tests/verify-v0.6.3-source-contract.sh`

**Interfaces:**
- Home Store still returns/supplies the same supply/style/decor prompts to `world`.
- Town Hall still returns contribution and noticeboard anchors.
- Courier Depot still returns pickup/delivery anchors.
- Village Shop, Workshop and Market retain service-facing anchors/status surfaces.

- [ ] **Step 1: Guard the known civic failures and verify RED.**

Require:

- Home Store uses `ArchitecturalDetailBuilder.addPitchedRoof` and `addWindow`;
- Village Shop/Town Hall/Courier/Workshop each contain layered roof/facade/entrance treatment;
- ordinary civic source contains no `Material.Neon` Ball named as Lamp/Lantern;
- Market platform/awning is broken into authored stall cluster rather than one giant monolithic canopy being the primary silhouette.

- [ ] **Step 2: Rebuild Home Store as a cosy furniture showroom.**

Visual requirements:

- pitched or stepped roof;
- framed shop windows;
- inset doorway;
- supported awning;
- exterior furniture vignette;
- warm fixture lights;
- planter/homeware clusters;
- existing supply/style/gallery anchors moved with the displays.

- [ ] **Step 3: Improve Town Hall.**

Keep the strong clock-tower identity but add entrance portico/columns, window depth, roof/cornice hierarchy, civic planting and proper lantern fixtures.

- [ ] **Step 4: Improve Village Shop.**

Keep a distinct shop roof/awning, improve entrance, framed windows, visible stock/crates and practical lighting. Remove any duplicate Home Store visual affordances left from the historical shared-shop implementation when they no longer own live prompts.

- [ ] **Step 5: Improve Courier Depot and Workshop.**

Courier: parcel racks, loading canopy, handcart, framed building/open loading area, warm practical fixtures.

Workshop: proper garage opening/frame, asymmetric pitched/shed roof, workbench/tool/vehicle context, restrained industrial lighting.

- [ ] **Step 6: Improve Market / Trading Post.**

Use multiple smaller stall/canopy/crate/table groups and coherent circulation instead of one oversized table/awning block dominating the scene. Keep trading-side anchors/status surface unchanged.

- [ ] **Step 7: Run compile/source tests and commit.**

Commit message:

```text
feat: rebuild civic hero destinations
```

---

### Task 5: Replace practical glowing spheres and unfinished ambient creatures across the village

**Files:**
- Modify: `src/server/WorldBuilder.luau`
- Modify: `src/server/VillageSceneryBuilder.luau`
- Modify: `src/server/HomeService.luau`
- Modify: `tests/verify-v0.6.3-source-contract.sh`

**Interfaces:**
- Existing prompt/interaction contracts unchanged.
- Existing ambient-motion client remains available for foliage/water hooks only.

- [ ] **Step 1: Source guard scans all ordinary-village files for known naked practical-light sphere patterns and Part-built ambient actors. Verify RED.**

- [ ] **Step 2: Replace `WorldBuilder.makeLantern` and `VillageSceneryBuilder.makeLantern` with `ArchitecturalDetailBuilder.addLantern`.**

- [ ] **Step 3: Replace home bedside practical lamp presentation with a fixture-shaped lamp and bounded `PointLight`; preserve `LampToggle` target semantics.**

- [ ] **Step 4: Delete Part-built `BirdAmbient` and `ButterflyAmbient` creation from `VillageSceneryBuilder`.**

Keep foliage sway/water highlights where visually suitable. Do not substitute another primitive creature.

- [ ] **Step 5: Run source guard/compile and commit.**

Commit message:

```text
fix: remove ordinary-world prototype glow and creature fallback
```

---

### Task 6: Recompose the village landscape and neighbourhoods

**Files:**
- Create: `src/server/VillageLandscapeBuilder.luau`
- Modify: `src/server/WorldBuilder.luau`
- Modify: `src/server/VillageSceneryBuilder.luau`
- Modify: `src/shared/VillageCompositionRules.luau`
- Modify: `src/shared/VisualBudgetRules.luau` only if the existing bounded budget cannot represent the approved cluster count
- Modify: `tests/VillageComposition.spec.luau`
- Modify: `tests/VisualBudgetRules.spec.luau` only if budget changes

**Interfaces:**
- `VillageLandscapeBuilder.build(parent, layout) -> { civic = Model, neighbourhoods = {[string]: Model} }`
- It consumes deterministic layout/art seed and never owns gameplay state.
- Existing plot coordinates stay stable unless a tested composition change proves movement safe; prefer filling/framing space rather than breaking plot ownership/persistence assumptions.

- [ ] **Step 1: Add failing deterministic tests for the upgraded composition manifest.**

Require each neighbourhood to declare a distinct cluster language:

```lua
MeadowLane = { stream=true, bridge=true, cottageGarden=true, flowerMeadow=true }
HarbourRow = { retainingWall=true, dockClutter=true, coastalPlanting=true }
WoodlandRise = { canopy=true, rockClusters=true, narrowPath=true, woodlandFence=true }
OrchardEnd = { orchard=true, vegetableBeds=true, nursery=true, terrace=true }
```

Require civic composition flags for fountain plaza, planted edges, seating, lamps and framed approaches.

- [ ] **Step 2: Verify tests RED.**

- [ ] **Step 3: Implement deterministic clustered landscape composition.**

Focus detail into player routes:

- civic square edges and approaches;
- home approach/plot fronts;
- neighbourhood connecting paths;
- stream/bridge/woodland/orchard landmarks.

Avoid evenly scattering decorations across the entire world.

- [ ] **Step 4: Add segmented/curved approach paths and planted edges that visually connect the civic center to neighbourhoods without changing service anchors.**

- [ ] **Step 5: Add low berms/terraces/hedge/fence groups to break the giant-plane silhouette while preserving safe walkable routes.**

- [ ] **Step 6: Run unit/static/build tests and commit.**

Commit message:

```text
feat: recompose village landscape and neighbourhood identity
```

---

### Task 7: Raise hero-home interior craft without changing home gameplay

**Files:**
- Modify: `src/server/HomeService.luau`
- Modify: `src/server/FurniturePrefabBuilder.luau` only for priority objects actually visible on the golden route
- Modify: `tests/verify-v0.6.3-source-contract.sh`

**Interfaces:**
- Existing home item IDs/prompts/action IDs remain unchanged.
- `LampToggle`, `KitchenUse`, `FridgeToggle`, `SinkUse`, `ShowerUse`, `StorageView`, `PottingUse` retain existing authoritative/interaction semantics.

- [ ] **Step 1: Guard the priority interior visual failures and verify RED.**

At minimum reject naked Ball+Neon bedside lamp and require room-light/furniture-cluster art roles.

- [ ] **Step 2: Improve the starter-home room composition.**

- bedroom: bed + bedside table/lamp + rug + shelf/mirror cluster;
- kitchen: counter/cooker/sink/fridge + table/food + warmer material hierarchy;
- living: sofa/table/rug + lamp/shelf or equivalent focal cluster;
- bathroom: recognisable bath/shower/sink zone;
- storage: chest/cabinet/shelf cluster;
- garden: potting/planter relationship.

Use bounded part count and preserve traversal.

- [ ] **Step 3: Give physical verbs visible feedback through the existing target parts/PointLights/material changes, not larger UI.**

- [ ] **Step 4: Run compile/source tests and commit.**

Commit message:

```text
feat: raise starter home interior craft
```

---

### Task 8: Tune ordinary-village lighting after geometry is correct

**Files:**
- Modify: `src/server/VisualTheme.luau`
- Modify: `src/shared/VisualPalette.luau` only if the existing palette lacks a restrained glass/light colour
- Modify: `tests/VisualQualityRules.spec.luau` or focused source guard where appropriate

**Interfaces:**
- Preserve existing palette names consumed by UI/gameplay unless aliases are intentionally retained.

- [ ] **Step 1: Add/adjust deterministic visual constants only after all geometry changes compile.**

Targets:

- readable soft daylight;
- slightly warmer practicals;
- reduced fluorescent/cyan window feel;
- restrained Bloom;
- enough shadows/contrast to show roof/facade depth;
- portal glow still clearly stronger than ordinary village glow.

- [ ] **Step 2: Run tests/build and commit.**

Commit message:

```text
fix: tune ordinary village lighting hierarchy
```

---

### Task 9: Final source audit, exact build evidence, draft PR and Studio handoff

**Files:**
- Modify: `docs/releases/v0.6.3/acceptance.md`
- Modify: `docs/progress.md`
- Modify: PR body

**Interfaces:**
- Required workflows: Luau tests, Release authority, Rojo build.
- Final artifact: `TinyWorld-v0.6.3.rbxlx` plus `dist/release.json`.

- [ ] **Step 1: Run the complete repository/current-authority audit.**

Must reject:

- stale current v0.6.1/v0.6.2 authority in durable docs;
- active `TinyWorld-v0.6.2.rbxlx` build contracts;
- ordinary-village naked Neon lamp spheres;
- Part-built ambient birds/cats/butterflies;
- giant known home/Home Store slab roof recipes;
- write-enabled temporary workflows;
- fake asset IDs/credentials/publishing actions.

- [ ] **Step 2: Push the final source candidate and wait for all required workflows.**

Required Luau workflow:

```text
unit specs
shared analysis
StyLua
recursive server/client compile
```

Required authority workflow:

```text
canonical release authority
v0.6.3 source contract
repository/current-authority audit
```

Required Rojo workflow:

```text
shell build contract
release contract
TinyWorld-v0.6.3.rbxlx
traceability manifest/artifact upload
```

- [ ] **Step 3: Fix every red gate at root cause until exact-head automated checks are green.**

- [ ] **Step 4: Record exact source SHA, run IDs, artifact ID, archive digest and inner `.rbxlx` SHA-256 in acceptance.**

- [ ] **Step 5: Open/update draft PR titled `feat: TinyWorld v0.6.3 Production Art & World Craft`.**

PR body must explicitly distinguish:

```text
Automated/source: PASS on exact head
Studio visual comparison: NOT RUN until exact candidate is opened
Before baseline: user-provided v0.6.2 screenshots, 11 Aug 2026
Target reference: approved concept board, reference-only
```

- [ ] **Step 6: Deliver the exact `.rbxlx` candidate for Studio and request the eight comparable screenshot views from the v0.6.3 test route.**

Do not call v0.6.3 visually successful until those screenshots are actually reviewed.
