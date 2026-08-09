# Development progress

## 2026-08-09 - v0.5.1 physical-world and state hardening

- Centralized the `world-or-popup` physical-affordance invariant in `PhysicalAffordanceRules`; the Item Chest now renders the shared five-item catalog with labelled world objects and explicit physical markers.
- Added physical markers for crops, village pickups, courier parcels, home furniture, portal collectibles, Tiny Bike, Tiny Boat, and a labelled `HOME CHARM` display. The source guard now checks these paths rather than relying only on HUD inventory counts.
- Fixed two persistence omissions found during the audit: successful home upgrades and Village Fund contributions now call the coalescing `ProfileStore.save` queue after syncing their visible result.
- Added the [v0.5.1 physical-world test](v0.5.1-physical-world-test.md). Studio/published parity remains a separate runtime dependency; no live claim is made from source proof alone.

## 2026-08-09 - v0.5.0 traversal expansion source slice

- Added schema-v10 `ownsTinyBoat`/session `boatActive` defaults and pure server-side purchase/board/return rules for a 600-coin earned Tiny Boat. Existing v0.4 profile fields normalize forward without reset.
- Added a physical Tiny Boat model, Sea Dock purchase kiosk, capacity-aware boundary-derived Tidepool Cove island, cove dock, beacon, story marker, and physical return endpoints. The HUD now reports Bike and Boat state from server attributes.
- Added the physical-affordance invariant guard across the Item Chest, garden, living-world, portal, trade, and home reward/presentation paths. Item counts remain server state; the player-facing proof must be a world object/pickup or named popup.
- The fresh source gate passes at 23 Luau specs, shared analysis, server/client compilation, traversal and physical-affordance guards, existing item/material guards, Rojo assembly, and `git diff --check`. Studio boarding/return and published-place parity are runtime dependencies for this slice and are not claimed by source proof alone.

## 2026-08-09 - v0.4.0 profession expansion

- Preserved Courier and added fair Farmer and Designer career progression. Farmer XP comes from the existing physical Carrot harvest; Designer XP comes from physical home decoration and owner-only showcase actions. No new inventory item, paid gate, random reward, or power advantage was added.
- Added a physical Profession Board and a server-authoritative popup that names all three careers and their current XP thresholds. The v0.3 physical-affordance invariant remains enforced for every item path.
- Migrated the profile schema to version 9 with safe Farmer/Designer defaults, replicated the career fields to the HUD, and added deterministic profession specs plus a source guard.
- The source gate is green at 22 Luau specs, Luau analysis, server/client compilation, all repository guards, Rojo assembly, and `git diff --check`. Studio evidence covers the v0.4 HUD, physical Profession Board, profession popup, `CARROT READY` object, Farmer harvest, and a clean stopped Output. Designer runtime still requires a clean normal-movement Studio pass; temporary teleportation did not prove it.

## 2026-08-09 - v0.3.0 home expression

- Added schema-v8 home expression state with backward-compatible defaults: free Meadow/Harbor/Sunset style, six bounded decoration ownership flags, and a persistent showcase count. The v0.0.9 four-item functional home remains intact.
- Added server-authoritative Home Style and Home Gallery prompts. Decoration acquisition uses fair coins, existing earned life-kit materials, or the completed-portal milestone; every piece is one-copy, cosmetic, and no Robux product or random paid reward is involved.
- Added authored Rest, Make, and Showcase room zones; visible named décor objects; exterior style accents; and an owner-only showcase plaque. The HUD exposes style, `Items %d/4`, décor progress, and showcase count.
- Added the physical-affordance rule: every non-empty inventory resource is rendered as a named object on the owner's Item Chest, the chest has an owner-only inspection prompt, and garden beds render their server-authoritative carrot stage through sprouts to a labelled ready carrot. A profile count alone is no longer accepted as item proof.
- The [v0.3.0 home-expression test](v0.3.0-home-expression-test.md) records the route and evidence boundary. Source/assembly verification is green; Studio evidence covers style cycling, Lantern Nook acquisition, owner showcase, persistence across rejoin, a visible Item Chest with named physical contents, and the garden's physical watered/harvest path. The ready-state auto-refresh is source-gated by the bounded server tick; two-client visitor behavior, published-place parity, scale, and family/device claims remain separate.

## 2026-08-09 - v0.2.0 portal worlds

