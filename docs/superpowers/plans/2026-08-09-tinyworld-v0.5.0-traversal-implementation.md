# TinyWorld v0.5.0 Traversal Expansion Implementation Plan

> For agentic workers: REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

Goal: Add a server-authoritative physical Tiny Boat and Tidepool Cove route while preserving the existing Tiny Bike, item-presentation invariant, and all v0.4 gameplay contracts.

Architecture: TraversalRules owns pure boat purchase/session transitions. BoundaryBuilder owns the physical Sea Dock and Tidepool Cove geometry. BoatBuilder owns the visible boat model and prompts. BoatService owns per-player boat models, purchase, travel, respawn, and cleanup. Existing item reward services remain authoritative and are protected by a physical-affordance source guard.

Tech Stack: Luau, Roblox server/client APIs, Rojo, Rokit/Luau CLI, PowerShell source guards, Git.

## Global Constraints

- Preserve the north star: Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.
- Anything the player receives or interacts with must exist in the world or be presented immediately on screen.
- Inventory items must have a physical pickup, visible Item Chest/table representation, or immediate named reward popup.
- Vehicles must have a visible server-created model and physical prompt or seat; profile flags alone are not player-facing affordances.
- Destinations must have a physical arrival space and physical return interaction.
- Keep economy, ownership, progression, privacy, trade, and transport decisions server-authoritative.
- Preserve all v0.4 profile data and normalize v9 profiles safely into schema version 10.
- Use Roblox-native primitives/materials and existing semantic palette tokens; no third-party assets or HTTP services.
- Keep world construction once per server and keep the cove/boat geometry bounded and non-flickering.
- Write a failing test or source guard before each production implementation slice.
- Run tests, analysis, server/client compilation, material safety, and all existing guards before release claims.
- All Studio changes flow source -> Git -> Rojo -> Studio -> publish; never edit source manually in Studio.
- Stage explicit paths only and preserve unrelated user changes.

---

### Task 1: Add failing traversal and physical-affordance contracts

Files:
- Create: tests/TraversalRules.spec.luau
- Create: tests/verify-traversal.ps1
- Create: tests/verify-physical-affordance-invariant.ps1
- Modify: tests/run.luau

Interfaces:
- The test requires src/shared/TraversalRules.luau with TINY_BOAT_PRICE, buyTinyBoat(profile), mountTinyBoat(profile), and returnTinyBoat(profile).
- The guards inspect the missing BoatBuilder/BoatService, v10 profile/state wiring, Tidepool Cove world contracts, and all item reward paths.

- [ ] Step 1: Write the failing pure-rule test.

~~~lua
local TestUtil = require("./TestUtil")
local ProfileSchema = require("../src/shared/ProfileSchema")
local TraversalRules = require("../src/shared/TraversalRules")

return function()
	local poor = ProfileSchema.new()
	local boughtPoor, poorReason = TraversalRules.buyTinyBoat(poor)
	TestUtil.isFalse(boughtPoor)
	TestUtil.equal(poorReason, "not_enough_coins")
	TestUtil.equal(poor.coins, 100)
	TestUtil.isFalse(poor.ownsTinyBoat)

	local profile = ProfileSchema.new()
	profile.coins = TraversalRules.TINY_BOAT_PRICE
	local bought, reason = TraversalRules.buyTinyBoat(profile)
	TestUtil.isTrue(bought)
	TestUtil.equal(reason, "purchased")
	TestUtil.equal(profile.coins, 0)
	TestUtil.isTrue(profile.ownsTinyBoat)
	TestUtil.isFalse(profile.boatActive)

	local mounted, mountReason = TraversalRules.mountTinyBoat(profile)
	TestUtil.isTrue(mounted)
	TestUtil.equal(mountReason, "mounted")
	TestUtil.isTrue(profile.boatActive)

	local mountedAgain, mountedAgainReason = TraversalRules.mountTinyBoat(profile)
	TestUtil.isFalse(mountedAgain)
	TestUtil.equal(mountedAgainReason, "already_mounted")

	local returned, returnReason = TraversalRules.returnTinyBoat(profile)
	TestUtil.isTrue(returned)
	TestUtil.equal(returnReason, "returned")
	TestUtil.isFalse(profile.boatActive)

	local returnedAgain, returnedAgainReason = TraversalRules.returnTinyBoat(profile)
	TestUtil.isFalse(returnedAgain)
	TestUtil.equal(returnedAgainReason, "already_parked")
end
~~~

