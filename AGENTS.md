# TinyWorld agent guide

## Product north star

TinyWorld is a persistent Roblox life sandbox: **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Active authority

For current work, read these in order:

1. `docs/README.md` for documentation precedence and current links.
2. `docs/releases/v0.6.3/acceptance.md` for what v0.6.3 must prove.
3. `docs/product/target-state-v1.md` for the v1 product north star and non-negotiables.
4. Relevant durable product/engineering/quality documents.
5. `docs/roadmap/v0.6.3-production-art-world-craft.md` plus the active v0.6.3 Superpowers design/plan for release scope.

v0.6.2 Village Life & Visual Craft is the merged gameplay/presentation baseline beneath this corrective release. v0.7.0 remains reserved for the family/girls review and must not be pre-filled with guessed scope.

For substantial work, use Superpowers for design/TDD/verification discipline, the current Graphite Mountain lifecycle for integrated product/architecture/engineering review, and Cave Pony for smallest-trustworthy-change/root-cause review. These are process inputs, not runtime dependencies.

## v0.6.3 visual direction

Broad target:

**Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder, expressed as original TinyWorld design.**

The reference games/film are quality-principle shorthand only. Never copy identifiable buildings, layouts, characters, props, logos, UI or other distinctive expression.

Hard visual rules:

1. Preserve the player's Roblox avatar when no approved TinyWorld character art exists.
2. Do not create primitive Part-built ambient animals and present them as finished characters.
3. Do not use large always-on-top BillboardGui information walls for ordinary village systems.
4. Put destination identity into physical form, material, approach, props and diegetic signage.
5. Do not use labels or semantic metadata to rescue unclear finished 3D objects.
6. Keep the permanent HUD compact and world-first.
7. Hero homes/civic buildings may not use one oversized flat roof slab as the dominant silhouette.
8. Ordinary windows require frame/depth/material hierarchy and may not read as bright cyan pasted rectangles.
9. Ordinary practical lights require recognisable fixture geometry plus bounded light; a naked Neon sphere fails.
10. Village composition must not read as repeated plots on a single empty green plane.
11. Four neighbourhoods require visible path/terrain/planting/prop identity.
12. Hero content has a higher craft bar than background scenery.
13. Production assets require owner/source/licence/provenance/version/approval state.
14. Studio/device evidence, not source metadata, decides visual acceptance.

## Gameplay and engineering rules

1. Keep authoritative economy, progression, ownership, trade, rewards and final placement state on the server.
2. v0.6.3 freezes gameplay scope. Do not add careers, economy, portal mechanics, trading capability or monetisation while doing this visual pass.
3. Put deterministic, Roblox-service-free rules/definitions in `src/shared`.
4. Keep files focused and prefer explicit service/builder boundaries over a framework rewrite.
5. Use test-first development where deterministic/source contracts can be proven.
6. Never trust client-supplied coins, XP, prices, ownership, rewards, trade contents, route completion or final transforms.
7. Use `RemoteGuard` for mutating remotes and validate type/size/range/ID/rate/context/ownership as relevant.
8. Never silently replace inaccessible, lease-conflicted, failed-migration or future-version saved data with a fresh profile.
9. Profile schema v11 remains the compatibility bridge; v0.6.3 adds no migration.
10. DEV and LIVE persistence namespaces remain separate. Studio defaults to DEV.
11. Prefer clear Luau over Knit/React/Roact/Wally unless an approved measured need justifies a dependency.
12. Do not add fake Roblox IDs, pay-to-win mechanics, production credentials or automatic LIVE publishing.
13. Production assets enter only through the manifest with provenance/approval.
14. Do not claim Studio, multiplayer, device, published DEV or LIVE evidence from source inspection.

## Visual-builder architecture

- `ArchitecturalDetailBuilder`: focused reusable pitched-roof/window/door/porch/chimney/lantern craft primitives.
- `VillageLandscapeBuilder`: deterministic clustered civic/neighbourhood landscape composition.
- semantic builders retain the same gameplay/service anchors while improving presentation behind them.
- decorative parts should be anchored and non-touch/non-query/non-colliding where practical.
- portal/fantasy glow is allowed to be stronger than ordinary practical light.

## Verification before merge

At minimum:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
bash tests/verify-release-authority.sh
bash tests/verify-v0.6.3-source-contract.sh
bash tests/verify-v0.6.3-repository-audit.sh
./scripts/verify-release-contract.sh
./tests/build-contract.sh
./scripts/build.sh
git diff --check
```

Automated success is necessary but insufficient. The exact candidate must still pass `docs/v0.6.3-production-art-world-craft-test.md` before visual success is claimed.

## Commit discipline

Use small conventional commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`). Keep v0.6.3 scoped to Production Art & World Craft. Do not merge unless the user separately authorises it after evidence is reviewed.