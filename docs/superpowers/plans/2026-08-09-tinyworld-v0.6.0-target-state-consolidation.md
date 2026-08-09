# TinyWorld v0.6.0 Target-State Consolidation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the complete repository-side TinyWorld target-state upgrade blueprint as v0.6.0 in one pull request without weakening server authority or fabricating Studio/device/publishing evidence.

**Architecture:** Preserve the existing shared/server/client layers. Introduce data-driven content definitions and profile v11 as a compatibility bridge, then layer server-authoritative home placement, remote security, transaction safety, responsive client components, analytics/performance contracts, and canonical release documentation around the existing playable village. Real Roblox IDs, credentials and runtime evidence remain fail-closed external gates.

**Tech Stack:** Luau, Roblox services, Rojo 7.7.0, Rokit, StyLua, GitHub Actions, pure Luau CLI tests.

## Global Constraints

- One pull request for v0.6.0.
- Use Superpowers TDD for deterministic behaviour.
- Apply `brockmartin/roblox-game-skill` architecture, persistence, inventory, security, GUI, performance, multiplayer, testing, tooling, sharp-edge, review and publish-readiness guidance in offline mode.
- Never trust client-supplied currency, rewards, prices, ownership or final transforms.
- Do not add Knit, React/Roact, Wally dependencies, fake Roblox IDs or pay-to-win.
- Preserve the custom leased ProfileStore and fail-closed load behaviour.
- Do not claim Studio, multiplayer, device, published DEV or LIVE evidence unless actually observed.

---

### Task 1: Lock release authority and full v0.6.0 specification

**Files:**
- Create: `docs/superpowers/specs/2026-08-09-tinyworld-v0.6.0-target-state-consolidation-design.md`
- Create: `docs/superpowers/plans/2026-08-09-tinyworld-v0.6.0-target-state-consolidation.md`
- Later modify: `AGENTS.md`, `README.md`, `docs/README.md`, `docs/progress.md`, `docs/roadmap/roadmap.md`

- [ ] Commit the approved design and this plan on the existing PR branch.
- [ ] Keep v0.5.2/v0.5.3 acceptance files historical.
- [ ] Make v0.6.0 the only active repository release after implementation.

### Task 2: RED tests for scalable content, migration, placement and transactions

**Files:**
- Create: `tests/ProfileMigrations.spec.luau`
- Create: `tests/ContentDefinitions.spec.luau`
- Create: `tests/FurniturePlacementRules.spec.luau`
- Create: `tests/RemoteGuardRules.spec.luau`
- Create: `tests/TradeTransactionRules.spec.luau`
- Modify: `tests/ProfileSchema.spec.luau`
- Modify: `tests/run.luau`

**Interfaces:**
- `ProfileMigrations.migrate(raw) -> (table?, string?)`
- `FurniturePlacementRules.validate(profile, furnitureId, request) -> (boolean, string, canonical?)`
- `RemoteGuardRules.*` pure validators usable by the server-only adapter.
- `TradeTransactionRules.*` pure idempotent transaction state transitions.

- [ ] Write tests asserting profile v11 generic inventory/furniture/outfit/world fields.
- [ ] Write migration tests for v10 -> v11, idempotence and future-version rejection.
- [ ] Write content-floor tests for >=80 furniture items, >=20 interaction items, >=4 activities, 4 worlds and >=30 keepsakes.
- [ ] Write placement tests for finite numbers, bounds, 90-degree rotation, ownership and budget.
- [ ] Write remote guard pure validation/rate-window tests.
- [ ] Write trade transaction duplicate-completion/locking/state tests.
- [ ] Push tests before production modules so CI demonstrates RED for missing behaviour.

### Task 3: GREEN content definitions and profile v11

**Files:**
- Create: `src/shared/ItemDefinitions.luau`
- Create: `src/shared/FurnitureDefinitions.luau`
- Create: `src/shared/ActivityDefinitions.luau`
- Create: `src/shared/WorldDefinitions.luau`
- Create: `src/shared/ShopDefinitions.luau`
- Create: `src/shared/AppearanceDefinitions.luau`
- Create: `src/shared/ProfileMigrations.luau`
- Modify: `src/shared/ProfileSchema.luau`
- Modify: `src/shared/HomeCatalog.luau`
- Modify: `src/shared/PortalRules.luau`
- Modify: `src/shared/Inventory.luau`

