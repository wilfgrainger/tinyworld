# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, belong to a village, explore impossible worlds, and discover gentle mysteries.

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Current release: v0.6.1 Visual Rescue

v0.6.1 is the corrective visual release after the first observed v0.6.0 screenshots exposed a serious gap between TinyWorld's written visual-quality contract and the rendered game.

The release keeps the v0.6.0 server-authoritative life-sandbox foundation and focuses on presentation quality:

- remove primitive welded Part hair and shoes from the player character;
- preserve the player's normal Roblox avatar until approved TinyWorld character assets exist;
- remove large always-on-top ordinary-world information walls;
- replace prototype world labels with recognisable physical landmarks, diegetic signs and contextual prompts;
- make the permanent HUD compact enough that the world remains visually dominant;
- raise Town Hall, Village Shop, Home Store, Courier Depot, fountain, jobs board, starter home, primary touched objects, bike and portal entrances above prototype quality;
- prove one golden ordinary-life route from spawn through home, courier work, Home Store placement and rejoin continuity;
- require real Studio/device visual evidence before the player-facing release can become merge-ready.

The broad visual direction is **Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder**, expressed as original TinyWorld design rather than copied characters, props, buildings, layouts, UI or other distinctive IP expression.

Start here:

- [Canonical documentation index](docs/README.md)
- [v1 target state](docs/product/target-state-v1.md)
- [v0.6.1 roadmap](docs/roadmap/v0.6.1-visual-rescue.md)
- [v0.6.1 acceptance](docs/releases/v0.6.1/acceptance.md)
- [v0.6.1 approved design](docs/superpowers/specs/2026-08-10-tinyworld-v0.6.1-visual-rescue-design.md)
- [v0.6.1 implementation plan](docs/superpowers/plans/2026-08-10-tinyworld-v0.6.1-visual-rescue.md)
- [Current progress/evidence state](docs/progress.md)

v0.6.0 Target-State Consolidation is the merged technical/product baseline. v0.5.2 Village Soul and v0.5.3 Production Engineering Foundation remain earlier historical records. Historical records explain how the current state was reached; they do not override v0.6.1.

## Visual identity

TinyWorld's normal village should be readable, warm and tactile. A player should recognise a house, shop, fountain, jobs board, parcel, bike or cooker from the world itself rather than a floating paragraph.

Impossible worlds provide the strongest visual contrast: unusual scale, richer colour, restrained magic and authored spectacle. Ordinary village life stays grounded enough for that contrast to matter.

Hard rules:

- no anonymous finished interaction geometry;
- no primitive character blocks masquerading as hair or shoes;
- no large ordinary-world BillboardGui information walls;
- no full-screen telemetry/dashboard language in normal play;
- labels clarify proper names/details but do not rescue weak 3D objects;
- gold/orange is an accent, not the entire interface;
- hero objects have a higher craft bar than background fallback dressing.

## Evidence model

Repository/CI evidence, one-player Studio evidence, multi-client Studio evidence, real-device evidence, published DEV evidence and LIVE promotion are separate gates.

A green CI run proves source/build properties only. It does **not** prove recognisability, visual craft, FPS, memory, controller/touch quality, multiplayer behaviour or published-place correctness.

For v0.6.1, required player-facing Studio/device rows may be NOT RUN while the PR is draft, but they block merge-ready status. See [v0.6.1 acceptance](docs/releases/v0.6.1/acceptance.md).

## Local verification

With the pinned toolchain installed:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
bash tests/verify-release-authority.sh
bash tests/verify-v0.6.1-visual-contract.sh
./scripts/verify-release-contract.sh
./tests/build-contract.sh
./scripts/build.sh
git diff --check
```

The build creates the ignored `dist/TinyWorld-v0.6.1.rbxlx` candidate and `dist/release.json` traceability manifest. DEV/LIVE publishing remains explicitly unconfigured and human-gated.

## Studio setup

Run `rojo serve`, connect the Rojo Studio plugin to a private DEV test experience, enable Studio Access to API Services for that test experience, and press Play. Studio defaults to the `TinyWorld_DEV_PlayerProfile_v11` namespace. Profile loading intentionally fails closed when saved data cannot be read or safely migrated.

Follow the v0.6.1 visual-rescue route and acceptance record. Do not point Studio testing at LIVE player data.

## Source layout

```text
src/shared/   deterministic rules, definitions and validation
src/server/   authoritative services, persistence, security and world builders
src/client/   presentation and input intent only
tests/        pure Luau tests and fail-closed source/build guards
docs/         canonical product, engineering, quality, roadmap and release records
assets/       approved asset-manifest/provenance boundary
config/       release/environment contracts without credentials
```

## Product guardrails

TinyWorld is not an idle clicker, combat-first game, portal lobby, menu-only house decorator or pay-to-win simulator. Major world objects must be recognisable without explanatory labels, the village must remain satisfying without portals, and impossible worlds must feed ordinary life back home.
