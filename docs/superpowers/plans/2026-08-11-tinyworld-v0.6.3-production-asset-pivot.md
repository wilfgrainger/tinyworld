# TinyWorld v0.6.3 Production Asset Pivot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the failed ART R1-R3 hero visual layering with an original TinyWorld production-art system that renders true custom MeshPart art in Studio/DEV immediately and can publish the same art specifications as permanent Roblox Model assets.

**Architecture:** Keep TinyWorld gameplay/service roots authoritative and separate from presentation. Repository-owned art specifications describe composite hero models. Studio/DEV consumes those specifications through an EditableMesh-based preview factory; the deterministic art toolchain consumes the same specifications to generate glTF for Open Cloud/Studio import. When approved Roblox asset IDs are available, ProductionVisualService loads the permanent Model asset instead of generating the DEV preview. Legacy R1-R3 visible hero builders are retired from the normal runtime path as each semantic role moves to ART R4.

**Tech Stack:** Luau, Roblox `AssetService`, `EditableMesh`, `MeshPart`, Rojo 7.7.0, Python 3 standard library, glTF 2.0 JSON/binary buffers, Roblox Open Cloud Assets API, existing StyLua/Luau/Release Authority/Rojo gates.

## Global Constraints

- Release remains `v0.6.3 Production Art & World Craft`; profile schema remains `11`.
- Work only on `release/v0.6.3-production-art-world-craft`; do not merge to `main`.
- Gameplay scope is frozen. Do not change economy, rewards, persistence, ownership, activity completion, trade authority or portal progression.
- Preserve semantic interaction anchors and simple collision roots independently from visual art.
- No copied Creator Store/reference-game assets and no invented Roblox IDs.
- Production art must be original TinyWorld expression with recorded provenance.
- Hero visuals may not silently degrade to known ART R1-R3 primitive presentation and still report visual success.
- Studio/device screenshots remain the final visual acceptance authority.
- Generated glTF files are deterministic build outputs and are not committed; `art/specs` and generator code are the source of truth.
- The DEV preview must use the same component specifications as glTF generation so preview art and upload art cannot drift by design.

---

### Task 1: ART R4 release contract and source-of-truth art specification

**Files:**
- Create: `tests/verify-v0.6.3-art-r4-contract.sh`
- Create: `art/README.md`
- Create: `art/specs/palette.json`
- Create: `art/specs/village-product-art.json`
- Modify: `.github/workflows/release-authority.yml`
- Modify: `src/shared/ReleaseInfo.luau`
- Modify: `docs/releases/v0.6.3/acceptance.md`

**Interfaces:**
- Produces: canonical ART R4 asset roles and component schema used by both runtime preview and glTF generator.
- Produces: candidate identity `ART R4` in `ReleaseInfo.artRevision`.

- [ ] **Step 1: Add a failing ART R4 contract** requiring the new art spec, runtime production-visual modules, generator/uploader files, `ART R4` identity, and removal of the R1-R3 visible post-processing chain from `Main.server.luau`.
- [ ] **Step 2: Run/observe Release Authority and verify RED** because required ART R4 files do not yet exist.
- [ ] **Step 3: Add the art specification schema.** `village-product-art.json` must define at minimum these semantic roles: `town-hall`, `starter-home`, `village-shop`, `home-store`, `courier-depot`, `workshop`, `market-stall-a`, `market-stall-b`, `fountain`, `portal-clockwork`, `tree-a`, `tree-b`, `tree-c`, `lantern`, `bench`, `planter`, `hedge`, `parcel-crates`, `starter-interior-kit`.
- [ ] **Step 4: Define component primitives in the spec** using a bounded vocabulary: `beveledBox`, `gableRoof`, `hipRoof`, `frustum`, `cylinder`, `ellipsoid`, `archSegment`, `panel`, `windowSet`, and `waterArc`. Every component records transform, material key, colour key and art role.
- [ ] **Step 5: Stamp `ART R4`** and update acceptance history to preserve R1-R3 as failed evidence rather than deleting it.
- [ ] **Step 6: Commit** with `test: establish ART R4 production asset contract` and `docs: define TinyWorld product art source` as appropriate.

### Task 2: Deterministic mesh geometry library and DEV MeshPart preview

**Files:**
- Create: `src/server/ProductionMeshFactory.luau`
- Create: `src/server/EditableMeshPreviewFactory.luau`
- Create: `src/shared/ProductionArtSpec.luau`
- Create: `tools/art/build_asset_pack.py`
- Create: `tools/art/validate_asset_pack.py`
- Test: `tests/verify-v0.6.3-art-r4-contract.sh`

