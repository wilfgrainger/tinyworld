# TinyWorld v0.7.1 ART R5 Published DEV Recovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make TinyWorld published DEV incapable of exposing ART R4 runtime EditableMesh corruption while preserving Studio preview, existing gameplay, and the single free-only direct-to-DEV deployment path.

**Architecture:** Published servers keep legacy village visuals unless a persistent approved Roblox asset mounts successfully. Studio alone may use EditableMesh preview. Direct v0.7.0 objects that currently call `ProductionMeshFactory` receive a deterministic ordinary-BasePart recovery representation outside Studio, so NPCs, Bike, Boat, Car, companions and the future prestige pad remain visible without any runtime EditableMesh dependency.

**Tech Stack:** Roblox Luau, Rojo 7.7.0, Rokit 1.2.0, StyLua 2.5.2, Bash source/build contracts, GitHub Actions `ubuntu-latest`, Roblox Open Cloud Place Publishing API.

## Global Constraints

- Release identity is `v0.7.1` and visual revision is `ART R5`.
- Target is TinyWorld DEV only. LIVE remains deferred and human-gated.
- Profile schema remains 11 with no player-data migration.
- Published DEV must never authorize EditableMesh preview because `ReleaseInfo.channel == "DEV"`.
- Empty or failed persistent-art registry entries must retain last-known-good legacy presentation.
- No player-facing checkerboard/debug/failure geometry is an acceptable fallback.
- Studio may continue to use the ART R4 product-art specification for authoring preview.
- Direct production-mesh users must have a non-EditableMesh published fallback.
- Existing coast, Mermaid Land, NPC, home, vehicle, companion, progression and interaction authority must remain intact.
- Exactly one GitHub Actions workflow remains.
- No `actions/upload-artifact`, `actions/cache`, larger runners or automatic LIVE publishing.
- Do not claim visual acceptance from CI. Real published-client evidence is required after deployment.

---

### Task 1: Add the failing ART R5 published-safety contract

**Files:**
- Create: `tests/verify-v0.7.1-art-r5-source-contract.sh`
- Modify: `.github/workflows/tinyworld-ci.yml`

**Interfaces:**
- Consumes: current R4 source and existing single workflow.
- Produces: a red architectural gate that encodes the published corruption failure and later proves it cannot return.

- [ ] **Step 1: Create the R5 source contract**

The contract must fail unless all of these are true:

```bash
jq -e '.productVersion == "0.7.1" and .artifactFile == "TinyWorld-v0.7.1.rbxlx"' config/release.json

grep -Fq 'artRevision = "ART R5"' src/shared/ReleaseInfo.luau
grep -Fq 'RunService:IsStudio()' src/server/EditableMeshPreviewFactory.luau
! grep -Fq 'ReleaseInfo.channel == "DEV"' src/server/ProductionVisualService.luau
grep -Fq 'PublishedFallbackFactory' src/server/ProductionMeshFactory.luau
grep -Fq 'published-safe-fallback-r5' src/server/PublishedFallbackFactory.luau
grep -Fq 'nativeFallbacksRemainValid": true' assets/manifests/assets.json
grep -Fq 'publishedEditableMeshPreviewAllowed": false' assets/manifests/assets.json
```

Also assert that `ProductionVillageVisuals` contains an explicit mount-before-hide helper and that the single workflow calls this R5 contract.

- [ ] **Step 2: Wire the contract into TinyWorld CI**

Replace the v0.7.0 source-contract step with:

```yaml
      - name: Verify ART R5 published safety
        run: bash ./tests/verify-v0.7.1-art-r5-source-contract.sh
```

- [ ] **Step 3: Run CI and verify RED**

Open a draft PR from `release/v0.7.1-art-r5-recovery` to `main`. Expected result: the new R5 source-contract step fails because release metadata, Studio gating, fallback factory and transactional replacement are not implemented yet.

- [ ] **Step 4: Commit**

Commit message:

```text
test: define ART R5 published visual safety
```

---

### Task 2: Move release/build contracts to v0.7.1 ART R5

**Files:**
- Modify: `config/release.json`
- Modify: `src/shared/ReleaseInfo.luau`
- Modify: `assets/manifests/assets.json`
- Modify: `scripts/verify-release-contract.sh`
- Modify: `tests/build-contract.sh`
- Delete after replacement: `tests/verify-v0.7.0-unified-source-contract.sh`

**Interfaces:**
- Produces release identity `0.7.1`, artifact `TinyWorld-v0.7.1.rbxlx`, release name `Published DEV Recovery`, and build stamp `TinyWorld DEV · v0.7.1 · <candidate> · ART R5`.

