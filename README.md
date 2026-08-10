# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, belong to a village, explore impossible worlds, and discover gentle mysteries.

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Current release: v0.6.2 Village Life & Visual Craft

v0.6.2 absorbs the previously planned v0.7.0 Village Life scope and the remaining Claude visual-craft recommendations into one consolidation release on top of merged v0.6.1 Visual Rescue.

The release deepens ordinary life without replacing the architecture:

- four canonical activities: Courier, Gardener, Designer and Village Explorer;
- varied server-selected Courier destinations with a visible parcel;
- Gardener and Village Trail loops that reuse persisted schema-11 state safely;
- legitimate new home placement contributes to Designer route progress without becoming an XP farm;
- deeper physical destination identity for Town Hall, Village Shop, Home Store, Courier Depot, Workshop and Market/Trading Post;
- removal of unfinished primitive ambient cats/birds rather than presenting block animals as finished content;
- compact world-first HUD and v0.6.1 visual-rescue rules remain mandatory;
- one hero-home/golden route must be observed in Studio before visual acceptance;
- real exact-candidate Studio/device evidence remains separate from CI/source evidence.

The previous v0.7.0 Village Life milestone has been vacated. v0.7.0 is reserved for the family/girls review and will receive a new delivery scope only after that detailed review is supplied.

Start here:

- [Canonical documentation index](docs/README.md)
- [v1 target state](docs/product/target-state-v1.md)
- [v0.6.2 roadmap](docs/roadmap/v0.6.2-village-life-visual-craft.md)
- [v0.6.2 acceptance](docs/releases/v0.6.2/acceptance.md)
- [v0.6.2 approved design](docs/superpowers/specs/2026-08-10-tinyworld-v0.6.2-village-life-visual-craft-design.md)
- [v0.6.2 implementation plan](docs/superpowers/plans/2026-08-10-tinyworld-v0.6.2-village-life-visual-craft.md)
- [Current progress/evidence state](docs/progress.md)

## Visual identity

TinyWorld's normal village should be readable, warm and tactile. A player should recognise a house, shop, fountain, jobs board, parcel, bike or cooker from the world itself rather than a floating paragraph.

Hard rules:

- no anonymous finished interaction geometry;
- no primitive character blocks masquerading as hair or shoes;
- no primitive Part-built ambient animals masquerading as finished characters;
- no large ordinary-world BillboardGui information walls;
- no full-screen telemetry/dashboard language in normal play;
- labels clarify proper names/details but do not rescue weak 3D objects;
- hero objects have a higher craft bar than background fallback dressing;
- production assets require provenance and approval;
- unobserved visual quality remains unfinished.

## Evidence model

Repository/CI evidence, one-player Studio evidence, multi-client Studio evidence, real-device evidence, published DEV evidence and LIVE promotion are separate gates.

A green CI run proves source/build properties only. It does **not** prove recognisability, visual craft, FPS, memory, controller/touch quality, multiplayer behaviour or published-place correctness.

See [v0.6.2 acceptance](docs/releases/v0.6.2/acceptance.md).

## Local verification

With the pinned toolchain installed:

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

The build creates the ignored `dist/TinyWorld-v0.6.2.rbxlx` candidate and `dist/release.json` traceability manifest. DEV/LIVE publishing remains explicitly unconfigured and human-gated.

## Studio setup

Run `rojo serve`, connect the Rojo Studio plugin to a private DEV test experience, enable Studio Access to API Services for that test experience, and press Play. Studio defaults to the `TinyWorld_DEV_PlayerProfile_v11` namespace. Profile loading intentionally fails closed when saved data cannot be read or safely migrated.

Do not point Studio testing at LIVE player data.

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
