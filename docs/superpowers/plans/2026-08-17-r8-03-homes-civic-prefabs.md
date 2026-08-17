# ART R8 Homes and Civic Prefabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace runtime-sculpted slab homes and façade overlays with complete authored residential and civic prefabs while preserving all home ownership/interior contracts.

**Architecture:** Five authored home tiers and four civic structures live under the R8 model tree. `HomePrefabBuilder` becomes a prefab selector/anchor adapter; `R8CivicPrefabBuilder` deterministically places complete destination buildings from `R8AssetLibrary`.

**Tech Stack:** `.rbxmx`, Luau, Rojo, existing PlotService/HomeService contracts, source-contract tests.

## Global Constraints

- Preserve `ResidentialShell` model name/role and FrontDoor interaction semantics.
- Preserve profile schema 11, house tiers/themes, ownership and interiors.
- R7 post-build charm overlay must be removed from PlotService.
- No missing-prefab fallback to a box.
- Hero homes must have coherent roof/wall/porch/window silhouette before decoration.

---

### Task 1: Author the five home prefabs

**Files:**
- Create: `assets/models/r8/Homes/HomeTier1.rbxmx` ... `HomeTier5.rbxmx`
- Modify: `assets/manifests/r8-models.json`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- Every home model exposes stable children `FrontDoorAnchor`, `InteriorOrigin`, and a primary root.
- Tier models are centred at local origin with front facing +Z.

- [ ] Add RED contract requiring all five paths, manifest entries, hashes and `FrontDoorAnchor` text in each model file.
- [ ] Create original TinyWorld home models with progressively richer silhouettes: pitched/hipped roof forms, eaves, framed windows, integrated porch, chimney/dormer/bay only where tier-appropriate, and a coherent frontage.
- [ ] Keep collision-bearing structure simple and deliberate; decorative details are non-colliding.
- [ ] Refresh manifest hashes and pass source contract.
- [ ] Commit `art: author R8 residential prefab family`.

---

### Task 2: Convert HomePrefabBuilder into a prefab adapter

**Files:**
- Modify: `src/server/HomePrefabBuilder.luau`
- Modify: `src/server/PlotService.luau`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- Existing `HomePrefabBuilder.buildShell(parent, anchor, profile, house)` signature remains.
- Implementation clones `Homes/HomeTier<tier>`, pivots to `CFrame.new(anchor)`, applies approved theme accents only to tagged/known accent descendants, and returns expected shell/anchor data.

- [ ] Add RED contract forbidding runtime hero-wall construction markers such as `BackWall`, `FrontLeft`, `FrontRight`, `MainPitchedRoof` inside HomePrefabBuilder and forbidding `R7BuildingPolishBuilder.decorateHomeShell` in PlotService.
- [ ] Replace sculpture code with R8 asset lookup/clone/pivot logic while preserving current return signature and `ResidentialShell` semantics.
- [ ] Re-home/alias `FrontDoor` prompt anchor to the prefab's `FrontDoorAnchor` so callers do not change unnecessarily.
- [ ] Remove R7 charm overlay call from PlotService.
- [ ] Run compile/source contract and existing home tests.
- [ ] Commit `refactor: make home builder consume R8 prefabs`.

---

### Task 3: Author and place civic buildings

**Files:**
- Create: `assets/models/r8/Civic/MarketHouse.rbxmx`
- Create: `assets/models/r8/Civic/GardenShed.rbxmx`
- Create: `assets/models/r8/Civic/Workshop.rbxmx`
- Create: `assets/models/r8/Civic/HarbourHut.rbxmx`
- Create: `src/server/R8CivicPrefabBuilder.luau`
- Modify: `assets/manifests/r8-models.json`
- Modify: `src/server/Main.server.luau`

**Interfaces:**
- `R8CivicPrefabBuilder.apply(world, layout) -> Model`
- Each building has a primary root plus `NpcAnchor` and `PromptAnchor`; harbour also has `BoatSpawnAnchor`.

- [ ] Add RED checks for the four authored civic assets and named anchors.
- [ ] Author structures with distinct silhouettes: market canopy/shop frontage, small garden shed, craft workshop, harbour hut.
- [ ] Implement placement by canonical R8 destination CFrames.
- [ ] Remove `R6CivicPresentationBuilder.apply` and `R7BuildingPolishBuilder.apply` from active Main composition; retain direct fountain placement only if it remains an intentional plaza asset.
- [ ] Run full tests/format/compile/contracts.
- [ ] Commit `art: install R8 civic prefab set`.