- [ ] **Step 1: Update exact release metadata**

`config/release.json` becomes:

```json
{
  "productVersion": "0.7.1",
  "releaseName": "Published DEV Recovery",
  "profileSchema": 11,
  "rojoVersion": "7.7.0",
  "styluaVersion": "2.5.2",
  "rokitVersion": "1.2.0",
  "rokitInstallerCommit": "2f2618428ef31279e2fc80b0b1d73485bc929ddd",
  "projectFile": "default.project.json",
  "artifactFile": "TinyWorld-v0.7.1.rbxlx"
}
```

Update `ReleaseInfo` to `productVersion = "0.7.1"`, `artRevision = "ART R5"`, `releaseName = "Published DEV Recovery"`. Once the draft PR number exists, use that exact PR number for `candidate`.

- [ ] **Step 2: Make fallback policy truthful**

In `assets/manifests/assets.json`, retain schema 3 and ART R4 asset-spec identity, but set:

```json
"nativeFallbacksRemainValid": true,
"studioEditableMeshPreviewAllowed": true,
"publishedEditableMeshPreviewAllowed": false
```

- [ ] **Step 3: Update release/build contracts**

Change all exact v0.7.0 filename/version/release-name assertions in `scripts/verify-release-contract.sh` and `tests/build-contract.sh` to v0.7.1 / `Published DEV Recovery`. Required paths must reference the new R5 source contract, not the old v0.7.0 contract.

- [ ] **Step 4: Verify the R5 contract still fails for architecture, not metadata**

Expected: release identity assertions pass, but Studio gating/fallback/transaction assertions still fail.

- [ ] **Step 5: Commit**

```text
release: identify v0.7.1 ART R5 recovery
```

---

### Task 3: Make production visual mounting Studio-strict and transactional

**Files:**
- Modify: `src/server/ProductionVisualService.luau`
- Modify: `src/server/EditableMeshPreviewFactory.luau`

**Interfaces:**
- `ProductionVisualService:mount(role, parent, pivot) -> Model?`
- Outside Studio: returns a mounted persistent approved model or `nil`; it never calls preview.
- In Studio: may fall back to EditableMesh preview.

- [ ] **Step 1: Add hard Studio guard to preview factory**

At the start of `EditableMeshPreviewFactory.build`:

```lua
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	warn("[TinyWorld ART R5] EditableMesh preview rejected outside Studio", role)
	return nil
end
```

The guard must execute before any call that can reach `AssetService:CreateEditableMesh()`.

- [ ] **Step 2: Remove DEV-channel preview authorization**

Remove `ReleaseInfo` from `ProductionVisualService`. Replace `_canUseDevPreview()` with `_canUseStudioPreview()` returning only `RunService:IsStudio()`.

- [ ] **Step 3: Make mount atomic**

Build the replacement container detached from `parent`. Validate that successful persistent/preview content contains at least one visible `BasePart`. Only then destroy an existing visual root, parent the new container and return it. On failure, destroy the detached container and return `nil` without changing `parent` or marking its legacy presentation degraded.

- [ ] **Step 4: Run CI**

Expected: preview-isolation assertions pass; R5 contract remains red until published direct-object fallback and village ordering are implemented.

- [ ] **Step 5: Commit**

```text
fix: isolate ART preview to Studio
```

---

### Task 4: Add published-safe fallback for every direct mesh caller

**Files:**
- Create: `src/server/PublishedFallbackFactory.luau`
- Modify: `src/server/ProductionMeshFactory.luau`
- Audit: `src/server/BikeBuilder.luau`
- Audit: `src/server/BoatBuilder.luau`
- Audit: `src/server/CarBuilder.luau`
- Audit: `src/server/CompanionService.luau`
- Audit: `src/server/VillageNpcService.luau`
- Audit: `src/server/PrestigePadBuilder.luau`

**Interfaces:**
- `PublishedFallbackFactory.createComponent(parent, component, rootCFrame, palette) -> BasePart`
- `ProductionMeshFactory.createComponent(...) -> BasePart?`
- Studio path continues to generate EditableMesh-backed MeshParts; published path never allocates EditableMesh.

- [ ] **Step 1: Implement deterministic fallback component rendering**

`PublishedFallbackFactory` creates only ordinary Roblox `Part` instances. Map component shapes as follows:

```text
ellipsoid -> Ball
cylinder -> Cylinder
all other current ART shapes -> Block
```

