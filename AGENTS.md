# TinyWorld agent guide

## Product north star

TinyWorld is a persistent Roblox life sandbox: **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Controlling issue first

For every meaningful feature, visual release, refactor, infrastructure change, bug fix, or release, GitHub Issues are the operational source of truth.

Before modifying code:

1. Find the controlling GitHub Issue, or create one before implementation begins.
2. Read its approved design, scope, non-goals, dependencies, acceptance criteria, decisions, branch/PR links and current evidence.
3. If durable methodology requires a design/spec under `docs/superpowers/specs/`, link it from the issue and summarize its operational decisions in the issue.
4. Record material scope or acceptance changes in the issue before treating them as the new plan.
5. Keep progress, CI evidence, publication evidence and human acceptance traceable from the controlling issue.

The lifecycle is:

`design → ready → in progress → CI green → DEV published → human acceptance → done`

A tiny emergency fix may use a compact issue, but it does not bypass issue-first tracking.

See `docs/DEVELOPMENT_WORKFLOW.md` for the canonical process.

## Durable authority

After the controlling issue, read:

1. `docs/README.md` for documentation precedence and current links.
2. `docs/product/target-state-v1.md` for the product north star and non-negotiables.
3. Relevant durable product, engineering, security and quality documents.
4. The active release/feature spec and implementation plan linked from the controlling issue.

Historical release docs are evidence and context, not automatic authority for current scope.

## Product and visual principles

Broad visual target:

**Highly readable Roblox play + tactile toy-world warmth + impossible-world wonder, expressed as original TinyWorld design.**

Reference games, films and screenshots are quality-principle shorthand only. Never copy identifiable buildings, layouts, characters, props, logos, UI or other distinctive expression.

Hard visual rules:

1. Preserve the player's Roblox avatar when no approved TinyWorld character art exists.
2. Do not present primitive placeholder geometry as finished hero characters or hero props.
3. Do not use large always-on-top BillboardGui information walls for ordinary village systems.
4. Put destination identity into physical form, material, approach, props and restrained diegetic signage.
5. Do not use labels or semantic metadata to rescue unclear finished 3D objects.
6. Keep the permanent HUD compact and world-first.
7. Hero homes/civic buildings may not use one oversized flat roof slab as the dominant silhouette.
8. Ordinary windows require frame/depth/material hierarchy and may not read as pasted bright rectangles.
9. Ordinary practical lights require recognisable fixture geometry plus bounded light.
10. Village composition must not read as repeated plots on a single empty green plane.
11. Hero content has a higher craft bar than background scenery.
12. Production assets require owner/source/licence/provenance/version/approval state.
13. Real Studio/device/published-client evidence, not source metadata, decides visual acceptance.

## Gameplay and engineering rules

1. Keep authoritative economy, progression, ownership, trade, rewards and final placement state on the server.
2. Put deterministic, Roblox-service-free rules/definitions in `src/shared`.
3. Keep files focused and prefer explicit service/builder boundaries over framework rewrites.
4. Use test-first development where deterministic/source contracts can be proven.
5. Never trust client-supplied coins, XP, prices, ownership, rewards, trade contents, route completion or final transforms.
6. Use `RemoteGuard` for mutating remotes and validate type/size/range/ID/rate/context/ownership as relevant.
7. Never silently replace inaccessible, lease-conflicted, failed-migration or future-version saved data with a fresh profile.
8. DEV and LIVE persistence namespaces remain separate. Studio defaults to DEV.
9. Prefer clear Luau over additional frameworks unless an approved measured need justifies a dependency.
10. Do not add fake Roblox IDs, pay-to-win mechanics, production credentials or automatic LIVE publishing.
11. Production assets enter only through the manifest with provenance/approval.
12. Do not claim Studio, multiplayer, device, published DEV or LIVE evidence from source inspection.
13. Published runtime EditableMesh preview remains forbidden unless a future controlling issue explicitly changes the architecture with verified Roblox support and a migration plan.
14. Existing R5/R6 published-safe fallback boundaries must not be weakened accidentally.

## Visual-builder architecture

- `ArchitecturalDetailBuilder`: reusable pitched-roof/window/door/porch/chimney/lantern craft primitives.
- `VillageLandscapeBuilder`: deterministic clustered civic/neighbourhood landscape composition.
- semantic builders retain gameplay/service anchors while improving presentation behind them.
- decorative parts should be anchored and non-touch/non-query/non-colliding where practical.
- portal/fantasy glow may be stronger than ordinary practical light.
- canonical activity/NPC placement belongs in `VillageActivityLocations`, not duplicated coordinates.

## Branch and PR discipline

1. Use a dedicated branch based on current `main` for implementation work.
2. Branch and PR must reference the controlling issue or release purpose.
3. PR descriptions summarize implementation, verification, risks and remaining human acceptance.
4. Keep PRs draft while materially incomplete.
5. The exact final PR head must be green before merge.
6. Player-facing visual releases require human merge authorization unless release-wide authorization is already recorded in the controlling issue/conversation.
7. Post-merge DEV publication evidence must be posted back to the controlling issue.
8. Use small conventional commits where practical (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).

## Verification before merge

Use the repository's authoritative workflow and release-specific source contract. At minimum, preserve the existing checks for:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
./scripts/verify-release-contract.sh
./tests/build-contract.sh
./scripts/build.sh
git diff --check
```

The active release may add stricter checks. Never weaken a current safety/release contract merely to make CI green.

## Evidence and completion

Automated success is necessary but insufficient for player-facing visual work.

Before merge, record exact candidate SHA and CI evidence in the controlling issue. After merge, record the merged `main` SHA, authoritative workflow run, test/contract results, built release identity, retained artifact count and Roblox DEV place version.

For visual/player-facing work, keep the issue open until real-client screenshots/gameplay produce the defined human acceptance verdict. A release may be engineering-green and still be a visual failure.

Never put credentials, API keys, tokens or secret values into issues, docs, PR bodies, comments or source files.