- [ ] Step 2: Add the test to tests/run.luau and run it.

Run: & "$env:USERPROFILE/.rokit/bin/luau.exe" tests/run.luau

Expected: FAIL because src/shared/TraversalRules.luau does not exist.

- [ ] Step 3: Write the failing source guards.

verify-traversal.ps1 must require TINY_BOAT_PRICE, the three rule functions, named TinyBoat/BoatHull/BoatSeat/BoatMast/Board Tiny Boat/Return to Sea Dock, TidepoolCove, boatShopPrompt, endpoint CFrames, and TinyWorldOwnsBoat/TinyWorldBoatActive/TinyWorldBoatState.

verify-physical-affordance-invariant.ps1 must require the physical catalog/display and named popup/sync contracts for Carrot, SugarCrystal, MeadowSeed, Seashell, and WoodToken, including InventoryItem_, Item Chest:, addSyncListener, PlayerStateService.sync, and named reward messages in daily reward, garden, living-world, portal, trade, and home paths.

- [ ] Step 4: Run both guards to verify RED.

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-traversal.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-physical-affordance-invariant.ps1
~~~

Expected: both fail for missing traversal implementation contracts. Do not weaken the guards to make the current tree pass.

- [ ] Step 5: Commit the red tests and guards.

~~~powershell
git add tests/TraversalRules.spec.luau tests/verify-traversal.ps1 tests/verify-physical-affordance-invariant.ps1 tests/run.luau
git commit -m "test: define v0.5 traversal and physical item contracts"
~~~

### Task 2: Implement v10 profile migration and pure boat rules

Files:
- Create: src/shared/TraversalRules.luau
- Modify: src/shared/ProfileSchema.luau
- Modify: tests/ProfileSchema.spec.luau

Interfaces:
- TraversalRules.TINY_BOAT_PRICE is 600.
- buyTinyBoat(profile): (boolean, string) mutates only a valid purchase.
- mountTinyBoat(profile): (boolean, string) requires ownership and sets boatActive.
- returnTinyBoat(profile): (boolean, string) clears boatActive and is safe when parked.
- ProfileSchema.PlayerProfile gains ownsTinyBoat and boatActive; the version becomes 10.

- [ ] Step 1: Implement the minimal TraversalRules needed by the failing test, using the same pure-rule style as TransportRules.

~~~lua
local TraversalRules = {}
TraversalRules.TINY_BOAT_PRICE = 600

function TraversalRules.buyTinyBoat(profile: any): (boolean, string)
	if profile.ownsTinyBoat then return false, "already_owned" end
	if profile.coins < TraversalRules.TINY_BOAT_PRICE then return false, "not_enough_coins" end
	profile.coins -= TraversalRules.TINY_BOAT_PRICE
	profile.ownsTinyBoat = true
	return true, "purchased"
end

function TraversalRules.mountTinyBoat(profile: any): (boolean, string)
	if not profile.ownsTinyBoat then return false, "not_owned" end
	if profile.boatActive then return false, "already_mounted" end
	profile.boatActive = true
	return true, "mounted"
end

function TraversalRules.returnTinyBoat(profile: any): (boolean, string)
	if not profile.boatActive then return false, "already_parked" end
	profile.boatActive = false
	return true, "returned"
end

return TraversalRules
~~~

- [ ] Step 2: Run the focused rule test and expect PASS.

Run: & "$env:USERPROFILE/.rokit/bin/luau.exe" tests/TraversalRules.spec.luau

- [ ] Step 3: Add v10 defaults and normalization.

Add ownsTinyBoat = false and boatActive = false to ProfileSchema.new() and normalize(). Preserve all existing inventory, home, route, social, portal, profession, and bike fields. Add assertions for ProfileSchema.VERSION == 10, fresh false boat fields, and v9 data migrating to v10 with false boat fields.

- [ ] Step 4: Run all pure tests.

Run: & "$env:USERPROFILE/.rokit/bin/luau.exe" tests/run.luau

Expected: the full suite passes with v10 migration assertions.

- [ ] Step 5: Commit.

~~~powershell
git add src/shared/TraversalRules.luau src/shared/ProfileSchema.luau tests/TraversalRules.spec.luau tests/ProfileSchema.spec.luau tests/run.luau
git commit -m "feat: add v0.5 boat ownership rules"
~~~

### Task 3: Build the physical Sea Dock, Tidepool Cove, and boat model

