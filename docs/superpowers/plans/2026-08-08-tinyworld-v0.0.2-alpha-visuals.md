# TinyWorld v0.0.2 Alpha Visuals Implementation Plan

> For agentic workers: REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

Goal: Fix the stale suggested-goal regression and turn the current TinyWorld playable slice into a polished, low-cost v0.0.2 alpha visual candidate for family testing.

Architecture: Keep deterministic decision logic and pure hex palette tokens in src/shared, Roblox-native palette conversion/lighting in src/server/VisualTheme.luau, and visual construction in the existing WorldBuilder, PlotService, and client presentation scripts. Existing services, prompts, profile fields, rewards, and server authority remain unchanged.

Tech Stack: Luau, Roblox Studio, Rojo 7.7.0, Rokit, PowerShell, Git.

## Global Constraints

- Preserve the current v0.01/v0.0.1 gameplay contract and server-authoritative interactions.
- Use only Roblox-native Parts, simple shapes, materials, lighting, and UI primitives; no remote asset downloads.
- Keep decorative generation fixed and bounded for phone/tablet play.
- Label the candidate v0.0.2 / alpha in player-facing UI and docs.
- Keep PR #1 open and draft; local branch integration must not alter remote PR state.
- Run the full available verification set before claiming completion or committing the candidate.

---

### Task 1: Commit the approved design and create the candidate branch

Files:
- Create: docs/superpowers/specs/2026-08-08-tinyworld-v0.0.2-alpha-visuals-design.md
- Create: docs/superpowers/plans/2026-08-08-tinyworld-v0.0.2-alpha-visuals.md

Interfaces:
- Consumes: the clean feat/v0.1-foundation checkout and the committed v0.0.2 design.
- Produces: local main containing the v0.0.1 baseline and local branch feat/v0.0.2-alpha for all candidate changes.

- [ ] Step 1: Review the design and plan files for placeholders and contradictions

Run:

    Get-Content docs/superpowers/specs/2026-08-08-tinyworld-v0.0.2-alpha-visuals-design.md,docs/superpowers/plans/2026-08-08-tinyworld-v0.0.2-alpha-visuals.md | Where-Object { $_ -notmatch 'Get-Content' } | Select-String -Pattern 'TBD|TODO|FIXME|Similar to Task'

Expected: no output.

- [ ] Step 2: Commit the approved design and plan on the current v0.1 foundation branch

    git add docs/superpowers/specs/2026-08-08-tinyworld-v0.0.2-alpha-visuals-design.md docs/superpowers/plans/2026-08-08-tinyworld-v0.0.2-alpha-visuals.md
    git commit -m "docs: design TinyWorld v0.0.2 alpha visuals"

- [ ] Step 3: Merge the v0.0.1 foundation into local main

    git switch main
    git merge --no-ff feat/v0.1-foundation -m "merge: promote TinyWorld v0.0.1 foundation"

Expected: local main contains the v0.1 foundation history; do not push or close PR #1.

- [ ] Step 4: Create and switch to the v0.0.2 candidate branch

    git switch -c feat/v0.0.2-alpha

Expected: git branch --show-current prints feat/v0.0.2-alpha.

### Task 2: Add the stale-goal regression test and shared rule boundary

Files:
- Create: tests/GoalRules.spec.luau
- Create: src/shared/GoalRules.luau
- Modify: tests/run.luau
- Modify: src/server/PlayerStateService.luau

Interfaces:
- Consumes: ProfileSchema.new() and HouseCatalog.get().
- Produces: GoalRules.suggestedGoal(profile): string, used by PlayerStateService.sync.

- [ ] Step 1: Write the failing regression test before implementation

The test must cover these exact states:

    local profile = ProfileSchema.new()
    profile.onboardingComplete = true
    profile.inventory.Carrot = 1
    profile.courierXp = 100
    profile.courierLevel = 2
    profile.ownsTinyBike = true
    profile.houseTier = 1

    profile.level = 1
    profile.coins = 100
    TestUtil.equal(GoalRules.suggestedGoal(profile), "Reach level 2 and upgrade your home.")

    profile.level = 2
    profile.coins = 100
    TestUtil.equal(GoalRules.suggestedGoal(profile), "Save 250 coins and upgrade your home.")

    profile.level = 4
    profile.coins = 900
    TestUtil.equal(GoalRules.suggestedGoal(profile), "Upgrade your home to Cosy Cottage.")

