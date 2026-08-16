# TinyWorld v0.7.0 Unified Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate PR #8, PR #12 and issue #11 into one production-quality TinyWorld v0.7.0 release, one free-only GitHub Actions workflow, and one automatic DEV publish path.

**Architecture:** Start from current `main` so the known-good Open Cloud DEV deployment remains authoritative. Import PR #8 production-art source and PR #12 coast/traversal source by content while deliberately rejecting their stale workflow/release files. Finish the remaining family-review scope with server-authoritative rules/services, then replace the three existing Actions workflows with one canonical workflow that tests, validates, builds and publishes directly to Roblox DEV without artifacts or caches.

**Tech Stack:** Roblox Luau, Rojo 7.7.0, Rokit 1.2.0, StyLua 2.5.2, Python 3 for deterministic art tooling, GitHub Actions standard public runners, Roblox Open Cloud Place Publishing API.

## Global Constraints

- Release identity is `v0.7.0`.
- Profile compatibility must preserve all v0.6.2 player state.
- Existing `ROBLOX_DEV_API_KEY` remains the only publishing credential surface.
- DEV Universe ID stays `10654114907`; DEV Place ID stays `76129528245924`.
- No automatic LIVE publishing.
- No `actions/upload-artifact`.
- No `actions/cache`.
- No larger/paid GitHub runners.
- No invented Roblox asset IDs.
- No client-authoritative economy, quest rewards, ownership, pets or progression.
- Finished hero art, NPCs, pets and vehicles must not be primitive placeholder geometry.

---

### Task 1: Import and reconcile the production-art release source

**Files:**
- Import from PR #8 head `d9516a293cf0eac7dcc06e5a883aec80e5f3c6df`: `art/**`, production-art server/shared modules, art tooling, asset manifest and v0.6.3 art tests/docs.
- Do **not** import PR #8 versions of `.github/workflows/**`, `config/release.json`, `config/environments/**`, `scripts/publish-dev.sh` or current-main free-only policy files.
- Modify: `src/server/Main.server.luau`
- Modify: `src/shared/ReleaseInfo.luau`
- Modify: `src/client/BuildStamp.client.luau`

**Interfaces:**
- Consumes: current-main world/service startup and DEV deployment configuration.
- Produces: `ProductionVisualService`, `ProductionVillageVisuals`, `ProductionArtCleanup`, `VillageLandscapeBuilder`, `VillageGroundRebuildBuilder`, `SpawnPresentationBuilder` integrated without owning gameplay authority.

- [ ] **Step 1: Bring forward all non-conflicting production-art files from PR #8**

Use the PR #8 changed-file list, excluding these stale/conflicting paths:

```text
.github/workflows/luau-tests.yml
.github/workflows/release-authority.yml
.github/workflows/rojo-build.yml
config/release.json
scripts/verify-release-contract.sh
src/server/Main.server.luau
src/shared/ReleaseInfo.luau
src/client/BuildStamp.client.luau
tests/build-contract.sh
tests/build-contract.ps1
```

Copy the remaining files byte-for-byte from `release/v0.6.3-production-art-world-craft`.

- [ ] **Step 2: Add a failing unified startup contract**

Create `tests/verify-v0.7.0-unified-source-contract.sh` with initial assertions:

```bash
#!/usr/bin/env bash
set -euo pipefail

grep -Fq 'ProductionArtCleanup' src/server/Main.server.luau
grep -Fq 'ProductionVisualService' src/server/Main.server.luau
grep -Fq 'ProductionVillageVisuals' src/server/Main.server.luau
grep -Fq 'productVersion": "0.7.0"' config/release.json
```

Run:

```bash
bash tests/verify-v0.7.0-unified-source-contract.sh
```

Expected: FAIL because v0.7.0 release identity and reconciled startup are not complete yet.

- [ ] **Step 3: Reconcile production-art startup into current main**

Keep current-main service order and add the production-art startup around world creation exactly once:

