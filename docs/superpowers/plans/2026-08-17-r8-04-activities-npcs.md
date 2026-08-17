# ART R8 Activity Destinations and NPC Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Place the five existing R6 activity loops inside complete authored destinations and make NPC placement/context support the rebuilt world without changing reward logic.

**Architecture:** Authored activity assets live under `Activities/`; `R8ActivityDestinationBuilder` clones them and wires named anchors. `VillageActivityLocations` becomes an adapter over `R8VillageLayout`, so NPCs and activity services share one coordinate authority.

**Tech Stack:** `.rbxmx`, Luau, existing VillageActivityService handlers, VillageNpcService, source contracts.

## Global Constraints

- Preserve existing Mara/Pip/Finn/Skye/Milo identities.
- Preserve R6 activity reward/ownership/arbitration rules.
- No new profile fields.
- Activity visuals may not obstruct prompts or travel routes.
- Destinations must connect physically to R8 routes/shore rather than float nearby.

---

### Task 1: Author complete activity destination assets

**Files:**
- Create: `assets/models/r8/Activities/MarketDisplay.rbxmx`
- Create: `assets/models/r8/Activities/CommunityGarden.rbxmx`
- Create: `assets/models/r8/Activities/FishingDock.rbxmx`
- Create: `assets/models/r8/Activities/HarbourLaunch.rbxmx`
- Create: `assets/models/r8/Activities/WorkshopYard.rbxmx`
- Modify: `assets/manifests/r8-models.json`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- Market: `ActivityOrigin`.
- Garden: `ActivityOrigin`, `GardenBed1..3`.
- Fishing: `ActivityOrigin`, `FishingOrigin`.
- Harbour: `ActivityOrigin`, `DeliveryOrigin`, `DockBoardingAnchor`.
- Workshop: `ActivityOrigin`, `RepairOrigin`.

- [ ] Add RED checks for all five files, approved manifest hashes and required anchors.
- [ ] Author original TinyWorld destination sets using coherent themed props and architecture, not scattered standalone cubes.
- [ ] Ensure dock/harbour roots are designed to meet the canonical shoreline attachment plane.
- [ ] Refresh hashes and pass asset checks.
- [ ] Commit `art: author R8 activity destinations`.

---

### Task 2: Build the destination assembler and canonical location adapter

**Files:**
- Create: `src/server/R8ActivityDestinationBuilder.luau`
- Modify: `src/server/VillageActivityLocations.luau`
- Modify: `src/server/Main.server.luau`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- `R8ActivityDestinationBuilder.apply(world, layout) -> Model`
- `VillageActivityLocations.get(roleId) -> CFrame` or existing equivalent now reads R8 layout rather than literals.

- [ ] Add RED contract requiring the R8 builder and forbidding `R7ActivityPresentationBuilder.apply` in Main.
- [ ] Clone/pivot the five activity prefabs to layout destinations and attach civic building edges where appropriate.
- [ ] Replace duplicated location literals in `VillageActivityLocations` with R8 layout lookups.
- [ ] Compile and run source contract.
- [ ] Commit `feat: assemble R8 activity destinations`.

---

### Task 3: Integrate NPCs without changing gameplay ownership

**Files:**
- Modify: `src/server/VillageNpcService.luau`
- Test: existing R6/R7 activity specs plus source contract

**Interfaces:**
- NPC root CFrame comes from canonical activity location/destination `NpcAnchor`.
- Existing proximity-prompt callback still invokes the current `VillageActivityService` start/talk path.

- [ ] Reduce nameplate distance/size so labels are secondary to world context.
- [ ] Position NPC models on safe standing surfaces beside their activity anchors.
- [ ] Keep ART R7 native character builder and published-safe role props intact.
- [ ] Run all Luau specs and runtime compile; specifically confirm no reward/ownership tests regress.
- [ ] Commit `art: integrate villagers into R8 destinations`.
