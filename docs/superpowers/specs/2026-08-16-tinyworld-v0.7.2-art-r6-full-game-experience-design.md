# TinyWorld v0.7.2 / ART R6 Full Game Experience Design

Status: Approved design
Date: 16 August 2026
Branch: `release/v0.7.2-art-r6-full-game`
Base: `main` at `1f1f34a2508be3f3ba5c2a631a4c44b2fcaafce5`
Target: TinyWorld DEV only

## 1. Goal

ART R6 is the first TinyWorld release whose success criterion is not merely visual recovery or feature presence. The village must feel like a small, coherent game.

The player should be able to arrive, understand where useful activity lives, choose something to do, perform a physical in-world action, earn a visible reward, make durable progress, discover another activity, and continue playing without developer explanation.

ART R6 combines three inseparable outcomes:

1. **Visual coherence:** remove grass flicker/z-fighting and obvious prototype presentation, improve NPCs, fountain, signage, hero façades and village dressing.
2. **Interactive village gameplay:** turn the five village NPC roles into recognisable characters who each anchor a real activity loop.
3. **Progression and replayability:** activities award existing coins, XP, inventory, profession progress and route/discovery progress so homes, vehicles, companions, coast and Mermaid Land become part of one connected game loop.

A release that looks better but still feels empty fails. A release with more mechanics but placeholder-looking presentation also fails.

## 2. Product tone: cosy first, skill rewarded

TinyWorld balances relaxed exploration with satisfying game mechanics.

> Every activity is completable by an ordinary player without high skill or stressful failure. Better timing, route choice, accuracy or streaks may award a modest bonus, but never gate basic completion.

The village remains calm. Timers and score feedback appear only inside activities where they improve the interaction. Rewards make a good result feel worthwhile without making an average result feel like punishment.

## 3. The connected game loop

Short loop:

`arrive/home -> notice activity -> use NPC station -> accept -> travel/interact physically -> complete -> reward -> spend/use/unlock -> choose next activity`

Long loop:

`village activities -> coins + XP + profession progress + useful items -> homes/appearance/transport/companions -> coast/boat -> Mermaid Land/exploration -> return to village`

Existing systems remain authoritative where they already solve part of the loop. R6 connects and extends them rather than creating duplicate economies or progression models.

## 4. Five character-led activities

The existing identities are preserved: **Mara the Trader, Pip the Gardener, Finn the Fisherman, Skye the Boat Keeper and Milo the Builder**.

### 4.1 Mara the Trader: village requests

Mara becomes a proper village merchant rather than a conversation prop.

1. Talk to Mara.
2. Receive one active request selected from low-value inventory items already supported by the game.
3. If the player owns the requested item, hand it in directly.
4. Otherwise Mara tells the player where it can be obtained.
5. Completion awards coins and XP.
6. Efficient completion can grant a small quality bonus.

This does not replace the existing player-to-player Trading Post. Mara's loop gives solo players a useful reason to grow/collect items, while the Trading Post remains social exchange.

The initial request pool is limited to proven low-value items such as `Carrot` and `SugarCrystal`. No unique/high-value trading is added.

### 4.2 Pip the Gardener: public garden round

The personal garden remains intact. Pip adds a short public village gardening activity accessible immediately.

1. Talk to Pip to begin a three-bed round.
2. Tend three clearly visible public beds.
3. Each bed visibly changes from dry to tended.
4. Completing all beds awards coins, XP and Gardener profession progress.
5. Completing them cleanly in sequence grants a small quality bonus.

This is session-owned activity state, not a second persistent crop simulation. Durable personal crops continue through the existing `GardenService` and profile schema.

### 4.3 Finn the Fisherman: timing-based fishing

Finn becomes visually recognisable as a fisherman and anchors a real water interaction.

1. Talk to Finn and start a fishing attempt.
2. Use the nearby fishing spot.
3. A bite occurs after a short variable delay.
4. Interact during a generous catch window.
5. The broad window awards a normal catch; better timing produces `good` or `perfect` quality.
6. Completion awards coins and XP; quality catches add a modest coin bonus and session fishing streak feedback.

R6 does not create a complex fish inventory catalogue. It uses visible catch feedback and reward grades only.

### 4.4 Skye the Boat Keeper: coastal delivery

Skye connects the village to the coast and makes the Tiny Boat useful as gameplay.

1. Talk to Skye and accept a coastal parcel.
2. A physical parcel appears with the player.
3. Use the Tiny Boat and travel to one marked safe-coast destination.
4. Deliver at the destination prompt.
5. Basic completion always awards coins and XP.
6. Efficient route time grants a modest bonus, with no failure timeout.