```lua
local ProductionArtCleanup = require(script.Parent:WaitForChild("ProductionArtCleanup"))
local VillageLandscapeBuilder = require(script.Parent:WaitForChild("VillageLandscapeBuilder"))
local VillageGroundRebuildBuilder = require(script.Parent:WaitForChild("VillageGroundRebuildBuilder"))
local SpawnPresentationBuilder = require(script.Parent:WaitForChild("SpawnPresentationBuilder"))
local ProductionVisualService = require(script.Parent:WaitForChild("ProductionVisualService"))
local ProductionVillageVisuals = require(script.Parent:WaitForChild("ProductionVillageVisuals"))

local world = WorldBuilder.build(Players.MaxPlayers)
ProductionArtCleanup.apply(world.root)
HomeStoreDestinationBuilder.extend(world)
local _productionLandscape = VillageLandscapeBuilder.build(world.root, world.layout)
VillageGroundRebuildBuilder.apply(world.root)
ImpossibleWorldBuilder.extend(world)
PortalMechanicBuilder.extend(world)
SpawnPresentationBuilder.apply(world.root)

local productionVisualService = ProductionVisualService.new()
ProductionVillageVisuals.apply(world, productionVisualService)
```

Do not duplicate any `WorldBuilder.build`, portal, home-store or service construction already present on main.

- [ ] **Step 4: Set unified release identity**

Replace `config/release.json` with:

```json
{
  "productVersion": "0.7.0",
  "releaseName": "Family World & Production Art",
  "profileSchema": 11,
  "rojoVersion": "7.7.0",
  "styluaVersion": "2.5.2",
  "rokitVersion": "1.2.0",
  "rokitInstallerCommit": "2f2618428ef31279e2fc80b0b1d73485bc929ddd",
  "projectFile": "default.project.json",
  "artifactFile": "TinyWorld-v0.7.0.rbxlx"
}
```

Update `ReleaseInfo.luau` and `BuildStamp.client.luau` so the visible DEV stamp includes `TinyWorld DEV · v0.7.0`.

- [ ] **Step 5: Run art and source contracts**

Run:

```bash
bash tests/verify-v0.6.3-art-r4-contract.sh
bash tests/verify-v0.6.3-repository-audit.sh
bash tests/verify-v0.7.0-unified-source-contract.sh
```

Expected: art contracts PASS; unified contract may remain red only for later coast/family requirements.

- [ ] **Step 6: Commit**

```bash
git add art assets src tools tests docs config/release.json
git commit -m "feat: absorb production art into v0.7.0"
```

---

### Task 2: Import and reconcile safe explorable coast

**Files:**
- Import from PR #12 head `03e8b7a424377c45f169f8983748319309035188`: `src/server/CoastBuilder.luau`, `src/server/TraversalSafetyService.luau`, `src/shared/TraversalRules.luau`, `tests/TraversalRules.spec.luau`, v0.7.0 family-review docs.
- Modify: `src/server/Main.server.luau`

**Interfaces:**
- Produces: `world.coast`, shoreline/swim/recovery boundary fields, `TraversalSafetyService.new(world, ProfileStore, PlayerStateService)`.

- [ ] **Step 1: Import PR #12 coast files without its workflow file**

Copy exactly these source/test files from `feature/v0.7.0-family-review`:

```text
src/server/CoastBuilder.luau
src/server/TraversalSafetyService.luau
src/shared/TraversalRules.luau
tests/TraversalRules.spec.luau
docs/releases/v0.7.0/acceptance.md
docs/roadmap/v0.7.0-family-review.md
```

Do not import `.github/workflows/release-authority.yml` or PR #12's full `Main.server.luau`.

- [ ] **Step 2: Add coast startup to the reconciled Main**

Immediately after `WorldBuilder.build` and before service construction:

```lua
local CoastBuilder = require(script.Parent:WaitForChild("CoastBuilder"))
local TraversalSafetyService = require(script.Parent:WaitForChild("TraversalSafetyService"))

world.coast = CoastBuilder.build(world.root, world.layout)
world.boundary.shorelineDistance = world.coast.shorelineDistance
world.boundary.swimDistance = world.coast.swimDistance
world.boundary.safeShoreCFrame = world.coast.safeShoreCFrame
world.boundary.worldRecoveryCFrame = world.coast.worldRecoveryCFrame
```

After `BoatService.new(...)`:

```lua
local traversalSafetyService = TraversalSafetyService.new(world, ProfileStore, PlayerStateService)
```

