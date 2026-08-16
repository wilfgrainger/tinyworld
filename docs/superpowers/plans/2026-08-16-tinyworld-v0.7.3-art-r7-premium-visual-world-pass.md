# TinyWorld v0.7.3 ART R7 Premium Visual World Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a dramatic published-client visual quality uplift across the general map, houses, activity spaces and NPCs while preserving R6 gameplay and R5 published-safe rendering.

**Architecture:** Build on TinyWorld's existing authored native Roblox builder architecture. Introduce focused R7 visual builders where existing files are already broad, centralize the brighter premium palette in `VisualPalette`/`VisualTheme`, keep `VillageActivityLocations` authoritative for gameplay/NPC placement, and add a release-specific source contract so the visual architecture and safety boundaries are machine-verifiable.

**Tech Stack:** Roblox Luau, native Parts/Models/Gui surfaces, existing Rojo/Rokit/Stylua/Luau CI, GitHub Issues #17-#22, direct free-only GitHub Actions → Roblox DEV publishing.

## Global Constraints

- Release identity is exactly `v0.7.3 · ART R7 · Premium Visual World Pass`.
- Mandatory order is map → houses → activities → NPCs → final verification/publish.
- Existing R6 gameplay remains functional and server-authoritative.
- R5/R6 published-safe rendering boundary remains intact; no published runtime EditableMesh preview.
- No major gameplay, Mermaid Land, vehicle, economy, profile-schema or LIVE-publishing expansion.
- Reference screenshots communicate qualities only; do not copy distinctive expression.
- GitHub Issue #17 is the operational source of truth and #18-#22 track the ordered workstreams.

---

### Task 1: R7 release contract and visual palette

**Files:**
- Modify: `config/release.json`
- Modify: `src/shared/ReleaseInfo.luau`
- Modify: `src/shared/VisualPalette.luau`
- Modify: `src/server/VisualTheme.luau`
- Create: `tests/verify-v0.7.3-art-r7-source-contract.sh`
- Modify: `.github/workflows/tinyworld-ci.yml`

**Interfaces:**
- Consumes: R7 design and R5/R6 rendering boundaries.
- Produces: exact R7 release identity, brighter shared palette/lighting and a failing-then-green R7 source contract.

- [ ] **Step 1:** Add the R7 source contract first, asserting exact release identity, required R7 builders, unchanged Studio-only EditableMesh boundary, single free-only workflow, canonical activity locations and absence of coplanar grass overlays.
- [ ] **Step 2:** Wire the new contract into the single CI workflow and verify the branch is RED because R7 identity/builders are missing.
- [ ] **Step 3:** Change release metadata from v0.7.2/ART R6 to v0.7.3/ART R7 and artifact name `TinyWorld-v0.7.3.rbxlx`.
- [ ] **Step 4:** Expand the palette with coherent aqua/mint/peach/lavender/pink/cream accents and tune lighting/colour grade for bright toy-world warmth without bloom washout.
- [ ] **Step 5:** Run the contract to ensure it advances to the missing R7 builder assertions.
- [ ] **Step 6:** Commit and post lifecycle `in progress` to #17 and #18.

### Task 2: General map premium composition (#18)

**Files:**
- Create: `src/server/R7WorldCompositionBuilder.luau`
- Modify: `src/server/VillageGroundRebuildBuilder.luau`
- Modify: `src/server/VillageLandscapeBuilder.luau`
- Modify: `src/server/OrganicNatureBuilder.luau`
- Modify: `src/server/HeroFountainBuilder.luau`
- Modify: `src/server/Main.server.luau`
- Test: `tests/verify-v0.7.3-art-r7-source-contract.sh`

**Interfaces:**
- Consumes: `VisualTheme`, existing `VillageGroundRebuildBuilder`, R6 gameplay anchors.
- Produces: `R7WorldCompositionBuilder.apply(root)` that adds the final district framing and hero-plaza composition without replacing gameplay geometry.

- [ ] **Step 1:** Extend the RED contract to require a root `ART_R7_WorldComposition` model, district markers for plaza/homes/market/garden/harbour, non-colliding decoration and R6 grass safety.
- [ ] **Step 2:** Implement `R7WorldCompositionBuilder` with rounded planter islands, layered tree/shrub clusters, lamp/bench pockets, district colour accents, route-edge beads/stepping forms and harbour shoreline framing. Decorations are anchored and non-colliding.
- [ ] **Step 3:** Improve civic ground patches so their surfaces are clearly separated from the single walkable lawn and never use near-coplanar Grass layers.
- [ ] **Step 4:** Tune existing landscape/nature shapes toward rounder canopies, varied scale and deliberate clusters instead of repeated boxes.
- [ ] **Step 5:** Strengthen the fountain plaza with a readable circular/soft-edged forecourt and seating/planting composition while preserving the fountain interaction-free hero landmark.
- [ ] **Step 6:** Compose the R7 world builder in `Main.server.luau` after ground/scenery and before activity/NPC presentation.
- [ ] **Step 7:** Run tests/analyze/format/compile/source contract and update #18 with exact commit evidence.

### Task 3: Houses and civic building silhouettes (#19)

**Files:**
- Create: `src/server/R7BuildingPolishBuilder.luau`
- Modify: `src/server/HomePrefabBuilder.luau`
- Modify: `src/server/CivicFacadePolishBuilder.luau`
- Modify: `src/server/ArchitecturalDetailBuilder.luau`
- Modify: `src/server/Main.server.luau`
- Test: `tests/verify-v0.7.3-art-r7-source-contract.sh`

**Interfaces:**
- Consumes: existing functional home/civic models, `ArchitecturalDetailBuilder`, `VisualTheme`.
- Produces: `R7BuildingPolishBuilder.apply(root)` that decorates existing building models without changing ownership/interior/service anchors.

