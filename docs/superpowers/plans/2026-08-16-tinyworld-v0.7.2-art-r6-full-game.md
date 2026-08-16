# TinyWorld v0.7.2 / ART R6 Full Game Experience Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the recovered v0.7.1 DEV build into a coherent, replayable village game with character-grade NPCs, five server-authoritative activity loops, visible world-state feedback, improved civic presentation, and no grass z-fighting.

**Architecture:** Keep ART R5's published-safe visual boundary intact. Add pure shared activity definitions/rules, a narrow server coordinator, role-specific activity services, and a dedicated native-part NPC builder. Reuse existing profile, inventory, progression, profession, route, transport, garden, trade and message services rather than introducing a parallel economy or profile migration.

**Tech Stack:** Roblox Luau, Rojo, StyLua, Luau CLI tests/static analysis, Bash source contracts, GitHub Actions, Roblox Open Cloud Place Publishing.

## Global Constraints

- Release identity is exactly `0.7.2`, `ART R6`, `Full Game Experience`, channel `DEV`.
- Published DEV must not execute runtime EditableMesh preview or regress ART R5 fallback safety.
- No profile schema migration unless implementation proves it unavoidable; transient R6 activity state stays server-side.
- One player may have at most one R6 village activity active at a time.
- Basic activity completion is accessible; `good` gives +15% coins, `perfect` gives +30% coins, XP is not quality-multiplied.
- Short activity base reward: 60 coins + 30 XP. Medium traversal activity: 100 coins + 50 XP. Coastal delivery: 140 coins + 70 XP.
- Existing player-to-player Trading Post remains intact.
- Existing courier, personal garden, homes, furniture, bike, car, boat, coast, Mermaid Land and quests remain intact.
- Single free-only GitHub Actions workflow remains authoritative; no `actions/upload-artifact`, no `actions/cache`, no automatic LIVE publish.
- PR runs validate/build only; `main` push publishes DEV.

---

### Task 1: Establish the R6 RED release/source gate

**Files:**
- Create: `tests/verify-v0.7.2-art-r6-source-contract.sh`
- Modify: `tests/build-contract.sh`
- Modify later in this task: `src/shared/ReleaseInfo.luau`, `config/release.json`, `scripts/build.sh`, `scripts/build.ps1`, `tests/build-contract.ps1`, `tests/release-contract.sh`

**Interfaces:**
- Produces: a source gate that requires R6 identity, activity modules/services, native NPC builder wiring, absence of the old 0.04-stud Grass overlay, and retention of ART R5 published-safety guards.

- [ ] **Step 1: Write a failing R6 source contract**

Require exact source markers:

```bash
require_file src/shared/VillageActivityDefinitions.luau
require_file src/shared/VillageActivityRules.luau
require_file src/server/VillageNpcBuilder.luau
require_file src/server/VillageActivityService.luau
require_file src/server/TraderRequestActivityService.luau
require_file src/server/VillageGardenActivityService.luau
require_file src/server/FishingActivityService.luau
require_file src/server/CoastalDeliveryActivityService.luau
require_file src/server/BuilderRepairActivityService.luau

grep -q 'productVersion = "0.7.2"' src/shared/ReleaseInfo.luau
grep -q 'artRevision = "ART R6"' src/shared/ReleaseInfo.luau
grep -q 'releaseName = "Full Game Experience"' src/shared/ReleaseInfo.luau

grep -q 'VillageNpcBuilder' src/server/VillageNpcService.luau
grep -q 'VillageActivityService' src/server/Main.server.luau

grep -q 'RunService:IsStudio()' src/server/ProductionMeshFactory.luau
grep -q 'PublishedFallbackFactory' src/server/ProductionMeshFactory.luau

if grep -n 'Vector3.new(size.X, 0.04, size.Y)' src/server/VillageGroundRebuildBuilder.luau; then
  echo "ERROR: legacy coplanar 0.04-stud grass overlay remains" >&2
  exit 1
fi
```

- [ ] **Step 2: Wire the contract into `tests/build-contract.sh` and run CI**

Expected: FAIL because R6 modules and release identity do not exist yet.

- [ ] **Step 3: Update release/build identity to v0.7.2**

