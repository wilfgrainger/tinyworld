# TinyWorld v0.0.5–v0.0.7 Release Train Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (\`- [ ]\`) syntax for tracking.

**Goal:** Ship the storybook cosmetic overhaul, queue/session persistence hardening, scale foundations, and an evidence-ready girls-at-scale playtest route on main without changing the existing gameplay contract.

**Architecture:** The visual work stays in the existing Roblox-native palette, world-builder, plot-builder, and client-HUD boundaries. Persistence becomes a single server adapter with an in-memory per-player state machine, coalesced saves, conditional session leases, retry/backoff, and bounded shutdown flushing; deterministic rules remain in src/shared so Luau CLI tests can exercise them without Roblox services. v0.0.7 adds documentation, diagnostics, and acceptance evidence rather than another large gameplay system.

**Tech Stack:** Luau, Roblox server/client APIs, Roblox DataStoreService, Rojo, Rokit/Luau CLI, PowerShell source guards, Git.

## Global Constraints

- Preserve the north star: Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.
- v0.0.5 is cosmetic-only: no reward, progression, ownership, privacy, trade, transport, profile-schema, or monetisation changes.
- Keep authoritative economy/progression logic on the server and keep client code read-only.
- Preserve schema-v2 migration compatibility and the current normalized profile shape/version.
- Never replace inaccessible saved data with a fresh profile after a DataStore failure.
- Never add fake Roblox product/game-pass IDs or pay-to-win power.
- Use Roblox-native primitives/materials/UI; do not add an unverified external asset pipeline.
- Keep visual geometry bounded by explicit layout budgets and avoid unstable overlapping surfaces.
- Use a failing test or source guard before each production implementation slice.
- Run luau tests/run.luau, luau-analyze src/shared/*.luau tests/*.luau, luau-compile src/server/*.luau, luau-compile src/client/*.luau, and the Roblox material guard before release claims.
- Preserve unrelated user changes; stage explicit paths only.
- All Studio changes flow through source → Git → Rojo → Studio → publish; no manual source edits in Studio.
- The final branch target is main; local implementation commits must be pushed and the published place must be verified separately from the push.

---

## Task 1: Establish visual and capacity budget contracts

**Files:**
- Create: src/shared/VisualBudgetRules.luau
- Create: tests/VisualBudgetRules.spec.luau
- Modify: tests/run.luau
- Modify: src/shared/WorldLayoutRules.luau
- Modify: tests/WorldLayoutRules.spec.luau

**Interfaces:**
- VisualBudgetRules.forPlayers(plotCount: number, boundaryTrees: number): { totalDecorations: number, perPlotDecorations: number, boundaryDecorations: number, billboards: number, interactionMarkers: number }
- VisualBudgetRules.isWithinBudget(budget: table): boolean
- WorldLayoutRules.create(maxPlayers) adds budgets.visual using the same calculation.

- [ ] Step 1: Write the failing budget tests.

Create tests/VisualBudgetRules.spec.luau:

~~~lua
local TestUtil = require("./TestUtil")
local VisualBudgetRules = require("../src/shared/VisualBudgetRules")

return function()
    local four = VisualBudgetRules.forPlayers(4, 16)
    TestUtil.equal(four.perPlotDecorations, 24)
    TestUtil.isTrue(VisualBudgetRules.isWithinBudget(four))

    local sixty = VisualBudgetRules.forPlayers(60, 180)
    TestUtil.equal(sixty.perPlotDecorations, 24)
    TestUtil.isTrue(sixty.totalDecorations <= 4200)
    TestUtil.isTrue(sixty.boundaryDecorations <= 900)
    TestUtil.isTrue(VisualBudgetRules.isWithinBudget(sixty))

    local over = { totalDecorations = 4201, perPlotDecorations = 24, boundaryDecorations = 100, billboards = 10, interactionMarkers = 10 }
    TestUtil.isFalse(VisualBudgetRules.isWithinBudget(over))
end
~~~

Add the spec to tests/run.luau.

- [ ] Step 2: Run the focused test to confirm RED.

Run luau tests/VisualBudgetRules.spec.luau. Expected: FAIL because VisualBudgetRules does not exist.

- [ ] Step 3: Implement the deterministic budget module.

Create src/shared/VisualBudgetRules.luau with these limits and formulas:

~~~lua
local VisualBudgetRules = {
    MAX_TOTAL_DECORATIONS = 4200,
    MAX_PER_PLOT_DECORATIONS = 24,
    MAX_BOUNDARY_DECORATIONS = 900,
    MAX_BILLBOARDS = 180,
    MAX_INTERACTION_MARKERS = 180,
}

function VisualBudgetRules.forPlayers(plotCount: number, boundaryTrees: number)
    local safePlots = math.max(4, math.floor(plotCount))
    local safeTrees = math.max(4, math.floor(boundaryTrees))
    return {
        totalDecorations = (safePlots * VisualBudgetRules.MAX_PER_PLOT_DECORATIONS) + (safeTrees * 3) + 360,
        perPlotDecorations = VisualBudgetRules.MAX_PER_PLOT_DECORATIONS,
        boundaryDecorations = safeTrees * 3,
        billboards = math.min(VisualBudgetRules.MAX_BILLBOARDS, safePlots + 60),
        interactionMarkers = math.min(VisualBudgetRules.MAX_INTERACTION_MARKERS, safePlots * 3),
    }
end

function VisualBudgetRules.isWithinBudget(budget): boolean
    return budget.totalDecorations <= VisualBudgetRules.MAX_TOTAL_DECORATIONS
        and budget.perPlotDecorations <= VisualBudgetRules.MAX_PER_PLOT_DECORATIONS
        and budget.boundaryDecorations <= VisualBudgetRules.MAX_BOUNDARY_DECORATIONS
        and budget.billboards <= VisualBudgetRules.MAX_BILLBOARDS
        and budget.interactionMarkers <= VisualBudgetRules.MAX_INTERACTION_MARKERS
end

return VisualBudgetRules
~~~

Import it from WorldLayoutRules and set budgets.visual = VisualBudgetRules.forPlayers(target, boundaryTrees), retaining all existing v0.0.4 budget fields.

- [ ] Step 4: Run the focused and existing tests.

Run luau tests/VisualBudgetRules.spec.luau and luau tests/run.luau. Expected: PASS.

- [ ] Step 5: Commit the budget contract.

~~~powershell
git add src/shared/VisualBudgetRules.luau src/shared/WorldLayoutRules.luau tests/VisualBudgetRules.spec.luau tests/WorldLayoutRules.spec.luau tests/run.luau
git commit -m "test: define TinyWorld visual capacity budgets"
~~~

## Task 2: Implement the v0.0.5 storybook visual pass

**Files:**
- Modify: src/shared/VisualPalette.luau
- Modify: src/server/VisualTheme.luau
- Modify: src/server/VillageSceneryBuilder.luau
- Modify: src/server/BoundaryBuilder.luau
- Modify: src/server/WorldBuilder.luau
- Modify: src/server/PlotService.luau
- Modify: src/client/Main.client.luau
- Modify: tests/verify-roblox-materials.ps1
- Create: docs/v0.0.5-cosmetic-test.md

**Interfaces:**
- Existing builder return tables and prompt instances remain unchanged.
- New decorative helpers are private to their builder files and return anchored, non-interactive Part instances or models.
- Main.client.luau continues to read the existing player attributes only.

- [ ] Step 1: Add a failing source guard for the v0.0.5 presentation contract.

Extend tests/verify-roblox-materials.ps1 with this guard:

~~~powershell
$visualTheme = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\VisualTheme.luau")
$hud = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\client\Main.client.luau")
$scenery = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\VillageSceneryBuilder.luau")
if ($visualTheme -notmatch 'TinyWorldColorGrade' -or
    $visualTheme -notmatch 'TinyWorldAtmosphere' -or
    $hud -notmatch 'STORYBOOK' -or
    $hud -notmatch 'UIGradient' -or
    $scenery -notmatch 'VillagePlanter' -or
    $scenery -notmatch 'MarketBanner') {
    Write-Output "The v0.0.5 storybook presentation contract is incomplete."
    exit 1
}
~~~

Run powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-roblox-materials.ps1. Expected: FAIL with the new contract message.

- [ ] Step 2: Extend semantic palette and lighting tokens.

Add semantic tokens to VisualPalette.luau for creamDeep, woodLight, roofLight, waterHighlight, pathLight, leafLight, inkGlass, and portalGlow. In VisualTheme.configureLighting, retain safe Roblox properties and use a soft daytime diorama configuration:

~~~lua
atmosphere.Density = 0.14
atmosphere.Offset = 0.25
atmosphere.Glare = 0.04
atmosphere.Haze = 0.55
correction.Contrast = 0.08
correction.Saturation = 0.1
bloom.Intensity = 0.06
~~~

Do not set Lighting.Technology in a Play-session script.

- [ ] Step 3: Add bounded civic and route dressing.

In VillageSceneryBuilder.luau, add private helpers named makePlanter, makeMarketBanner, makePavingInset, and makeStreetCluster. They create anchored Roblox-native decoration, set CanCollide/CanTouch/CanQuery false, and use only existing route positions. Call them within layout.budgets.visual and keep roads and the square as the stable walkable surfaces.

- [ ] Step 4: Improve destination silhouettes without changing prompts.

In WorldBuilder.luau, extend amenity with a stone footing, side trim, shutter panels, supported awning, sign bracket, and two small planters. Keep building names, prompt parents, positions, and return values unchanged. Improve makePortalFrame with a non-collidable glow ring while keeping the existing VillagePortal prompt part.

In BoundaryBuilder.luau, add bounded makeRockCluster, makeReedCluster, and makeDockRail helpers at existing landmark positions. Do not add prompts or alter landmark positions. Keep water, sand, rock, basalt, and tree geometry vertically separated.

- [ ] Step 5: Improve plot and home presentation while preserving contracts.

In WorldBuilder.buildPlot, add only non-interactive dressing around existing plot surfaces: two low fence runs with a gate opening, a short path inset, an owner-sign/mailbox silhouette, and a garden trellis. Leave PlotBase, PlotBorder, GardenBed1–3, UpgradeKiosk, PrivacyKiosk, VisitKiosk, and HomeCharmKiosk names and positions intact.

In PlotService.rebuildHouse, preserve existing parts and add stable cosmetic layers: roof ridge/edge trim, two shutter panels per front window, a tier-coloured flower box, and a side garden for tiers 2–5. Do not add data fields, alter HouseCatalog, change tier prices, or change prompt behaviour.

- [ ] Step 6: Improve the HUD without changing its data contract.

In Main.client.luau:
- Change the eyebrow/title copy to TODAY / STORYBOOK ALPHA and TINYWORLD | v0.0.5 STORYBOOK VILLAGE.
- Add a UIGradient to the panel and status message using existing palette tokens.
- Add UIStroke/corner treatments to stats and goal rows, keeping existing labels and attributes.
- Add a static YOUR TINY LIFE section label without new player data.
- Keep the observed attribute list and server-only values unchanged.
- Keep the goal card within the existing size constraint and away from prompts.

- [ ] Step 7: Add the v0.0.5 manual test route.

Create docs/v0.0.5-cosmetic-test.md with exact steps to start rojo serve at the repository root, connect Studio to localhost:34872, capture spawn/fountain/plot/civic/portal/boundary screenshots, check Output for red errors, check for grass/plot-border flicker, check prompt access and collision, and run the existing reward, garden, courier, bike, privacy, trade, portal, living-world, and boundary routes. Stop, rejoin, and confirm existing profile values persist.

- [ ] Step 8: Run source checks and commit the cosmetic slice.

~~~powershell
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/*.luau
luau-compile src/client/*.luau
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-roblox-materials.ps1
~~~

Expected: all commands pass.

~~~powershell
git add src/shared/VisualPalette.luau src/server/VisualTheme.luau src/server/VillageSceneryBuilder.luau src/server/BoundaryBuilder.luau src/server/WorldBuilder.luau src/server/PlotService.luau src/client/Main.client.luau tests/verify-roblox-materials.ps1 docs/v0.0.5-cosmetic-test.md
git commit -m "feat: beautify TinyWorld village for v0.0.5"
~~~

## Task 3: Define the pure persistence/session state machine

**Files:**
- Create: src/shared/ProfileStoreRules.luau
- Create: tests/ProfileStoreRules.spec.luau
- Modify: tests/run.luau

**Interfaces:**
- ProfileStoreRules.SESSION_LEASE_SECONDS = 120
- ProfileStoreRules.SAVE_DEBOUNCE_SECONDS = 8
- ProfileStoreRules.RETRY_BASE_SECONDS = 5
- ProfileStoreRules.RETRY_MAX_SECONDS = 60
- ProfileStoreRules.MAX_RETRIES = 5
- ProfileStoreRules.isLeaseActive(session, now, ownerToken): boolean
- ProfileStoreRules.retryDelay(attempt, jitter): number
- ProfileStoreRules.shouldRetry(attempt): boolean
- ProfileStoreRules.nextSaveState(currentState, event): string

- [ ] Step 1: Write failing persistence-rule tests.

Create tests/ProfileStoreRules.spec.luau:

~~~lua
local TestUtil = require("./TestUtil")
local Rules = require("../src/shared/ProfileStoreRules")

return function()
    TestUtil.isTrue(Rules.isLeaseActive({ token = "a", expiresAt = 100 }, 99, "a"))
    TestUtil.isTrue(Rules.isLeaseActive({ token = "a", expiresAt = 100 }, 99, "b"))
    TestUtil.isFalse(Rules.isLeaseActive({ token = "a", expiresAt = 100 }, 101, "b"))
    TestUtil.isFalse(Rules.isLeaseActive(nil, 101, "b"))

    TestUtil.equal(Rules.retryDelay(0, 0), 5)
    TestUtil.equal(Rules.retryDelay(1, 0), 10)
    TestUtil.equal(Rules.retryDelay(5, 0), 60)
    TestUtil.equal(Rules.retryDelay(1, 0.5), 10.5)
    TestUtil.isTrue(Rules.shouldRetry(0))
    TestUtil.isFalse(Rules.shouldRetry(5))

    TestUtil.equal(Rules.nextSaveState("clean", "dirty"), "dirty")
    TestUtil.equal(Rules.nextSaveState("dirty", "scheduled"), "queued")
    TestUtil.equal(Rules.nextSaveState("saving", "success-current"), "clean")
    TestUtil.equal(Rules.nextSaveState("saving", "success-newer"), "queued")
    TestUtil.equal(Rules.nextSaveState("saving", "failure-retry"), "retrying")
    TestUtil.equal(Rules.nextSaveState("saving", "failure-final"), "failed")
end
~~~

Add the spec to tests/run.luau.

- [ ] Step 2: Run luau tests/ProfileStoreRules.spec.luau. Expected: FAIL because the module is absent.

- [ ] Step 3: Implement ProfileStoreRules.luau with the constants and exact functions above. Clamp exponential delay at RETRY_MAX_SECONDS, add the supplied jitter after clamping, treat expiresAt <= now as expired, and return the current state for unknown events.

- [ ] Step 4: Run luau tests/ProfileStoreRules.spec.luau and luau tests/run.luau. Expected: PASS.

- [ ] Step 5: Commit the persistence rules.

~~~powershell
git add src/shared/ProfileStoreRules.luau tests/ProfileStoreRules.spec.luau tests/run.luau
git commit -m "test: specify TinyWorld save and session rules"
~~~

## Task 4: Replace immediate profile writes with queued, leased persistence

**Files:**
- Modify: src/server/ProfileStore.luau
- Modify: src/server/Main.server.luau
- Modify: src/server/OnboardingService.luau
- Create: tests/verify-profile-store.ps1

**Interfaces:**
- ProfileStore.load(player: Player): profile? acquires a session lease and returns normalized profile or nil on load/conflict failure.
- ProfileStore.get(player: Player): profile? remains unchanged.
- ProfileStore.save(player: Player): boolean marks the current profile dirty and schedules one coalesced save; it does not synchronously issue a DataStore request.
- ProfileStore.saveNow(player: Player): boolean performs a bounded immediate save of the newest snapshot and refreshes the owned lease.
- ProfileStore.release(player: Player): boolean performs the final save, conditionally clears the owned lease, and then removes local state.
- ProfileStore.saveAll(): boolean performs bounded immediate saves for all active players.
- ProfileStore.shutdown(timeoutSeconds: number?): boolean flushes and conditionally releases all active sessions before the deadline.
- ProfileStore.getDiagnostics(player: Player?): table returns queue/session state only.

- [ ] Step 1: Add the failing adapter guard.

Create tests/verify-profile-store.ps1:

~~~powershell
$path = Join-Path $PSScriptRoot "..\src\server\ProfileStore.luau"
$source = Get-Content -Raw -LiteralPath $path
foreach ($pattern in @('UpdateAsync', 'GenerateGUID', 'SESSION_LEASE_SECONDS', 'SAVE_DEBOUNCE_SECONDS', 'task.delay', 'saveNow', 'getDiagnostics')) {
    if ($source -notmatch [regex]::Escape($pattern)) {
        Write-Output ("ProfileStore missing required hardening contract: " + $pattern)
        exit 1
    }
}
if ($source -match 'store:GetAsync') {
    Write-Output "ProfileStore must acquire the session and load the profile through UpdateAsync."
    exit 1
}
$main = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot "..\src\server\Main.server.luau")
if ($main -notmatch 'ProfileStore\.shutdown') {
    Write-Output "Main must use the bounded ProfileStore shutdown path."
    exit 1
}
Write-Output "ProfileStore hardening guard passed."
~~~

Run the guard. Expected: FAIL because the current adapter uses GetAsync and has no lease/queue API.

- [ ] Step 2: Implement envelope parsing and session acquisition.

In ProfileStore.luau require HttpService and ProfileStoreRules. Generate one token per load attempt with HttpService:GenerateGUID(false). Persist an envelope shaped as { profile = normalizedProfile, session = { token = token, expiresAt = number } }. Parse both the current raw profile shape and the new envelope so existing v5 data migrates without a schema bump.

Use store:UpdateAsync(key, callback) for load. Normalize previous.profile when present or previous for legacy data. Return nil when a different unexpired token owns the key; otherwise write the envelope with the new token and os.time() + SESSION_LEASE_SECONDS. Treat an UpdateAsync error or unresolved conflict as nil; never create a fresh local profile on failure.

Keep local runtime state separate from the persisted profile:

~~~lua
profiles[player] = {
    profile = profile,
    token = token,
    version = 0,
    savedVersion = 0,
    state = "clean",
    retryAttempt = 0,
    scheduled = false,
    releasing = false,
}
~~~

ProfileStore.get(player) returns record.profile.

- [ ] Step 3: Implement coalescing save scheduling.

ProfileStore.save returns false for no record or a releasing record; otherwise increments version, sets dirty, updates diagnostic attributes, and creates one task.delay callback using SAVE_DEBOUNCE_SECONDS. The callback clears scheduled and calls saveNow only when the record is still dirty.

saveNow snapshots ProfileSchema.normalize(record.profile) and the snapshot version, sets saving, and calls UpdateAsync. The callback refuses a different unexpired session and otherwise writes the snapshot while refreshing the owned token expiry. On success, savedVersion becomes the snapshot version; state is clean only when there is no newer mutation, otherwise queued and scheduled again.

No gameplay service may issue DataStore operations after this change; all persistence requests route through ProfileStore.save or explicit saveNow.

- [ ] Step 4: Implement retry, heartbeat, and release.

On transient saveNow failure increment retryAttempt. If ProfileStoreRules.shouldRetry is true, set retrying and schedule retryDelay(attempt, math.random()); otherwise set failed, warn with player name and state only, and retain the in-memory record.

After load schedule a heartbeat every SESSION_LEASE_SECONDS / 3. Refresh only the matching token with UpdateAsync. On a competing token or repeated failure set session diagnostics to lost, warn, and kick the player with a safe rejoin message.

release calls saveNow first. On success, conditionally clear the session with UpdateAsync only when the token matches. If final save or release fails, retain the lease until expiry, warn, return false, and remove local state only after the bounded attempt.

shutdown(timeoutSeconds) snapshots active players, calls saveNow and conditional release until os.clock() reaches the deadline, then returns whether all sessions resolved.

- [ ] Step 5: Add diagnostics and wire Main.

Set only these non-sensitive player attributes: TinyWorldSaveState, TinyWorldSaveVersion, TinyWorldSaveRetryAttempt, and TinyWorldSessionState.

Change Main.server.luau BindToClose to ProfileStore.shutdown(25). Keep PlayerRemoving cleanup order and use ProfileStore.release(player). Change onboarding’s validation checkpoint to ProfileStore.saveNow(player) so a failed first profile write rolls back onboarding fields; leave other ProfileStore.save calls as coalesced queue requests.

- [ ] Step 6: Run the adapter guard and static checks.

~~~powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/verify-profile-store.ps1
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/*.luau
~~~

Expected: PASS.

- [ ] Step 7: Commit persistence hardening.

~~~powershell
git add src/server/ProfileStore.luau src/server/Main.server.luau src/server/OnboardingService.luau tests/verify-profile-store.ps1
git commit -m "feat: harden TinyWorld profile queue and sessions"
~~~

## Task 5: Add scale diagnostics and v0.0.7 readiness documentation

**Files:**
- Modify: src/server/WorldBuilder.luau
- Modify: src/server/Main.server.luau
- Modify: src/client/Main.client.luau
- Modify: README.md
- Modify: docs/progress.md
- Create: docs/v0.0.6-persistence-scale-test.md
- Create: docs/v0.0.7-girls-scale-playtest.md
- Modify: tests/verify-roblox-materials.ps1

- [ ] Step 1: Add a failing scale-contract guard requiring WorldLayoutRules budgets.visual, WorldBuilder TinyWorldPlotCapacity, and WorldBuilder TinyWorldVisualBudget. Run the guard and expect RED.

- [ ] Step 2: After WorldLayoutRules.create and root creation, set TinyWorldPlotCapacity, TinyWorldVisualBudget, TinyWorldBuiltPlotCount, and TinyWorldScaleBudgetStatus from the actual layout. Keep them non-sensitive.

- [ ] Step 3: Create docs/v0.0.6-persistence-scale-test.md covering local commands, API Services prerequisite, burst-mutation queue test, stop/rejoin test, conflict test, shutdown diagnostics, and Studio-only capacity matrix for 1, 4, 8, 16, 32, 50, and 60.

- [ ] Step 4: Create docs/v0.0.7-girls-scale-playtest.md covering commit/branch/Rojo/publish fields, five-minute route, first-impression questions, functional and social questions, visual questions, stop conditions, and evidence separation.

- [ ] Step 5: Update README.md and docs/progress.md with links to the new spec, plan, v0.0.5 route, v0.0.6 persistence route, and v0.0.7 girls route; retain historical v0.01–v0.04 instructions.

- [ ] Step 6: Run the guard, Luau suite, and git diff --check, then commit:

~~~powershell
git add src/server/WorldBuilder.luau src/server/Main.server.luau src/client/Main.client.luau README.md docs/progress.md docs/v0.0.6-persistence-scale-test.md docs/v0.0.7-girls-scale-playtest.md tests/verify-roblox-materials.ps1
git commit -m "docs: prepare v0.0.7 scale playtest handoff"
~~~

## Task 6: Full verification, Rojo/Studio integration, publish, and main handoff

- [ ] Step 1: From a clean tree run luau tests/run.luau, luau-analyze src/shared/*.luau tests/*.luau, luau-compile src/server/*.luau, luau-compile src/client/*.luau, both PowerShell guards, and git diff --check. Record actual output.

- [ ] Step 2: Run rojo serve from the repository root, connect Studio to localhost:34872, and confirm the three synced source trees. Do not edit source in Studio.

- [ ] Step 3: In Studio run onboarding, reward, garden, courier, shop, bike mount/park, privacy, home upgrade, living-world pickup, boundary, portal, and trade with Output visible. Capture cosmetic and diagnostics evidence.

- [ ] Step 4: Run the v0.0.6 persistence route: burst mutations, inspect save attributes, stop/rejoin, verify visible profile fields, run the permitted conflict route, and run Server & Clients at supported local counts. Label this evidence local-only.

- [ ] Step 5: Publish the Rojo-synced place to the existing TinyWorld Dev experience. Record Studio save confirmation, local commit SHA, pushed branch SHA, and reopened/published evidence. Do not equate publish output alone with live parity.

- [ ] Step 6: Append only verified facts to docs/progress.md, fetch origin, verify no unrelated changes, push main, and confirm HEAD/origin/main/published source evidence.

- [ ] Step 7: Apply the completion gate requirement-by-requirement. If Studio/published evidence is missing, report the exact gap and keep the goal active rather than calling the release complete.

