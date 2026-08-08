# TinyWorld v0.0.4 Living-World Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task with verification checkpoints.

**Goal:** Turn the accepted v0.0.4 village into a more lived-in, colourful, grounded MVP by adding a real rideable Tiny Bike, persistent life-kit items, richer plants, cabin/home dressing, and bounded village props while preserving the original multiplayer, boundary, street, and flicker-fix scope.

**Architecture:** Keep pure progression and migration rules in `src/shared`. Keep Roblox instance construction in focused server builders, and keep prompt/profile mutation in focused server services. The existing `WorldBuilder` remains the composition root; static scenery is created once under one owned model, player-owned bikes are created and cleaned up per player, and `PlotService` remains the authority for home upgrades and home charm visuals.

**Tech Stack:** Luau, Roblox server/client scripts, Luau CLI, `luau-analyze`, `luau-compile`, Rojo 7.7.0, PowerShell regression guards, Roblox Studio Play and Server & Clients.

## Global Constraints

- Preserve the parent v0.0.4 MVP contract: playable, multiplayer-testable, capacity-aware, visually improved, with stable plot surfaces, streets, civic scenery, and woods/cliffs/sea boundaries.
- All gameplay authority stays on the server; client code only renders replicated attributes.
- Existing profiles migrate through safe `ProfileSchema.normalize` defaults; never discard Carrots, Sugar Crystals, houses, bikes, or boundary progress.
- The Tiny Bike costs 300 coins, remains persistent ownership, and is a visible mount; no full wheel physics, new currency, combat, weapons, or enemies.
- Static decorations are bounded from `WorldLayoutRules`, anchored, and non-collidable/non-touching/non-queryable unless they are an intentional floor, porch, step, or prompt carrier.
- Never write a Roblox place or source file manually in Studio; the source tree is the only amendment surface and Rojo is the sync path.
- Stage explicit paths only. Preserve unrelated worktree changes.

---

### Task 1: Add the persistent life-kit and home-charm rules

**Files:**
- Create: `src/shared/LivingWorldRules.luau`
- Create: `tests/LivingWorldRules.spec.luau`
- Modify: `src/shared/Inventory.luau`
- Modify: `src/shared/ProfileSchema.luau`
- Modify: `tests/Inventory.spec.luau`
- Modify: `tests/ProfileSchema.spec.luau`
- Modify: `tests/run.luau`

**Interfaces:**
- `LivingWorldRules.ITEMS = { "MeadowSeed", "Seashell", "WoodToken" }`
- `LivingWorldRules.itemBit(itemName: string): number?`
- `LivingWorldRules.collectionCount(profile: any, dayKey: string): number`
- `LivingWorldRules.collect(profile: any, itemName: string, dayKey: string): (boolean, string)`
- `LivingWorldRules.canAddHomeCharm(profile: any): boolean`
- `LivingWorldRules.addHomeCharm(profile: any): (boolean, string)`
- `Inventory.isSupported`, `Inventory.get`, `Inventory.add`, and `Inventory.remove` accept the three new item names.
- `ProfileSchema.VERSION` becomes `5`; `inventory` gains zero defaults; profile gains `livingCollectionDay`, `livingCollectionMask`, and `homeCharmApplied`.

- [ ] **Step 1: Write the failing tests**

Add tests proving:

```luau
local profile = ProfileSchema.new()
TestUtil.isTrue(Inventory.add(profile, "MeadowSeed", 1))
TestUtil.equal(Inventory.get(profile, "MeadowSeed"), 1)
TestUtil.isTrue(LivingWorldRules.collect(profile, "Seashell", "2026-08-08"))
TestUtil.isFalse(LivingWorldRules.collect(profile, "Seashell", "2026-08-08"))
TestUtil.equal(LivingWorldRules.collectionCount(profile, "2026-08-08"), 1)

TestUtil.isTrue(Inventory.add(profile, "WoodToken", 1))
TestUtil.isTrue(LivingWorldRules.canAddHomeCharm(profile))
TestUtil.isTrue(LivingWorldRules.addHomeCharm(profile))
TestUtil.isTrue(profile.homeCharmApplied)
TestUtil.equal(Inventory.get(profile, "MeadowSeed"), 0)
TestUtil.isFalse(LivingWorldRules.addHomeCharm(profile))
```

Extend schema tests to prove old v4 data normalises to version 5 with zero life-kit items and false charm/mask state, while complete v4 data preserves all existing fields.

- [ ] **Step 2: Run the tests and verify the expected RED state**