Set:

```lua
return {
    productName = "TinyWorld",
    productVersion = "0.7.2",
    channel = "DEV",
    candidate = "ART R6",
    artRevision = "ART R6",
    releaseName = "Full Game Experience",
}
```

Update deterministic artifact naming from `TinyWorld-v0.7.1.rbxlx` to `TinyWorld-v0.7.2.rbxlx` in both shell/PowerShell build contracts and scripts.

- [ ] **Step 4: Commit**

`test: establish ART R6 full-game release gate`

---

### Task 2: Add pure activity definitions and reward/quality rules

**Files:**
- Create: `src/shared/VillageActivityDefinitions.luau`
- Create: `src/shared/VillageActivityRules.luau`
- Create: `tests/VillageActivityDefinitions.spec.luau`
- Create: `tests/VillageActivityRules.spec.luau`
- Modify: `tests/run.luau`

**Interfaces:**
- Produces: `VillageActivityDefinitions.all()`, `.get(id)`, `.forRole(role)`.
- Produces: `VillageActivityRules.gradeTiming(elapsed, goodMax, perfectMax)`, `.coinReward(baseCoins, quality)`, `.canStart(activeId)`, `.validTarget(expected, actual)`, `.canComplete(completed)`.

- [ ] **Step 1: Write failing pure tests**

Test five unique activity IDs/roles (`TraderRequest`, `VillageGarden`, `Fishing`, `CoastalDelivery`, `BuilderRepair`), reward bands, and quality maths:

```lua
TestUtil.assertEqual(Rules.coinReward(100, "normal"), 100)
TestUtil.assertEqual(Rules.coinReward(100, "good"), 115)
TestUtil.assertEqual(Rules.coinReward(100, "perfect"), 130)
TestUtil.assertEqual(Rules.gradeTiming(1.0, 3.0, 1.5), "perfect")
TestUtil.assertEqual(Rules.gradeTiming(2.0, 3.0, 1.5), "good")
TestUtil.assertEqual(Rules.gradeTiming(4.0, 3.0, 1.5), "normal")
```

- [ ] **Step 2: Run tests and verify RED**

Expected: module not found.

- [ ] **Step 3: Implement the minimal shared modules**

Definitions include exact base rewards and role ownership. Rules contain no Roblox service dependencies and never trust a client-provided quality grade.

- [ ] **Step 4: Run the Luau suite and verify GREEN**

- [ ] **Step 5: Commit**

`feat: define R6 village activity rules`

---

### Task 3: Fix grass z-fighting structurally

**Files:**
- Modify: `src/server/VillageGroundRebuildBuilder.luau`
- Extend: `tests/verify-v0.7.2-art-r6-source-contract.sh`

**Interfaces:**
- Keeps `VillageGroundRebuildBuilder.apply(root)` unchanged.

- [ ] **Step 1: Extend the RED source assertion**

Reject `0.04` lawn sheets and reject decorative `Enum.Material.Grass` patches created by the district patch helper.

- [ ] **Step 2: Replace lawn overlays with non-coplanar authored ground composition**

Keep `VillageGround` as the continuous Grass lawn. District colour variation uses raised soil/ground beds and cobblestone/path accents at safe separation, plus existing vegetation, not second Grass sheets.

Use a helper minimum Y offset of at least `0.08` for thin non-grass hardscape/soil accents and give visible edges where appropriate.

- [ ] **Step 3: Run source contract + runtime compile**

Expected: no old lawn overlay pattern; builder still compiles.

- [ ] **Step 4: Commit**

`fix: remove village grass z-fighting layers`

---

### Task 4: Replace generic NPC fallback with character-grade native NPC builder

**Files:**
- Create: `src/server/VillageNpcBuilder.luau`
- Modify: `src/server/VillageNpcService.luau`
- Extend: `tests/verify-v0.7.2-art-r6-source-contract.sh`

**Interfaces:**
- Produces: `VillageNpcBuilder.build(parent, definition, origin, actionText, onInteract) -> Model`.
- `VillageNpcService` continues to own lifecycle/folder and delegates visuals to the builder.

- [ ] **Step 1: Write RED source assertions**