Files:
- Create: src/server/BoatBuilder.luau
- Modify: src/server/BoundaryBuilder.luau
- Modify: src/shared/WorldLayoutRules.luau
- Modify: tests/WorldLayoutRules.spec.luau and tests/VisualBudgetRules.spec.luau only if a named cove budget is added

Interfaces:
- BoundaryBuilder.build(parent, layout) still returns the existing boundary model/landmarks/explorer prompt and additionally returns boatShopPrompt, boatDockCFrame, coveBoatCFrame, coveArrivalCFrame, and villageReturnCFrame.
- BoatBuilder.build(parent, name, origin, accent) returns { model, mountPart, mountPrompt, returnPrompt } and sets TinyWorldPhysicalBoat=true.

- [ ] Step 1: Extend the source guard for TidepoolCoveIsland, TidepoolCoveDock, TidepoolCoveBeacon, TinyBoatDock, TinyBoatShop, and the returned CFrames. Run the guard and verify RED until the builder terms exist.

- [ ] Step 2: Extend BoundaryBuilder with a bounded cove beyond the east sea belt using layout.perimeterHalfExtent, a physical Sea Dock kiosk labeled TINY BOAT and 600 coins, and safe above-ground dock CFrames. Keep water, ground, sand, and decorative layers vertically separated.

Use this anchor:

~~~lua
local coveCenter = Vector3.new(half + 108, 0, 0)
~~~

The cove must include an island, meadow, dock, beacon, readable label, and no reward-only interaction.

- [ ] Step 3: Add BoatBuilder with named BoatHull, BoatDeck, BoatSeat, BoatOarLeft, BoatOarRight, BoatMast, BoatSail, and BoatFlag parts. Decorative parts are anchored/non-touching/non-querying; the Seat is queryable for prompts. Add Board Tiny Boat and Return to Sea Dock prompts, with return disabled at build time.

- [ ] Step 4: Run source/material guards and compile the new builder.

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-traversal.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-roblox-materials.ps1
& "$env:USERPROFILE/.rokit/bin/luau-compile.exe" src/server/BoatBuilder.luau
~~~

Expected: guards pass and the builder compiles with exit code 0.

- [ ] Step 5: Commit.

~~~powershell
git add src/server/BoatBuilder.luau src/server/BoundaryBuilder.luau src/shared/WorldLayoutRules.luau tests/verify-traversal.ps1 tests/verify-roblox-materials.ps1 tests/WorldLayoutRules.spec.luau tests/VisualBudgetRules.spec.luau
git commit -m "feat: build physical Tidepool Cove and Tiny Boat"
~~~

### Task 4: Wire authoritative BoatService and replicated state

Files:
- Create: src/server/BoatService.luau
- Modify: src/server/Main.server.luau
- Modify: src/server/PlayerStateService.luau
- Modify: src/client/Main.client.luau
- Modify: tests/verify-traversal.ps1

Interfaces:
- BoatService.new(world, ProfileStore, PlayerStateService) connects the physical Sea Dock purchase prompt.
- BoatService:apply(player, profile) resets session state and creates a boat only for owned profiles.
- BoatService:trackPlayer(player) resets/reapplies on respawn.
- BoatService:removePlayer(player) clears state and destroys transient models/connections.
- PlayerStateService.sync exposes TinyWorldOwnsBoat, TinyWorldBoatActive, and TinyWorldBoatState.

- [ ] Step 1: Add failing service wiring checks for BoatService, ProfileStore.get, PlayerStateService.sync, PlayerStateService.message, ProfileStore.save, boatActive=false, and endpoint teleport. Run RED until the service exists.

- [ ] Step 2: Implement purchase. On boatShopPrompt.Triggered, load the server profile. If unowned, call TraversalRules.buyTinyBoat; failure shows The Tiny Boat costs 600 coins.; success creates the visible boat, syncs, shows Tiny Boat purchased. Board it at the Sea Dock for Tidepool Cove., and requests a save. If already owned, show Your Tiny Boat is waiting at the Sea Dock. without changing coins.

- [ ] Step 3: Implement board/return. Connect each owner's boat prompts. Board calls the pure mount rule, moves the boat to coveBoatCFrame, moves the character to coveArrivalCFrame, toggles prompts, syncs, saves, and messages Boarded Tiny Boat. Welcome to Tidepool Cove. Return calls the return rule, moves the boat to boatDockCFrame, moves the character to villageReturnCFrame, toggles prompts, syncs, saves, and messages Returned to Sea Dock. Your Tiny Boat is parked. Reject other players' prompts.