- [ ] **Step 1:** Add RED source assertions for R7 building polish, distinct building-role attributes, pitched/stepped roof treatment, framed windows, porches/awnings and decorative collision safety.
- [ ] **Step 2:** Add reusable rounded awning, window-box, porch-step, fascia and chimney-cap primitives to `ArchitecturalDetailBuilder` using native geometry.
- [ ] **Step 3:** Implement R7 building polish by finding semantic building models and attaching role-specific exterior dressing: residential cottage, trader/market, builder workshop, garden structure and harbour hut/depot.
- [ ] **Step 4:** Ensure hero roof silhouettes use multiple planes/overhangs rather than one dominant slab and add depth around doors/windows.
- [ ] **Step 5:** Add small lived-in details such as planters, mailbox/parcel box, warm fixtures, fences and stepping stones without blocking doors/prompts.
- [ ] **Step 6:** Compose after base home/civic builders and before activity dressing.
- [ ] **Step 7:** Run full verification and update #19 with exact commit evidence.

### Task 4: Activity spaces premium presentation (#20)

**Files:**
- Create: `src/server/R7ActivityPresentationBuilder.luau`
- Modify: `src/server/R6CivicPresentationBuilder.luau` only where superseded presentation must be reduced
- Use: `src/server/VillageActivityLocations.luau`
- Modify: `src/server/Main.server.luau`
- Test: `tests/verify-v0.7.3-art-r7-source-contract.sh`

**Interfaces:**
- Consumes: canonical role positions from `VillageActivityLocations` and existing R6 activity services.
- Produces: `R7ActivityPresentationBuilder.apply(root)` with five role-themed non-blocking visual stations.

- [ ] **Step 1:** Add RED assertions requiring five named R7 activity zones and prohibiting giant status-board copy as the dominant presentation.
- [ ] **Step 2:** Build Mara's colourful market canopy/display with crates, fruit/goods forms and compact sign.
- [ ] **Step 3:** Build Pip's layered garden nook with raised beds, watering can/tool silhouettes and colourful plants.
- [ ] **Step 4:** Build Finn's fishing nook with a short dock edge, rope posts, tackle box, bucket, buoy and fish-crate dressing without altering the real bobber/bite service.
- [ ] **Step 5:** Build Skye's harbour launch with pier language, route board, parcel stack and boat-focused framing while preserving Tiny Boat progression/traversal.
- [ ] **Step 6:** Build Milo's workshop station with workbench, timber, tool silhouettes and repair-material dressing.
- [ ] **Step 7:** Keep all station collision off around player routes/prompts, compose once, run full verification and update #20.

### Task 5: Character-grade native NPCs (#21)

**Files:**
- Modify: `src/server/VillageNpcBuilder.luau`
- Modify: `src/server/VillageNpcService.luau` only if label/prompt presentation needs safe reduction
- Use: `src/server/VillageActivityLocations.luau`
- Test: `tests/verify-v0.7.3-art-r7-source-contract.sh`

**Interfaces:**
- Consumes: existing NPC definitions/names/roles and canonical placements.
- Produces: five expressive native character models with consistent proportions and role-specific clothing/accessory submodels.

- [ ] **Step 1:** Add RED assertions for head/torso/upper-lower limb hierarchy, face elements, hair/headwear, clothing layers and role prop marker on each NPC.
- [ ] **Step 2:** Replace the chunky mannequin proportions with a compact stylised humanoid proportion system using rounded head, torso layering, articulated-looking upper/lower limbs, hands and shoes while keeping parts anchored/static for service simplicity.
- [ ] **Step 3:** Add simple native face construction using tiny SurfaceGui/geometry elements rather than external asset IDs.
- [ ] **Step 4:** Style Mara as trader, Pip as gardener, Finn as fisherman, Skye as boatkeeper and Milo as builder with unique palette/headwear/clothing/prop silhouettes.
- [ ] **Step 5:** Reduce floating-label visual dominance while preserving accessible interaction prompts and names.
- [ ] **Step 6:** Verify props do not block prompts/movement and no runtime EditableMesh is introduced.
- [ ] **Step 7:** Run full verification and update #21.

### Task 6: Full R7 release verification, merge and DEV publication (#22)

**Files:**
- Modify: release acceptance/docs where current version references require v0.7.3 alignment
- Track: Issues #17-#22
- PR: release branch → `main`

**Interfaces:**
- Consumes: Tasks 1-5.
- Produces: exact green R7 candidate merged to `main`, published DEV version, and a test request for the girls.

- [ ] **Step 1:** Run/confirm all Luau specs, analysis, formatting, runtime compile, R7 source contract, release contract and free-only/build contract on the exact PR head.
- [ ] **Step 2:** Review the entire branch diff for copied reference expression, traversal blockers, duplicate coordinates, regression to published runtime EditableMesh, oversized labels and visual geometry with accidental collisions.
- [ ] **Step 3:** Confirm zero retained Actions artifacts and no review threads/blockers.
- [ ] **Step 4:** Mark the exact green PR ready and squash-merge under the user's recorded full-release authorization.
- [ ] **Step 5:** Verify the post-merge `main` workflow is successful and retrieve the exact returned Roblox DEV place version.
- [ ] **Step 6:** Post main SHA, run ID, test count, contract results, build identity, artifact count and Roblox DEV place version to #17/#22.
- [ ] **Step 7:** Close #18-#21 as completed; leave #17/#22 open at `human acceptance`.
- [ ] **Step 8:** Tell the user that the complete R7 build is ready for the girls and request the ten predefined real-client views.