- Added a reusable `PortalRules.WORLDS` catalog and generic server-authoritative start/collect/return pipeline. Giant Kitchen remains compatible; Moonlit Meadow now has its own portal, arrival space, pond, trees, flowers, three visible Moonlit Seed objects, and return portal.
- Updated the goal/HUD to point to the second portal after the first completion and to report generic mission finds rather than Giant Kitchen-only copy. No schema drift, paid gate, ads, or progression advantage was added.
- The [v0.2.0 portal-worlds test](v0.2.0-portal-worlds-test.md) records a green source/assembly gate and the corrected single-client Studio route: both portals, Moonlit Meadow arrival, all three seed prompts, return, and reward completion. Seed 3 was lowered from an inaccessible elevated position before the final run. The stopped Output had no red source/runtime exception but retained the known Studio DataStore queue/competing-session warnings. Two-client, published-place, scale, and family/device claims remain separate.

## 2026-08-09 - v0.1.0 invited alpha operations

- Added an invited-alpha operations contract: `INVITED_ALPHA`, candidate version `v0.1.0`, a recommended eight-player cohort boundary, and pure health states for setup, saving, recovery-required, and ready.
- Added server-only `AlphaOpsService` observation. It mirrors safe release/health attributes to players and aggregate-only operational counts to `TinyWorldGenerated`, polls the existing ProfileStore diagnostics on a bounded cadence, and announces a recovery transition without exposing names, IDs, profile contents, or secrets.
- Preserved the existing onboarding, return-loop, social, home, persistence, and fair-economy contracts. The HUD now identifies the invited-alpha candidate; no Robux products, ads, paid access, or progression advantage were added.
- The [v0.1.0 invited-alpha test](v0.1.0-invited-alpha-test.md) records the route and evidence boundary. The current synced Studio session visibly showed the candidate label and read aggregate `ready / 1 active / queue 0` diagnostics; the stopped Output had no red source/runtime exception. Static/compile proof and one Studio client still do not prove DataStore recovery, two-client behavior, published-place parity, or family/device comprehension.

## 2026-08-09 - v0.0.9 social village and functional home

- Implemented the first social/home vertical slice after v0.0.8: a four-player Village Walk party, server-enforced plot privacy, shared-activity hooks for visits/trades, and a bounded trade negotiation lease with offer preflight and timeout invalidation.
- Added schema-v7 home ownership and use fields with backward-compatible normalisation. Every player receives a concrete Cosy Bed; the Home Supply counter sells a Kitchen Counter, Wardrobe, and Creative Desk in a fixed fair order, and each owned item is built as a visible in-house object with an owner-only use prompt.
- Added deterministic home/social specs, social and home source guards, and the [v0.0.9 social and functional-home route](v0.0.9-social-home-test.md). The deeper rooms, decor collections, and home showcase remain explicitly scheduled for v0.3.0 rather than being implied by this first slice.
- The source gate is green at 20 Luau specs, shared analysis, server/client compilation, Roblox material guard, ProfileStore hardening guard, social guard, functional-home guard, Rojo place build, and `git diff --check`. A Rojo-synced Studio session then exercised the Home Supply purchase path, all four visible home prompts, home use persistence, and Village Walk join/leave. The stopped Output had no red source/runtime exception; DataStore queue and competing-session warnings remain documented test-environment dependencies. Two-client multiplayer and publish claims remain unproven.

## 2026-08-09 - v0.0.8 return loop

- Implemented the first retention-focused release after the v0.0.5-v0.0.7 foundation. Daily and weekly routes use deterministic UTC period keys and rotating task sets built from the existing fountain, Courier, garden, and boundary actions.
- Added schema-v6 route fields with backward-compatible normalisation, duplicate-task protection, once-per-period completion claims, bounded route rewards, and server diagnostics/HUD progress for today and the current week.
- Wired route recording into successful fountain claims, Courier deliveries, Carrot harvests, and Boundary Explorer claims. Successful garden and Courier mutations now explicitly enter the coalescing save queue as well.
- Added the [v0.0.8 return-loop route](v0.0.8-return-loop.md) and kept the existing [roadmap through v1.0.0](superpowers/specs/2026-08-08-tinyworld-v0.0.5-to-v0.0.7-release-train-design.md) as the north-star backlog: social proof, invited alpha operations, portal/content expansion, home expression, professions, traversal, fair cosmetics, live content, safety, and launch hardening remain ordered gates.
- The local gate is green at 18 Luau specs, shared/server/client analysis, Roblox material guard, ProfileStore hardening guard, Rojo place build, and `git diff --check`. The authenticated Rojo-synced Studio runtime gate then passed on 2026-08-09: the HUD progressed through daily 0/3, 1/3, 2/3, 3/3 and weekly 0/3, 1/3, 2/3, 3/3 across fountain, Courier, garden, and boundary actions; duplicate fountain credit was refused with no coin/count increase. The current place still needs the final publish step for v0.0.8, and this is single-client integration evidence rather than multi-client or family retention evidence.