In player lifecycle:

```lua
traversalSafetyService:trackPlayer(player)
traversalSafetyService:removePlayer(player)
```

In shutdown:

```lua
traversalSafetyService:stop()
```

- [ ] **Step 3: Run coast tests**

```bash
luau tests/run.luau
bash tests/verify-v0.7.0-source-contract.sh
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add src tests docs
git commit -m "feat: add safe explorable coast to v0.7.0"
```

---

### Task 3: Finish plot ownership, homes and companion progression

**Files:**
- Modify: `src/server/PlotService.luau`
- Modify: `src/shared/HouseCatalog.luau`
- Modify: `src/shared/ProfileSchema.luau`
- Create: `src/shared/CompanionRules.luau`
- Create: `src/server/CompanionService.luau`
- Test: `tests/CompanionRules.spec.luau`
- Test: `tests/HouseUpgrade.spec.luau`

**Interfaces:**
- `CompanionRules.isUnlocked(profile, companionId) -> boolean`
- `CompanionRules.unlock(profile, companionId) -> (boolean, string?)`
- Durable companion state uses existing `keepsakes` map keys `Companion:TinyCat` and `Companion:TinyDog`, avoiding a schema migration.

- [ ] **Step 1: Write companion tests first**

```lua
local CompanionRules = require("../src/shared/CompanionRules")

return function(t)
    local profile = { level = 9, keepsakes = {} }
    t.expect(CompanionRules.isUnlocked(profile, "TinyCat") == false)
    local ok, reason = CompanionRules.unlock(profile, "TinyCat")
    t.expect(ok == false)
    t.expect(reason == "level_too_low")

    profile.level = 10
    ok = CompanionRules.unlock(profile, "TinyCat")
    t.expect(ok == true)
    t.expect(CompanionRules.isUnlocked(profile, "TinyCat") == true)

    local second = CompanionRules.unlock(profile, "TinyCat")
    t.expect(second == false)
end
```

Run `luau tests/run.luau`; expected FAIL because `CompanionRules` does not exist.

- [ ] **Step 2: Implement deterministic companion rules**

```lua
local CompanionRules = {}

local VALID = { TinyCat = true, TinyDog = true }
local REQUIRED_LEVEL = 10

function CompanionRules.isUnlocked(profile, companionId: string): boolean
    return VALID[companionId] == true and profile.keepsakes["Companion:" .. companionId] == 1
end

function CompanionRules.unlock(profile, companionId: string): (boolean, string?)
    if VALID[companionId] ~= true then
        return false, "unknown_companion"
    end
    if profile.level < REQUIRED_LEVEL then
        return false, "level_too_low"
    end
    local key = "Companion:" .. companionId
    if profile.keepsakes[key] == 1 then
        return false, "already_unlocked"
    end
    profile.keepsakes[key] = 1
    return true, nil
end

return CompanionRules
```

- [ ] **Step 3: Extend home prestige to castle tier**

Set `ProfileSchema.MAX_HOUSE_TIER = 6` and append:

```lua
{ tier = 6, name = "Tiny Castle", price = 6000, requiredLevel = 15 },
```

to `HouseCatalog`. Existing `houseTier` persistence remains compatible because it is already a numeric field.

- [ ] **Step 4: Make ownership visually explicit**

In `PlotService:assign` and `refreshIdentity`, use:

```lua
plot.ownerLabel.Text = string.format("%s's Home • Plot %d", displayNameFor(player, profile), index)
```

Keep assignment server-owned. Add/retain a nearby claim/identity prompt only if the world builder exposes an unclaimed prompt; no client may set `plotOwners`.

- [ ] **Step 5: Add CompanionService**

`CompanionService` must create follower presentation only for server-authorized unlocked companions and must never mutate level/coins. Use Roblox avatar/model APIs or approved production model assets rather than primitive finished animals. Its public lifecycle is:

```lua
CompanionService.new(world, ProfileStore, PlayerStateService)
CompanionService:trackPlayer(player)
CompanionService:apply(player, profile)
CompanionService:removePlayer(player)
CompanionService:stop()
```

- [ ] **Step 6: Run tests and commit**

```bash
luau tests/run.luau
stylua --check src tests

git add src tests
git commit -m "feat: finish home and companion progression"
```