- [ ] Implement stable read-only definitions and target content floors.
- [ ] Keep static definition metadata out of saved profiles.
- [ ] Implement v10 -> v11 generic stack/instance/ownedFurniture/placements/outfit/discovery migration while retaining legacy fields.
- [ ] Make normalization defensive and reject future schema versions through migration.
- [ ] Adapt legacy HomeCatalog/PortalRules to definitions without changing server-owned prices/rewards.

### Task 4: GREEN placement and physical home system

**Files:**
- Create: `src/shared/FurniturePlacementRules.luau`
- Create: `src/server/FurniturePrefabBuilder.luau`
- Create: `src/server/FurniturePlacementService.luau`
- Modify: `src/server/HomeService.luau`
- Modify: `src/server/PlotService.luau`
- Modify: `src/server/Main.server.luau`

- [ ] Implement pure canonical placement validation.
- [ ] Build recognisable fallback prefab roles and stable art/interaction anchors.
- [ ] Create server-owned place/move/store remotes and collision/plot/ownership checks.
- [ ] Persist only canonical placement data.
- [ ] Render placements when the owner's plot exists so visitors receive server replication.
- [ ] Avoid whole-house rebuild for furniture-only changes.
- [ ] Dispatch reusable interaction verbs from server-authoritative definitions.

### Task 5: GREEN remote hardening and environment-safe persistence

**Files:**
- Create: `src/shared/RemoteGuardRules.luau`
- Create: `src/server/security/RemoteGuard.luau`
- Create: `src/server/EnvironmentConfig.luau`
- Modify: `src/server/ProfileStore.luau`
- Modify: `src/server/OnboardingService.luau`
- Modify: `src/server/Main.server.luau`

- [ ] Implement pure type/range/string/allow-list/rate-window rules.
- [ ] Implement server adapter with per-player cleanup, distance and structured warning helpers.
- [ ] Rate-limit onboarding and cap incoming strings before TextService.
- [ ] Migrate before normalize on load/save envelopes.
- [ ] Use DEV/LIVE-separated DataStore namespace configuration with DEV-safe default.
- [ ] Refuse unsupported future profile versions rather than normalizing them away.

### Task 6: GREEN durable trade protocol

**Files:**
- Create: `src/shared/TradeTransactionRules.luau`
- Create: `src/server/TradeJournal.luau`
- Modify: `src/server/TradeService.luau`

- [ ] Add transaction IDs and immutable agreed offer snapshots.
- [ ] Add lock/confirmed/committing/committed/cancelled state transitions.
- [ ] Make completion idempotent and reject stale/duplicate commit.
- [ ] Record audit/recovery shape before inventory mutation.
- [ ] Keep unique/high-value trading disabled until recovery evidence passes.

### Task 7: GREEN responsive UI, placement controls and appearance

**Files:**
- Create: `src/client/UiTokens.luau`
- Create: `src/client/UiScaleRules.luau`
- Create: `src/client/ButtonFactory.luau`
- Create: `src/client/PanelFactory.luau`
- Create: `src/client/ModalController.luau`
- Create: `src/client/FocusController.luau`
- Create: `src/client/FurniturePlacement.client.luau`
- Create: `src/client/Appearance.client.luau`
- Modify: `src/client/Main.client.luau`
- Modify: `src/client/Onboarding.client.luau`

- [ ] Use `Activated`/ContextActionService-compatible input instead of hover-only controls.
- [ ] Enforce >=44x44 effective touch targets and explicit small-phone/portrait/desktop rules.
- [ ] Add placement preview, rotate, confirm, cancel and store UX.
- [ ] Add controller focus order and modal ownership.
- [ ] Expand journal information architecture to Today, Bag, Home, Careers, Collection and Places without bloating HUD.
- [ ] Add free appearance preset/saved-outfit presentation paths.

### Task 8: Analytics, performance, asset and ambient-world foundations

**Files:**
- Create: `src/shared/AnalyticsEvents.luau`
- Create: `src/server/AnalyticsService.luau`
- Create: `src/shared/PerformanceBudgets.luau`
- Create: `src/server/AmbientLifeService.luau`
- Modify: `src/server/Main.server.luau`
- Modify: `src/server/WorldBuilder.luau`
- Modify: `assets/manifest.json` if present, otherwise create an approved manifest at the repository's established asset-manifest path.

