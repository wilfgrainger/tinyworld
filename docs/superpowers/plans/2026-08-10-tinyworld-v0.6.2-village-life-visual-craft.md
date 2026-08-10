# TinyWorld v0.6.2 Village Life & Visual Craft Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a green v0.6.2 PR that absorbs the existing v0.7.0 Village Life scope and the remaining Claude visual-craft recommendations without weakening TinyWorld's current architecture, server authority, or evidence honesty.

**Architecture:** Extend the existing shared-rule/server-service/world-builder/client-presentation boundaries. Reuse `ActivityDefinitions`, `RouteRules`, `JobService`, `GardenService`, `ExplorationService`, `FurniturePlacementService`, existing village builders, and the v0.6.1 UI/visual contracts. Add only focused deterministic rules where new replayable behavior needs proof; remove unfinished primitive ambient-character fallback instead of layering another visual system.

**Tech Stack:** Roblox Luau, Rojo 7.7.0, Luau 0.732 CI, StyLua 2.5.2, Rokit 1.2.0, GitHub Actions, schema 11.

## Global Constraints

- Release is exactly `0.6.2` named `Village Life & Visual Craft`.
- Profile schema remains `11` unless a concrete persistence requirement makes a compatible representation impossible.
- The former v0.7.0 Village Life scope moves into v0.6.2; v0.7.0 becomes reserved for the forthcoming family/girls review.
- No Knit, React/Roact, Wally, ECS, NPC framework, new state framework, or other large dependency.
- No invented Roblox asset IDs or production publishing credentials.
- Client sends intent/IDs only; server owns rewards, XP, prices, route completion, placement, privacy, inventory and trade outcomes.
- Preserve the hardened trade journal/mutation-lock path.
- Preserve the player's Roblox avatar until approved TinyWorld character assets exist.
- Native fallback geometry is not accepted as finished hero art merely because metadata says it is authored.
- CI/source green never substitutes for Studio/device visual evidence.
- Do not pull v0.8 portal expansion or v0.9 production deployment into this release.

---

### Task 1: Move release authority and the Village Life roadmap to v0.6.2

**Files:**
- Modify: `config/release.json`
- Modify: `.github/workflows/rojo-build.yml`
- Modify: `scripts/verify-release-contract.sh`
- Modify: `tests/build-contract.sh`
- Modify: `tests/build-contract.ps1`
- Modify: `tests/verify-release-authority.sh`
- Create: `tests/verify-v0.6.2-source-contract.sh`
- Modify: `.github/workflows/release-authority.yml`
- Create: `docs/roadmap/v0.6.2-village-life-visual-craft.md`
- Create: `docs/releases/v0.6.2/acceptance.md`
- Modify: `docs/roadmap/v0.7.0-village-life.md`
- Modify: `docs/roadmap/roadmap.md`
- Modify: `docs/progress.md`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `docs/README.md`

**Interfaces:**
- Produces: canonical release metadata `productVersion=0.6.2`, `releaseName="Village Life & Visual Craft"`, `artifactFile="TinyWorld-v0.6.2.rbxlx"`.
- Produces: generic release authority pointing at v0.6.2 and a source contract that requires the new roadmap/acceptance and rejects active v0.7.0-as-next wording.

- [ ] **Step 1: Change the release/source guards first so the branch goes red until all authority files move together.**

The new source contract must include checks equivalent to:

```bash
grep -Fq '"productVersion": "0.6.2"' config/release.json
grep -Fq '"releaseName": "Village Life & Visual Craft"' config/release.json
grep -Fq '# v0.6.2 Village Life & Visual Craft' docs/roadmap/v0.6.2-village-life-visual-craft.md
grep -Fq '# v0.6.2 Village Life & Visual Craft acceptance' docs/releases/v0.6.2/acceptance.md
grep -Fq 'reserved for the family/girls review' docs/roadmap/v0.7.0-village-life.md
```

- [ ] **Step 2: Update release metadata, build artifact names and shell/PowerShell build-contract expectations to 0.6.2.**

Required metadata:

```json
{
  "productVersion": "0.6.2",
  "releaseName": "Village Life & Visual Craft",
  "profileSchema": 11,
  "artifactFile": "TinyWorld-v0.6.2.rbxlx"
}
```

Preserve the existing exact tool versions and installer commit.

- [ ] **Step 3: Move the complete current v0.7.0 goals into the new v0.6.2 roadmap and reduce v0.7.0 to a deliberate reservation record.**

The v0.6.2 roadmap must explicitly include:

