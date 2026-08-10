# TinyWorld agent guide

## Product north star

TinyWorld is a persistent Roblox life sandbox: **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Active authority

For current work, read these in order:

1. `docs/README.md` for documentation precedence and current links.
2. `docs/releases/v0.6.2/acceptance.md` for what v0.6.2 must prove.
3. `docs/product/target-state-v1.md` for the v1 product north star and non-negotiables.
4. The relevant durable product/engineering/quality document.
5. `docs/roadmap/v0.6.2-village-life-visual-craft.md` plus the active v0.6.2 Superpowers design/plan for implementation scope.

v0.6.1 Visual Rescue is the merged presentation baseline. v0.6.0 is the merged target-state foundation. Historical records remain useful decision history but do not override v0.6.2.

The previous v0.7.0 Village Life scope is absorbed into v0.6.2. v0.7.0 is reserved for the family/girls review and must not be pre-filled with guessed scope.

Before expanding scope beyond the approved release, use Superpowers brainstorming/specification and write a dated design/plan.

For substantial v0.6.2 work, apply the current Graphite Mountain lifecycle as the integrated delivery/review method, Superpowers for design/TDD/verification discipline, and Cave Pony for the final smallest-trustworthy-change audit. These are process inputs, not vendored runtime dependencies.

For Roblox implementation/review, apply external Roblox development guidance without copying/vendoring its source unless licence provenance is confirmed.

## v0.6.2 visual direction

The broad target remains:

**Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder, expressed as original TinyWorld design.**

Hard visual rules:

1. Do not create primitive welded Part hair or shoes as normal player presentation.
2. Preserve the player's Roblox avatar when no approved TinyWorld character asset exists.
3. Do not create primitive Part-built ambient animals and present them as finished characters.
4. Do not use large always-on-top BillboardGui information walls for ordinary village destinations or systems.
5. Put destination identity into physical form, material, approach, props and diegetic signage; use contextual prompts for actions.
6. Do not use labels or metadata to rescue unclear finished 3D objects.
7. Keep the permanent HUD compact and world-first; no telemetry/dashboard or website-header treatment in normal play.
8. Hero objects have a higher craft bar than background fallback scenery.
9. Production assets require owner/source/licence/provenance/version/approval state.
10. Player-facing visual changes require Studio/device evidence before visual acceptance.

## v0.6.2 gameplay rules

1. Canonical ordinary-life activities are Courier, Gardener, Designer and Village Explorer.
2. `Gardener` remains persisted through the existing `Farmer` profession fields in schema 11.
3. Courier destinations are selected and completed by the server; clients never choose destination/reward.
4. Legitimate new furniture placement may record `home_design` route progress. Move/store/rejected/preview paths may not.
5. Do not add unlimited Designer XP to every placement.
6. Village Explorer uses the existing server-observed three-landmark route and compatible persisted fields.
7. Deepen the existing six civic destinations rather than adding another village architecture.
8. Keep the deterministic sixteen-home cap.

## Engineering rules

1. Keep authoritative economy, progression, ownership, trade, rewards and final placement state on the server.
2. Put deterministic, Roblox-service-free game rules and definitions in `src/shared`.
3. Keep files focused and prefer explicit service boundaries over a framework rewrite.
4. Use test-first development for deterministic behaviour: failing test first, then minimal implementation.
5. Never trust client-supplied coins, XP, levels, prices, ownership, rewards, trade contents, route completion or final transforms.
6. Use `RemoteGuard` for new mutating remotes and validate type/size/range/ID/rate/context/ownership as relevant.
7. Never silently replace inaccessible, lease-conflicted, failed-migration or future-version saved data with a fresh profile.
8. Profile schema v11 is the active compatibility bridge. Keep legacy resource/home fields until a later explicit migration removes all consumers.
9. DEV and LIVE persistence namespaces must remain separate. Studio defaults to DEV.
10. Prefer clear boring Luau over Knit/React/Roact/Wally unless a measured need and approved design justifies the dependency.
11. Do not add pay-to-win mechanics or fake Roblox product/game-pass/asset IDs.
12. Production assets enter only through the manifest with owner/source/licence/provenance and approval state.
13. Do not claim Studio, multiplayer, device, published DEV or LIVE evidence from source inspection.
14. Do not pull v0.8 portal expansion or v0.9 production deployment into v0.6.2.

## Source layout

- `src/shared`: deterministic rules/definitions mapped to `ReplicatedStorage/TinyWorld/Shared`.
- `src/server`: authoritative adapters/services mapped to `ServerScriptService/TinyWorld`.
- `src/server/security`: server-only remote/security adapters.
- `src/client`: presentation and input intent mapped to `StarterPlayerScripts/TinyWorld`.
- `tests`: pure Luau behaviour tests plus build/release/source guards.
- `docs`: canonical product/engineering/quality/release contracts.

## Verification before merge

At minimum:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
bash tests/verify-release-authority.sh
bash tests/verify-v0.6.2-source-contract.sh
./scripts/verify-release-contract.sh
./tests/build-contract.sh
./scripts/build.sh
git diff --check
```

Automated source/build success is necessary but not sufficient for visual acceptance. Required player-facing Studio/device rows in `docs/releases/v0.6.2/acceptance.md` remain NOT RUN until directly observed.

Do not add production credentials or automated LIVE publishing. DEV/LIVE promotion remains separately configured and human-approved, using the exact tested artifact.

## Commit discipline

Use small conventional commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`). Keep v0.6.2 scoped to Village Life & Visual Craft. Do not merge unless the user separately authorises it after release evidence is reviewed.