**Interfaces:**
- `ProductionArtSpec.get(role: string): table?`
- `ProductionMeshFactory.createComponent(parent: Instance, component: table, rootCFrame: CFrame): MeshPart?`
- `EditableMeshPreviewFactory.build(role: string, parent: Instance, pivot: CFrame): Model`
- Python `build_asset_pack.py --spec art/specs/village-product-art.json --out dist/art-r4` produces deterministic `.gltf` files for the same roles.

- [ ] **Step 1: Extend the failing contract** to require that runtime and Python use the same role names and spec version.
- [ ] **Step 2: Implement `ProductionArtSpec`** as the checked-in Luau mirror generated from the JSON spec; the ART R4 contract verifies its declared spec digest against the JSON source digest produced by the generator.
- [ ] **Step 3: Implement true mesh primitives** with `AssetService:CreateEditableMesh()`, explicit vertices/triangles, and `AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh), {CollisionFidelity = Enum.CollisionFidelity.Box})`. MeshParts are anchored, non-touching, non-querying and non-colliding by default.
- [ ] **Step 4: Implement bevelled/chamfered boxes, roof prisms, tapered cylinders/frustums, low-poly ellipsoids and arch segments.** These are actual polygon meshes rather than collections of Roblox block Parts.
- [ ] **Step 5: Implement the DEV preview factory** that builds a composite Model for any role from the static spec and marks it `TinyWorldVisualState=production-preview-r4`.
- [ ] **Step 6: Implement the Python glTF generator** with the same primitive math and deterministic float ordering. No external Python dependency is allowed.
- [ ] **Step 7: Implement validator** checking finite coordinates, triangle indices, bounds, component count, allowed materials, duplicate role names and deterministic SHA-256 output.
- [ ] **Step 8: Verify StyLua, Luau compile, Python syntax and the ART R4 source contract.**

### Task 3: Production asset manifest v3 and permanent Roblox asset path

**Files:**
- Modify: `assets/manifests/assets.json`
- Create: `scripts/generate-production-asset-registry.py`
- Create: `scripts/upload-roblox-assets.py`
- Create: `src/shared/ProductionAssetRegistry.luau`
- Create: `src/server/ProductionVisualService.luau`
- Test: `tests/verify-v0.6.3-art-r4-contract.sh`

**Interfaces:**
- `ProductionAssetRegistry.get(role: string): table?`
- `ProductionVisualService.new()`
- `ProductionVisualService:mount(role: string, parent: Instance, pivot: CFrame): Model?`
- Manifest asset IDs are nullable/absent until a real upload succeeds; they are never fabricated.

- [ ] **Step 1: Upgrade manifest to schema v3** with `sourceSha256`, `qualityTier`, expected bounds, asset family and approval fields while keeping zero fake IDs.
- [ ] **Step 2: Implement registry generation** so runtime Luau is derived from manifest and CI rejects drift.
- [ ] **Step 3: Implement `ProductionVisualService`.** If a real approved asset ID exists, load it server-side with `AssetService:LoadAssetAsync()` inside `pcall`, validate/strip unexpected scripts, cache the template and clone into a `VisualRoot`.
- [ ] **Step 4: DEV fallback:** when no uploaded ID exists and Studio/DEV is running, build the same role with `EditableMeshPreviewFactory`. Mark `TinyWorldProductionArtDegraded=false` for this intentional ART R4 preview mode; a legacy primitive hero fallback sets it true.
- [ ] **Step 5: Implement Open Cloud uploader** using `ROBLOX_OPEN_CLOUD_API_KEY`, `TINY_WORLD_ASSET_CREATOR_ID`, and `TINY_WORLD_ASSET_CREATOR_TYPE`. Upload Model `.gltf`, poll `/assets/v1/operations/{operationId}`, capture only real returned IDs, and update the manifest with original TinyWorld provenance. No credentials are written to disk by the script.
- [ ] **Step 6: Verify upload script dry-run** validates request payloads and source hashes without network mutation.

### Task 4: Replace the civic square hero layer

**Files:**
- Modify: `src/server/Main.server.luau`
- Modify: semantic world/destination builders only where needed to expose stable roots/pivots.
- Create: `src/server/ProductionVillageVisuals.luau`
- Retire from visible runtime path: `CivicCraftBuilder`, `CivicHeroRebuildBuilder`, `CivicFacadePolishBuilder`, `VillageArrivalPolishBuilder`, `HeroFountainBuilder`, `HeroPortalBuilder`, `OrganicNatureBuilder` for roles replaced by ART R4.
- Test: `tests/verify-v0.6.3-art-r4-contract.sh`