Apply component size, local position/rotation, palette color, safe material mapping, transparency and shadow settings. Mark every fallback part:

```lua
part:SetAttribute("TinyWorldVisualState", "published-safe-fallback-r5")
part:SetAttribute("TinyWorldPublishedSafeFallback", true)
```

Set the parent model's `TinyWorldVisualState` to `published-safe-fallback-r5` as soon as a fallback component is created. Preserve role and motion attributes used by the vehicle/NPC code.

- [ ] **Step 2: Split ProductionMeshFactory by environment before EditableMesh allocation**

At the top of `createComponent`:

```lua
if not RunService:IsStudio() then
	return PublishedFallbackFactory.createComponent(parent, component, rootCFrame, palette)
end
```

Only the Studio branch may call `AssetService:CreateEditableMesh()` or `CreateMeshPartAsync`.

- [ ] **Step 3: Audit all direct callers**

Verify every direct `ProductionMeshFactory` caller goes through `createComponent` and does not separately invoke EditableMesh APIs. In particular, prompts must still attach to the returned `BasePart` for Car and NPCs; Bike/Boat motion attributes must still attach; companions and prestige pad must remain visible.

- [ ] **Step 4: Run CI**

Expected: direct-user published-safety assertions pass. No runtime compile/format regressions.

- [ ] **Step 5: Commit**

```text
fix: add published-safe ART fallback
```

---

### Task 5: Make village replacement mount-before-hide everywhere

**Files:**
- Modify: `src/server/ProductionVillageVisuals.luau`

**Interfaces:**
- Existing semantic/legacy visual remains visible unless `ProductionVisualService:mount` returns a valid replacement.

- [ ] **Step 1: Introduce explicit transactional helper**

Add a helper with this ordering:

```lua
local function mountThenHideLegacy(productionVisualService, role, model, pivot)
	local replacement = productionVisualService:mount(role, model, pivot)
	if replacement then
		hideLegacyVisuals(model)
		return replacement
	end
	model:SetAttribute("TinyWorldLegacyVisualsHidden", false)
	return nil
end
```

`hideLegacyVisuals` must skip the mounted visual-root subtree.

- [ ] **Step 2: Convert fixed buildings, market and portals**

Town Hall, Courier Depot, Village Shop, Home Store, Workshop, Fountain, market and portals must mount first and hide only after success.

- [ ] **Step 3: Convert trees, flower beds and hedges**

Do not hide any legacy tree/flower/hedge element until its replacement mounted. If the registry is empty in published DEV, all these legacy visuals remain untouched.

- [ ] **Step 4: Remove empty supporting holders on failed mount**

Supporting ART holders such as lantern/bench/planter/parcel-crate containers must be destroyed when no replacement mounts, preventing empty/degraded debris in the hierarchy.

- [ ] **Step 5: Mark the world ART R5**

Set:

```lua
root:SetAttribute("TinyWorldProductionArtRevision", "ART R5")
root:SetAttribute("TinyWorldProductionVisualArchitecture", "published-safe-legacy-fallback")
```

- [ ] **Step 6: Run CI**

Expected: full ART R5 source contract passes.

- [ ] **Step 7: Commit**

```text
fix: retain legacy art until replacement succeeds
```

---

### Task 6: Full release verification and DEV handoff

**Files:**
- Review all changed files.
- No new workflow or storage mechanism may be added.

**Interfaces:**
- Produces a green draft PR ready for the explicit integration decision.

- [ ] **Step 1: Run the exact full TinyWorld CI on the PR head**

Required green steps:

```text
Run unit tests
Analyze deterministic shared Luau
Check formatting
Compile runtime Luau for syntax
Verify ART R5 published safety
Verify release contract
Verify build and free-only policy
Build release candidate
```

PR publish step must be skipped.

- [ ] **Step 2: Inspect build evidence**

Confirm the build emits `TinyWorld-v0.7.1.rbxlx`, release manifest reports `0.7.1`, and the run retains zero GitHub Actions artifacts.

- [ ] **Step 3: Review the branch against the approved R5 spec**

Confirm there is no DEV-channel preview authorization, no published EditableMesh allocation path, no hide-before-mount village path, no second workflow, and no LIVE publishing.

- [ ] **Step 4: Integration gate**

Present the verified PR for the user's merge decision. After merge, verify the `main` TinyWorld CI run publishes successfully to Roblox DEV and report the returned place version. Do not claim ART R5 visually accepted until the girls test that exact published version and screenshots show zero checkerboard/floating mesh corruption.