Also retain checks for onboarding, fountain/carrot, courier, bike, portal, and completed-life fallback priorities.

- [ ] Step 2: Run the suite and capture the expected red result

    & 'C:\Users\wilf6\scoop\apps\luau\current\luau.exe' tests\run.luau

Expected before the module exists: the new spec cannot require GoalRules.

- [ ] Step 3: Implement the minimal pure goal rule

GoalRules.suggestedGoal must use the next HouseCatalog tier:

    local nextHouse = HouseCatalog.get(profile.houseTier + 1)
    if nextHouse then
        if profile.level < nextHouse.requiredLevel then
            return string.format("Reach level %d and upgrade your home.", nextHouse.requiredLevel)
        end
        if profile.coins < nextHouse.price then
            return string.format("Save %d coins and upgrade your home.", nextHouse.price)
        end
        return "Upgrade your home to " .. nextHouse.name .. "."
    end

Preserve the existing priority order before the home branch.

- [ ] Step 4: Delegate PlayerStateService to the shared rule

Require GoalRules from the replicated shared folder and replace the local duplicated decision tree with GoalRules.suggestedGoal(profile).

- [ ] Step 5: Run the suite green

    & 'C:\Users\wilf6\scoop\apps\luau\current\luau.exe' tests\run.luau

Expected: TinyWorld tests passed: 12 specs.

- [ ] Step 6: Commit the regression fix

    git add src/shared/GoalRules.luau src/server/PlayerStateService.luau tests/GoalRules.spec.luau tests/run.luau
    git commit -m "fix: correct stale home upgrade goal"

### Task 3: Add the shared visual theme and lighting baseline

Files:
- Create: src/shared/VisualPalette.luau
- Create: src/server/VisualTheme.luau
- Modify: src/server/WorldBuilder.luau
- Modify: tests/verify-roblox-materials.ps1 only if a newly used material requires an explicit guard entry.

Interfaces:
- Consumes: pure hex tokens from VisualPalette and Roblox Lighting service during server startup/world build.
- Produces: VisualTheme.Colors, VisualTheme.configureLighting(), and one palette shared by world and UI.

- [ ] Step 1: Add VisualTheme palette and lighting configuration

Use named hex tokens for meadow, path, timber, cream, roof, berry, sky, water, gold, portal, and ink in VisualPalette. Convert them with Color3.fromHex in VisualTheme, then configure a sunny daytime Lighting setup, Atmosphere, ColorCorrectionEffect, and restrained BloomEffect once, reusing existing instances if the world rebuilds.

- [ ] Step 2: Route world labels and primary materials through the theme

Keep prompt behaviour unchanged. Update label cards with rounded corners, outline, consistent font, and theme colours. Ensure purely decorative pieces have CanCollide = false where safe.

- [ ] Step 3: Build and run the material guard

    powershell -NoProfile -ExecutionPolicy Bypass -File tests\verify-roblox-materials.ps1
    & 'C:\Users\wilf6\.rokit\bin\rojo.exe' build default.project.json --output "$env:TEMP\tinyworld-v0.0.2-theme.rbxlx"

Expected: the material guard lists only valid Roblox materials and Rojo exits 0.

- [ ] Step 4: Commit the theme baseline

git add src/shared/VisualPalette.luau src/server/VisualTheme.luau src/server/WorldBuilder.luau tests/verify-roblox-materials.ps1
    git commit -m "feat: add TinyWorld alpha visual theme"

### Task 4: Dress the village plaza, roads, and terrain

Files:
- Modify: src/server/WorldBuilder.luau

Interfaces:
- Consumes: VisualTheme, VisualPalette, and existing makePart, makeLabel, and prompt helpers.
- Produces: fixed-count decorative plaza, path, tree, flower, shrub, stone, and landmark trim geometry with no new gameplay state.

- [ ] Step 1: Add bounded helper constructors

Add small helpers for a decorative tree, flower cluster, stone border, roof/awning, window, doorway, and interaction marker. Each helper accepts a parent and world position, creates anchored geometry, and returns the primary part where needed.

- [ ] Step 2: Improve the spawn plaza and fountain surround

Add a circular-looking stepped plaza using a fixed ring of wedge/cylinder/simple parts, a fountain base, planted corners, and a clear open approach to the existing daily prompt.

- [ ] Step 3: Improve roads and add low-density terrain dressing