---

### Task 4: Add inhabited village and coherent transport progression

**Files:**
- Create: `src/server/VillageNpcService.luau`
- Create: `src/shared/VillageNpcDefinitions.luau`
- Create: `src/server/CarBuilder.luau`
- Modify: `src/server/TransportService.luau`
- Modify: `src/shared/TransportRules.luau`
- Modify: `src/server/Main.server.luau`
- Test: `tests/TransportRules.spec.luau`
- Test: `tests/VillageNpcDefinitions.spec.luau`

**Interfaces:**
- NPC roles exactly: `Trader`, `Gardener`, `Fisherman`, `BoatKeeper`, `Builder`.
- `TransportRules.canUseTinyCar(profile) -> boolean`.
- Tiny Bike, Tiny Car and Tiny Boat presentation remains server-spawned and profile-gated.

- [ ] **Step 1: Add deterministic NPC definition tests**

Assert the role set is exactly the five required roles and every role has a non-empty display name and destination anchor key.

- [ ] **Step 2: Implement NPC definitions**

```lua
local DEFINITIONS = {
    { id = "Trader", displayName = "Mara", anchor = "VillageShop" },
    { id = "Gardener", displayName = "Pip", anchor = "Garden" },
    { id = "Fisherman", displayName = "Finn", anchor = "Harbor" },
    { id = "BoatKeeper", displayName = "Skye", anchor = "Harbor" },
    { id = "Builder", displayName = "Milo", anchor = "Workshop" },
}
```

Expose `all()` and `get(id)` only.

- [ ] **Step 3: Implement VillageNpcService with Roblox character rigs**

Create humanoid rigs using Roblox character APIs or approved assets. Anchor them to existing semantic destination anchors and use proximity prompts for role copy. They may provide navigation/help messages but must not directly mutate rewards or ownership.

- [ ] **Step 4: Add Tiny Car as progression transport**

Use existing profile-compatible state rather than inventing client state. If no durable car field exists, gate Tiny Car by player level and keep it session-only for v0.7.0:

```lua
function TransportRules.canUseTinyCar(profile): boolean
    return profile.level >= 8
end
```

Build a production-readable car model in `CarBuilder` using the same production art/model approach as ART R4. Do not add fake asset IDs.

- [ ] **Step 5: Run tests and commit**

```bash
luau tests/run.luau
stylua --check src tests

git add src tests
git commit -m "feat: add village NPC life and Tiny Car"
```

---

### Task 5: Implement hidden Mermaid Land and five idempotent quests

**Files:**
- Create: `src/shared/MermaidQuestRules.luau`
- Create: `src/server/MermaidLandBuilder.luau`
- Create: `src/server/MermaidLandService.luau`
- Modify: `src/server/Main.server.luau`
- Test: `tests/MermaidQuestRules.spec.luau`

**Interfaces:**
- Exactly five quest IDs: `PearlTrail`, `CoralGarden`, `LostParcel`, `MoonShells`, `WhirlpoolPromise`.
- Completion keys use `keepsakes["MermaidQuest:" .. questId] = 1`.
- Discovery uses `discoveredWorlds.MermaidLand = true`.
- Rewards are granted exactly once by the server.

- [ ] **Step 1: Write idempotency tests**

```lua
local profile = { coins = 0, xp = 0, keepsakes = {}, discoveredWorlds = {} }
local ok = MermaidQuestRules.complete(profile, "PearlTrail")
t.expect(ok == true)
local coins = profile.coins
local xp = profile.xp
local again, reason = MermaidQuestRules.complete(profile, "PearlTrail")
t.expect(again == false)
t.expect(reason == "already_complete")
t.expect(profile.coins == coins)
t.expect(profile.xp == xp)
```

Also assert `#MermaidQuestRules.all() == 5`.

- [ ] **Step 2: Implement quest rules**

Use fixed definitions such as:

```lua
local QUESTS = {
    PearlTrail = { coins = 75, xp = 50 },
    CoralGarden = { coins = 100, xp = 60 },
    LostParcel = { coins = 125, xp = 75 },
    MoonShells = { coins = 150, xp = 90 },
    WhirlpoolPromise = { coins = 250, xp = 150 },
}
```