## 2026-08-08 - v0.0.5–v0.0.7 release-train implementation

- The main-branch vision review found no core-product drift from the original proposal: TinyWorld still contains the home, daily-life, progression, transport, portal, social, and woods/cliffs/sea pillars. The gap is first-impression presentation quality, not the functional direction.
- Committed the release-train design and implementation plan: [design](superpowers/specs/2026-08-08-tinyworld-v0.0.5-to-v0.0.7-release-train-design.md) and [plan](superpowers/plans/2026-08-08-tinyworld-v0.0.5-to-v0.0.7-implementation.md).
- Implemented the v0.0.5 storybook direction in source: warmer semantic palette, softer atmosphere/grade, civic/plot/boundary dressing, stronger façades/windows/roof details, portal glow, and a clearer HUD. The gameplay contract remains unchanged.
- Added visual capacity rules and world diagnostics so richer presentation is bounded at the generated layout’s capacity rather than being an unmeasured part expansion.
- Replaced immediate profile writes with a coalescing save queue, backward-compatible profile envelope, conditional session lease, retry/backoff, heartbeat, fail-closed conflicts, bounded shutdown release, and non-sensitive save/session diagnostics.
- Local deterministic verification currently passes 17 specs, Luau analysis, the Roblox material guard, and the profile-store hardening guard. The runtime Studio/Publish gate remains to be run against the current Rojo-synced place before this release train can be called shipped.
- The evidence routes are [v0.0.5 cosmetic](v0.0.5-cosmetic-test.md), [v0.0.6 persistence/scale](v0.0.6-persistence-scale-test.md), and [v0.0.7 girls-at-scale](v0.0.7-girls-scale-playtest.md). Studio Server & Clients and production-scale claims remain separate evidence levels.

## 2026-08-08 - v0.0.4 living-world MVP handoff

- Implemented and committed the approved v0.0.4 expansion on `main`: the original capacity-aware woods/cliffs/sea boundary and stable Ground/plot surfaces, plus a visible rideable Tiny Bike, persistent Meadow Seed/Seashell/Wood Token pickups, nursery, three cabins, grounded planters, flowers, lanterns, windows, home-tier dressing, and the Home Charm home-upgrade loop. The slice remains grounded and colourful rather than becoming a combat or high-fantasy game.
- Fixed two defects found during the release gate: pickup prompts now pass all required metadata to Roblox, and nursery planters are grounded at Y=0. The source guards cover both regressions.
- The final local gate passed on the committed source: 15 Luau specs, Luau analysis, all server/client compilation, Roblox material guard, rideable-bike guard, living-world guard, Rojo place build, and `git diff --check`.
- The v0.0.4 implementation, README scope, and [living-world acceptance route](v0.0.4-living-world-test.md) are pushed to `main` at `049e2b87bbda69ab32ddd7ebf4f1a4542c77affa`; the working tree and `origin/main` agree at that SHA.
- Per the developer's instruction, the Roblox Studio acceptance evidence is treated as approved for this handoff. The unlocked Studio Play capture showed the v0.0.4 HUD, life-kit line, parked-bike state, inhabited village presentation, and an empty Output pane before the session was stopped. The source-side release gates remain the independently reproducible proof; the later stopped-session Output retained a DataStore queue warning but no new code exception.
- After the synced place was stopped, Studio's normal publish flow recorded `Saved new changes in "TinyWorld Dev" to Roblox.` at 22:13:25. This confirms the current `TinyWorld Dev` place was saved from the Rojo-synced source for SHA `049e2b8`. Family/device acceptance remains a separate release check; no live Robux products, ads, or pay-to-win mechanics are part of this slice.

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
