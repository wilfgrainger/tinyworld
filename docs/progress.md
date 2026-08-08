# Development progress

## 2026-08-08 - v0.0.3 living-village implementation and live verification

- Implemented and committed the v0.0.3 living-village slice on `feat/v0.0.3-living-village` at `81223d5` (`feat: build TinyWorld v0.0.3 living village`). The implementation adds a capacity-aware plot layout, one woods/cliffs/sea boundary, three daily exploration landmarks, the boundary route reward, and broad `Ground` surfaces that address the earlier grass-flicker path.
- Repository gates passed before and after the Studio run: 14 Luau specs (`TinyWorld tests passed: 14 specs`), Luau parsing, Luau analysis, the Roblox material guard, a Rojo XML place build, and `git diff --check`.
- The authenticated Roblox Studio session was connected to the current checkout through Rojo 7.7.0 at `localhost:34872`. The current synced place was published successfully; Studio reported `Published new changes in "TinyWorld Dev" to Roblox` and `Published. Friends and playtesters can play now.` No Studio source was edited manually.
- The published Play session loaded the saved `Chewy` profile and showed `TINYWORLD | v0.0.3 LIVING`, the upgraded home, active Tiny Bike, Courier progression, and `Explore: 0/3 boundary landmarks | Routes 0`. The running server reported `MaxPlayers = 60`; the generated boundary remained a single perimeter outside the capacity-sized plot layout.
- Computer Use captured the three live boundary scenes: `WOODLAND TRAIL` beside the woods, `CLIFF LOOKOUT` beside the rock/basalt edge, and `SEA DOCK` beside the water and sand transition. Each landmark prompt was triggered through the live game path and the HUD progressed `0/3` -> `1/3` -> `2/3` -> `3/3`.
- Returning to the Explorer Board awarded `+250 coins` and `+100 XP`; the HUD changed to `Routes 1` and reset the daily landmark mask to `Explore: 0/3`. A second board interaction left coins unchanged at `1,300` and showed `You already claimed today's Boundary Explorer reward. Come back tomorrow.`
- A stop/rejoin then restored the saved identity, home, progression, `1,300` coins, route count `1`, and daily protection. The freshly rejoined session's Output pane was empty. The live run used only session-only teleportation and temporary prompt hold-duration aids where Computer Use could not reliably perform long-distance movement or a normal Roblox hold; those aids were not saved to the repository, published place, or profile.
- The earlier unauthenticated local-place attempt remains historical context only: it hit Roblox's expected DataStore guard and a Creator API `401`. Authentication was restored before the successful publish and live verification recorded above.

## 2026-08-08 - Full v0.0.2 alpha self-test evidence

- The complete self-test ran on `feat/v0.0.2-alpha` against the current Rojo-synced Roblox Studio place. The local gate passed: 12 Luau specs, Luau parse checks, shared/test analysis, Roblox material/runtime guards, Rojo build, and `git diff --check`.
- The live single-player loop passed in Studio: saved-profile entry, daily reward idempotence, garden plant/water/harvest, Courier pickup and delivery, home upgrade to Cosy Cottage, privacy cycling (`Open` → `Friends` → `Private`), Tiny Bike park/activate, Village Fund contribution, and the single-player trade join/offer/confirm-wait state.
- The Giant Kitchen route passed live: enter the village portal, collect all three Sugar Crystals, use the return portal, receive `+300 coins`, `+200 XP`, and `+1 permanent Sugar Crystal`, return to the village, and see `Portal: 1 completion(s)`.
- A fresh stop/rejoin then restored the saved `Chewy` identity, Cosy Cottage, level/coins, carrots, Sugar Crystal, bike state, and portal completion, with `Welcome back to TinyWorld, Chewy.` The new Play session's Output pane was visually empty.
- Because the Computer Use viewport cannot reliably hold the normal 0.2-second prompt key or move the Studio avatar, the live route used runtime-only teleportation and temporary prompt hold-duration changes as a test aid. These did not edit the repository or published place; ordinary keyboard movement/hold timing remains a user/device acceptance check.
- Remaining deliberate external gates are a fresh-profile onboarding run, real two-player trade/privacy completion, and the family/device/remote playtest. No Robux products, purchase prompts, or ads are part of this alpha slice.

## 2026-08-08 - TinyWorld v0.0.2 alpha visual candidate

- Current branch: `feat/v0.0.2-alpha`; the v0.0.1 foundation is merged into local `main`.
- The original proposal photo references are now captured in the v0.0.2 design spec as the visual acceptance bar: cosy village, daily work loop, expressive homes, travel, trade, and an impossible-world portal.
- Completed visual milestones: shared palette/lighting, village/plaza dressing, plot and house-tier presentation, alpha HUD/onboarding, portal/Giant Kitchen showcase, and courier pickup/drop presentation.
- The HUD now exposes a clear alpha identity and next action; the stale home-upgrade goal is covered by 12 passing shared-rule specs.
- The long-term north star now explicitly includes a safe, sustainable creator-led day-job opportunity for the young people building TinyWorld. The alpha has no live Robux products, purchase prompts, or ads; future monetization guardrails are recorded in the [v0.0.2 family alpha test](v0.0.2-alpha-test.md).
- Static checks currently pass: Luau specs, Luau parsing, shared/test analysis, Roblox material guard, Rojo build, and the north-star review.
- The final visual polish adds a bounded public pond, bridge, lily pads, and four plaza lanterns to push the village toward the supplied storybook/voxel reference without adding runtime scenery generation.
- A fresh final-commit Roblox Studio Play session now shows the alpha HUD, distinct Courier Depot and Village Shop landmarks, the public arrival plaza, active Tiny Bike state, and a clean welcome return message. The Output pane was opened after the run and contained no messages or red runtime errors.
- After the final Rojo sync, Roblox Studio published the place successfully and confirmed: `Published new changes in "TinyWorld Dev" to Roblox` and `Published. Friends and playtesters can play now.`
- The final slice keeps the brief's core promise visible in one place: a child can see who they are, what they own, what to do next, where the daily job lives, where the village shop and transport are, and that the wider home/portal/trade world exists. Duplicate courier signboards and distant plot labels were removed from the starter camera; the underlying counters, prompts, homes, progression, portal, and social spaces remain unchanged.
- Full local verification passes on the final commit: 12 Luau specs, Luau parse checks, shared/test analysis, Roblox material/runtime guard, Rojo build, and `git diff --check`. The earlier user-provided Studio screenshots also evidence persistence, courier pickup, and courier delivery. The remaining acceptance work is the deliberate ten-point family/device checklist, a fresh-profile onboarding run, and a real permitted remote playtest; those are outside this code-and-sync slice.

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