Run from `C:\Users\wilf6\dev\tinyworld`:

```powershell
& C:\Users\wilf6\scoop\apps\luau\current\luau.exe tests\run.luau
```

Expected: failure because `LivingWorldRules` and the new inventory/profile fields do not yet exist. Fix only test typos if the failure is unrelated.

- [ ] **Step 3: Implement the minimal shared rules and migration**

Use a three-bit mask (`MeadowSeed = 1`, `Seashell = 2`, `WoodToken = 4`). Reset the mask when the supplied day key differs from `livingCollectionDay`; never grant a second item for the same bit on the same day. `addHomeCharm` must require all three inventory items, consume exactly one of each, and be idempotent through `homeCharmApplied`.

- [ ] **Step 4: Run the focused and full tests GREEN**

Run:

```powershell
& C:\Users\wilf6\scoop\apps\luau\current\luau.exe tests\run.luau
```

Expected: all existing specs plus `LivingWorldRules` pass.

- [ ] **Step 5: Commit the shared contract**

```powershell
git add src/shared/LivingWorldRules.luau src/shared/Inventory.luau src/shared/ProfileSchema.luau tests/LivingWorldRules.spec.luau tests/Inventory.spec.luau tests/ProfileSchema.spec.luau tests/run.luau
git commit -m "feat: add v0.0.4 living world item rules"
```

### Task 2: Make the Tiny Bike a visible rideable mount

**Files:**
- Create: `src/server/BikeBuilder.luau`
- Modify: `src/shared/TransportRules.luau`
- Modify: `tests/TransportRules.spec.luau`
- Modify: `src/server/TransportService.luau`
- Modify: `src/server/PlayerStateService.luau`
- Modify: `src/client/Main.client.luau`

**Interfaces:**
- `TransportRules.mountTinyBike(profile): (boolean, string)`
- `TransportRules.dismountTinyBike(profile): (boolean, string)`
- `TransportRules.movementSpeed(profile): number`
- `BikeBuilder.build(parent: Instance, name: string, origin: CFrame, accent: Color3)` returns `{ model: Model, mountPart: BasePart, mountPrompt: ProximityPrompt, dismountPrompt: ProximityPrompt }`.
- `TransportService` owns per-player bike models and connections; `bikeActive` is treated as session mount state and is explicitly reset to false on join/respawn.

- [ ] **Step 1: Write the failing transport tests**

Add tests proving an unowned profile cannot mount, an owned profile can mount once, a mounted profile cannot mount again, dismount returns to parked, and `movementSpeed` is 24 while mounted and 16 while parked. Keep the existing 300-coin purchase assertions.

- [ ] **Step 2: Run the transport tests RED**

Run the full Luau suite and confirm failure names the missing mount transitions rather than a syntax/import error.

- [ ] **Step 3: Implement pure mount transitions**

Keep purchase separate from mount. Do not make `buyTinyBike` implicitly activate the bike. `TransportRules.mountTinyBike` must require `ownsTinyBike`; `dismountTinyBike` must be safe when already parked.

- [ ] **Step 4: Run transport tests GREEN**

Run `tests\run.luau` and confirm all specs pass before touching Roblox instance code.

- [ ] **Step 5: Build the stable bike model**

`BikeBuilder` must create a named model with a frame, two wheel cylinders, seat, handlebars, pedals, and an anchored/non-colliding mount carrier. Every decorative part must be separated from the floor by a positive y offset. Add a bounded `ProximityPrompt` with `Mount Bike`/`Dismount Bike` copy.

- [ ] **Step 6: Integrate server mount lifecycle**

Refactor `TransportService` so the transport prompt purchases the bike when unowned, otherwise mounts/dismounts it. Create an owned bike model after profile load, place it at the transport stand until the plot is available, and follow the player through a server-owned mount carrier while mounted. On dismount, respawn, or player removal, restore speed 16, reset the session flag, disconnect follow connections, and park/destroy the model without leaving stale models.

Do not let a client set speed or mount state. Sync `TinyWorldBikeState` (`not owned`, `parked`, `mounted`) and retain legacy `TinyWorldBikeActive` for compatibility.

- [ ] **Step 7: Update HUD copy and run static compilation**

Show truthful bike state in the transport row. Compile the changed server and client files before moving on.

- [ ] **Step 8: Commit the bike slice**

```powershell
git add src/server/BikeBuilder.luau src/server/TransportService.luau src/server/PlayerStateService.luau src/shared/TransportRules.luau src/client/Main.client.luau tests/TransportRules.spec.luau
git commit -m "feat: make Tiny Bike a rideable mount"
```