```text
Courier + Gardener/Farmer + Designer + Village Explorer
Town Hall + Village Shop + Home Store + Courier Depot + Workshop + Market
16-home cap
visual-craft / diegetic interaction requirements
hero-home route
asset/prefab quality states
Studio screenshot and labels-off gates
```

The v0.7.0 file must not speculate on the girls' future feedback beyond preserving the milestone.

- [ ] **Step 4: Create v0.6.2 acceptance with automated rows separated from Studio/device rows.**

All Studio/device rows begin `NOT RUN`; source inspection cannot change them to PASS.

- [ ] **Step 5: Run authority/build guards and commit the release-authority slice.**

Run via CI-triggering commit, expecting the release-authority and Rojo workflows to fail if any stale 0.6.1 active metadata remains.

Commit message:

```text
chore: move TinyWorld authority to v0.6.2
```

---

### Task 2: Make the four Village Life activities explicit and testable

**Files:**
- Modify: `src/shared/ActivityDefinitions.luau`
- Create: `src/shared/CourierRouteRules.luau`
- Modify: `src/shared/RouteRules.luau`
- Create: `tests/CourierRouteRules.spec.luau`
- Modify: `tests/RouteRules.spec.luau`
- Modify: `tests/ContentDefinitions.spec.luau`
- Modify: `tests/run.luau`

**Interfaces:**
- `ActivityDefinitions.get(activityId: string) -> activity?`
- `CourierRouteRules.destinationIds() -> {string}`
- `CourierRouteRules.nextDestination(previousId: string?, nonce: number) -> string`
- Existing route task IDs remain stable; add `home_design` with a new bit.

- [ ] **Step 1: Write failing tests for exactly four canonical Village Life activities and courier destination rotation.**

Required assertions:

```lua
local expected = { "Courier", "Gardener", "Designer", "VillageExplorer" }
for _, id in expected do
    assert(ActivityDefinitions.get(id) ~= nil, id .. " definition missing")
end
assert(ActivityDefinitions.get("HarborHelper") == nil, "obsolete HarborHelper activity survived")

local first = CourierRouteRules.nextDestination(nil, 1)
local second = CourierRouteRules.nextDestination(first, 2)
assert(first ~= second, "courier route repeated immediately")
```

- [ ] **Step 2: Run the Luau suite and verify RED.**

Run in CI through the normal `luau tests/run.luau` workflow after committing tests only or by making the implementation commit immediately after a confirmed failure when local execution is unavailable.

- [ ] **Step 3: Replace `HarborHelper` with `VillageExplorer`, document persisted `Farmer` compatibility under the player-facing `Gardener`, and add three or four named courier destinations.**

Use destination IDs already represented by the village:

```lua
local DESTINATIONS = {
    "VillageShop",
    "TownHall",
    "HomeStore",
    "Workshop",
}
```

`nextDestination` must be deterministic for a supplied nonce and avoid an immediate repeat when more than one destination exists.

- [ ] **Step 4: Add `home_design = 16` to `RouteRules.TASK_BITS` and include it in daily/weekly rotations without changing the three-task completion size.**

Preserve existing task IDs and masks for compatibility.

- [ ] **Step 5: Run tests and commit.**

Commit message:

```text
feat: define replayable village activities
```

---

### Task 3: Turn Courier into a multi-destination physical route

**Files:**
- Modify: `src/server/WorldBuilder.luau`
- Modify: `src/server/JobService.luau`
- Modify: `src/server/Main.server.luau` only if constructor wiring changes
- Modify: `src/server/PlayerStateService.luau` only if new courier attributes need central sync
- Modify: `src/client/Main.client.luau`

**Interfaces:**
- `world.deliveryDestinations[destinationId] = { prompt = ProximityPrompt, displayName = string }`
- `JobService.active[player] = { destinationId = string, nonce = number }`
- Player attributes: `TinyWorldCarryingParcel`, `TinyWorldCourierDestination`.

- [ ] **Step 1: Change `WorldBuilder` to expose destination delivery prompts on physical destination anchors rather than one global `deliveryEndPrompt`.**

Each prompt must use local action copy such as:

```text
ActionText = "Deliver Parcel"
ObjectText = "Town Hall"
```

No floating billboard is added.

- [ ] **Step 2: Replace the single cube parcel with a small parcel model that reads as a package without relying on a label.**

The model should contain at minimum a cardboard box body plus contrasting parcel tape/band and remain welded/massless/non-colliding. It is ordinary gameplay feedback, not a production hero asset claim.

- [ ] **Step 3: Make `JobService:_start` choose a server-side destination through `CourierRouteRules` and expose only the chosen destination to the player.**