- [ ] Add stable funnel event names without free-form player text.
- [ ] Emit only bounded lifecycle/gameplay milestone events.
- [ ] Encode initial 30 FPS mobile / 60 FPS desktop / 500 MB mobile / 15s mobile load budgets.
- [ ] Add a small deterministic ambient-life layer rather than hundreds of NPCs.
- [ ] Extend world definitions/build paths for four authored portal worlds while preserving existing two.
- [ ] Fail closed on unapproved/empty production asset IDs and record provenance fields.

### Task 9: Tooling and CI

**Files:**
- Modify: `rokit.toml`
- Create: `stylua.toml`
- Modify: `.github/workflows/luau-tests.yml`
- Modify: `.github/workflows/rojo-build.yml` only where v0.6.0 artifact naming/release manifest requires it.
- Modify: `scripts/build.sh`, `scripts/build.ps1`, `scripts/verify-release-contract.sh`
- Add/modify fail-closed source guards under `tests/`.

- [ ] Pin StyLua in Rokit.
- [ ] Add `stylua --check src tests` to CI.
- [ ] Keep `luau`, `luau-analyze`, compile, build-contract and release-contract gates.
- [ ] Update build artifact and manifest naming to v0.6.0.
- [ ] Add canonical-version contradiction guard.
- [ ] Add source guards for DEV/LIVE namespace separation, no credentials/fake IDs and server-only remote guard.

### Task 10: Canonical product/engineering/quality documentation

**Files:**
- Create: `docs/product/core-loop.md`
- Create: `docs/product/content-catalog.md`
- Create: `docs/product/safety-social.md`
- Create: `docs/engineering/data-model.md`
- Create: `docs/engineering/runtime-contracts.md`
- Create: `docs/engineering/remote-security.md`
- Create: `docs/engineering/asset-pipeline.md`
- Create: `docs/quality/performance-budgets.md`
- Create: `docs/quality/accessibility-mobile.md`
- Create: `docs/quality/release-evidence-template.md`
- Create: `docs/roadmap/v0.6.0-target-state-consolidation.md`
- Create: `docs/releases/v0.6.0/acceptance.md`
- Modify: `docs/product/vision.md`, `experience-pillars.md`, `art-direction.md`, `homes.md`, `village.md`, `ui-ux.md`
- Modify: `docs/engineering/architecture.md`, `production-engineering.md`, `world-content-pipeline.md`
- Modify: `docs/quality/definition-of-done.md`, `visual-quality-bar.md`, `playtesting.md`
- Modify: `AGENTS.md`, `README.md`, `docs/README.md`, `docs/progress.md`, `docs/roadmap/roadmap.md`

- [ ] Make audience, first 2/10/30 minutes, anti-goals, originality guard and v1 non-negotiables explicit.
- [ ] Specify home rooms/placement/guest/storage/catalog/performance contracts.
- [ ] Specify destination gameplay, ambient life, travel targets and portal world contract.
- [ ] Specify mobile/controller/safe-area/focus/loading/error/empty-state requirements.
- [ ] Specify social safety, filtering, visit/trade permissions and family-playtest rules.
- [ ] Specify analytics, data migration, remote security, asset provenance and performance evidence.
- [ ] Document DEV -> exact artifact -> evidence -> approved LIVE promotion and rollback without adding credentials.

### Task 11: Verification and Roblox-skill review

- [ ] Wait for GitHub Actions on the PR head.
- [ ] Fix every deterministic CI failure rather than documenting it away.
- [ ] Run/inspect code-review workflow criteria from `brockmartin/roblox-game-skill` against the final diff.
- [ ] Run/inspect security-audit criteria against every client -> server path.
- [ ] Run/inspect performance-audit and publish-checklist criteria, recording runtime-only items as pending evidence.
- [ ] Verify no licence-restricted external skill source was copied into TinyWorld.
- [ ] Update `docs/releases/v0.6.0/acceptance.md` with exact automated evidence and explicit pending Studio/device gates.
- [ ] Confirm the branch remains one PR and is mergeable.