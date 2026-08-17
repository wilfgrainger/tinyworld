# TinyWorld v0.7.5 ART R8.1 Finish the Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish R8.1 by moving permanent village-activity scenery and coordinates onto authored R8 destinations while preserving the published-recovery improvements already on `main`.

**Architecture:** Add four authored activity prefabs, compose them with the existing R8 civic prefabs into `world.r8Destinations`, convert `VillageActivityLocations` into a registry adapter, and keep the existing activity state machines while removing their structural debug geometry. Then strengthen CI and publish only from exact-green `main`.

**Tech Stack:** Roblox Luau, Rojo `.rbxmx`, Bash contracts, jq/sha256sum, GitHub Actions, Roblox Place Publishing API.

## Global Constraints

- Base is `main` at `1ec8072325c8f643c31e8a081f25b46561f83ba2` or a verified descendant.
- Preserve v0.7.5, ART R8.1, Profile schema 11, authored homes, authored civic prefabs and R8 coast recovery.
- Normalize release name to `Finish the Rebuild`; artifact remains `TinyWorld-v0.7.5.rbxlx`.
- No published runtime EditableMesh, invented asset IDs, paid CI features or automatic LIVE publishing.
- Existing activity rewards/progression and server authority remain unchanged.
- Human DEV visual evidence is required after machine verification.

---

### Task 1: RED Contract for the Remaining R8.1 Gap

**Files:**
- Create: `tests/verify-v0.7.5-art-r8.1-source-contract.sh`
- Modify: `.github/workflows/tinyworld-ci.yml`

- [ ] Add a contract that requires `R8DestinationBuilder.apply`, `world.r8Destinations`, authored activity manifest entries and exact release identity; rejects `perimeterHalf(world)`, runtime fishing dock construction, `makeBed`, `makeBoard`, runtime delivery buoy construction and any return of R6/R7 presentation calls.
- [ ] Wire the workflow to the new contract immediately so PR CI is the RED executor.
- [ ] Confirm PR CI fails on the current main-derived branch specifically because the remaining activity authority is absent.

### Task 2: Authored Activity Prefabs and Canonical Destination Registry

**Files:**
- Create: `assets/models/r8/Activities/GardenBeds.rbxmx`
- Create: `assets/models/r8/Activities/FishingDock.rbxmx`
- Create: `assets/models/r8/Activities/RepairStation.rbxmx`
- Create: `assets/models/r8/Activities/DeliveryBuoy.rbxmx`
- Create: `src/server/R8DestinationBuilder.luau`
- Modify: `assets/manifests/r8-models.json`
- Modify: `src/shared/R8VillageLayoutRules.luau`
- Modify: `src/server/VillageActivityLocations.luau`

**Required prefab names:**

```text
GardenBeds: Root, GardenBed1, GardenBed2, GardenBed3, PromptAnchor
FishingDock: Root, Deck, RailLeft, RailRight, NpcAnchor, PromptAnchor, FishingOrigin
RepairStation: Root, RepairBoard1, RepairBoard2, RepairBoard3, PromptAnchor
DeliveryBuoy: Root, Body, Beacon, PromptAnchor
```

**Registry interface:**

```luau
world.r8Destinations = {
  Trader = { model = Model, npcAnchor = BasePart, promptAnchor = BasePart },
  Gardener = { model = Model, npcAnchor = BasePart, promptAnchor = BasePart, gardenBeds = { BasePart, BasePart, BasePart } },
  Fisherman = { model = Model, npcAnchor = BasePart, promptAnchor = BasePart, fishingOrigin = BasePart },
  BoatKeeper = { model = Model, npcAnchor = BasePart, promptAnchor = BasePart, boatSpawnAnchor = BasePart },
  Builder = { model = Model, npcAnchor = BasePart, promptAnchor = BasePart, repairBoards = { BasePart, BasePart, BasePart } },
  CoastalDelivery = { model = Model, promptAnchor = BasePart },
}
```