Pseudo-contract:

```lua
local destinationId = CourierRouteRules.nextDestination(previousDestination[player], nonce[player])
self.active[player] = { destinationId = destinationId }
player:SetAttribute("TinyWorldCourierDestination", destinationId)
```

- [ ] **Step 4: Bind every destination prompt, but only complete when the player with an active parcel reaches the assigned destination.**

Wrong destination returns a short directional message and performs no reward mutation.

- [ ] **Step 5: Keep reward, account XP, Courier XP, analytics, route recording and save entirely server-owned.**

Do not accept destination or reward from a client RemoteEvent.

- [ ] **Step 6: Update the HUD quest copy to show the assigned friendly destination while carrying a parcel.**

- [ ] **Step 7: Run Luau/static/build checks and commit.**

Commit message:

```text
feat: add varied courier routes
```

---

### Task 4: Make Gardener and Village Explorer read as real Village Life activities

**Files:**
- Modify: `src/server/GardenService.luau`
- Modify: `src/server/ExplorationService.luau`
- Modify: `src/server/ProfessionService.luau`
- Modify: `src/client/Main.client.luau`
- Modify: `docs/product/village.md`
- Modify: `docs/product/core-loop.md`

**Interfaces:**
- Persisted profession remains `Farmer`; player-facing activity label is `Village Gardener`.
- Existing `ExplorationRules` profile fields remain unchanged; player-facing route becomes `Village Explorer`.

- [ ] **Step 1: Remove prototype/internal language from garden interaction copy while preserving the current deterministic grow rule.**

Replace copy such as:

```text
"It grows in about 5 seconds in this prototype."
```

with player-facing copy derived from remaining grow time without using the word `prototype`.

- [ ] **Step 2: Update profession/job inspection copy so the player sees Courier, Gardener and Designer, while source compatibility still maps Gardener progress to persisted `Farmer` fields.**

- [ ] **Step 3: Rename boundary-route player copy to `Village Explorer` / `Village Trail` language without renaming persisted fields or deterministic landmark IDs.**

- [ ] **Step 4: Keep plant/water/harvest and explorer claim rewards server-authored and idempotent.**

No new remote is needed.

- [ ] **Step 5: Update journal/HUD language to make the four activities legible without adding permanent counters.**

- [ ] **Step 6: Run tests and commit.**

Commit message:

```text
feat: deepen village gardener and explorer loops
```

---

### Task 5: Make legitimate furniture placement advance Designer without becoming an XP farm

**Files:**
- Modify: `src/server/FurniturePlacementService.luau`
- Modify: `src/server/Main.server.luau`
- Modify: `src/shared/RouteRules.luau` only if Task 2 tests reveal a required adjustment
- Modify: `src/client/Main.client.luau`

**Interfaces:**
- `FurniturePlacementService.new(ProfileStore, PlayerStateService, RouteService)`
- On successful **new** placement only: `RouteService:record(player, "home_design")`.

- [ ] **Step 1: Inject the existing `RouteService` into `FurniturePlacementService`; do not create another activity-state service.**

- [ ] **Step 2: After an authoritative new placement succeeds, record `home_design`. Do not record on move, store, invalid placement, collision rejection, or client preview.**

Required shape:

```lua
local routeChanged, routeText = self.RouteService:record(player, "home_design")
if routeChanged and routeText ~= "" then
    self.PlayerStateService.message(player, routeText)
end
```

- [ ] **Step 3: Do not add repeatable raw Designer XP to every placement.**

Designer profession XP continues to come from existing bounded home-expression acquisition/showcase paths; `home_design` supplies route progress without creating a store/place XP exploit.

- [ ] **Step 4: Update Today/Journal copy so selected `home_design` route text becomes a friendly decorating goal.**

- [ ] **Step 5: Run tests/build and commit.**

Commit message:

```text
feat: connect home placement to village routes
```

---

### Task 6: Apply Claude visual-craft corrections without blind geometry growth

**Files:**
- Modify: `src/server/AmbientLifeService.luau`
- Modify: `src/server/AuthoredPrefabBuilder.luau` only for clearly deficient destination affordances
- Modify: `src/server/WorldBuilder.luau` only for diegetic route/destination props needed by Tasks 3–4
- Modify: `docs/engineering/asset-pipeline.md`
- Modify: `docs/product/art-direction.md`
- Modify: `docs/product/village.md`
- Modify: `assets/manifests/assets.json` only if approved real assets are already present; otherwise leave IDs empty

**Interfaces:**
- No new visual framework.
- Asset states are explicitly `fallback/prototype`, `authored-native`, or `approved-production` in documentation/manifest policy.

