# ART R8 World, Terrain, Roads and Shoreline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace R7's flat/fragmented map and slab coast with one compact deterministic village layout, continuous routes, authoritative elevation and coherent shoreline.

**Architecture:** `R8VillageLayout` is the sole coordinate/elevation authority. `R8GroundBuilder` creates collision-safe land/roads/plazas; `R8CoastBuilder` creates water/seabed/shore recovery; `R8VillageCompositionBuilder` clones approved StreetKit/Nature assets from the R8 asset library.

**Tech Stack:** Luau, Roblox Terrain/native Parts for safety surfaces, authored `.rbxmx` prefabs, Rojo, shell source contracts.

## Global Constraints

- Preserve 16-player/home admission contract.
- Preserve swim-distance/water-belt gameplay intent.
- No 0.04-stud coplanar ground overlays.
- No legacy rotated `*HillSlope` shoreline slabs.
- Ground, safe shore and recovery heights derive from one authority.
- R7 visible world composition is retired, not layered beneath R8.

---

### Task 1: Define layout authority with pure tests

**Files:**
- Create: `src/shared/R8VillageLayoutRules.luau`
- Create: `tests/R8VillageLayoutRules.spec.luau`
- Modify: `tests/run.luau`
- Create: `src/server/R8VillageLayout.luau`

**Interfaces:**
- `R8VillageLayoutRules.create() -> layout`
- layout fields: `groundY`, `waterY`, `shorelineDistance`, `safeShoreCFrame`, `worldRecoveryCFrame`, `plaza`, `residentialClusters`, `destinations`, `routes`.
- `R8VillageLayout.get() -> layout` server adapter.

- [ ] Write RED tests asserting exactly four residential clusters with four plot origins each, all destinations within the compact hub radius, `safeShoreCFrame.Y > groundY`, and routes connecting plaza to each destination.
- [ ] Run `luau tests/run.luau`; expected module-missing failure.
- [ ] Implement deterministic rules with named destination CFrames for Mara/Pip/Finn/Skye/Milo and sixteen plot placements.
- [ ] Run unit tests and compile; expected PASS.
- [ ] Commit `feat: define R8 village layout authority`.

---

### Task 2: Build authoritative ground and continuous route network

**Files:**
- Create: `src/server/R8GroundBuilder.luau`
- Modify: `src/server/WorldBuilder.luau`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- `R8GroundBuilder.build(parent: Instance, layout) -> Model`
- `WorldBuilder.build(maxPlayers, r8Layout?)` consumes R8 plot placements when supplied.

- [ ] Extend source contract to require `R8GroundBuilder`, forbid active `VillageGroundRebuildBuilder.apply`, and reject source text containing the old `Vector3.new(size.X, 0.04, size.Y)` ground-patch pattern in the R8 path.
- [ ] Verify RED before implementation.
- [ ] Implement one solid village base, integrated plaza volumes and continuous road/lane segments at deliberate vertical separation. Roads may be thin visual surfaces only when they do not overlap each other and sit clearly above the authoritative base.
- [ ] Adapt `WorldBuilder` plot placement to the 16 canonical R8 placements without changing player-capacity rules.
- [ ] Run unit tests, compile, source contract; expected PASS for ground/layout checks.
- [ ] Commit `feat: rebuild R8 village ground and routes`.

---

### Task 3: Replace coast and traversal height mismatch

**Files:**
- Create: `src/server/R8CoastBuilder.luau`
- Modify: `src/server/Main.server.luau`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- `R8CoastBuilder.build(parent, layout) -> {model, shorelineDistance, swimDistance, waterBelt, safeShoreCFrame, worldRecoveryCFrame}` matching current CoastBuilder return contract.

- [ ] Add RED contract requiring `R8CoastBuilder.build` in Main and forbidding `CoastBuilder.build` plus `VillageGroundRebuildBuilder.apply`.
- [ ] Implement Terrain water/seabed and a broad stepped bank/beach transition derived from `layout.groundY`/`layout.waterY`; do not use rotated square hill slabs.
- [ ] Ensure returned safety CFrames are exactly layout-derived, not independent literals.
- [ ] Update Main to consume R8 layout/ground/coast and remove R7 world/ground composition calls.
- [ ] Compile full runtime and run source contract.
- [ ] Commit `feat: replace TinyWorld coast with R8 shoreline`.

---

### Task 4: Assemble authored streetscape and remove empty-field composition

**Files:**
- Create: `src/server/R8VillageCompositionBuilder.luau`
- Modify: `src/server/Main.server.luau`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- `R8VillageCompositionBuilder.apply(world, layout, assetLibrary)` clones only approved StreetKit/Nature prefabs.

- [ ] Add contract markers requiring grouped tree/hedge/bench/lamp placements around routes and forbidding `R7WorldCompositionBuilder.apply` in Main.
- [ ] Implement deterministic clusters that frame routes, plaza, residential lanes and coastline while keeping spawn and travel corridors clear.
- [ ] All decoration descendants are non-touch/non-query and non-colliding unless a named boundary asset explicitly opts in.
- [ ] Run full tests, formatting, compile and R8 source contract.
- [ ] Commit `art: compose R8 authored village streetscape`.
