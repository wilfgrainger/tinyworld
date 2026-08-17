# TinyWorld v0.7.6 Runtime Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close all code-owned findings from audit #36 in a coordinated `v0.7.6` / `ART R8.2 Runtime Hardening` release, while preserving TinyWorld's published rendering safety, server authority, persistence compatibility, free-only CI and DEV/LIVE separation.

**Architecture:** Add a small set of deterministic shared rule modules for traversal decisions, portal lifecycle reconciliation, activity leases and player gameplay phase. Roblox services keep Instance/lifecycle responsibilities, but cross-service state decisions become testable in the CLI suite. R8 becomes the single visible village/coast presentation authority, the Tiny Boat becomes bounded controllable traversal, and release/runtime evidence contracts are strengthened without adding a new framework.

**Tech Stack:** Roblox Luau, Rojo, Rokit, StyLua, `luau` CLI tests, `luau-analyze`, `luau-compile`, Bash/JQ source contracts, GitHub Actions, Roblox Place Publishing API.

## Global Constraints

- Preserve the R5 published-runtime safety boundary: no published runtime `EditableMesh`.
- Preserve Studio-only preview behaviour where already approved.
- Preserve the free-only GitHub Actions workflow.
- Preserve DEV/LIVE DataStore separation and manual LIVE promotion.
- Preserve profile schema compatibility. No profile schema bump is planned for this release.
- Do not invent Roblox asset IDs.
- Do not re-enable retired R6/R7 visual presentation paths.
- Keep authoritative economy, progression, ownership, trade, rewards and final placement state on the server.
- Keep alternate portal worlds out of village coastal recovery only while a valid server portal session is active.
- Human visual/device acceptance remains a release gate after DEV publication.
- Release identity: `0.7.6`, `ART R8.2`, `Runtime Hardening`.
- Controlling audit: #36. Workstreams: #37-#43. External/human dependency issues: #46-#48.

---

## File Structure

### New deterministic modules

- `src/shared/TraversalSafetyRules.luau`: decide village recovery vs valid portal exemption from distance/world/session state.
- `src/shared/ActivityLeaseRules.luau`: acquire, refresh, expire and release serialized public activity ownership.
- `src/shared/PlayerPhaseRules.luau`: decide whether a loaded profile is allowed to mutate normal gameplay state.
- `src/shared/BoatTraversalRules.luau`: clamp/control bounded Tiny Boat movement inside authored water limits.

### New tests

- `tests/TraversalSafetyRules.spec.luau`
- `tests/ActivityLeaseRules.spec.luau`
- `tests/PlayerPhaseRules.spec.luau`
- `tests/BoatTraversalRules.spec.luau`

### Main modified runtime files

- `src/server/TraversalSafetyService.luau`
- `src/server/PortalService.luau`
- `src/server/VillageActivityService.luau`
- `src/server/VillageGardenActivityService.luau`
- `src/server/FishingActivityService.luau`
- `src/server/BuilderRepairActivityService.luau`
- `src/server/WorldBuilder.luau`
- `src/server/R8GroundBuilder.luau`
- `src/server/ProductionArtCleanup.luau` or a focused R8 retirement helper if cleanup would otherwise become unfocused
- `src/server/OnboardingService.luau`
- normal mutating/reward service entry points identified by source search
- `src/server/BoatBuilder.luau`
- `src/server/BoatService.luau`
- `src/client/GameNav.luau`
- `src/client/Main.client.luau`
- `src/client/ModalController.luau`
- `src/shared/AnalyticsEvents.luau`
- `src/server/AnalyticsService.luau` and the first meaningful activity emission point

### Release/contracts/docs

- `tests/run.luau`
- `tests/verify-v0.7.5-art-r8.1-source-contract.sh` only where compatibility assertions must remain valid
- Create `tests/verify-v0.7.6-art-r8.2-source-contract.sh`
- `.github/workflows/tinyworld-ci.yml`
- `default.project.json`
- `config/release.json`
- `src/shared/ReleaseInfo.luau`
- `docs/releases/v0.7.6/acceptance.md`
- `docs/quality/performance-budgets.md` or a dedicated `docs/releases/v0.7.6/performance-evidence.md`

---

### Task 1: Traversal Safety Rules and Portal Respawn Reconciliation (#37)

**Files:**
- Create: `src/shared/TraversalSafetyRules.luau`
- Create: `tests/TraversalSafetyRules.spec.luau`
- Modify: `tests/run.luau`
- Modify: `src/server/TraversalSafetyService.luau`
- Modify: `src/shared/PortalSessionRules.luau`
- Modify: `tests/PortalSessionRules.spec.luau`
- Modify: `src/server/PortalService.luau`