### Task 3: Add bounded cabins, nursery, plants, props, and per-player pickups

**Files:**
- Create: `src/server/LivingWorldBuilder.luau`
- Create: `src/server/LivingWorldService.luau`
- Create: `tests/verify-living-world.ps1`
- Modify: `src/server/WorldBuilder.luau`
- Modify: `src/server/Main.server.luau`
- Modify: `src/shared/WorldLayoutRules.luau`
- Modify: `tests/WorldLayoutRules.spec.luau`

**Interfaces:**
- `LivingWorldBuilder.build(parent: Instance, layout)` returns `{ model: Model, pickupPrompts: { [string]: ProximityPrompt }, nurseryAnchor: BasePart, cabins: { Model } }`.
- Pickup keys are exactly `MeadowSeed`, `Seashell`, and `WoodToken`.
- `LivingWorldService.new(world, ProfileStore, PlayerStateService)` connects the three prompts and exposes no client mutation API.
- `WorldLayoutRules` adds a bounded `livingWorld` placement/budget record derived from `perimeterHalfExtent`, not from hard-coded player count.

- [ ] **Step 1: Add a failing source-contract guard**

The PowerShell guard must fail against the current tree because `LivingWorldBuilder.luau` does not yet exist. It will later verify the builder creates `Cabin`, `Nursery`, `MeadowSeedPickup`, `SeashellPickup`, `WoodTokenPickup`, `FlowerPatch`, and `Planter` names; decoration helpers set `CanCollide`, `CanTouch`, and `CanQuery` false; and the builder reads layout/budget values.

- [ ] **Step 2: Run the guard RED**

```powershell
.\tests\verify-living-world.ps1
```

Expected: a clear missing-builder failure.

- [ ] **Step 3: Add layout budgets and placement rules**

Add bounded counts for cabins, nursery props, life-kit pickups, planters, and flower clusters. Keep the existing plot-capacity assertions and add tests proving the values are positive, deterministic, and do not grow with more than `WorldLayoutRules.MAX_PLOTS` players.

- [ ] **Step 4: Implement the builder**

Create reusable helpers for anchored parts, decorations, labels, prompts, windows, flower clusters, lanterns, fences, cabin kits, and item pickup displays. Use the existing `VisualTheme` palette and valid Roblox materials only. Put all static output under one `TinyWorldLivingWorld` model. Keep cabin footprints outside player plot slots and inside the village boundary.

- [ ] **Step 5: Implement the server pickup service**

On a prompt, load the profile, call `LivingWorldRules.collect`, sync attributes, save only on success, and send clear messages for success, duplicate collection, or missing profile. The same prompt may be used by all players because the daily mask is per profile.

- [ ] **Step 6: Wire the builder and service into `Main.server.luau`**

Build static living-world scenery after the original world builder returns. Construct `LivingWorldService` after `ProfileStore`/`PlayerStateService` are available and before player-added handling. Keep the returned world object stable for all clients.

- [ ] **Step 7: Run the guard, tests, and compilers GREEN**

Run the full suite, material guard, `luau-analyze`, and server/client compilation. Fix source defects, not assertions.

- [ ] **Step 8: Commit the living-world builder and pickups**

```powershell
git add src/server/LivingWorldBuilder.luau src/server/LivingWorldService.luau src/server/WorldBuilder.luau src/server/Main.server.luau src/shared/WorldLayoutRules.luau tests/WorldLayoutRules.spec.luau tests/verify-living-world.ps1
git commit -m "feat: add living village cabins and pickups"
```

### Task 4: Connect home charm to plot dressing and house upgrades

**Files:**
- Modify: `src/server/PlotService.luau`
- Modify: `src/server/WorldBuilder.luau`
- Modify: `src/server/PlayerStateService.luau`
- Modify: `src/client/Main.client.luau`
- Modify: `tests/verify-roblox-materials.ps1`

**Interfaces:**
- Every plot returns a server-owned `homeCharmPrompt`.
- `PlotService:_decorate(player, plotIndex)` validates plot ownership and calls `LivingWorldRules.addHomeCharm`.
- `PlotService:rebuildHouse` renders the charm only when `profile.homeCharmApplied` is true.

- [ ] **Step 1: Add a failing plot/source test**

Extend the material guard with a missing-contract assertion for `HomeCharmPrompt`, `HomePlanter`, `HomeFlowerCluster`, `HomeLantern`, `HouseWindow`, `CabinChimney`, and explicit decoration collision flags. Run it RED against the current source.

