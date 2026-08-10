# TinyWorld agent guide

## Product north star

TinyWorld is a persistent Roblox life sandbox: **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Active authority

For current work, read these in order:

1. `docs/README.md` for documentation precedence and current links.
2. `docs/releases/v0.6.0/acceptance.md` for what v0.6.0 actually proves and what remains pending.
3. `docs/product/target-state-v1.md` for the v1 product north star and non-negotiables.
4. The relevant durable product/engineering/quality document.
5. `docs/roadmap/v0.6.0-target-state-consolidation.md` plus the active v0.6.0 Superpowers design/plan for implementation scope.

v0.5.2 and v0.5.3 records are historical evidence. They remain valuable decision records but do not override v0.6.0 or the v1 target state.

Before expanding scope beyond the current approved release, use Superpowers brainstorming/specification and write a dated design/plan. For Roblox implementation/review, also apply the external `brockmartin/roblox-game-skill` guidance without copying/vendoring its source unless licence provenance is confirmed.

## Engineering rules

1. Keep authoritative economy, progression, ownership, trade, rewards and final placement state on the server.
2. Put deterministic, Roblox-service-free game rules and definitions in `src/shared`.
3. Keep files focused and prefer explicit service boundaries over a framework rewrite.
4. Use test-first development for deterministic behaviour: failing test first, then minimal implementation.
5. Never trust client-supplied coins, XP, levels, prices, ownership, rewards, trade contents or final transforms.
6. Use `RemoteGuard` for new mutating remotes and validate type/size/range/ID/rate/context/ownership as relevant.
7. Never silently replace inaccessible, lease-conflicted, failed-migration or future-version saved data with a fresh profile.
8. Profile schema v11 is the active compatibility bridge. Keep legacy resource/home fields until a later explicit migration removes all consumers.
9. DEV and LIVE persistence namespaces must remain separate. Studio defaults to DEV.
10. Prefer clear boring Luau over Knit/React/Roact/Wally unless a measured need and approved design justifies the dependency.
11. Do not add pay-to-win mechanics or fake Roblox product/game-pass/asset IDs.
12. Production assets enter only through the manifest with owner/source/licence/provenance and approval state.
13. Do not use labels to rescue unclear finished 3D objects. Major objects must remain recognisable labels-off.
14. Do not claim Studio, multiplayer, device, published DEV or LIVE evidence from source inspection.

## Source layout

- `src/shared`: deterministic rules/definitions mapped to `ReplicatedStorage/TinyWorld/Shared`.
- `src/server`: authoritative adapters/services mapped to `ServerScriptService/TinyWorld`.
- `src/server/security`: server-only remote/security adapters.
- `src/client`: presentation and input intent mapped to `StarterPlayerScripts/TinyWorld`.
- `tests`: pure Luau behaviour tests plus build/release guards.
- `docs`: canonical product/engineering/quality/release contracts.

## Verification before merge

At minimum:

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

Gameplay/runtime changes also require the Studio/multi-client/device routes in `docs/releases/v0.6.0/acceptance.md` before those evidence rows can be marked PASS.

Do not add production credentials or automated LIVE publishing. DEV/LIVE promotion remains separately configured and human-approved, using the exact tested artifact.

## Commit discipline

Use small conventional commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`). The active v0.6.0 work is intentionally one consolidated PR; future releases should return to focused playable slices unless explicitly approved otherwise.