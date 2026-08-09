# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, belong to a village, explore impossible worlds, and discover gentle mysteries.

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## Current release: v0.5.2 Village Soul

v0.5.2 resets presentation and world content around a compact HUD, a deterministic sixteen-home village, recognizable physical affordances, and a playful hero starter home. It preserves the existing profile version 10 data and server authority for economy, progression, inventory, plots, privacy, trade, transport, portals, homes, and saves.

- Start at the [canonical documentation index](docs/README.md).
- Check [current release progress](docs/progress.md).
- Follow the [v0.5.2 roadmap](docs/roadmap/v0.5.2-village-soul.md).
- Record evidence in the [v0.5.2 acceptance checklist](docs/releases/v0.5.2/acceptance.md).
- Run the exact [v0.5.2 Studio route](docs/v0.5.2-village-soul-test.md).
- Run the [local visual-contract guard](tests/verify-v0.5.2-visual-contract.ps1).
- Run the [ambient acceptance guard](tests/verify-v0.5.2-ambient-acceptance.ps1).

Historical release material and dated design/implementation records remain linked from the [documentation index](docs/README.md). Material under `docs/superpowers/` is historical context unless an active release document explicitly links it as an implementation input.

## Local verification

With the Luau and PowerShell tools installed:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/*.luau >/dev/null
luau-compile src/client/*.luau >/dev/null
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-visual-contract.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-ambient-acceptance.ps1
git diff --check
```

The v0.5.2 guard fails closed while required release slices are absent. Studio, multi-client, published-place, and device evidence are separate human gates and must not be inferred from local checks.

The v0.5.2 premium-feel quality gate is an observable craft gate, not monetisation: authored silhouettes, quality materials, composed lighting, tactile feedback, restrained UI, no arbitrary coloured cubes or telemetry walls, and a labels-off child-recognition test must all pass. See the acceptance checklist and Studio route for pass/fail instructions.

## Studio setup

Run `rojo serve`, connect the Rojo Studio plugin to a private test experience, enable Studio Access to API Services for that test experience, and press Play. Profile loading intentionally fails closed when saved data cannot be read; it does not create a replacement profile after a DataStore failure.

## Source layout

```text
src/shared/   deterministic Roblox-service-free contracts
src/server/   authoritative services and world builders
src/client/   presentation-only HUD and onboarding
tests/        pure Luau tests and fail-closed source guards
docs/         canonical product, engineering, quality, roadmap, and release records
```