Require the builder to create native `Part`/`Humanoid` character anatomy and forbid `ProductionMeshFactory` import from `VillageNpcService`.

- [ ] **Step 2: Implement `VillageNpcBuilder`**

Build readable head/torso/arms/legs, face cues, role colours and a unique accessory per NPC using only published-safe native instances. Preserve NPC names Mara, Pip, Finn, Skye, Milo.

Prompt text maps to activity intent:

```lua
Trader = "See village request"
Gardener = "Start garden round"
Fisherman = "Go fishing"
BoatKeeper = "Take coastal delivery"
Builder = "Take repair job"
```

- [ ] **Step 3: Refactor `VillageNpcService` to delegate build and activity start callback**

Constructor becomes `VillageNpcService.new(world, PlayerStateService, VillageActivityService)` and interaction calls `VillageActivityService:startForRole(player, definition.id)`.

- [ ] **Step 4: Run format/compile/source contract**

- [ ] **Step 5: Commit**

`feat: rebuild village NPCs as native characters`

---

### Task 5: Implement server-authoritative activity coordinator

**Files:**
- Create: `src/server/VillageActivityService.luau`
- Create: `src/server/TraderRequestActivityService.luau`
- Create: `src/server/VillageGardenActivityService.luau`
- Create: `src/server/FishingActivityService.luau`
- Create: `src/server/CoastalDeliveryActivityService.luau`
- Create: `src/server/BuilderRepairActivityService.luau`

**Interfaces:**
- Coordinator: `VillageActivityService.new(world, ProfileStore, PlayerStateService, RouteService)`.
- Coordinator: `startForRole(player, role)`, `complete(player, activityId, quality)`, `removePlayer(player)`.
- Role services expose `start(player, context) -> (boolean, string?)` and own their prompt/state connections.

- [ ] **Step 1: Implement coordinator state and reward application**

State is keyed by `Player`; reject a second active activity. On completion, retrieve server-owned activity state, apply base + server-calculated quality coins, apply XP with `Progression.addXp`, sync, save, message, then clear activity before any path can award again.

- [ ] **Step 2: Implement Mara Trader request**

Use safe request pool `{ "Carrot", "SugarCrystal" }`. Validate inventory immediately before `Inventory.remove`. Reward 60 coins + 30 XP plus the definition's request compensation. No player-to-player TradeService changes.

- [ ] **Step 3: Implement Pip public garden round**

Create/locate three village activity beds near Pip. Session state per active player tracks three tended beds. Each interaction visibly changes dry bed -> tended bed. Completion after all three grants 60 coins + 30 XP and Gardener/Farmer profession progress through existing `Profession` APIs.

- [ ] **Step 4: Implement Finn fishing**

Create one fishing spot near water. Server stores attempt start/bite timestamps. Prompt interaction during the broad success window completes; quality is calculated from server elapsed time. Normal completion always succeeds once bite is active, with `good/perfect` bonus based on proximity to ideal timing. Maintain session-only streak message.

- [ ] **Step 5: Implement Skye coastal delivery**

Assign one safe coastal destination, attach a visible parcel, record server start time, and install/locate destination prompt. Completion always pays 140 coins + 70 XP; efficient route time earns good/perfect coin bonus. No failure timeout and no bypass of boat/swimming/whirlpool rules.

- [ ] **Step 6: Implement Milo repair job**

Select one authored repair target. Show `damaged` state, require three server-counted interactions, then transition visibly to `repaired`. Completion pays 60 coins + 30 XP; server timing may award good/perfect craftsmanship bonus.

- [ ] **Step 7: Add cleanup**

Player removal clears active state, parcel/accessory/session streaks and prompt-side transient ownership with no penalty.

- [ ] **Step 8: Run compile/source contract**

- [ ] **Step 9: Commit**

`feat: add five playable village activity loops`

---

### Task 6: Wire R6 into runtime and contextual player feedback

**Files:**
- Modify: `src/server/Main.server.luau`
- Modify: `src/server/VillageNpcService.luau`
- Optionally modify: `src/client/Main.client.luau` only if a compact activity status is needed beyond existing message UI.