**Interfaces:**
- `ProductionVillageVisuals.apply(world, productionVisualService)` mounts production roles onto existing semantic roots without owning gameplay state.

- [ ] **Step 1: Extend the RED contract** so `Main.server.luau` may no longer execute the old visible civic/fountain/portal/nature R1-R3 stack.
- [ ] **Step 2: Build the P0 civic product-art specifications** for Town Hall, Village Shop, Home Store, Courier Depot, Workshop, two market stalls, fountain, Clockwork portal, trees, lanterns, benches, planters and hedges. Shapes must use bevels/taper/profile depth and avatar-correct scale.
- [ ] **Step 3: Mount production visuals onto semantic roots** and hide/destroy only competing visible legacy shell geometry while preserving prompts, route anchors and simple collision.
- [ ] **Step 4: Reduce street furniture scale and count** so Town Hall/fountain regain visual hierarchy.
- [ ] **Step 5: Preserve portal/fountain interactions** on hidden/simple anchors independent of the visual model.
- [ ] **Step 6: Verify the generated place builds and all existing Luau tests still pass.**

### Task 5: Replace the starter home exterior and interior hero layer

**Files:**
- Modify: `src/server/HomePrefabBuilder.luau`
- Modify: `src/server/HomeInteriorCraftBuilder.luau`
- Modify: `src/server/PlotService.luau`
- Create: `src/server/ProductionHomeVisuals.luau`
- Test: existing home tests plus ART R4 contract.

**Interfaces:**
- `ProductionHomeVisuals.apply(plot, profile, house, productionVisualService)` mounts the visual shell/interior kit after each home rebuild.

- [ ] **Step 1: Add failing source guard** requiring home rebuild lifecycle to call `ProductionHomeVisuals.apply` and forbidding ART R3 organic-nature post-processing on the home visual root.
- [ ] **Step 2: Build `starter-home` product art** with a shaped cottage shell, recessed window bays, coherent roof/chimney, porch, scaled lantern and non-blank side elevations.
- [ ] **Step 3: Build `starter-interior-kit` product art** with readable living/kitchen/sleep/bath/storage zones, rounded/tapered furniture silhouettes, clear avatar traversal and a fully enclosed ceiling.
- [ ] **Step 4: Keep interaction objects anchored separately** so cooker/sink/storage/lamp/bed behavior remains server-owned and functional.
- [ ] **Step 5: Reapply production home visuals after claim/upgrade/restyle/rebuild.**
- [ ] **Step 6: Run home/gameplay tests and recursive compile.**

### Task 6: Art build verification, documentation and candidate freeze

**Files:**
- Modify: `.github/workflows/release-authority.yml`
- Modify: `.github/workflows/rojo-build.yml` if art validation is not already covered by Release Authority.
- Modify: `docs/engineering/asset-pipeline.md`
- Modify: `docs/product/art-direction.md`
- Modify: `docs/quality/visual-quality-bar.md`
- Modify: `docs/releases/v0.6.3/acceptance.md`
- Modify: `docs/v0.6.3-production-art-world-craft-test.md`

**Interfaces:**
- CI proves source/spec integrity and build integrity only. Studio screenshots still decide visual PASS/FAIL.

- [ ] **Step 1: Add CI art-pack validation** with `python3 tools/art/validate_asset_pack.py` and deterministic build checks from `build_asset_pack.py`.
- [ ] **Step 2: Update durable docs** so hero assets are explicitly production-mesh/model art while native Parts remain collision/support/background where visually appropriate.
- [ ] **Step 3: Update acceptance** to record ART R3 as FAIL and ART R4 as the current candidate, with visible version badge `TinyWorld DEV · v0.6.3 · PR #8 · ART R4`.
- [ ] **Step 4: Run full verification on exact head:** 36+ Luau specs, `luau-analyze`, `stylua --check src tests`, recursive server/client `luau-compile`, ART R4 contract, repository audit, release contract, Rojo build and `git diff --check` equivalent through CI.
- [ ] **Step 5: Freeze the exact green ART R4 head for Studio.** Do not merge.
- [ ] **Step 6: Studio visual route:** user captures the same eight views. Any required hero view that still reads as prototype blocks the release and drives a bounded ART R4.x art-spec correction, not a return to runtime Part layering.