**Interfaces:**
- Produces `TraversalSafetyRules.Action = { Allow, RecoverShore, RecoverWorld, PortalExempt }`.
- Produces `TraversalSafetyRules.decide(input)` where `input` contains `distance`, `y`, `shorelineDistance`, `waterBelt`, `portalWorld`, `hasValidPortalSession`.
- Produces `PortalSessionRules.resetState()` returning canonical transient Village state data.
- `TraversalSafetyService` consumes a callback `hasValidPortalSession(player)` supplied from `PortalService` or a server-authoritative player attribute maintained only from the server session table.

- [ ] **Step 1: Write failing traversal decision tests**

Add cases equivalent to:

```luau
local decision = TraversalSafetyRules.decide({
    distance = 511,
    y = 0,
    shorelineDistance = 210,
    waterBelt = 180,
    portalWorld = "Village",
    hasValidPortalSession = false,
})
TestUtil.assertEqual(decision, TraversalSafetyRules.Action.RecoverShore)
```

Cover `389, 390, 391, 510, 511, 570, 571, 10000`, under-map `y < -20`, valid portal session exemption, and stale non-Village attribute without a valid session.

- [ ] **Step 2: Register the new spec and verify RED**

Run `luau tests/run.luau`. Expected: fail because `TraversalSafetyRules` does not exist.

- [ ] **Step 3: Implement the minimal pure decision module**

Core rule:

```luau
if input.y < TraversalSafetyRules.RECOVERY_Y then
    return TraversalSafetyRules.Action.RecoverWorld
end
if input.portalWorld ~= nil and input.portalWorld ~= "" and input.portalWorld ~= "Village" then
    if input.hasValidPortalSession then
        return TraversalSafetyRules.Action.PortalExempt
    end
end
if input.distance > input.shorelineDistance + input.waterBelt then
    return TraversalSafetyRules.Action.RecoverShore
end
return TraversalSafetyRules.Action.Allow
```

No maximum recovery distance exists.

- [ ] **Step 4: Run tests and verify GREEN**

Run `luau tests/run.luau`.

- [ ] **Step 5: Write failing portal reset-state tests**

Add tests proving reset state is `Village`, zero crystals/mechanics, secret false, inactive/no session.

- [ ] **Step 6: Implement portal reset/reconciliation**

Add a focused helper in `PortalService`:

```luau
function PortalService:_resetToVillageState(player: Player, teleportHome: boolean)
    self.sessions[player] = nil
    player:SetAttribute("TinyWorldPortalCrystals", 0)
    player:SetAttribute("TinyWorldPortalMechanics", 0)
    player:SetAttribute("TinyWorldPortalSecretFound", false)
    player:SetAttribute("TinyWorldPortalWorld", "Village")
    if teleportHome then
        teleport(player, self.world.villageReturnCFrame)
    end
end
```

`setupPlayer` connects one `CharacterAdded` handler per player and calls the reset helper on later character spawns. `removePlayer` disconnects it.

- [ ] **Step 7: Replace attribute-only traversal exemption**

`TraversalSafetyService` must ask an authoritative server session predicate. Do not trust a non-Village replicated attribute by itself.

- [ ] **Step 8: Run focused/full tests and compile**