- [ ] **Step 1: Delete the current primitive Part-built cats/birds from normal runtime.**

`AmbientLifeService` must not construct anonymous block/ball animals and then call them finished ambient characters. Until approved creature assets exist, prefer no creature over visibly unfinished creature art.

- [ ] **Step 2: Keep ambient motion limited to existing approved/authored world affordances and existing client motion machinery.**

Do not add a large NPC routine framework. If there is no existing suitable authored target, the service may safely become a minimal lifecycle/no-op placeholder rather than fabricate actors.

- [ ] **Step 3: Ensure Courier Depot, Town Hall, Home Store, Village Shop, Workshop and Market interactions use physical destination objects introduced by the current builders instead of generic kiosk boxes.**

Only change a builder where the actual source still relies on a generic interaction block. Do not add decorative parts merely to inflate the diff.

- [ ] **Step 4: Strengthen asset-pipeline docs so hero visual acceptance requires observed Studio evidence and approved provenance; semantic attributes cannot certify quality.**

- [ ] **Step 5: Run the visual source contract/repository audit and commit.**

Commit message:

```text
fix: remove unfinished ambient character fallback
```

---

### Task 7: Lock the hero-home and golden-route contract to observable behavior

**Files:**
- Modify: `docs/product/homes.md`
- Modify: `docs/product/core-loop.md`
- Modify: `docs/quality/visual-quality-bar.md`
- Modify: `docs/quality/playtesting.md`
- Create: `docs/v0.6.2-village-life-visual-craft-test.md`
- Modify: `docs/releases/v0.6.2/acceptance.md`

**Interfaces:**
- Golden route: `spawn -> village -> home -> physical home interaction -> Courier pickup -> assigned delivery -> reward -> Home Store -> buy -> place -> rejoin`.

- [ ] **Step 1: Add the hero-home observable route.**

At minimum require observed:

```text
enter
sit/rest
one kitchen or water/light interaction
one open/close or storage interaction
honest wardrobe/style surface
buy/place/store one furnishing
rejoin and observe persisted placement
```

- [ ] **Step 2: Add exact Studio screenshot slots for normal HUD, village centre, six civic destinations, starter home exterior/interior, parcel carry/delivery and one labels-off route view.**

- [ ] **Step 3: Keep every screenshot/device row `NOT RUN` until captured from the exact candidate.**

- [ ] **Step 4: Add phone/controller/performance observations inherited from current quality budgets.**

- [ ] **Step 5: Commit the player-facing evidence contract.**

Commit message:

```text
docs: define v0.6.2 player evidence route
```

---

### Task 8: Final repository audit, exact-head build evidence and PR

**Files:**
- Modify: `tests/verify-v0.6.1-repository-audit.sh` by replacing it with a current-release v0.6.2 audit or creating `tests/verify-v0.6.2-repository-audit.sh`
- Modify: `.github/workflows/release-authority.yml`
- Modify: `docs/releases/v0.6.2/acceptance.md`
- Modify: PR body only after exact-head evidence exists

**Interfaces:**
- Required workflows: Luau tests, Release authority, Rojo build.
- Candidate evidence records exact source SHA, PR merge-test SHA where applicable, artifact ID, archive digest and inner `.rbxlx` SHA-256.

- [ ] **Step 1: Make the repository audit reject stale active 0.6.1/0.7.0 authority, stale artifact names, temporary remediation files, write-enabled workflows, fake asset IDs and production publishing actions.**

- [ ] **Step 2: Push final source candidate and wait for all three workflows.**

Required Luau workflow steps:

```text
unit specs
shared analysis
StyLua check
recursive server/client compile
```

Required authority steps:

```text
canonical release authority
v0.6.2 source contract
repository text/authority audit
```

Required Rojo steps:

```text
build contract
release contract
TinyWorld-v0.6.2.rbxlx build
artifact upload
```

- [ ] **Step 3: Fix any red gate at its root, push again, and repeat until exact-head green.**

Do not weaken a test merely to obtain green.

- [ ] **Step 4: Record automated evidence in acceptance.**

Studio/device rows remain unchanged unless actual evidence was produced.

- [ ] **Step 5: Open a PR against `main` titled `feat: TinyWorld v0.6.2 Village Life & Visual Craft`.**

PR body must say:

```text
Automated/source: PASS on exact head
Studio/device visual evidence: NOT RUN unless actually captured
Merge: not performed by this execution
```

- [ ] **Step 6: Verify PR is open, points at the expected branch/base, is mergeable, and all required automated workflows are green. Stop there.**
