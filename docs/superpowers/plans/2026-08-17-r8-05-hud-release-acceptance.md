# ART R8 Mobile HUD, Release and Human Acceptance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce mobile UI obstruction, verify the exact R8 release candidate, publish DEV, and keep R8 open until published-client screenshots pass the human visual bar.

**Architecture:** Existing UI components are compacted rather than replaced. Release identity/config/contracts advance to v0.7.4 / ART R8. The single free-only workflow remains authoritative; only a post-merge push to `main` publishes DEV.

**Tech Stack:** Luau UI, Bash release contracts, GitHub Actions, Rojo build, Roblox Place Publishing API.

## Global Constraints

- No LIVE publish.
- Single workflow only; no upload-artifact/cache actions.
- Retained Actions artifacts must remain zero.
- Human screenshots, not CI, decide visual acceptance.
- Preserve essential player state and touch-safe controls.

---

### Task 1: Compact the mobile HUD

**Files:**
- Modify: `src/client/Main.client.luau`
- Modify: `src/client/GameNav.luau`
- Modify: `src/client/BuildStamp.client.luau`
- Modify supporting UI factory/token files only where existing architecture requires it
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- Coins + level remain visible in a compact top-left row.
- Today becomes a compact quest affordance and expands on demand.
- Journal remains touch-accessible as a compact control.
- DEV tag displays exact `TinyWorld DEV · v0.7.4 · ART R8` identity at small corner scale.

- [ ] Add source-contract checks for R8 stamp and compact HUD identifiers/size ceilings.
- [ ] Update existing components without creating a second navigation framework.
- [ ] Preserve remote/message bindings and state updates.
- [ ] Compile client Luau and run formatting.
- [ ] Commit `ui: compact TinyWorld mobile HUD for R8`.

---

### Task 2: Advance release identity and complete R8 contract

**Files:**
- Modify: `config/release.json`
- Modify: `scripts/build.sh`
- Modify: `scripts/build.ps1`
- Modify: `scripts/verify-release-contract.sh`
- Modify: `tests/build-contract.sh`
- Modify: `tests/build-contract.ps1`
- Modify: `.github/workflows/tinyworld-ci.yml`
- Modify: `tests/verify-v0.7.4-art-r8-source-contract.sh`

**Interfaces:**
- Artifact name: `TinyWorld-v0.7.4.rbxlx`.
- Workflow R8 source-contract step runs before release/build contract and build.

- [ ] Add deliberate RED release expectations for `0.7.4`/`ART R8`.
- [ ] Update release identity consistently across Linux/PowerShell paths.
- [ ] Make R8 source contract assert: authored asset tree + hashes; R8 Main composition; retirement of old Coast/R6/R7 visual apply calls; shared layout authority; five home assets; four civic assets; five activity assets; published EditableMesh prohibition preserved.
- [ ] Run the complete local command set used by Actions and fix only real failures.
- [ ] Commit `release: prepare TinyWorld v0.7.4 ART R8`.

---

### Task 3: PR verification and exact-head merge

**Files:**
- GitHub PR and issues #26–#31

- [ ] Open one R8 PR from `release/v0.7.4-art-r8-world-rebuild` to `main` linking `Closes #27`, `Closes #28`, `Closes #29`, `Closes #30` while #26/#31 remain open through human acceptance.
- [ ] Verify exact PR head passes all unit tests, analysis, StyLua, runtime compile, R8 source contract, release contract, build contract and deterministic build.
- [ ] Verify zero retained workflow artifacts and no unresolved review threads.
- [ ] Record exact SHA and CI evidence in #26/#31.
- [ ] Squash-merge using `expected_head_sha` so a moved head cannot be merged accidentally.

---

### Task 4: Post-merge DEV publish and human gate

**Files:**
- GitHub main workflow evidence and issues #26/#31

- [ ] Verify the post-merge `main` workflow succeeds through `Publish TinyWorld DEV`.
- [ ] Record main SHA and returned Roblox DEV place version in #26/#31.
- [ ] Request published-client screenshots of: village hero view; residential lane/home entrance; plaza/fountain; Mara market; Pip garden; Finn dock; Skye harbour; Milo workshop; shoreline/water edge; ordinary mobile HUD.
- [ ] Keep #26/#31 open if any screenshot shows loose prototype hero Parts, exploded entrances, avatar sinking, giant empty grass field, disconnected paths, slab shore, old/new layer overlap, checkerboard corruption, or major HUD obstruction.
- [ ] Close #26/#31 only when published-client evidence passes the written R8 acceptance bar.
