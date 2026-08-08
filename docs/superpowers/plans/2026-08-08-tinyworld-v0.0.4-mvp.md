# TinyWorld v0.0.4 MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the v0.0.3 living-village prototype into a visually readable, multiplayer-testable TinyWorld MVP while preserving the server-authoritative progression and the no-pay-to-win north star.

**Architecture:** Keep WorldBuilder as the one-time server orchestration boundary, add a focused VillageSceneryBuilder for the civic core and road dressing, keep BoundaryBuilder as the shared capacity-aware perimeter, and expose only deterministic numeric geometry through WorldLayoutRules. Strengthen plots/houses and the client HUD without moving authority into the client or adding external assets.

**Tech Stack:** Luau, Roblox primitives and services, Rojo 7.7.0, Rokit, Luau CLI/analyzer/compiler, PowerShell regression guards, Roblox Studio Play and Server & Clients.

## Global Constraints

- Preserve the TinyWorld north star: **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**
- All production amendments go through source code, Git, Rojo sync, and Roblox publish flow; do not edit Studio source manually.
- Keep authoritative economy, progression, ownership, privacy, rewards, and trade validation on the server.
- Keep deterministic Roblox-service-free rules in src/shared and add a failing behavior test before changing gameplay rules.
- Do not add fake product/game-pass IDs, purchase prompts, ads, or pay-to-win power.
- Preserve schema-v2 migration compatibility unless a task explicitly adds and tests a migration.
- Keep broad gameplay surfaces and decorative overlays at explicit, non-coplanar heights.
- Keep the generated world bounded for requested capacities 1, 4, 8, 16, 32, 50, and 60.
- Keep unrelated user changes untouched and stage explicit paths only.

---

### Task 1: Lock stable surface ownership and commit the flicker fix

**Files:**
- Modify: src/server/WorldBuilder.luau:193-196,323-345
- Modify: tests/verify-roblox-materials.ps1:84-106
- Test: tests/verify-roblox-materials.ps1

**Interfaces:**
- WorldBuilder.build(maxPlayers: number?) must destroy a retained Workspace.Baseplate before creating TinyWorldGenerated.
- makeStoneBorder(model, "PlotBorder", origin + Vector3.new(0, 0.08, 0), width, depth) must keep the plot border visibly above the PlotBase top without sharing a plane.

- [x] **Step 1: Write the failing guard**

Require all of the following source contracts in the PowerShell guard: VillageGround and PlotBase use Enum.Material.Ground, Baseplate is destroyed, and PlotBorder is created with the explicit 0.08 vertical separation.

- [x] **Step 2: Run the guard to verify it fails on the old source**

Run from C:\Users\wilf6\dev\tinyworld:

~~~powershell
.\tests\verify-roblox-materials.ps1
~~~

Expected before the source change: a non-zero exit with the stable-surface message.

- [x] **Step 3: Implement the minimal source change**

Keep the generated ground material and insert the Baseplate removal before creating TinyWorldGenerated; offset only the plot border input origin by Vector3.new(0, 0.08, 0).

- [x] **Step 4: Run the focused guard to verify it passes**

Expected: exit 0 and the guard reports the valid Roblox material names, including Ground, Cobblestone, Rock, Basalt, Sand, and Water.

- [ ] **Step 5: Commit the isolated fix**

~~~powershell
git add src/server/WorldBuilder.luau tests/verify-roblox-materials.ps1
git commit -m "fix: separate generated village surfaces"
~~~

### Task 2: Add deterministic v0.0.4 layout and geometry budgets

**Files:**
- Modify: src/shared/WorldLayoutRules.luau
- Modify: tests/WorldLayoutRules.spec.luau
- Modify: tests/verify-roblox-materials.ps1
- Test: tests/WorldLayoutRules.spec.luau

