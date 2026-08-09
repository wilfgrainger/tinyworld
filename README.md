# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, belong to a village, explore impossible worlds, and discover gentle mysteries.

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Current release: v0.6.0 Target-State Consolidation

v0.6.0 applies the target-state upgrade blueprint as one consolidated release candidate. It preserves the server-authoritative v0.5.x village while introducing the scalable profile/content/home/security/UI/release foundations required for TinyWorld's v1 direction.

Highlights:

- profile schema v11 with explicit migrations and fail-closed future-version handling;
- generic stack/instance inventory, owned furniture, persisted placements, saved outfits, discovered worlds and keepsakes;
- an 80-item home catalogue across eight categories, with reusable physical interactions;
- server-authoritative furniture purchase, placement, move/store and visitor replication;
- four authored impossible worlds and four ordinary-life activity definitions;
- free character-expression/wardrobe foundation;
- RemoteGuard, hardened onboarding and durable trade-journal semantics;
- separate DEV/LIVE DataStore namespaces;
- responsive touch/mouse/controller UI foundations;
- bounded analytics, performance budgets and production-asset provenance contracts;
- StyLua plus recursive Luau compile gates;
- traceable `TinyWorld-v0.6.0.rbxlx` build evidence.

Start here:

- [Canonical documentation index](docs/README.md)
- [v1 target state](docs/product/target-state-v1.md)
- [v0.6.0 roadmap](docs/roadmap/v0.6.0-target-state-consolidation.md)
- [v0.6.0 acceptance](docs/releases/v0.6.0/acceptance.md)
- [Current progress/evidence state](docs/progress.md)

v0.5.2 Village Soul and v0.5.3 Production Engineering Foundation remain historical acceptance records. They explain how the current baseline was reached, but they do not override the v0.6.0 contract.

## Evidence model

Repository/CI evidence, one-player Studio evidence, multi-client Studio evidence, real-device evidence, published DEV evidence and LIVE promotion are separate gates.

A green CI run proves source/build properties only. It does **not** prove recognisability, FPS, memory, controller/touch quality, multiplayer behaviour or published-place correctness. Those remain PENDING until actually observed and recorded in [v0.6.0 acceptance](docs/releases/v0.6.0/acceptance.md).

## Local verification

With the pinned toolchain installed:

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

The build creates the ignored `dist/TinyWorld-v0.6.0.rbxlx` candidate and `dist/release.json` traceability manifest. CI builds the same credential-free candidate. DEV/LIVE publishing remains explicitly unconfigured and human-gated.

## Studio setup

Run `rojo serve`, connect the Rojo Studio plugin to a private DEV test experience, enable Studio Access to API Services for that test experience, and press Play. Studio defaults to the `TinyWorld_DEV_PlayerProfile_v11` namespace. Profile loading intentionally fails closed when saved data cannot be read or safely migrated.

Follow the routes in the v0.6.0 acceptance record and quality documents. Do not point Studio testing at LIVE player data.

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