`complete` must check the quest ID, reject repeated completion, write the completion key, increment coins/xp once and mark Mermaid Land discovered.

- [ ] **Step 3: Build hidden whirlpool and Mermaid Land destination**

`MermaidLandBuilder.build(world)` must create:

```lua
{
    whirlpoolTrigger = BasePart,
    entryCFrame = CFrame,
    returnCFrame = CFrame,
    questAnchors = { [string]: BasePart },
}
```

The whirlpool must not be mentioned by onboarding copy.

- [ ] **Step 4: Enforce outer-sea/boat access in MermaidLandService**

Before transition, require the server profile to own/activate Tiny Boat and require the player's current traversal state to be outer-sea eligible. On success, pivot the character to `entryCFrame`; on return, pivot to `returnCFrame`.

- [ ] **Step 5: Add five mermaid quest prompts and server-owned completion**

Each quest prompt calls `MermaidQuestRules.complete`, then `PlayerStateService.sync`, `ProfileStore.save`, and a clear player message. Never accept client-provided reward values.

- [ ] **Step 6: Run tests and commit**

```bash
luau tests/run.luau
stylua --check src tests

git add src tests
git commit -m "feat: add hidden Mermaid Land questline"
```

---

### Task 6: Replace all redundant Actions with one free-only workflow

**Files:**
- Delete: `.github/workflows/luau-tests.yml`
- Delete: `.github/workflows/release-authority.yml`
- Delete: `.github/workflows/rojo-build.yml`
- Create: `.github/workflows/tinyworld-ci.yml`
- Modify: `scripts/verify-release-contract.sh`
- Modify: `tests/build-contract.sh`

**Interfaces:**
- PR: test + contracts + build, no publish.
- `main` push: same gates plus direct DEV publish.
- Zero Actions artifacts and zero Actions caches.

- [ ] **Step 1: Make the free-only contract fail while three workflows still exist**

Add to `tests/build-contract.sh`:

```bash
workflow_count="$(find .github/workflows -maxdepth 1 -type f -name '*.yml' | wc -l | tr -d ' ')"
[[ "$workflow_count" == "1" ]] || { echo "ERROR: TinyWorld must have exactly one Actions workflow" >&2; exit 1; }
if grep -RIEq 'actions/(upload-artifact|cache)@' .github/workflows; then
  echo "ERROR: persistent Actions storage is prohibited" >&2
  exit 1
fi
```

Run it and confirm FAIL before deleting the old workflows.

- [ ] **Step 2: Create the canonical workflow**

Create `.github/workflows/tinyworld-ci.yml`:

```yaml
name: TinyWorld CI

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read

concurrency:
  group: tinyworld-ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  verify-build-publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - name: Install Luau 0.732
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          set -euo pipefail
          api="https://api.github.com/repos/luau-lang/luau/releases/tags/0.732"
          asset_url="$(curl -fsSL -H "Authorization: Bearer ${GH_TOKEN}" -H "Accept: application/vnd.github+json" "$api" | jq -r '.assets[] | select(.name == "luau-ubuntu.zip") | .browser_download_url')"
          test -n "$asset_url"
          test "$asset_url" != "null"
          curl -fsSL "$asset_url" -o /tmp/luau.zip
          mkdir -p "$RUNNER_TEMP/luau"
          unzip -q /tmp/luau.zip -d "$RUNNER_TEMP/luau"
          chmod +x "$RUNNER_TEMP/luau/luau" "$RUNNER_TEMP/luau/luau-analyze" "$RUNNER_TEMP/luau/luau-compile"
          echo "$RUNNER_TEMP/luau" >> "$GITHUB_PATH"

      - name: Install pinned Rokit tools
        run: |
          set -euo pipefail
          rokit_version="$(jq -er '.rokitVersion' config/release.json)"
          rokit_installer_commit="$(jq -er '.rokitInstallerCommit' config/release.json)"
          curl -sSf "https://raw.githubusercontent.com/rojo-rbx/rokit/${rokit_installer_commit}/scripts/install.sh" | bash -s -- "$rokit_version"
          echo "$HOME/.rokit/bin" >> "$GITHUB_PATH"
          export PATH="$HOME/.rokit/bin:$PATH"
          rokit install --no-trust-check

      - name: Unit tests
        run: luau tests/run.luau

      - name: Shared analysis and runtime compile
        run: |
          set -euo pipefail
          find src/shared -maxdepth 1 -type f -name '*.luau' ! -name 'ProductionArtSpec.luau' -print0 | xargs -0 luau-analyze
          luau-compile src/shared/ProductionArtSpec.luau >/dev/null
          find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
          find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null

      - name: Formatting
        run: stylua --check src tests

      - name: Release and repository contracts
        run: |
          bash ./tests/verify-release-authority.sh
          bash ./tests/verify-v0.7.0-unified-source-contract.sh
          bash ./tests/verify-v0.6.3-art-r4-contract.sh
          bash ./tests/verify-v0.6.3-repository-audit.sh
          bash ./tests/build-contract.sh
          bash ./scripts/verify-release-contract.sh

      - name: Build v0.7.0
        run: ./scripts/build.sh

      - name: Publish TinyWorld DEV
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        env:
          ROBLOX_DEV_API_KEY: ${{ secrets.ROBLOX_DEV_API_KEY }}
        run: bash ./scripts/publish-dev.sh
```