- [ ] **Step 2: Add the home-charm prompt and service path**

Create the prompt near the house, connect it in `PlotService.new`, reject non-owners and incomplete kits with an explanatory message, consume the three items through the pure rule, rebuild the house, sync, and save.

- [ ] **Step 3: Add tier-aware house/cabin detail**

Keep the existing floor/wall/roof geometry and add separated visual details: chimney/roof trim for tier 2+, extra window/upper feature for tier 3+, planter/flower cluster/warm lantern for the home charm. Ensure all decorative pieces are non-colliding and do not sit on the same plane as PlotBase or PlotBorder.

- [ ] **Step 4: Update player attributes/HUD**

Expose `TinyWorldMeadowSeeds`, `TinyWorldSeashells`, `TinyWorldWoodTokens`, `TinyWorldLifeKitCount`, and `TinyWorldHomeCharm` through `PlayerStateService.sync`. Add a compact HUD line without hiding existing coins, XP, home, garden, profession, portal, exploration, or goal state.

- [ ] **Step 5: Run focused tests and static guards GREEN**

Run the full suite, both material guards, analyzer, and compilers. Inspect the generated source for accidental co-planar surfaces and malformed numeric loops.

- [ ] **Step 6: Commit the home and plot slice**

```powershell
git add src/server/PlotService.luau src/server/WorldBuilder.luau src/server/PlayerStateService.luau src/client/Main.client.luau tests/verify-roblox-materials.ps1
git commit -m "feat: connect living items to home dressing"
```

### Task 5: End-to-end gates and Studio verification

**Files:**
- Modify: `docs/progress.md`
- Create: `docs/v0.0.4-mvp-test.md`
- Modify: `README.md`

- [ ] **Step 1: Run the complete local gate**

From `C:\Users\wilf6\dev\tinyworld` run:

```powershell
& C:\Users\wilf6\scoop\apps\luau\current\luau.exe tests\run.luau
& C:\Users\wilf6\scoop\apps\luau\current\luau-analyze.exe src\shared tests
Get-ChildItem src\server\*.luau | ForEach-Object { & C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe $_.FullName *> $null; if ($LASTEXITCODE -ne 0) { throw "server compile failed: $($_.Name)" } }
Get-ChildItem src\client\*.luau | ForEach-Object { & C:\Users\wilf6\scoop\apps\luau\current\luau-compile.exe $_.FullName *> $null; if ($LASTEXITCODE -ne 0) { throw "client compile failed: $($_.Name)" } }
.\tests\verify-roblox-materials.ps1
.\tests\verify-living-world.ps1
rojo build default.project.json --output "$env:TEMP\tinyworld-v004-living-world.rbxlx"
git diff --check
```

Record exact output, exit codes, and commit SHA before opening Studio.

- [ ] **Step 2: Sync and run single-player Studio smoke test**

With `rojo serve` on `localhost:34872` and the connected plugin, open the published TinyWorld Dev place, press Play, and verify the v0.0.4 HUD, empty Output, stable grass/plot borders while moving, richer cabins/props, pickup prompts, bike purchase/mount/dismount, and home charm rebuild.

- [ ] **Step 3: Run Studio Server & Clients**

Use at least two clients. Verify each player can see the shared static world, only the owner can mount their bike or decorate their home, each profile receives its own daily pickup credit, and the existing garden/job/trade/portal routes remain available.

- [ ] **Step 4: Publish only the Rojo-synced tree**

Publish the verified source-synced place to the limited TinyWorld Dev experience. Record whether Studio confirms the save, the visible v0.0.4 HUD, Output state, mode, and exact local Git SHA. Do not claim cloud SHA equality unless surfaced by direct evidence.

- [ ] **Step 5: Write evidence docs and commit**

`docs/v0.0.4-mvp-test.md` must separate local static proof, single-player Studio proof, multi-client proof, publish proof, and remaining remote-device/public-readiness gates. `docs/progress.md` gets a dated concise entry; `README.md` keeps the older v0.01/v0.0.3 instructions while linking the new controlled v0.0.4 route.

```powershell
git add README.md docs/progress.md docs/v0.0.4-mvp-test.md
git commit -m "docs: record v0.0.4 living world evidence"
git push origin main
git rev-parse HEAD
git ls-remote origin refs/heads/main
```

- [ ] **Step 6: Complete the requirement audit**

Check each original and amended requirement against direct evidence. Leave the goal active if multiplayer, publish, or remote-device proof is missing; mark complete only when all required evidence exists.