The route must preserve the existing swimming, boat and whirlpool gating and stay inside the safe explorable coast.

### 4.5 Milo the Builder: visible repairs

Milo makes the village react visibly to player effort.

1. Talk to Milo and accept an available repair.
2. The repair target visibly appears damaged/incomplete.
3. Perform 2-3 simple repair interactions.
4. The object visibly changes to repaired state.
5. Completion awards coins and XP.
6. Completing without long pauses grants a small craftsmanship bonus.

Repair targets are deterministic server-session presentation state, not permanent global mutations.

## 5. Character-grade NPC presentation

R5's published fallback prevents EditableMesh corruption but the generic NPC fallback is visually inadequate. R6 introduces a dedicated native Roblox `VillageNpcBuilder`. NPCs are not built as generic scenery components.

Each NPC must include:

- readable humanoid proportions: head, torso, two arms and two legs;
- simple face cues visible at interaction distance;
- hair or hat silhouette;
- role-specific clothing colours;
- at least one role-specific prop/accessory;
- stable interaction anchor and ProximityPrompt;
- no runtime EditableMesh dependency in published DEV.

Role cues:

- Mara: apron/waistcoat plus satchel or market item.
- Pip: sun hat, green workwear and watering-can cue.
- Finn: fishing cap/hat, layered blue workwear and rod/net/bucket cue.
- Skye: harbour jacket, cap and rope/life-ring cue.
- Milo: work vest, hard-hat/tool-belt or hammer cue.

## 6. Grass and ground glitch fix

`VillageGroundRebuildBuilder` currently creates multiple 0.04-stud Grass Parts at approximately `Y = 0.01` over the existing Grass `VillageGround`. That near-coplanar layering is a credible source of the observed camera-dependent grass flicker.

R6 fixes the structure:

1. `VillageGround` remains the single continuous walkable lawn surface.
2. Decorative district lawns must not be near-coplanar Grass overlays.
3. District variation uses raised bordered beds/verges, Ground/Mud/Cobblestone accents, vegetation clusters or clearly separated authored features.
4. Thin hardscape/soil accents require safe vertical separation and non-overlapping edges.
5. The source contract rejects the old 0.04-stud Grass-overlay pattern.

Acceptance: normal walking and camera rotation across the civic centre and all four village districts shows no flashing, crawling or noisy layer interference.

## 7. Village visual upgrade

R6 improves the most visible prototype areas without another unsafe whole-world art-pipeline rewrite.

Required hero fixes:

- **Fountain:** readable basin, pedestal and water feature while preserving daily reward interaction.
- **Trading Post:** physical market/trading kiosk rather than a giant developer status board.
- **NPC stations:** each character gets a small authored activity area that communicates their role.
- **Major civic façades:** add depth, trims, windows/doors, awnings/signs and roof-edge detail to the worst slab-like views.
- **Signage:** smaller designed in-world signs; functional status text must not dominate the scene.
- **Dressing:** planters, crates, barrels, rope, tools and garden details within existing visual budgets.

Published DEV must retain R5's native/safe rendering path. Runtime EditableMesh preview remains Studio-only.

## 8. Architecture

R6 is split into small modules rather than growing `VillageNpcService` into a monolith.

- `VillageActivityDefinitions` (shared): IDs, roles, display names, reward bands and thresholds.
- `VillageActivityRules` (shared): pure activity lifecycle, quality and reward calculations.
- `VillageActivityService` (server): one-active-activity lifecycle, reward application and handler coordination.
- `VillageNpcBuilder` (server): native character construction.
- `TraderRequestActivityService` (server): safe request selection and inventory hand-in.
- `VillageGardenActivityService` (server): public garden round state/visuals.
- `FishingActivityService` (server): bite/catch timing and fishing spot.
- `CoastalDeliveryActivityService` (server): parcel, destination and route-time bonus.
- `BuilderRepairActivityService` (server): repair selection, interaction progress and visible state.

Role services expose narrow activity methods and do not directly modify unrelated systems.

## 9. State and durability

R6 avoids a profile migration.

Durable outcomes use existing systems:

- profile `coins`;
- `Progression` XP;
- existing `Profession` XP where appropriate;
- `Inventory`;
- existing `RouteService`/discovery recording where appropriate.

Transient server state includes active activity, assigned target, start/bite timestamps, repair/garden progress and session streaks. Leaving abandons the transient activity without penalty. Cleared/completed activities cannot be rewarded twice.