- [ ] **Step 3: Delete the three old workflows**

Delete the exact files listed above. Do not retain disabled copies under `.github/workflows` because GitHub still parses files in that directory.

- [ ] **Step 4: Verify the build contract turns green**

```bash
bash tests/build-contract.sh
```

Expected: PASS and exactly one workflow discovered.

- [ ] **Step 5: Commit**

```bash
git add .github tests scripts
git commit -m "ci: consolidate TinyWorld into one free-only pipeline"
```

---

### Task 7: Final release authority, one PR, merge and DEV publish

**Files:**
- Modify: `docs/releases/v0.7.0/acceptance.md`
- Modify: `docs/progress.md`
- Modify: `README.md` if current release/version copy is stale.

**Interfaces:**
- One final PR from `release/v0.7.0-unified` to `main`.
- PR #8 and PR #12 close as superseded only after the unified PR contains their required source.
- Issue #11 closes as completed only after all checklist scope is implemented and verified.

- [ ] **Step 1: Run the complete local/CI-equivalent suite**

```bash
luau tests/run.luau
stylua --check src tests
bash tests/verify-release-authority.sh
bash tests/verify-v0.7.0-unified-source-contract.sh
bash tests/verify-v0.6.3-art-r4-contract.sh
bash tests/verify-v0.6.3-repository-audit.sh
bash tests/build-contract.sh
bash scripts/verify-release-contract.sh
./scripts/build.sh
```

Expected: every command PASS and `dist/TinyWorld-v0.7.0.rbxlx` exists.

- [ ] **Step 2: Open exactly one unified PR**

Title:

```text
feat: TinyWorld v0.7.0 unified family world release
```

Body must explicitly state that it supersedes PR #8 and PR #12 and completes issue #11, while retaining the free-only direct DEV publish path.

- [ ] **Step 3: Wait for the unified PR CI to pass and verify zero artifacts**

Confirm the sole `TinyWorld CI` workflow is green and its workflow-run artifact list is empty.

- [ ] **Step 4: Close old PRs as superseded**

Close PR #8 and PR #12 with comments pointing to the unified PR. Do not merge either old PR independently.

- [ ] **Step 5: Close issue #11 as completed**

Close issue #11 only after the unified branch includes all required player outcomes and CI is green.

- [ ] **Step 6: Merge the unified PR**

Use squash merge to keep main release history compact.

- [ ] **Step 7: Verify the post-merge DEV publish**

Inspect the `main` `TinyWorld CI` run. Required evidence:

```text
Build v0.7.0: success
Publish TinyWorld DEV: success
Published TinyWorld DEV place version <number>
Artifacts: 0
```

If Roblox returns a non-2xx response, stop and diagnose the exact response before making any further release-state claims.

- [ ] **Step 8: Final repository state check**

Confirm:

```text
Open release PRs: 0
Open issue #11: no
Actions workflow files: 1
Automatic DEV publishing: enabled
Automatic LIVE publishing: disabled
Actions artifacts created by new pipeline: 0
```