**Interfaces:**
- Instantiate `VillageActivityService` after profile/player-state/world dependencies exist.
- Pass it into `VillageNpcService`.
- Call `VillageActivityService:removePlayer(player)` in the existing player-removal lifecycle.

- [ ] **Step 1: Wire services in dependency order**

No client RPC can directly grant rewards or submit quality. Use world `ProximityPrompt` triggers/server timestamps.

- [ ] **Step 2: Preserve existing systems**

Do not remove/replace `JobService`, `GardenService`, `TradeService`, transport, Mermaid Land or home lifecycle.

- [ ] **Step 3: Run full Luau tests, static analysis, formatting and runtime compile**

- [ ] **Step 4: Commit**

`feat: wire ART R6 village gameplay into runtime`

---

### Task 7: Premium civic presentation pass without unsafe mesh regression

**Files:**
- Modify: `src/server/HeroFountainBuilder.luau`
- Modify: `src/server/VillageSceneryBuilder.luau`
- Modify one or more existing civic façade builders only where necessary: `src/server/CivicHeroRebuildBuilder.luau`, `src/server/CivicFacadePolishBuilder.luau`, `src/server/ArchitecturalDetailBuilder.luau`
- Extend: `tests/verify-v0.7.2-art-r6-source-contract.sh`

**Interfaces:**
- Existing public builder signatures remain unchanged.

- [ ] **Step 1: Improve fountain silhouette**

Use native parts to create a readable basin, pedestal and water jet/bowl composition while preserving the daily reward prompt/anchor semantics.

- [ ] **Step 2: Reduce developer-board signage**

Shrink status boards, use authored sign frames, move verbose state into contextual prompts/messages, and keep only short in-world labels.

- [ ] **Step 3: Dress NPC stations**

Add role-specific safe-native props: market crates/satchel, garden tools/watering can, fishing bucket/rod cue, harbour rope/life ring, builder tools/material stack.

- [ ] **Step 4: Improve worst civic façades**

Add native trim/depth/awning/window/roof-edge details where the civic-centre camera currently sees slab-like fronts. Do not attempt a new runtime mesh pipeline.

- [ ] **Step 5: Run format/compile/source gate**

- [ ] **Step 6: Commit**

`feat: upgrade ART R6 civic presentation`

---

### Task 8: Final release contract, regression suite and PR gate

**Files:**
- Finalise: `tests/verify-v0.7.2-art-r6-source-contract.sh`
- Modify: `.github/workflows/tinyworld-ci.yml` only if needed to invoke the R6 source gate through the existing build contract, never to add storage.
- Add: `docs/releases/v0.7.2/acceptance.md`

**Interfaces:**
- Existing single workflow stays `TinyWorld CI`.

- [ ] **Step 1: Run exact final PR suite**

Required green stages:

```text
Luau specs
static analysis
StyLua
runtime compile
ART R6 source contract
release contract
free-only/build contract
deterministic Rojo v0.7.2 build
```

- [ ] **Step 2: Verify zero retained workflow artifacts**

`fetch_workflow_run_artifacts` must return an empty artifact list.

- [ ] **Step 3: Review exact PR head**

Check changed files, PR diff, reviews/threads and combined status. Fix any real finding and rerun on the new exact head.

- [ ] **Step 4: Mark PR ready**

Only after exact-head green and review clean.

---

### Task 9: Merge and publish TinyWorld DEV

**Files:** none beyond merge-produced `main` state.

- [ ] **Step 1: Squash-merge using expected final head SHA**

Reject merge if the PR head moved.

- [ ] **Step 2: Verify the post-merge `main` workflow**

All validation/build gates must be green and `Publish TinyWorld DEV` must succeed.

- [ ] **Step 3: Read publish logs**

Capture the returned Roblox `versionNumber`; never expose `ROBLOX_DEV_API_KEY`.

- [ ] **Step 4: Verify zero retained artifacts on the main run**

- [ ] **Step 5: Hand off to real-device playtest**

Do not call visual acceptance complete until published DEV evidence confirms: no glitchy grass, NPC roles readable, three activities discoverable without developer instruction, visible world-state change, rewards update progression, and no R5 rendering regression.
