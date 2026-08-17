# ART R8 Asset-First Visual Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make authored Roblox model files first-class TinyWorld release inputs and make missing/unapproved hero visuals a build failure rather than a primitive fallback.

**Architecture:** Rojo maps `assets/models/r8/` into `ReplicatedStorage.TinyWorldAssets.R8`. A local-model manifest records file SHA-256/provenance/approval. `R8AssetLibrary` resolves approved prefabs by stable semantic IDs; hero builders clone assets and fail loudly when required content is absent.

**Tech Stack:** Rojo 7.7.x, Roblox XML `.rbxmx`, Luau, Bash, jq, sha256sum, GitHub Actions.

## Global Constraints

- Product version remains `0.7.4`; art revision is `ART R8`.
- Existing `assets/manifests/assets.json` remains the uploaded-Roblox-ID manifest and is not weakened.
- No invented Roblox asset IDs.
- Published EditableMesh remains forbidden.
- No new paid/cloud dependency.
- Hero buildings/destinations may not silently fall back to runtime boxes.
- GitHub repository remains source of truth.

---

### Task 1: Wire the authored model tree and RED contract

**Files:**
- Modify: `default.project.json`
- Create: `assets/manifests/r8-models.json`
- Create: `tests/verify-v0.7.4-art-r8-source-contract.sh`
- Modify: `.github/workflows/tinyworld-ci.yml`

**Interfaces:**
- Produces `ReplicatedStorage.TinyWorldAssets.R8` in Rojo builds.
- Produces manifest schema `{schemaVersion, models[]}` where each model has `id`, `path`, `sha256`, `role`, `source`, `license`, `revision`, `devApproved`.

- [ ] **Step 1: Add a failing R8 source contract**

The shell contract must assert that `default.project.json` contains an R8 asset mapping, that `r8-models.json` exists, that `src/server/R8AssetLibrary.luau` exists, and that R7 remains active only until later R8 tasks retire it.

```bash
#!/usr/bin/env bash
set -euo pipefail
jq -e '.tree.ReplicatedStorage.TinyWorldAssets.R8["$path"] == "assets/models/r8"' default.project.json >/dev/null
test -f assets/manifests/r8-models.json
test -f src/server/R8AssetLibrary.luau
```

- [ ] **Step 2: Wire the contract into the single workflow and verify RED**

Replace the R7 visual-contract step with an R8 step:

```yaml
- name: Verify ART R8 structural world rebuild
  run: bash ./tests/verify-v0.7.4-art-r8-source-contract.sh
```

Expected PR result: FAIL because R8 asset tree/library do not yet exist.

- [ ] **Step 3: Add Rojo asset mapping and empty-valid manifest shell**

`default.project.json` adds:

```json
"TinyWorldAssets": {
  "$className": "Folder",
  "R8": { "$path": "assets/models/r8" }
}
```

Create manifest with schema version 1 and an initially empty `models` array; later tasks populate it before the contract can pass.

- [ ] **Step 4: Commit checkpoint**

Commit message: `build: establish R8 authored asset pipeline`.

---

### Task 2: Add deterministic prefab lookup and validation

**Files:**
- Create: `src/server/R8AssetLibrary.luau`
- Create: `src/shared/R8AssetRules.luau`
- Create: `tests/R8AssetRules.spec.luau`
- Modify: `tests/run.luau`

**Interfaces:**
- `R8AssetRules.validateManifest(manifest) -> (boolean, string?)`
- `R8AssetLibrary.requirePrefab(category: string, name: string) -> Instance`
- `R8AssetLibrary.clonePrefab(category: string, name: string) -> Instance`

- [ ] **Step 1: Write failing pure Luau tests**

Tests cover duplicate IDs, blank paths, non-approved models and valid entries. Example:

```lua
expect(R8AssetRules.validateManifest({
    models = {{ id = "home-tier-1", path = "Homes/HomeTier1.rbxmx", sha256 = string.rep("a", 64), role = "home", source = "TinyWorld", license = "Original", revision = "r8.1", devApproved = true }}
})).toEqual(true)
```

- [ ] **Step 2: Run `luau tests/run.luau` and verify RED**

Expected: module missing.

- [ ] **Step 3: Implement rules and runtime asset library**

`R8AssetLibrary` resolves from `ReplicatedStorage:WaitForChild("TinyWorldAssets"):WaitForChild("R8")` and errors with `R8 required prefab missing: <category>/<name>` rather than returning a prototype fallback.

- [ ] **Step 4: Run tests and compile**

Run:

```bash
luau tests/run.luau
luau-compile src/server/R8AssetLibrary.luau >/dev/null
```

Expected: PASS.

- [ ] **Step 5: Commit checkpoint**

Commit message: `feat: add R8 prefab asset library`.

---

### Task 3: Add original TinyWorld authored starter kit and provenance validation

**Files:**
- Create model files under `assets/models/r8/StreetKit/`, `Nature/`, `Architecture/`
- Modify: `assets/manifests/r8-models.json`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`
- Create: `docs/ART_AUTHORING.md`

**Interfaces:**
- Every required `.rbxmx` file is referenced by one manifest entry.
- Manifest `sha256` equals `sha256sum <path>`.

- [ ] **Step 1: Add original native-Roblox authored models**

Minimum starter kit: `Bench.rbxmx`, `Lamp.rbxmx`, `Planter.rbxmx`, `FenceSection.rbxmx`, `Mailbox.rbxmx`, `TreeSmall.rbxmx`, `TreeLarge.rbxmx`, `HedgeSection.rbxmx`, `WindowAssembly.rbxmx`, `PorchAssembly.rbxmx`.

Each file is original TinyWorld work using native Roblox geometry and contains a top-level `Model` with a stable `PrimaryPart`.

- [ ] **Step 2: Populate manifest with real SHA-256 values and provenance**

Each entry uses `source: "TinyWorld original"`, `license: "Project-owned original"`, `revision: "r8.1"`, `devApproved: true`.

- [ ] **Step 3: Extend contract to validate hashes**

For each manifest item:

```bash
jq -c '.models[]' assets/manifests/r8-models.json | while read -r item; do
  path="$(jq -r '.path' <<<"$item")"
  expected="$(jq -r '.sha256' <<<"$item")"
  test -f "$path"
  actual="$(sha256sum "$path" | awk '{print $1}')"
  test "$actual" = "$expected"
done
```

- [ ] **Step 4: Document authoring workflow**

Document Studio/export/syncback, required anchors, manifest update, hash refresh and GitHub review. Explicitly state that Studio-only unsaved art is not production art.

- [ ] **Step 5: Run full contract and commit**

Run `bash tests/verify-v0.7.4-art-r8-source-contract.sh` and expect this workstream's checks to pass.

Commit message: `art: add R8 authored starter kit`.