Add path edging and fixed decoration clusters around the existing cross roads and plot approaches. Keep the central routes unobstructed and avoid decorative parts over prompt objects.

- [ ] Step 4: Improve building silhouettes and signs

Replace each amenity's visual single block with a simple facade, roof, door, windows, trim, awning, and colour-coded sign while retaining the same named prompt parts and positions.

- [ ] Step 5: Build and inspect the generated place artifact

    & 'C:\Users\wilf6\.rokit\bin\rojo.exe' build default.project.json --output "$env:TEMP\tinyworld-v0.0.2-village.rbxlx"

Expected: Rojo exits 0; no new invalid material references are introduced.

- [ ] Step 6: Commit the village presentation slice

    git add src/server/WorldBuilder.luau
    git commit -m "feat: dress TinyWorld village for alpha"

### Task 5: Improve plot presentation and house tiers

Files:
- Modify: src/server/PlotService.luau

Interfaces:
- Consumes: existing plot assignment, HouseCatalog, and VisualTheme.
- Produces: more expressive house/plot geometry while keeping HouseUpgrade.tryUpgrade and all prompt authority unchanged.

- [ ] Step 1: Add tier-safe house details

Add front door, porch/steps, windows, roof trim, lamp, flower boxes, and plot edging. Gate upper features and larger details by the existing tier so every successful upgrade is visually distinct.

- [ ] Step 2: Preserve ownership/privacy labels

Keep displayNameFor, privacy text, house names, and the existing identity refresh connection. Update label styling only; do not change access rules.

- [ ] Step 3: Run the pure suite and Rojo build

    & 'C:\Users\wilf6\scoop\apps\luau\current\luau.exe' tests\run.luau
    & 'C:\Users\wilf6\.rokit\bin\rojo.exe' build default.project.json --output "$env:TEMP\tinyworld-v0.0.2-homes.rbxlx"

Expected: 12 specs pass and Rojo exits 0.

- [ ] Step 4: Commit house/plot presentation

    git add src/server/PlotService.luau
    git commit -m "feat: polish TinyWorld homes and plots"

### Task 6: Polish the HUD and onboarding presentation

Files:
- Modify: src/client/Main.client.luau
- Modify: src/client/Onboarding.client.luau

Interfaces:
- Consumes: existing replicated player attributes, VisualPalette, and onboarding RemoteEvent.
- Produces: responsive v0.0.2 alpha HUD/onboarding visuals with no new client authority.

- [ ] Step 1: Restyle the HUD card

Add theme-compatible header/accent treatment, clearer typography hierarchy, subtle borders, a distinct goal area, and mobile-safe size constraints. Change the title to TINYWORLD • v0.0.2 ALPHA.

- [ ] Step 2: Correct and emphasize the suggested goal

Continue rendering TinyWorldSuggestedGoal from the server, including parcel-active state. Do not compute goal logic on the client. The Level 4/900-coin screenshot state must display Upgrade your home to Cosy Cottage. after the server fix.

- [ ] Step 3: Restyle onboarding

Require VisualPalette through the existing replicated shared folder, convert its tokens with Color3.fromHex, and use the same palette, rounded cards, selected-state colours, clearer option grouping, and mobile-safe constraints while retaining the name/style/outfit validation and submission flow.

- [ ] Step 4: Parse-check and Rojo-build the client changes

    $compiler = 'C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe'
    Get-ChildItem src,tests -Recurse -Filter *.luau | ForEach-Object { & $compiler --only-parse $_.FullName }
    if ($LASTEXITCODE -ne 0) { throw 'Luau parse check failed' }
    & 'C:\Users\wilf6\.rokit\bin\rojo.exe' build default.project.json --output "$env:TEMP\tinyworld-v0.0.2-ui.rbxlx"

Expected: every file parses and Rojo exits 0.

- [ ] Step 5: Commit the UI presentation

    git add src/client/Main.client.luau src/client/Onboarding.client.luau
    git commit -m "feat: polish TinyWorld alpha HUD and onboarding"

### Task 7: Improve the portal, Giant Kitchen, and interaction readability

Files:
- Modify: src/server/WorldBuilder.luau
- Modify: src/server/JobService.luau only if the existing parcel visual needs a presentation-only adjustment.

