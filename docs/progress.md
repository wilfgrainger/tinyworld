# Development progress

## 2026-08-08 - First-run character setup implemented

- Added persistent first-run setup for an in-game display name, Boy/Girl avatar style metadata, and one of three free built-in outfit palettes.
- Added server-side name filtering, schema-v2 migration to schema version 3, save-failure rollback, palette reapplication after respawn, and HUD/plot display-name updates.
- Rojo project assembly and the Roblox material guard pass locally. Luau CLI tests and the Roblox Studio/device acceptance pass still require the configured development environment and manual session.

## 2026-08-08 — Roblox Studio setup and first Play session

- Cloned the repository and switched to `feat/v0.1-foundation`.
- Initialized Rokit and installed Rojo `7.7.0`.
- Started `rojo serve` on `localhost:34872`, then connected and synced the Rojo Studio plugin.
- Published and started the test experience, reaching a successful Play session in Roblox Studio.

This records the setup and launch milestone only. The existing [v0.01 design](superpowers/specs/2026-08-07-tinyworld-v0.01-vertical-slice-design.md) and [15-minute smoke test](../README.md#15-minute-v001-smoke-test) remain the authoritative feature and testing instructions.