## 10. Rewards

Reward bands stay modest relative to the existing courier job (+150 coins / +75 XP).

- short village activity: **60 coins + 30 XP**;
- medium traversal activity: **100 coins + 50 XP**;
- coastal delivery: **140 coins + 70 XP**.

Quality coin bonus:

- `normal`: no bonus;
- `good`: +15%, rounded down;
- `perfect`: +30%, rounded down.

Quality does not multiply XP in R6. Trader requests that consume inventory items use an activity definition with sufficient base compensation for the supported low-value item pool.

## 11. Guidance and feedback

R6 uses contextual feedback rather than a giant permanent quest panel:

- ProximityPrompts for immediate world actions;
- existing message system for acceptance/completion;
- small activity status presentation only while active;
- visible object-state changes;
- timing/quality feedback only during relevant skill moments.

Prompts become meaningful, for example `Ask about fishing`, `Start garden round`, `Take coastal delivery` and `Help repair`, instead of every character simply showing `Talk`.

## 12. Server authority and abuse handling

- Only server code starts/completes activities and applies rewards.
- A player can have at most one R6 village activity active.
- Completion must match the server-assigned target/destination.
- Repeated prompt triggers cannot duplicate rewards.
- Trader hand-in validates inventory immediately before removal.
- Timing grades use server timestamps, never a client-provided score.
- Player removal clears transient state.
- Durable reward saving follows existing `ProfileStore` conventions.

## 13. Compatibility and non-goals

R6 preserves:

- ART R5 published-safe rendering and legacy fallback;
- homes/furniture/personal garden;
- player-to-player Trading Post safety;
- existing courier job;
- bike/car/boat progression;
- coast swim/boat/whirlpool gating;
- Mermaid Land and its five quests;
- one free-only GitHub Actions workflow;
- direct `main -> TinyWorld DEV` publish;
- no automatic LIVE publish.

Non-goals: complex fish collection, combat, new monetisation, global timed events, major profile migration, permanent cross-server repair state or published runtime EditableMesh.

## 14. Testing

### Pure tests

Cover:

- unique/valid activity definitions;
- quality thresholds and reward math;
- one-active-activity lifecycle;
- target validation and idempotent completion;
- trader request eligibility;
- fishing timing grades;
- delivery timing grades;
- repair/garden completion calculations.

### R6 source contract

Add `tests/verify-v0.7.2-art-r6-source-contract.sh` and wire it into the single CI/build path. It must assert:

- release identity `v0.7.2 · ART R6`;
- dedicated native NPC builder is used;
- all five activity roles are wired;
- R5 published EditableMesh safety remains;
- old 0.04-stud coplanar Grass overlay is absent;
- coordinator and role services are runtime-wired;
- no artifact/cache storage is added;
- DEV publish remains main-only and LIVE deferred.

Existing CI continues Luau specs, analysis, formatting, runtime compile, contracts, deterministic Rojo build and direct DEV publish only from `main`.

## 15. Published DEV acceptance

Automated green is necessary but not enough. Family testing of the exact published DEV version must show:

1. No checkerboard/runtime-mesh failure.
2. No visible glitchy grass/flicker in civic centre or four districts.
3. All five NPCs read as actual characters and their role is visually guessable.
4. A player can complete at least three different R6 activities without developer instruction.
5. At least one activity visibly changes a world object.
6. Rewards visibly update progress and connect to existing unlocks.
7. Coastal delivery is understandable and keeps safe transport gating.
8. Fountain, Trading Post and civic centre no longer read as prototype geometry/signage.
9. Homes, garden, courier, transport, coast and Mermaid Land still work.
10. Build stamp visibly identifies `v0.7.2 · ART R6`.

## 16. Release process

1. Implement on `release/v0.7.2-art-r6-full-game`.
2. Open one draft PR to `main`; PRs never publish.
3. Require the single TinyWorld CI workflow green on the exact final head.
4. Review the final diff and confirm zero retained Actions artifacts.
5. Mark ready and squash-merge when green.
6. The `main` push builds and publishes v0.7.2 directly to TinyWorld DEV using the existing repository secret.
7. Verify Roblox returns a new DEV place version and the run stores zero artifacts.
8. Family tests that exact published version.

## 17. Definition of done

R6 is engineering-complete when all automated gates pass and DEV publishes successfully.

R6 is product-accepted only when the published DEV playtest demonstrates both outcomes: the village is visually coherent and free of the known grass/render defects, and it provides a connected, understandable, replayable game experience rather than a collection of static features.