Run:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/TraversalSafetyService.luau >/dev/null
luau-compile src/server/PortalService.luau >/dev/null
```

- [ ] **Step 9: Commit**

`git commit -m "fix: harden traversal and portal lifecycle"`

---

### Task 2: Bounded Public Activity Leases and Explicit Abandon (#38)

**Files:**
- Create: `src/shared/ActivityLeaseRules.luau`
- Create: `tests/ActivityLeaseRules.spec.luau`
- Modify: `tests/run.luau`
- Modify: `src/server/VillageGardenActivityService.luau`
- Modify: `src/server/FishingActivityService.luau`
- Modify: `src/server/BuilderRepairActivityService.luau`
- Modify: `src/server/VillageActivityService.luau`
- Modify: `src/server/Main.server.luau` if lifecycle release wiring belongs at composition root

**Interfaces:**
- `ActivityLeaseRules.LEASE_SECONDS = 120`.
- `ActivityLeaseRules.new(ownerId, now)` returns `{ ownerId, expiresAt }`.
- `ActivityLeaseRules.isExpired(lease, now)`.
- `ActivityLeaseRules.canAcquire(lease, requesterId, now)`.
- `ActivityLeaseRules.refresh(lease, ownerId, now)`.

- [ ] **Step 1: Write failing lease tests** covering acquire, second-owner rejection, same-owner refresh, expiry at/after 120s, release/reacquire.
- [ ] **Step 2: Register spec and verify RED** with `luau tests/run.luau`.
- [ ] **Step 3: Implement minimal lease rules** with no Roblox dependencies.
- [ ] **Step 4: Verify GREEN**.
- [ ] **Step 5: Refactor three public activity services** so each replaces bare `self.owner` lifetime with `self.lease` and calls shared rules before denying a player. Meaningful progress refreshes the lease.
- [ ] **Step 6: Add one common release API** to each activity service: `abandonPlayer(player)` clears local progress only when owned by that player.
- [ ] **Step 7: Add `VillageActivityService:abandon(player)`** which releases the current activity service and clears its active map. Use the existing message channel to confirm cancellation.
- [ ] **Step 8: Wire release on `CharacterAdded`, player removal and portal start/transition**. Do not leave activity ownership live across world changes.
- [ ] **Step 9: Run tests/analyze/compile**.
- [ ] **Step 10: Commit** `fix: bound public activity ownership`.

---

### Task 3: R8 Single Visible World Authority (#39)

**Files:**
- Modify: `src/server/WorldBuilder.luau`
- Modify: `src/server/R8GroundBuilder.luau`
- Modify: `src/server/BoundaryBuilder.luau` only if needed to separate gameplay anchors from presentation
- Create or modify focused helper: `src/server/R8LegacyPresentationRetirement.luau`
- Create: `tests/verify-v0.7.6-art-r8.2-source-contract.sh`
- Modify: `.github/workflows/tinyworld-ci.yml`

**Interfaces:**
- `R8LegacyPresentationRetirement.apply(root)` removes/hides only superseded visible legacy presentation.
- It must preserve service anchors/prompts/docks/cove references that existing services use.

- [ ] **Step 1: Write the source contract first**. It must fail if R8 startup still permits visible legacy `SeaNorth`, `SeaSouth`, `SeaEast`, `SeaWest`, legacy village path/scenery presentation, or direct activation of R6/R7 visual builders.
- [ ] **Step 2: Run the contract and verify RED** on current branch.
- [ ] **Step 3: Implement the smallest structural split**. Preferred: have `WorldBuilder` tag or group legacy presentation separately from gameplay anchors, then retire that group before R8 presentation mounts. Do not blanket-delete the world tree.
- [ ] **Step 4: Ensure `R8GroundBuilder` removes/replaces old ground/routes deterministically** and R8 Terrain coast is the only visible sea/coast layer.
- [ ] **Step 5: Verify source contract GREEN and compile all server files**.
- [ ] **Step 6: Run existing R5/R8/R8.1 contracts** to prove safety boundaries were not weakened.
- [ ] **Step 7: Commit** `fix: make r8 the single world authority`.

---

### Task 4: Server-Authoritative Gameplay Phase (#40)

**Files:**
- Create: `src/shared/PlayerPhaseRules.luau`
- Create: `tests/PlayerPhaseRules.spec.luau`
- Modify: `tests/run.luau`
- Create: `src/server/GameplayAccessService.luau`
- Modify: `src/server/OnboardingService.luau`
- Modify mutating/rewarding service entry points identified by search, including at minimum portal completion/start, transport purchase/mount, public activities, trade, home mutation/store purchase and reward paths.

**Interfaces:**
- `PlayerPhaseRules.canEnterGameplay(profile): (boolean, string)` returns `false, "onboarding_incomplete"` until durable onboarding completion.
- `GameplayAccessService.canEnter(player)` reads the server ProfileStore and applies the rule.
- `GameplayAccessService.require(player, message?)` returns boolean and optionally sends a standard setup-required message.

- [ ] **Step 1: Write failing phase tests** for nil profile, incomplete onboarding, completed onboarding.
- [ ] **Step 2: Register and verify RED**.
- [ ] **Step 3: Implement `PlayerPhaseRules` and verify GREEN**.
- [ ] **Step 4: Implement `GameplayAccessService`** as the single server helper.
- [ ] **Step 5: Search all mutating/rewarding entry points** and gate the user-initiated paths. Do not gate the onboarding service itself or read-only setup state.
- [ ] **Step 6: Ensure successful onboarding immediately changes the durable profile and therefore the gate result without rejoin**.
- [ ] **Step 7: Reconcile player phase on `CharacterAdded`** where movement/state reset is server-controlled.
- [ ] **Step 8: Run full tests/analyze/compile**.
- [ ] **Step 9: Commit** `fix: enforce onboarding gameplay phase`.

---

### Task 5: Real Tiny Boat Traversal (#42)

**Files:**
- Create: `src/shared/BoatTraversalRules.luau`
- Create: `tests/BoatTraversalRules.spec.luau`
- Modify: `tests/run.luau`
- Modify: `src/server/BoatBuilder.luau`
- Modify: `src/server/BoatService.luau`
- Modify: `src/shared/TraversalRules.luau` if boat-zone semantics need one canonical helper
- Modify client input only if the existing VehicleSeat input path is insufficient

**Interfaces:**
- Boat bounds derive from the R8 authored coast, not arbitrary client coordinates.
- `BoatTraversalRules.clampPosition(x, z, innerRadius, outerRadius)` returns a safe bounded planar position.
- `BoatTraversalRules.canDrive(profile)` requires `ownsTinyBoat` and active boat state.

- [ ] **Step 1: Write failing boat boundary tests** for inner water edge, outer water edge, absurd client displacement, and ownership/activity state.
- [ ] **Step 2: Verify RED**.
- [ ] **Step 3: Implement pure bound/control rules and verify GREEN**.
- [ ] **Step 4: Convert the boat root/seat from anchored display-only assembly into an actual controllable Roblox vehicle assembly** using server-created constraints/VehicleSeat or the simplest native server-safe control model already supported by the project. Decorative children may remain non-colliding; the vehicle root must be physically coherent.
- [ ] **Step 5: Remove `_mount()` teleport-as-the-primary-traversal mechanic**. Mount may position the boat at the cove/start, but subsequent travel must be player-controlled.
- [ ] **Step 6: Clamp/recover the boat server-side when it exits the authored water band or becomes invalid/under-map. Never trust client transforms as authoritative final state.
- [ ] **Step 7: Preserve return/dismount and Coastal Delivery compatibility**.
- [ ] **Step 8: Run tests/compile/source contract**.
- [ ] **Step 9: Commit** `feat: make tiny boat controllable`.

---

### Task 6: Controller/Mobile UX and Analytics Completion (#42)

**Files:**
- Modify: `src/client/GameNav.luau`
- Modify: `src/client/FocusController.luau`
- Modify: `src/client/Main.client.luau`
- Modify: `src/client/ModalController.luau`
- Modify: `src/client/UiScaleRules.luau` only if a shared rule is missing
- Modify: `src/shared/AnalyticsEvents.luau`
- Modify first meaningful activity emission point in server activity/service code

**Interfaces:**
- Explicit focus order is deterministic among visible core nav/modal buttons.
- Existing `UiTokens.TouchTarget = 44` remains the minimum.
- Analytics events remain allow-listed identifiers with numeric/enum-like bounded payloads only.

- [ ] **Step 1: Add deterministic focus ordering using `NextSelection*` or the existing `FocusController` abstraction** for core nav/modal controls.
- [ ] **Step 2: Make `Main.client` consume shared scale/safe-area rules rather than maintaining an independent responsive path**.
- [ ] **Step 3: Preserve 44x44 minimum touch targets and compact permanent HUD**.
- [ ] **Step 4: Add `AnalyticsEvents.FirstMeaningfulActivity` and emit it once per session at the first successful meaningful activity completion/start boundary chosen consistently with target-state analytics. Do not send names/free text.
- [ ] **Step 5: Compile all client/server files and run tests**.
- [ ] **Step 6: Commit** `feat: finish controller mobile and activity analytics`.

---

### Task 7: Behavioural CI and Performance Governance (#41, #46)

**Files:**
- Modify: `.github/workflows/tinyworld-ci.yml`
- Modify: `default.project.json`
- Create: `docs/releases/v0.7.6/performance-evidence.md`
- Modify: `docs/quality/performance-budgets.md` only if the evidence procedure is not already explicit
- Modify: `tests/verify-v0.7.6-art-r8.2-source-contract.sh`

**Interfaces:**
- CI runs all shared specs and the new R8.2 source contract on `ubuntu-latest`.
- No `upload-artifact`, cache or paid external SaaS is added.

- [ ] **Step 1: Add new specs/source contract to CI** while retaining all existing safety checks.
- [ ] **Step 2: Make Workspace streaming decision explicit**. If Rojo property serialization supports it in the current project representation, add a `Workspace` node with the chosen `StreamingEnabled` property; otherwise document the Roblox experience setting as a mandatory DEV evidence field rather than inventing unsupported project syntax.
- [ ] **Step 3: Add a reproducible performance evidence template** with fields for exact SHA/place version, device, graphics level, server players, instance count, load time, client memory, FPS, Developer Console and MicroProfiler notes.
- [ ] **Step 4: Keep actual measurements marked `PENDING HUMAN DEVICE EVIDENCE`** until supplied.
- [ ] **Step 5: Attempt branch-protection configuration only if an existing GitHub write tool supports it and it is available on the current plan. Otherwise update #46 with the exact limitation and retain exact-head PR verification as compensating control.
- [ ] **Step 6: Commit** `test: strengthen runtime hardening gates`.

---

### Task 8: Character Expression Dependency Handling (#42, #47)

**Files:**
- Inspect: `src/shared/AppearanceDefinitions.luau`
- Inspect/modify: `src/server/AppearanceService.luau`
- Modify player-facing copy/docs only where current language overstates visible customisation

**Interfaces:**
- No asset is applied unless already present/approved with repository provenance or a Roblox-native safe mechanism needs no invented asset ID.

- [ ] **Step 1: Inventory current appearance definitions/assets and manifest provenance**.
- [ ] **Step 2: If approved visible assets already exist, add deterministic visible application using Roblox-supported avatar description/accessory mechanisms and test definition validation.**
- [ ] **Step 3: If approved assets do not exist, keep avatar-preservation behaviour, remove any copy that falsely promises a visible outfit/hair change, and leave #47 open with exact asset dependency.**
- [ ] **Step 4: Never create a fake asset ID or primitive avatar attachment just to close the issue.**
- [ ] **Step 5: Commit** `docs:` or `feat:` according to whether visible approved assets were actually available.

---

### Task 9: Release Identity, Governance Drift and Acceptance (#43, #48)

**Files:**
- Modify: `config/release.json`
- Modify: `src/shared/ReleaseInfo.luau`
- Create: `docs/releases/v0.7.6/acceptance.md`
- Modify release contract/source contract as required
- Update GitHub issues #26, #31, #36, #37-#43, #47-#48 with evidence/status

**Interfaces:**
- Exact release identity everywhere: version `0.7.6`, ART `R8.2`, name `Runtime Hardening`, artifact `TinyWorld-v0.7.6.rbxlx`.

- [ ] **Step 1: Write release metadata and failing contract expectations first**.
- [ ] **Step 2: Update ReleaseInfo/build stamp so published client visibly identifies the current candidate**.
- [ ] **Step 3: Create v0.7.6 acceptance doc** separating automated evidence from human-only evidence.
- [ ] **Step 4: Update stale #26/#31 status comments to point to v0.7.6 remediation without closing their human gates**.
- [ ] **Step 5: Run authoritative local-equivalent command set where tooling is available through CI, then push exact branch head**.
- [ ] **Step 6: Verify exact branch-head GitHub Actions run is green**.
- [ ] **Step 7: Open PR referencing #36 and child issues. Keep it draft until all code work is complete.**
- [ ] **Step 8: Review changed files/PR diff and fix any findings, then reverify exact head**.
- [ ] **Step 9: Merge only the exact reviewed green head under the user's release-wide authorization**.
- [ ] **Step 10: Verify main independently passes and record main SHA/workflow run/DEV place version**. Existing main-only workflow may publish DEV.
- [ ] **Step 11: Do not publish LIVE**.
- [ ] **Step 12: Close engineering child issues whose automated acceptance is proven. Keep #36/#26/#31/#47/#48 open where approved-asset or real-client evidence remains pending.**

---

## Final Verification Checklist

Run/verify on exact final branch head:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
./tests/verify-v0.7.1-art-r5-source-contract.sh
./tests/verify-v0.7.4-art-r8-source-contract.sh
./tests/verify-v0.7.5-art-r8.1-source-contract.sh
./tests/verify-v0.7.6-art-r8.2-source-contract.sh
./scripts/verify-release-contract.sh
./tests/build-contract.sh
./scripts/build.sh
git diff --check
```

Then verify the authoritative GitHub Actions run for the exact SHA. Source success must not be represented as phone/controller/multiplayer/visual acceptance.

## Plan Self-Review

- Spec coverage: B1, B2, H1, H2, H3, H4, H5, P1, P2, controller/mobile, analytics, governance and release gates all map to Tasks 1-9.
- Placeholder scan: no TBD/TODO implementation placeholders. Human evidence is explicitly named as a post-DEV dependency, not an unspecified implementation step.
- Type/interface consistency: shared rule names and consumers are fixed in the File Structure and Task Interfaces sections.
- Scope: no framework migration, new world, monetisation, profile redesign, paid CI or LIVE publishing has been introduced.
