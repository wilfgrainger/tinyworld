# Development progress

## 2026-08-08 - Roblox Studio Courier delivery evidence

- A user-provided Roblox Studio screenshot shows the Courier parcel delivered at the Village Shop after the earlier pickup test.
- The live session reports `Delivery complete: +150 coins, +75 XP, +100 Courier XP - Courier level up!`; the HUD shows coins increasing to 750 and Courier level 3, with the Tiny Bike still active and no visible Output errors.
- The complete pickup-to-delivery job loop is now evidenced in Studio. Fresh-profile onboarding and real-device remote play remain the final demo gates.

## 2026-08-08 - Roblox Studio Courier interaction evidence

- A second user-provided Roblox Studio screenshot shows the live Courier interaction responding to `E`: the parcel prompt was accepted, the HUD shows `PARCEL ACTIVE`, and the status message says `Courier job started. Take the parcel to the Village Shop.`
- The same session shows the saved `Chewy` identity, `Boy`/`Harbor` choices, active Tiny Bike, level/coins, and an empty visible Output pane. This confirms the core job loop still works after the onboarding changes.
- The remaining demo gate is delivery completion, a fresh-profile onboarding run, and the real-device playtest.

## 2026-08-08 - Roblox Studio persistence smoke evidence

- A user-provided Roblox Studio screenshot shows `TinyWorld Dev` running in Play mode with a completed profile: display name `Chewy`, avatar style `Boy`, starter outfit `Harbor`, saved progression, active Tiny Bike, and the `Welcome back to TinyWorld, Chewy.` message.
- The HUD and visible Output pane show the live session entering normal play without a displayed runtime error. This confirms the completed-profile persistence path and normal post-onboarding entry.
- Fresh-profile validation and the real-device remote playtest remain separate acceptance checks.

## 2026-08-08 - First-run character setup implemented

- Added persistent first-run setup for an in-game display name, Boy/Girl avatar style metadata, and one of three free built-in outfit palettes.
- Added server-side name filtering, schema-v2 migration to schema version 3, save-failure rollback, palette reapplication after respawn, and HUD/plot display-name updates.
- Rojo project assembly, the Roblox material guard, Luau parse checks, and all 11 shared-rule specs pass locally. The Roblox Studio/device acceptance pass still requires a manual session.

## 2026-08-08 — Roblox Studio setup and first Play session

- Cloned the repository and switched to `feat/v0.1-foundation`.
- Initialized Rokit and installed Rojo `7.7.0`.
- Started `rojo serve` on `localhost:34872`, then connected and synced the Rojo Studio plugin.
- Published and started the test experience, reaching a successful Play session in Roblox Studio.

This records the setup and launch milestone only. The existing [v0.01 design](superpowers/specs/2026-08-07-tinyworld-v0.01-vertical-slice-design.md) and [15-minute smoke test](../README.md#15-minute-v001-smoke-test) remain the authoritative feature and testing instructions.
