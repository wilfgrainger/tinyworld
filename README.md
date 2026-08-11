# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, belong to a village, explore impossible worlds, and discover gentle mysteries.

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Current release: v0.6.3 Production Art & World Craft

v0.6.3 is a focused visual-production correction after post-merge Studio screenshots showed that v0.6.2's gameplay and UI foundations were materially stronger than its rendered world art.

Gameplay scope is intentionally frozen. This release concentrates on:

- authored home and civic architecture rather than slab-dominated boxes;
- framed/recessed windows, believable entrances, porches, foundations and roof hierarchy;
- proper practical lantern fixtures instead of naked glowing spheres;
- denser but bounded landscaping, planted path edges, fences, hedges and prop clusters;
- four visually distinct neighbourhoods;
- stronger Town Hall/fountain/shop/courier/workshop/market arrival views;
- a more crafted starter-home interior;
- preservation of the compact HUD, normal Roblox avatar and v0.6.2 gameplay/server-authority contracts;
- exact-candidate Studio screenshots as the final visual authority.

The visual shorthand remains **Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder**, expressed as original TinyWorld design rather than copied IP.

The previously generated concept board is an aspirational reference only, never release evidence.

Start here:

- [Canonical documentation index](docs/README.md)
- [v1 target state](docs/product/target-state-v1.md)
- [v0.6.3 roadmap](docs/roadmap/v0.6.3-production-art-world-craft.md)
- [v0.6.3 acceptance](docs/releases/v0.6.3/acceptance.md)
- [v0.6.3 approved design](docs/superpowers/specs/2026-08-11-tinyworld-v0.6.3-production-art-world-craft-design.md)
- [v0.6.3 implementation plan](docs/superpowers/plans/2026-08-11-tinyworld-v0.6.3-production-art-world-craft.md)
- [v0.6.3 Studio comparison route](docs/v0.6.3-production-art-world-craft-test.md)
- [Documentation audit](docs/audits/v0.6.3-documentation-review.md)
- [Current progress](docs/progress.md)

## Visual identity

TinyWorld's ordinary village must be readable, warm, tactile and architecturally intentional. A player should want to walk through it before they know what rewards exist there.

Hard rules:

- no anonymous finished interaction geometry;
- no primitive character or ambient-creature fallback masquerading as finished art;
- no large ordinary-world BillboardGui information walls;
- no telemetry/dashboard presentation dominating normal play;
- no oversized flat/slab roof as the dominant hero-building silhouette;
- no bright flat cyan pane treatment as the only window language;
- no naked Neon sphere as an ordinary practical lamp;
- labels clarify proper names/details but do not rescue weak 3D objects;
- hero objects have a higher craft bar than background dressing;
- production assets require provenance/approval;
- unobserved visual quality remains unfinished.

## Evidence model

Repository/CI evidence, one-player Studio evidence, multi-client Studio evidence, real-device evidence, published DEV evidence and LIVE promotion are separate gates.

A green CI run proves source/build properties only. It does **not** prove visual craft, recognisability, FPS, memory, controller/touch quality, multiplayer behaviour or published-place correctness.

See [v0.6.3 acceptance](docs/releases/v0.6.3/acceptance.md).

## Local verification

With the pinned toolchain installed:

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

The build creates the ignored `dist/TinyWorld-v0.6.3.rbxlx` candidate and `dist/release.json` traceability manifest. DEV/LIVE publishing remains explicitly unconfigured and human-gated.

## Studio setup

Run `rojo serve`, connect the Rojo Studio plugin to a private DEV test experience, enable Studio Access to API Services for that test experience, and press Play. Studio defaults to the `TinyWorld_DEV_PlayerProfile_v11` namespace. Never point Studio testing at LIVE player data.

## Source layout

```text
src/shared/   deterministic rules, definitions and validation
src/server/   authoritative services plus deterministic visual/world builders
src/client/   presentation and input intent only
tests/        pure Luau tests and fail-closed source/build guards
docs/         canonical product, engineering, quality, roadmap and release records
assets/       approved asset-manifest/provenance boundary
config/       release/environment contracts without credentials
```

## Product guardrails

TinyWorld is not an idle clicker, combat-first game, portal lobby, menu-only house decorator or pay-to-win simulator. The village must remain satisfying without portals, and impossible worlds must feel more extraordinary because ordinary life is grounded and believable.