- [ ] Add `coastalDelivery = point(SHORELINE_DISTANCE + 65, -20, -90)` to `R8VillageLayoutRules.create()` and return it in the layout.
- [ ] Author the four native-Part `.rbxmx` models with coherent scale/materials and transparent non-colliding anchors.
- [ ] Compute exact SHA-256 for final bytes and register `activity-garden-beds`, `activity-fishing-dock`, `activity-repair-station`, `activity-delivery-buoy` with `devApproved=true`.
- [ ] Implement `R8DestinationBuilder.apply(world, layout)` using `R8AssetLibrary.clonePrefab`, fail-closed anchor resolution and existing `layout.r8.destinations`.
- [ ] Convert `VillageActivityLocations` public methods to read only `world.r8Destinations`.
- [ ] Validate with Rojo build and the existing R8 asset contract.

### Task 3: Bind Activity State Machines to Authored Destinations

**Files:**
- Modify: `src/server/VillageGardenActivityService.luau`
- Modify: `src/server/FishingActivityService.luau`
- Modify: `src/server/BuilderRepairActivityService.luau`
- Modify: `src/server/CoastalDeliveryActivityService.luau`

- [ ] Garden: bind prompts/state to registered `GardenBed1..3`; remove destination-defining runtime bed creation; keep order scoring and Farmer XP.
- [ ] Fishing: bind pull prompt to registered dock; retain only transient bobber and existing timing/streak logic.
- [ ] Builder: bind damaged/secured/repaired state to registered repair boards; remove old frame/posts; do not destroy destination scenery on stop.
- [ ] Coastal delivery: bind prompt to registered authored buoy; keep player parcel, boat requirement and timing logic.
- [ ] Compile server Luau, run all unit specs and run the R8.1 contract. At this point only release/Main wiring failures may remain.

### Task 4: Runtime Wiring, Release Identity and Full Gate

**Files:**
- Modify: `src/server/Main.server.luau`
- Modify: `config/release.json`
- Modify: `src/shared/ReleaseInfo.luau`
- Modify: `scripts/verify-release-contract.sh`
- Modify: `tests/build-contract.sh`
- Modify PowerShell counterparts if present.

- [ ] Require `R8DestinationBuilder` and call `R8DestinationBuilder.apply(world, r8Layout)` after R8 civic/street composition and before village activity/NPC service construction.
- [ ] Keep the currently-clean Main free of R6/R7 presentation calls.
- [ ] Keep `productVersion=0.7.5`, `candidate/artRevision=ART R8.1`, artifact `TinyWorld-v0.7.5.rbxlx`; normalize release name to `Finish the Rebuild` in all release/build contracts.
- [ ] Run unit tests, Luau analysis, StyLua, server/client compile, R8.1 source contract, release contract, build contract and deterministic build.

### Task 5: Roblox Quality Audit, Exact-Head Merge and DEV Evidence

**Files:**
- Create: `docs/reviews/2026-08-17-v0.7.5-r8.1-roblox-quality-audit.md`
- Reuse draft PR #34.

- [ ] Audit gameplay discoverability, prompt clarity, mobile readability, destination completeness, single visual authority, scale/material coherence, traversal safety, performance sanity and publish safety; mark visual-only checks `PENDING DEV EVIDENCE` before publication.
- [ ] Require exact-head PR CI success; PR publish step must be skipped.
- [ ] Mark PR ready only after diff review, then squash-merge with `expected_head_sha` equal to the verified head.
- [ ] Require independent main CI success and successful DEV publication with a numeric Roblox place version in logs.
- [ ] Review published-client screenshots for spawn, plaza, residential lane, homes, Mara, Pip, Finn, Skye, Milo, shoreline/swimming, mobile HUD and wide traversal view.
- [ ] Do not call the rebuild visually complete until that evidence passes.