**Interfaces:**
- WorldLayoutRules.create(maxPlayers: any): Layout returns the existing plot fields plus:
  - roads = { mainHalfLength: number, sideOffset: number, laneWidth: number };
  - civic = { fountain: PlotSlot, townHall: PlotSlot, market: PlotSlot, portal: PlotSlot };
  - budgets = { plots: number, boundaryTrees: number, roadParts: number, totalDecorations: number }.
- WorldLayoutRules.safeCount(value: any, minimum: number, maximum: number): number clamps invalid counts for builder callers.

- [ ] **Step 1: Write the failing layout tests**

Add deterministic assertions with the existing TestUtil helpers:

~~~lua
local layout = WorldLayoutRules.create(60)
TestUtil.equal(#layout.plotSlots, 60)
TestUtil.equal(layout.civic.fountain.x, 0)
TestUtil.isTrue(layout.roads.laneWidth >= 10)
TestUtil.isTrue(layout.budgets.totalDecorations <= 2200)
~~~

Also test invalid capacities (nil, 0, math.huge) and the current minimum-four behavior.

- [ ] **Step 2: Run the focused test to verify it fails**

~~~powershell
& "C:\Users\wilf6\scoop\apps\luau\current\luau.exe" tests\run.luau
~~~

Expected: failure because the new roads, civic, and budgets fields do not exist.

- [ ] **Step 3: Implement the smallest pure layout extension**

Derive civic positions from the existing core extent, derive road length from perimeterHalfExtent, and calculate bounded counts from the requested plot count. Do not create Roblox instances in this module.

- [ ] **Step 4: Run focused and full rule tests**

~~~powershell
& "C:\Users\wilf6\scoop\apps\luau\current\luau.exe" tests\run.luau
~~~

Expected: the new layout tests and all existing specs pass.

- [ ] **Step 5: Commit the layout contract**

~~~powershell
git add src/shared/WorldLayoutRules.luau tests/WorldLayoutRules.spec.luau tests/verify-roblox-materials.ps1
git commit -m "feat: add v0.0.4 world layout budgets"
~~~

### Task 3: Build the civic square and readable streets

**Files:**
- Create: src/server/VillageSceneryBuilder.luau
- Modify: src/server/WorldBuilder.luau:1-180,330-420
- Modify: src/server/VisualTheme.luau
- Modify: tests/verify-roblox-materials.ps1
- Test: tests/WorldLayoutRules.spec.luau

**Interfaces:**
- VillageSceneryBuilder.build(parent: Instance, layout: Layout): { roads: { Instance }, civic: { [string]: Instance } } creates scenery once and returns named anchors only.
- Every helper-created decoration sets CanCollide = false, CanTouch = false, and CanQuery = false; road lanes and the fountain square are the only new walkable surfaces.

- [ ] **Step 1: Add a failing static contract**

Extend the material guard to require VillageSceneryBuilder.luau, Enum.Material.Asphalt, Enum.Material.Cobblestone, VillageSquare, RoadNorth, RoadSouth, RoadEast, RoadWest, MarketStall, and Lantern. Run the guard and observe failure because the file does not exist.

- [ ] **Step 2: Create the minimal scenery builder**

Implement these helpers with stable positions derived from layout.roads and layout.civic:

~~~lua
local function makeDecoration(parent, name, size, position, color, material)
    local part = makePart(parent, name, size, position, color, material)
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    return part
end
~~~

Build one VillageSquare at the Ground top plus 0.08, four asphalt road lanes with 0.12 top clearance, four kerb strips, six lanterns, four flower clusters, two market stalls, and a small bench pair. Keep the prompt-bearing buildings owned by WorldBuilder; the new builder only dresses and connects them.

- [ ] **Step 3: Call the builder once from WorldBuilder.build**

Call VillageSceneryBuilder.build(root, layout) after the authoritative VillageGround and before plot/boundary construction. Do not call it from a player event.

- [ ] **Step 4: Run guard and Rojo build**

~~~powershell
.\tests\verify-roblox-materials.ps1
rojo build default.project.json --output "$env:TEMP\tinyworld-v004-civic.rbxlx"
~~~

Expected: exit 0 for both commands and a build containing the new server module.

- [ ] **Step 5: Commit the civic slice**

~~~powershell
git add src/server/VillageSceneryBuilder.luau src/server/WorldBuilder.luau src/server/VisualTheme.luau tests/verify-roblox-materials.ps1
git commit -m "feat: build v0.0.4 civic square and streets"
~~~

### Task 4: Improve plot borders, gates, gardens, and house readability

**Files:**
- Modify: src/server/WorldBuilder.luau:190-245
- Modify: src/server/PlotService.luau:115-235
- Modify: tests/verify-roblox-materials.ps1
- Test: tests/GoalRules.spec.luau

**Interfaces:**
- Plot geometry continues to be returned by WorldBuilder.buildPlot with the existing prompt fields unchanged.
- PlotService.rebuildHouse continues to accept (player: Player, profile) and remains the only owner-controlled visual rebuild entrypoint.

- [ ] **Step 1: Add failing border/house presentation guards**

Require a non-collidable PlotHedge/PlotGate decoration, a GardenBed approach, and explicit HouseFacade/HouseName construction. Keep the existing PlotBorder separation assertion.

- [ ] **Step 2: Add non-authoritative visual dressing**

Add four low stone/hedge runs beside the existing border, one gate opening aligned to the plot outsideCFrame, a short cobblestone approach, and tier-dependent porch/roof/flower variations. These parts must not create new prompts or mutate profile state.

- [ ] **Step 3: Verify the gameplay rules remain unchanged**

~~~powershell
& "C:\Users\wilf6\scoop\apps\luau\current\luau.exe" tests\run.luau
.\tests\verify-roblox-materials.ps1
~~~

Expected: all existing progression/ownership tests remain green and the guard passes.

- [ ] **Step 4: Commit the plot presentation**

~~~powershell
git add src/server/WorldBuilder.luau src/server/PlotService.luau tests/verify-roblox-materials.ps1 tests/GoalRules.spec.luau
git commit -m "feat: give TinyWorld plots readable gates and gardens"
~~~

### Task 5: Make the boundary feel like an edge of a world

**Files:**
- Modify: src/server/BoundaryBuilder.luau
- Modify: src/shared/WorldLayoutRules.luau
- Modify: tests/WorldLayoutRules.spec.luau
- Modify: tests/verify-roblox-materials.ps1
- Test: tests/WorldLayoutRules.spec.luau

**Interfaces:**
- BoundaryBuilder.build(parent: Instance, layout: Layout) remains the only boundary construction function.
- Returned landmarkPrompts and explorerPrompt keys remain woodlandTrail, cliffLookout, seaDock, and the existing board prompt.

- [ ] **Step 1: Add failing budget/placement tests**

For capacities 4, 16, and 60, assert the perimeter exceeds every plot bound, landmark coordinates lie outside the plot ring, and budgets.boundaryTrees remains bounded.

- [ ] **Step 2: Upgrade deterministic perimeter dressing**

Use the layout budget to add alternating woodland clearings, stepped rock/basalt cliff caps, explicit sand bands, and a wider non-collidable water belt. Leave the landmark center lanes open and preserve the daily route positions.

- [ ] **Step 3: Run focused/full tests and static guard**

~~~powershell
& "C:\Users\wilf6\scoop\apps\luau\current\luau.exe" tests\WorldLayoutRules.spec.luau
& "C:\Users\wilf6\scoop\apps\luau\current\luau.exe" tests\run.luau
.\tests\verify-roblox-materials.ps1
~~~

- [ ] **Step 4: Commit the boundary upgrade**

~~~powershell
git add src/server/BoundaryBuilder.luau src/shared/WorldLayoutRules.luau tests/WorldLayoutRules.spec.luau tests/verify-roblox-materials.ps1
git commit -m "feat: strengthen the living village boundary"
~~~

### Task 6: Present the v0.0.4 daily-life route in the HUD

**Files:**
- Modify: src/client/Main.client.luau
- Modify: src/shared/GoalRules.luau
- Modify: tests/GoalRules.spec.luau
- Modify: README.md

**Interfaces:**
- GoalRules.suggestedGoal(profile): string remains deterministic and server-owned.
- Main.client.luau remains presentation-only and reads the existing player attributes.

- [ ] **Step 1: Add failing goal tests**

Add cases that return a concise route after the current boundary/portal/civic proof is complete, while retaining existing setup, carrot, Courier, bike, upgrade, portal, fund, and boundary precedence.

- [ ] **Step 2: Implement the minimal goal/copy update**

Add a v0.0.4 title and a short TODAY line that renders the next server-suggested action plus active parcel state. Do not add client-side reward checks or duplicate authoritative state.

- [ ] **Step 3: Run the full rule suite and compile the client**

~~~powershell
& "C:\Users\wilf6\scoop\apps\luau\current\luau.exe" tests\run.luau
& "C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe" src\client\Main.client.luau
~~~

- [ ] **Step 4: Commit the HUD route**

~~~powershell
git add src/client/Main.client.luau src/shared/GoalRules.luau tests/GoalRules.spec.luau README.md
git commit -m "feat: clarify the TinyWorld daily-life route"
~~~

### Task 7: Run the multiplayer and live release gate

**Files:**
- Create: docs/v0.0.4-mvp-test.md
- Modify: docs/progress.md
- Modify: README.md

**Interfaces:**
- The test document must distinguish local static proof, Studio single-player proof, Studio Server & Clients proof, and remote family/device proof.
- Progress entries must name the exact commit/SHA and never claim a gate that was not observed.

- [ ] **Step 1: Run every local gate on the release tree**

~~~powershell
& "C:\Users\wilf6\scoop\apps\luau\current\luau.exe" tests\run.luau
& "C:\Users\wilf6\scoop\apps\luau\current\luau-analyze.exe" src\shared tests
Get-ChildItem src\server\*.luau | ForEach-Object { & "C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe" $_.FullName }
Get-ChildItem src\client\*.luau | ForEach-Object { & "C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe" $_.FullName }
.\tests\verify-roblox-materials.ps1
rojo build default.project.json --output "$env:TEMP\tinyworld-v004-release.rbxlx"
git diff --check
~~~

- [ ] **Step 2: Sync and start fresh single-player Play**

From C:\Users\wilf6\dev\tinyworld, keep rojo serve running on localhost:34872, connect the Studio plugin, and sync the project. Open the TinyWorld Dev place rather than AutoRecovery, press Play, and capture the v0.0.4 HUD, no-red-Output state, plot border, civic square, and boundary transition.

- [ ] **Step 3: Run Studio Server & Clients**

Start two clients, confirm separate plot ownership and visible avatars, walk both through the civic streets, join opposite Trading Post sides, select valid offers, confirm, and verify the exchange occurs once. Test an owner privacy change and a non-owner denial.

- [ ] **Step 4: Test persistence and boundary movement**

Stop/rejoin, verify saved identity/progression/inventory/home/privacy/route state, and walk across village ground, plot border, house approach, road, woodland, cliff, sand, and sea edge. Treat any movement shimmer or red Output message as a release blocker.

- [ ] **Step 5: Publish and record exact evidence**

Publish only the Rojo-synced release tree to the limited TinyWorld Dev experience. Record the commit SHA, Studio Output result, test mode, screenshots, and any remaining remote-device gate in docs/v0.0.4-mvp-test.md and docs/progress.md.

- [ ] **Step 6: Commit the evidence documentation**

~~~powershell
git add docs/v0.0.4-mvp-test.md docs/progress.md README.md
git commit -m "docs: record v0.0.4 MVP release evidence"
~~~