Interfaces:
- Consumes: existing portal/crystal/courier prompt objects and VisualTheme.
- Produces: portal frame, arrival platform, crystal pedestals, better steps/props, courier depot/destination visuals, and consistent prompt markers.

- [ ] Step 1: Decorate the village portal without changing its prompt

Frame the existing VillagePortal with simple side pillars, an overhead arch, small lights, and a clear approach. Keep villagePortalPrompt as the only entry trigger.

- [ ] Step 2: Dress the Giant Kitchen route

Add a clear arrival platform, crystal pedestals/stands, table-edge details, safe stepped route, and a styled return portal around the existing crystal and return prompts.

- [ ] Step 3: Make courier pickup and delivery visually coherent

Use the same depot/shop colours and parcel station treatment. Preserve pickup/delivery reward code and prompt connections.

- [ ] Step 4: Run tests, material guard, and build

    & 'C:\Users\wilf6\scoop\apps\luau\current\luau.exe' tests\run.luau
    powershell -NoProfile -ExecutionPolicy Bypass -File tests\verify-roblox-materials.ps1
    & 'C:\Users\wilf6\.rokit\bin\rojo.exe' build default.project.json --output "$env:TEMP\tinyworld-v0.0.2-showcase.rbxlx"

Expected: 12 specs pass, materials are valid, and Rojo exits 0.

- [ ] Step 5: Commit the showcase pass

    git add src/server/WorldBuilder.luau src/server/JobService.luau
    git commit -m "feat: polish TinyWorld portal and courier showcase"

### Task 8: Add the family alpha test checklist and progress record

Files:
- Create: docs/v0.0.2-alpha-test.md
- Modify: docs/progress.md
- Modify: README.md

Interfaces:
- Consumes: the ten visual improvement acceptance points and existing remote Studio test guide.
- Produces: a repeatable manual acceptance script and versioned handoff documentation.

- [ ] Step 1: Write the ten-point family test checklist

For each improvement, include a short action, what the child should notice, and an observation field. Include gameplay regression checks for onboarding, fountain, garden, courier, bike, plot/home, privacy/visit, trade, portal, and Studio Output.

- [ ] Step 2: Update README release language

Add a v0.0.2 alpha section linking the checklist and state that visuals are a candidate for testing, not a final public release.

- [ ] Step 3: Record the implementation milestone in progress.md

Record the branch, candidate version, ten visual areas, automated verification results, and the remaining requirement for fresh Studio screenshots/device observations.

- [ ] Step 4: Commit the handoff docs

    git add docs/v0.0.2-alpha-test.md docs/progress.md README.md
    git commit -m "docs: add TinyWorld v0.0.2 alpha playtest guide"

### Task 9: Run the complete verification gate and prepare Studio handoff

Files:
- No source changes expected unless a verification failure identifies a real defect.

- [ ] Step 1: Run the complete pure test suite

    & 'C:\Users\wilf6\scoop\apps\luau\current\luau.exe' tests\run.luau

Expected: TinyWorld tests passed: 12 specs.

- [ ] Step 2: Run shared/test analysis

    & 'C:\Users\wilf6\scoop\apps\luau\current\luau-analyze.exe' src\shared tests

Expected: no diagnostics for the pure shared/test scope.

- [ ] Step 3: Run parse, material, build, and diff checks

    $compiler = 'C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe'
    Get-ChildItem src,tests -Recurse -Filter *.luau | ForEach-Object { & $compiler --only-parse $_.FullName }
    if ($LASTEXITCODE -ne 0) { throw 'Luau parse check failed' }
    powershell -NoProfile -ExecutionPolicy Bypass -File tests\verify-roblox-materials.ps1
    & 'C:\Users\wilf6\.rokit\bin\rojo.exe' build default.project.json --output "$env:TEMP\tinyworld-v0.0.2-final.rbxlx"
    git diff --check

Expected: all commands exit 0.

- [ ] Step 4: Verify branch and PR invariants

    git status --short --branch
    git branch --show-current
    gh pr view 1 --json number,state,isDraft,headRefName,baseRefName,url

Expected: current branch is feat/v0.0.2-alpha; PR #1 remains open and draft; no uncommitted files remain.

- [ ] Step 5: Give the user the Studio test batch

The handoff must tell the user to keep rojo serve running, sync the new branch, press Play, check the HUD goal, inspect the ten visual points, run the gameplay regression route, and paste the Output pane or screenshot. Do not claim visual acceptance until that evidence exists.
