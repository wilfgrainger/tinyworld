# TinyWorld v0.5.2 Village Soul & Presentation Reset Implementation Plan

> For agentic workers: REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Replace TinyWorld's telemetry-heavy prototype presentation with a compact playable HUD, a deterministic 16-home authored village, recognizable world affordances, a genuinely playful hero home, and canonical release documentation.

**Architecture:** Preserve the existing server-authoritative services and profile schema. Add a focused prefab/art boundary so WorldBuilder, PlotService, and HomeService place named models and bind prompts to returned anchors. Keep pure layout/quality contracts in shared rules and client presentation in Main.client.luau; no client writes to economy or ownership state.

**Tech Stack:** Luau, Roblox server/client APIs, Rojo, Luau CLI, PowerShell source guards, GitHub pull request workflow.

## Global Constraints

- Preserve the north star: Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.
- Keep economy, progression, privacy, trade, transport, portal, inventory, and saves server-authoritative.
- Keep WorldLayoutRules Roblox-service-free and deterministic.
- The maximum visible residential homes in one village is exactly 16, irrespective of Players.MaxPlayers.
- Key objects must be recognizable when labels are disabled; labels supplement objects and never substitute for them.
- Normal play must not show the permanent 360x480 telemetry dashboard or raw database-language status lines.
- Prompt anchors may be queryable; decoration parts must be non-collidable, non-touching, and non-queryable.
- Do not add a new economy, monetisation gate, combat system, or profile schema migration in v0.5.2.
- Do not use unseeded randomness. Art variation must use the fixed layout seed and bounded variants.
- Use existing Roblox-native materials and palette tokens; no third-party assets or HTTP services.
- Write or update a failing test/source guard before each production implementation slice.
- Run luau tests/run.luau, luau-analyze src/shared/*.luau tests/*.luau, server/client compilation, relevant PowerShell guards, and git diff --check when the tools are available.
- Studio/published-place evidence must be clearly separated from local source evidence.

---

### Task 1: Establish the 0.5.2 contracts and canonical documentation

**Files:**
- Create: tests/VisualQualityRules.spec.luau
- Create: tests/verify-v0.5.2-visual-contract.ps1
- Create: src/shared/VisualQualityRules.luau
- Create: docs/README.md
- Create: docs/product/vision.md
- Create: docs/product/experience-pillars.md
- Create: docs/product/art-direction.md
- Create: docs/product/village.md
- Create: docs/product/homes.md
- Create: docs/product/ui-ux.md
- Create: docs/roadmap/roadmap.md
- Create: docs/roadmap/v0.5.2-village-soul.md
- Create: docs/engineering/architecture.md
- Create: docs/engineering/world-content-pipeline.md
- Create: docs/quality/definition-of-done.md
- Create: docs/quality/visual-quality-bar.md
- Create: docs/quality/playtesting.md
- Create: docs/releases/v0.5.2/acceptance.md
- Modify: tests/run.luau
- Modify: README.md

**Interfaces:**
- VisualQualityRules exports MAX_RESIDENT_HOMES = 16, TOAST_DURATION_SECONDS = 3, NEIGHBOURHOOD_COUNT = 4, and isRecognizableObjectContract(contract).
- The guard requires the compact HUD, Studio-only debug gate, prefab modules, neighbourhood names, MAX_PLOTS = 16, no amenity( call, and no makeInteractionMarker( call in player-facing world construction.
- docs/README.md is the documentation entrypoint and explicitly marks docs/superpowers/ as historical context unless a release document links it as active.

- [ ] Step 1: Write the failing shared quality test.

~~~lua
local TestUtil = require("./TestUtil")
local VisualQualityRules = require("../src/shared/VisualQualityRules")

return function()
    TestUtil.equal(VisualQualityRules.MAX_RESIDENT_HOMES, 16)
    TestUtil.equal(VisualQualityRules.TOAST_DURATION_SECONDS, 3)
    TestUtil.equal(VisualQualityRules.NEIGHBOURHOOD_COUNT, 4)
    TestUtil.isTrue(VisualQualityRules.isRecognizableObjectContract({
        silhouette = true,
        scale = true,
        material = true,
        feedback = true,
    }))
    TestUtil.isFalse(VisualQualityRules.isRecognizableObjectContract({
        silhouette = false,
        scale = true,
        material = true,
        feedback = true,
    }))
end
~~~

- [ ] Step 2: Add the spec to tests/run.luau and run luau tests/run.luau. It must fail because VisualQualityRules.luau does not exist.
- [ ] Step 3: Add VisualQualityRules.luau, the guard, and the canonical docs. The guard must fail closed if the release contracts are absent.
- [ ] Step 4: Update README to a short current-release introduction and links to docs/README.md, docs/releases/v0.5.2/acceptance.md, and the local verification route. Keep historical release material linked rather than deleting it.
- [ ] Step 5: Run the focused test, the guard, and git diff --check; commit docs: define the v0.5.2 visual quality contract.

### Task 2: Cap and compose the deterministic village layout

**Files:**
- Modify: src/shared/WorldLayoutRules.luau
- Modify: src/shared/VisualBudgetRules.luau
- Modify: src/server/VillageSceneryBuilder.luau
- Modify: src/server/BoundaryBuilder.luau only where landmark anchors need the new bounds
- Modify: tests/WorldLayoutRules.spec.luau
- Modify: tests/VisualBudgetRules.spec.luau
- Create: tests/VillageComposition.spec.luau

**Interfaces:**
- WorldLayoutRules.MAX_PLOTS is 16.
- WorldLayoutRules.NEIGHBOURHOODS contains exactly MeadowLane, HarbourRow, WoodlandRise, and OrchardEnd.
- WorldLayoutRules.create(maxPlayers) returns plotSlots, neighbourhoods, artSeed = 2052, and bounded budgets.
- Each plot slot has neighbourhood, rotation, and setback values; all are deterministic for the same input.

- [ ] Step 1: Replace tests expecting 60 plots with a failing 16-cap and neighbourhood test. Assert create(60) returns 16, create(nil) returns 4, every neighbourhood is represented, slots do not overlap, and repeated create(60) values match exactly.
- [ ] Step 2: Run the focused layout tests and confirm RED because the current ring generator returns up to 60 plots and has no neighbourhood metadata.
- [ ] Step 3: Implement the fixed four-neighbourhood slot table. Fill slots in neighbourhood order until the safe player count is reached; cap requested count at 16; retain a minimum of four. Use fixed rotations and setbacks, not math.random().
- [ ] Step 4: Update visual budgets for 16 homes and bounded seeded dressing. Ensure isWithinBudget remains true for 4 and 16 plots, and interaction marker budget is no longer used as a target for world dressing.
- [ ] Step 5: Rebuild VillageSceneryBuilder around curved segment surfaces, stream/bridge, grass banks, rocks, orchard/tree-cluster variants, uneven fence/flower/lamp placements, and neighbourhood-specific scenery. Keep the stable VillageGround and plot bases as collision foundations.
- [ ] Step 6: Run layout, budget, material, and existing pure tests; commit feat: compose a deterministic sixteen-home village.

### Task 3: Add authored prefab boundaries and replace generic civic/plot boxes

**Files:**
- Create: src/server/AuthoredPrefabBuilder.luau
- Create: tests/verify-v0.5.2-prefabs.ps1
- Modify: src/server/WorldBuilder.luau
- Modify: src/server/LivingWorldBuilder.luau
- Modify: tests/verify-physical-affordance-invariant.ps1
- Modify: tests/verify-physical-items.ps1

**Interfaces:**
- AuthoredPrefabBuilder.buildTownHall(parent, origin) returns model, contributionAnchor, and noticeboard.
- AuthoredPrefabBuilder.buildCourierDepot(parent, origin) returns model, pickupAnchor, and deliveryAnchor.
- AuthoredPrefabBuilder.buildVillageShop(parent, origin) returns model, deliveryAnchor, supplyAnchor, styleAnchor, and galleryAnchor.
- AuthoredPrefabBuilder.buildTransportWorkshop(parent, origin) returns model and transportAnchor.
- AuthoredPrefabBuilder.buildMarket(parent, origin) returns model, sides, and statusLabel.
- AuthoredPrefabBuilder.buildPlotAffordances(parent, origin) returns gatePrompt, privacyPrompt, visitPrompt, and homeCharmPrompt.
- Every returned model has TinyWorldArtRole and TinyWorldPhysicalAffordance attributes; every prompt anchor has TinyWorldInteractionAnchor = true.

- [ ] Step 1: Add the failing prefab guard. It must require distinct civic builder functions, role attributes, real plot affordances, and the absence of the generic amenity( invocation and normal-play makeInteractionMarker( calls.
- [ ] Step 2: Run the guard and record RED against the current generic WorldBuilder.
- [ ] Step 3: Implement the focused prefab builder. Use named, multi-part Roblox-native models with roofs/awnings/windows/steps/props; use WedgeParts/cylinders/decoration clusters where they improve silhouette. Keep decoration parts non-collidable and prompt anchors explicit.
- [ ] Step 4: Replace WorldBuilder's four amenity calls, trade pads, home shop boxes, and transport box with the returned prefab anchors. Preserve all existing returned field names consumed by services.
- [ ] Step 5: Replace plot kiosks with an architect drawing board, doorbell/gate, potting bench/flower arch, estate sign, item chest, and garden beds. Keep upgradePrompt, privacyPrompt, visitPrompt, homeCharmPrompt, itemChestPrompt, and garden prompt arrays as the service-facing interface.
- [ ] Step 6: Remove interaction rings from normal world construction and run prefab, physical-affordance, material, and compilation guards; commit feat: place authored civic and plot prefabs.

### Task 4: Replace the dashboard HUD and configuration onboarding

**Files:**
- Modify: src/client/Main.client.luau
- Modify: src/client/Onboarding.client.luau
- Create: tests/verify-v0.5.2-client-presentation.ps1

**Interfaces:**
- The normal HUD exposes CoinChip, LevelChip, QuestChip, JournalButton, Toast, and JournalPanel.
- Main.client.luau observes existing player attributes only.
- Toasts use TinyWorldMessageNonce and expire after VisualQualityRules.TOAST_DURATION_SECONDS.
- Raw telemetry appears only behind a RunService:IsStudio() gated debug button.

- [ ] Step 1: Add the failing client presentation guard. Require the named compact components, journal sections, TweenService, nonce-based toast timer, and Studio-only debug gate; reject the old Panel.Size 480px dashboard and raw normal-play title/copy.
- [ ] Step 2: Run the guard and confirm RED.
- [ ] Step 3: Rewrite Main.client.luau as a compact presentation layer. Map coins and level to small chips; map current goals and portal progress to friendly quest copy; build the journal as a hidden tabbed panel; animate toast in/out and ignore stale timers; keep a Studio-only raw-attribute drawer.
- [ ] Step 4: Rewrite onboarding choices as visual cards. Keep the server payload keys and values unchanged, but add avatar silhouette panels, Meadow/Harbor/Sunset colour/scene previews, selected state, and mobile-sized touch targets.
- [ ] Step 5: Run the client guard and Luau compilation; commit feat: make TinyWorld playable without telemetry chrome.

### Task 5: Make the home a playable hero space and improve touched objects

**Files:**
- Create: src/server/HomePrefabBuilder.luau
- Create: tests/verify-v0.5.2-home-quality.ps1
- Modify: src/server/PlotService.luau
- Modify: src/server/HomeService.luau
- Modify: src/server/BikeBuilder.luau
- Modify: src/server/BoatBuilder.luau
- Modify: src/server/TransportService.luau
- Modify: src/server/BoatService.luau
- Modify: src/server/PhysicalItemService.luau

**Interfaces:**
- HomePrefabBuilder.buildShell(parent, anchor, profile, house) returns named exterior anchors and preserves HomeCharmDisplay.
- HomeService:buildInterior(plot, profile) creates bedroom, kitchen, living, bathroom, storage, and garden objects with explicit prompts where interaction exists.
- Ambient home prompts route through HomeService:_useAmbient(player, plotIndex, actionId, target) and never change coins, XP, inventory, or ownership.
- Bike and boat retain their current builder return shapes and service-facing prompt names.

- [ ] Step 1: Add the failing home-quality guard. Require named room props, ambient interaction handler, HomePrefabBuilder, vehicle recognizability attributes, and touched-item art roles.
- [ ] Step 2: Run the guard and confirm RED.
- [ ] Step 3: Extract the residential shell from PlotService into HomePrefabBuilder. Preserve house tier dimensions, themes, tier dressing, charm display, and owner label behavior while adding a clear facade/porch/gable silhouette.
- [ ] Step 4: Expand HomeService interior dressing. Add lamp, mirror, shelf, fridge, sink, cooker, table/chairs, sofa, side table, rug, book/toy shelf, bathroom fixtures, storage chest, potting bench, and flower arch. Add bounded visible actions such as lamp toggle, fridge open/close, wardrobe use, bed rest, sink/shower use, and chest view. Keep the four owned HomeCatalog items authoritative.
- [ ] Step 5: Improve bike and boat silhouettes with explicit production-object attributes, designed frame/bow/seat/handle/sail details, and lightweight motion hooks for wheels/flags/water. Remove the TINY BIKE - MOUNTED telemetry badge from ordinary play and use a friendly toast/state chip instead.
- [ ] Step 6: Add recognizable named roles/material treatment to parcels, crops, seeds, shells, furniture, trade trays, and shop stock without changing reward rules.
- [ ] Step 7: Run home, physical-affordance, traversal, material, client/server compilation and focused guards; commit feat: turn the starter home and touched objects into playsets.

### Task 6: Ambient life, release evidence, and documentation reconciliation

**Files:**
- Modify: src/server/VisualTheme.luau
- Modify: src/server/VillageSceneryBuilder.luau
- Modify: src/server/WorldBuilder.luau
- Modify: README.md
- Modify: docs/progress.md
- Create: docs/v0.5.2-village-soul-test.md
- Modify: docs/releases/v0.5.2/acceptance.md

- [ ] Step 1: Add the failing ambient/acceptance guard. Require bounded smoke, warm windows, water/foliage/bird/butterfly hooks, the visual acceptance checklist, and explicit human Studio/published-place evidence sections.
- [ ] Step 2: Run the guard and confirm RED.
- [ ] Step 3: Add bounded ambient effects. Use seeded, capped models/particles/lights; never create unbounded per-player emitters. Keep visual budgets and mobile readability in mind.
- [ ] Step 4: Write the exact v0.5.2 Studio route. Include onboarding, compact HUD, journal, neighbourhood walk, label-disabled recognizability check, hero-home interactions, bike/boat, portal, trade, persistence, Output review, and evidence classification.
- [ ] Step 5: Reconcile README/progress with the current release and link the canonical docs hierarchy. Do not delete historical plans/specs; mark them as history.
- [ ] Step 6: Run the complete available local verification suite, git diff --check, inspect the final diff, and commit docs: publish v0.5.2 village soul acceptance.

### Task 7: Full release verification and PR publication

- [ ] Step 1: Run fresh tests and source checks from the repository root.

~~~sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/*.luau >/dev/null
luau-compile src/client/*.luau >/dev/null
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-visual-contract.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-prefabs.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-client-presentation.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-home-quality.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-ambient-acceptance.ps1
git diff --check
~~~

- [ ] Step 2: Inspect the full diff against the 0.5.1 base and confirm every review section maps to a code, test, or canonical-document change.
- [ ] Step 3: Run the whole-branch code review and fix every Critical/Important finding before publication.
- [ ] Step 4: Create/update the remote branch agent/v0.5.2-village-soul from main, publish all changed files, and open a draft PR titled feat: TinyWorld v0.5.2 Village Soul & Presentation Reset.
- [ ] Step 5: Verify the PR body names the compact HUD, 16-home village, prefab boundary, plot affordances, hero home, object/vehicle polish, ambient life, documentation authority, tests, and Studio evidence gaps.