- [ ] Step 4: Wire Main.server.luau and state attributes. Instantiate BoatService after WorldBuilder, call trackPlayer/apply on join, and removePlayer on leave. Add the three attributes to PlayerStateService.sync without removing existing attributes.

- [ ] Step 5: Update the read-only HUD title/eyebrow to v0.5 and render transport from BikeState plus BoatState, for example Transport: Bike PARKED | Boat PARKED. Add boat attributes to the observed list. Do not add client mutations.

- [ ] Step 6: Run focused/static checks.

~~~powershell
& "$env:USERPROFILE/.rokit/bin/luau.exe" tests/run.luau
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-traversal.ps1
& "$env:USERPROFILE/.rokit/bin/luau-compile.exe" src/server/BoatService.luau
& "$env:USERPROFILE/.rokit/bin/luau-compile.exe" src/server/Main.server.luau
& "$env:USERPROFILE/.rokit/bin/luau-compile.exe" src/client/Main.client.luau
~~~

Expected: tests, traversal guard, and compiles pass.

- [ ] Step 7: Commit.

~~~powershell
git add src/server/BoatService.luau src/server/Main.server.luau src/server/PlayerStateService.luau src/client/Main.client.luau tests/verify-traversal.ps1
git commit -m "feat: wire authoritative Tiny Boat travel"
~~~

### Task 5: Complete the physical-affordance guard and v0.5 documentation

Files:
- Modify: tests/verify-physical-affordance-invariant.ps1
- Create: docs/v0.5.0-traversal-test.md
- Modify: README.md
- Modify: docs/progress.md

- [ ] Step 1: Implement the guard against all current reward paths. Require PlayerStateService.sync, PlayerStateService.message, item names, physical builder names, and PhysicalItemService.refresh/addSyncListener. Fail closed when a path only updates an attribute without a physical or popup contract.

- [ ] Step 2: Write the exact Studio route: start Rojo from the repository root, connect Studio, run the source gate, Play, inspect the physical boat/dock, buy with 600+ coins, board, inspect the physical Tidepool Cove, return through the physical prompt, stop/rejoin, verify owned/parked state, inspect the Item Chest plus one item reward path, check Output, and record the exact publish SHA.

- [ ] Step 3: Add a v0.5 README section naming the physical boat, Tidepool Cove, fair coin price, and physical-item invariant. Add a dated progress entry with only verified source/runtime facts and explicit evidence gaps.

- [ ] Step 4: Run the docs/source checks, diff check, and commit.

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-physical-affordance-invariant.ps1
git diff --check
git add tests/verify-physical-affordance-invariant.ps1 docs/v0.5.0-traversal-test.md README.md docs/progress.md
git commit -m "docs: record v0.5 physical affordance contract"
~~~

### Task 6: Full verification, synced Studio evidence, publish, and main handoff

- [ ] Step 1: Run a fresh full source gate: tests/run.luau, Luau analysis, server/client compilation, current material/bike/home/portal/living-world/item/physical guards, traversal, physical-affordance guard, and git diff --check.

- [ ] Step 2: Build and serve through Rojo from the repository root. Connect Studio to localhost:34872 and confirm synced ServerScriptService, ReplicatedStorage, and StarterPlayer trees.

- [ ] Step 3: With Output visible, use the physical Sea Dock prompt, buy/board the boat, observe the physical Tidepool Cove, use the physical return prompt, stop/rejoin, verify owned/parked state, and separately verify at least one existing item reward shows both the named popup and physical Item Chest/table representation. A command-bar teleport is only a positioning aid and is not normal-route evidence.

- [ ] Step 4: Stop, inspect Output, and classify known Studio DataStore queue/session warnings separately from red source/runtime exceptions. Do not call a normal route passed if only a teleport aid was exercised.

- [ ] Step 5: Publish the Rojo-synced TinyWorld Dev place, record Studio save confirmation, fetch Git, and verify HEAD, origin/main, and the release SHA. Reopen/verify the published target separately; publish output alone is not live parity proof.

- [ ] Step 6: Stage only verified docs/evidence, commit the release, push main, and verify the remote SHA.

~~~powershell
git status --short
git log -12 --oneline --decorate
git add docs/v0.5.0-traversal-test.md docs/progress.md README.md
git commit -m "feat: ship TinyWorld v0.5.0 traversal slice"
git push origin main
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
~~~

Expected: the release commit is pushed to origin/main; any missing Studio/published evidence remains documented as a dependency rather than being claimed complete.

