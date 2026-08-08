# Development progress

## 2026-08-08 - TinyWorld v0.0.2 alpha visual candidate

- Current branch: `feat/v0.0.2-alpha`; the v0.0.1 foundation is merged into local `main`.
- The original proposal photo references are now captured in the v0.0.2 design spec as the visual acceptance bar: cosy village, daily work loop, expressive homes, travel, trade, and an impossible-world portal.
- Completed visual milestones: shared palette/lighting, village/plaza dressing, plot and house-tier presentation, alpha HUD/onboarding, portal/Giant Kitchen showcase, and courier pickup/drop presentation.
- The HUD now exposes a clear alpha identity and next action; the stale home-upgrade goal is covered by 12 passing shared-rule specs.
- The long-term north star now explicitly includes a safe, sustainable creator-led day-job opportunity for the young people building TinyWorld. The alpha has no live Robux products, purchase prompts, or ads; future monetization guardrails are recorded in the [v0.0.2 family alpha test](v0.0.2-alpha-test.md).
- Static checks currently pass: Luau specs, Luau parsing, shared/test analysis, Roblox material guard, Rojo build, and the north-star review.
- The final visual polish adds a bounded public pond, bridge, lily pads, and four plaza lanterns to push the village toward the supplied storybook/voxel reference without adding runtime scenery generation.
- Remaining acceptance gate: a fresh Roblox Studio Play session with the final synced branch, no red Output errors, and observations from the ten-point family/device checklist.

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
