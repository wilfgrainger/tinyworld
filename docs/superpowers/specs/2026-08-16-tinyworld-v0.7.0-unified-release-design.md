# TinyWorld v0.7.0 Unified Release Design

Status: Approved direction, implementation pending
Date: 16 August 2026
Branch: `release/v0.7.0-unified`
Inputs: PR #8, PR #12, issue #11, current `main`

## Goal

Deliver one coherent TinyWorld v0.7.0 release that absorbs the useful work from the two open PRs, completes the remaining family-review scope in issue #11, replaces redundant GitHub Actions with one free-only CI/deploy workflow, merges through one PR, and publishes the resulting candidate automatically to TinyWorld DEV.

The old PRs and issue are closed only after the unified candidate is green and the DEV publish succeeds.

## Release identity

The consolidated release is `v0.7.0`.

The v0.6.3 production-art work is not shipped as a separate intermediate release. Its production-art architecture and assets become part of v0.7.0. This avoids maintaining two overlapping release authorities and prevents the v0.7 gameplay work from being layered on top of an unmerged visual branch later.

## Source integration strategy

Start from current `main`, which already contains the free-only direct-to-Roblox DEV pipeline and the real DEV target configuration.

Bring forward the useful source from PR #8 and PR #12 by content, not by blindly merging their historical workflow/release files. Both branches predate current `main` and contain stale CI/release assumptions.

Where the two PRs touch the same file, especially `src/server/Main.server.luau` and release-authority surfaces, the unified branch owns the final composition explicitly:

- production art and village visual services from PR #8;
- coast construction and traversal safety from PR #12;
- existing current-main services and DEV deployment behavior;
- one final startup order with no duplicate world ownership or parallel authority.

## Player-facing scope

### 1. Production art and world craft

Retain the v0.6.3 ART R4 direction:

- authored production-art specification as canonical hero-art source;
- original TinyWorld mesh/model pipeline;
- production village visuals, starter-home visuals, civic destinations, fountain, portal, trees, props and starter interior kit;
- truthful Roblox asset manifest with no invented IDs;
- semantic gameplay roots remain authoritative and visual assets never own persistence, economy or interaction authority;
- Studio/DEV fallback may use same-spec generated geometry where permanent assets are not yet approved.

The visible release stamp becomes `TinyWorld DEV · v0.7.0` with the unified PR/revision identity.

### 2. Explorable coast and traversal

Retain and finish the PR #12 safe-coast foundation:

- walkable hills and trustworthy terrain;
- real Terrain water;
- swimming rather than falling into a water void;
- safe seabed/fall recovery;
- deterministic near-shore swimming boundary;
- Tiny Boat-gated outer sea;
- server-authoritative traversal validation.

### 3. Plot ownership clarity

Complete issue #11 ownership improvements:

- grass-parcel claiming must be easy to discover and complete;
- claimed plots visibly identify their owner;
- onboarding explains claim and transport progression without revealing the hidden Mermaid Land discovery.

### 4. Village life and transport

Complete the family-review village-life scope:

- ambient villagers make the world feel inhabited;
- useful NPC roles include trader, gardener, fisherman, boat keeper and builder;
- Tiny Bike receives production-quality presentation;
- Tiny Car is introduced with coherent road use;
- Tiny Boat remains the authoritative outer-sea gate and receives matching production-quality presentation.

Finished hero characters and vehicles must not be primitive Part-built placeholders.

### 5. Hidden Mermaid Land

Implement the hidden whirlpool discovery without advertising it through onboarding.

Required behavior:

- player reaches the outer sea using the Tiny Boat;
- server validates boat/outer-sea eligibility before transition;
- authored whirlpool acts as the disguised transition;
- Mermaid Land is a distinct destination with mermaid NPCs;
- exactly five finite quests are available;
- completion grants server-authoritative coins, XP and/or cosmetic rewards;
- quest completion and rewards are idempotent;
- a safe return path always exists.

The destination may use an internal world/zone transition within the same Roblox experience for v0.7.0. It does not require a second Roblox place unless implementation evidence proves that separation is necessary.

### 6. Homes and companions

Complete the family-review progression direction:

- starter home intentionally reads as a modest shed/home rather than an unfinished placeholder;
- meaningful home tiers progress toward castle/palace prestige;
- Tiny Cat and Tiny Dog unlock around level 10 using server-owned progression rules;
- pets integrate visibly with the home, including a cat-flap style affordance where appropriate;
- future spaceship-pad prestige may be represented visually but full inter-world spaceship travel is out of scope for this release.

## Persistence and migrations

Reuse existing profile fields where they already model the required state.

If Mermaid quest completion, companion ownership or durable home-tier progression require new persistent fields, introduce one explicit profile migration for v0.7.0 rather than ad-hoc fields. Migration must be backwards compatible, deterministic, covered by tests, and preserve all existing v0.6.2 player state.

No client-authoritative rewards, ownership or economy state is permitted.

## One GitHub Actions workflow

Replace the current three workflow files:

- `.github/workflows/luau-tests.yml`
- `.github/workflows/release-authority.yml`
- `.github/workflows/rojo-build.yml`

with one canonical workflow, proposed path:

`.github/workflows/tinyworld-ci.yml`

The workflow contains ordered jobs/stages:

1. **test**: install pinned tooling, run Luau unit tests, analysis, formatting and compile checks;
2. **contracts**: verify release authority, v0.7.0 source contract, repository audit, asset/release contracts and free-only policy;
3. **build**: deterministically build the `.rbxlx` and release manifest on the ephemeral runner;
4. **publish-dev**: on pushes to `main` only, rebuild/verify the exact deterministic candidate and publish directly to TinyWorld DEV using `ROBLOX_DEV_API_KEY`.

Because GitHub job workspaces are isolated and Actions artifact storage is prohibited, the publish job must not depend on transferring an Actions artifact from the build job. It must deterministically rebuild and verify the same release contract before publishing. Alternatively the workflow may keep build and publish in the same job if that reduces duplicate compute and preserves clear gating. The final implementation should choose the simpler of these two options while retaining visible test/contract gates.

Free-only constraints:

- public-repository standard GitHub-hosted runners only;
- no `actions/upload-artifact`;
- no `actions/cache`;
- no paid/larger runners;
- no third-party build/storage service;
- no automatic LIVE publish;
- Roblox DEV publish only after all required gates pass;
- existing repository secret remains the only publishing credential surface.

The release contract must fail if a future workflow reintroduces persistent Actions storage.

## Validation and acceptance

Automated acceptance requires:

- all Luau tests green;
- formatting green;
- runtime syntax compile green;
- release authority and repository audit green;
- production-art spec/registry validation green;
- traversal, water, outer-sea gating and recovery tests green;
- ownership, Mermaid quest/reward idempotency, home progression and pet unlock rules covered by deterministic tests;
- Rojo build green;
- zero Actions artifacts created;
- successful Roblox DEV API response with a new place version number.

Player-facing acceptance additionally requires Studio/device evidence for:

- village arrival and production-art readability;
- starter home/interior;
- plot claim/ownership clarity;
- hills, swimming and recovery;
- bike/car/boat presentation;
- hidden whirlpool discovery and Mermaid Land;
- all five Mermaid quests and safe return;
- home/pet progression surfaces.

Automated green status must not be used to rationalise visibly poor production art.

## Consolidation lifecycle

1. Build the unified v0.7.0 branch from current `main`.
2. Bring forward and reconcile PR #8 production-art work.
3. Bring forward and reconcile PR #12 coast/traversal work.
4. Complete the remaining issue #11 scope.
5. Replace redundant Actions with the single free-only workflow.
6. Run the full release and repository test suite.
7. Open one unified v0.7.0 PR against `main`.
8. Close PR #8 and PR #12 as superseded only when the unified PR contains their required work.
9. Close issue #11 as completed only when all its required scope is implemented and verified.
10. Merge the unified PR.
11. Confirm the post-merge workflow publishes v0.7.0 successfully to TinyWorld DEV and creates zero Actions artifacts.

## Explicit non-goals

- automatic LIVE publishing;
- paid GitHub Actions features;
- a separate v0.6.3 release deployment;
- full spaceship/inter-world travel;
- client-authoritative economy, quest, reward, ownership or pet state;
- accepting primitive placeholder hero art as finished production quality.
