# TinyWorld v0.7.2 / ART R6 Full Game Experience Design

Status: Approved design
Date: 16 August 2026
Branch: `release/v0.7.2-art-r6-full-game`
Base: `main` at `1f1f34a2508be3f3ba5c2a631a4c44b2fcaafce5`
Target: TinyWorld DEV only

## 1. Goal

ART R6 is the first TinyWorld release whose success criterion is not merely visual recovery or feature presence. The village must feel like a small, coherent game.

The player should be able to arrive, understand where useful activity lives, choose something to do, perform a physical in-world action, earn a visible reward, make durable progress, discover another activity, and continue playing without needing developer explanation.

ART R6 therefore combines three inseparable outcomes:

1. **Visual coherence:** remove grass flicker/z-fighting and obvious prototype presentation, improve NPCs, fountain, signage, hero façades and village dressing.
2. **Interactive village gameplay:** turn the five village NPC roles into recognisable characters who each anchor a real activity loop.
3. **Progression and replayability:** activities award existing coins, XP, inventory, profession progress and route/discovery progress so the current homes, vehicles, companions, coast and Mermaid Land become part of one connected game loop.

A release that looks better but still feels empty fails. A release with more mechanics but placeholder-looking presentation also fails.

## 2. Product tone: cosy first, skill rewarded

TinyWorld must balance relaxed exploration with satisfying game mechanics.

Core rule:

> Every activity is completable by an ordinary player without high skill or stressful failure. Better timing, route choice, accuracy or streaks may award a modest bonus, but never gate basic completion.

The village itself remains calm. Timers and score feedback appear only inside activities where they improve the interaction, not as persistent pressure across the whole game.

Rewards should make a good result feel worthwhile without making an average result feel like punishment.

## 3. The village gameplay loop

The intended 5-15 minute loop is:

`arrive/home -> notice activity -> speak/use NPC station -> accept activity -> travel/interact physically -> complete -> reward feedback -> spend/use/unlock -> choose next activity`

The intended longer loop is:

`village activities -> coins + XP + profession progress + useful items -> homes/appearance/transport/companions -> coast/boat -> Mermaid Land and exploration -> return to village`

Existing systems remain authoritative where they already solve part of this loop. ART R6 should connect and extend them rather than create duplicate economies or parallel progression models.

## 4. Five character-led activity loops

### 4.1 Mira the Trader: requests and useful commerce

The Trader NPC becomes a proper village merchant rather than a conversation prop.

The activity loop:

1. Talk to Mira.
2. See one active village request selected from low-value safe items already supported by the inventory system.
3. If the player has the requested item, deliver it directly.
4. Otherwise the dialogue tells the player where that item comes from.
5. Completion awards coins and XP.
6. A small efficiency bonus is available for completing the request without abandoning it.

ART R6 does not replace the existing player-to-player Trading Post transaction system. The NPC request loop is complementary: it gives solo players a useful reason to grow/collect items while the existing Trading Post remains social player-to-player exchange.

Initial request pool is restricted to items already proven by the current inventory/economy, including `Carrot` and `SugarCrystal` where available. No high-value or unique-item exchange is introduced in R6.

### 4.2 Poppy the Gardener: shared village garden task

The existing personal garden remains intact. Poppy adds a short public village gardening activity so a new player can interact immediately even before caring about their home plot.

The activity loop:

1. Talk to Poppy to begin a three-bed village garden round.
2. Interact with clearly visible beds to water/tend them.
3. Each bed visibly changes from dry to tended.
4. Completing all beds awards coins, XP and Gardener profession progress.
5. Completing the beds cleanly in sequence awards a small quality bonus.

This does not create a second persistent crop simulation. The village round is a repeatable activity state owned by the session/service, while durable personal crop state continues to use the existing `GardenService` and profile garden schema.

### 4.3 Finn the Fisherman: simple timing-based fishing

Finn must become visually recognisable as a fisherman and anchor a real fishing interaction near water.

The activity loop:

1. Talk to Finn and start a fishing attempt.
2. Move to/use the nearby fishing spot.
3. A short bite window begins after a variable delay.
4. The player presses/interacts during the generous catch window to land the fish.
5. Missing the ideal moment does not destroy the activity: a broader success window still grants a normal catch, while accurate timing grants a quality bonus.
6. Completion awards coins and XP; quality catches award a modest extra reward and increment the current-session fishing streak.

R6 does not introduce a complex fish inventory/catalogue. The first version uses reward grades (`normal`, `good`, `perfect`) and visible catch feedback. This keeps the loop understandable and avoids unnecessary schema expansion.

### 4.4 Bo the Boat Keeper: coastal delivery run

The Boat Keeper connects the village to the coast and makes the Tiny Boat useful as gameplay rather than scenery.

The activity loop:

1. Talk to Bo and accept a coastal parcel.
2. A physical parcel appears with the player, reusing the established courier visual language where practical.
3. Use the Tiny Boat and travel to one clearly marked coastal destination.
4. Deliver the parcel at the destination prompt.
5. Basic completion always awards coins and XP.
6. A route-time bonus is awarded for efficient completion, with a forgiving target and no failure timeout.

This must not bypass the existing swimming/boat/whirlpool gating. The route stays inside the safe explorable coast and reinforces the intended transport progression.

### 4.5 Bea the Builder: visible repair jobs

The Builder NPC makes the village react visibly to player effort.

The activity loop:

1. Talk to Bea and accept one available repair.
2. The selected repair object is visibly damaged or incomplete.
3. The player visits it and performs 2-3 simple repair interactions.
4. The object visibly transitions to its repaired state.
5. Completion awards coins and XP.
6. Completing the interactions without long pauses grants a small craftsmanship bonus.

R6 repair targets are session-state presentation objects, not permanent global world mutations. Every new server can initialise known repair jobs predictably.

## 5. NPC character-grade presentation

The current R5 published fallback successfully prevents EditableMesh corruption, but the NPC fallback is not visually adequate. R6 introduces a dedicated native Roblox character builder for village NPCs rather than using generic `ProductionMeshFactory` components as if NPCs were scenery props.

Each NPC must include:

- humanoid readable proportions: head, torso, two arms and two legs;
- face cues visible from normal interaction distance;
- hair or hat silhouette;
- role-specific clothing colours;
- at least one role-specific prop/accessory;
- a stable interaction anchor and ProximityPrompt;
- no runtime EditableMesh dependency in published DEV.

Role cues:

- Trader: apron/waistcoat and satchel or small market item.
- Gardener: sun hat, green workwear, watering-can cue.
- Fisherman: cap/hat, layered blue workwear, rod/net/bucket cue.
- Boat Keeper: harbour jacket, cap, rope/life-ring cue.
- Builder: work vest, hard-hat/tool-belt or hammer cue.

NPC visual models remain server-owned native Roblox instances. ART R5's published-safe rendering invariant is preserved.

## 6. Grass and ground glitch fix

The current `VillageGroundRebuildBuilder` creates multiple 0.04-stud Grass Parts at `Y = 0.01` over an existing Grass `VillageGround`. This is effectively coplanar layered rendering and is a credible source of the reported flicker/z-fighting.

R6 fixes the structure, not the symptom.

Rules:

1. The base `VillageGround` remains the single continuous walkable lawn surface.
2. Decorative district lawn overlays must not be Grass Parts sitting almost coplanar with the base.
3. Where a district needs colour variation, use non-z-fighting treatments: raised bordered beds/verges, Ground/Mud/Cobblestone accents, vegetation clusters, or sufficient vertical separation with an explicit edge treatment.
4. Thin decorative patches are allowed for clearly non-overlapping hardscape, soil or path accents, but they must have a minimum safe vertical separation from the base and must not produce overlapping coplanar transparent/opaque surfaces.
5. R6 source contracts must reject the previous `0.04` grass-overlay pattern.

Acceptance: normal camera movement across the village must show no flashing, crawling or noisy grass-layer interference.

## 7. Village visual upgrade scope

R6 improves the most visible prototype areas without attempting another unsafe whole-world art pipeline rewrite.

### Required hero fixes

- Fountain: replace the plumbing-like composition with a readable basin, pedestal and water feature; keep the daily reward interaction.
- Trading Post: remove developer-board feeling from the presentation. Status can remain functional, but the physical structure must read as a market/trading kiosk.
- NPC interaction areas: give each NPC a small authored station that visually communicates the activity.
- Major façades visible from the civic centre: add depth, trims, doors/windows, awnings/signs and roof edge details where the current silhouette is especially slab-like.
- Signage: replace oversized developer-looking text panels with smaller designed in-world signs. Functional status text should be contextual rather than dominating the scene.
- Dressing: add planters/crates/barrels/rope/tools/garden details around activity stations while staying within existing visual budgets.

R6 must not re-enable published EditableMesh preview. Native parts and existing safe authored builders are preferred for this release.

## 8. Activity architecture

New gameplay is split into small modules rather than growing `VillageNpcService` into a monolith.

Proposed components:

- `VillageActivityDefinitions` (shared): IDs, display names, reward bands, quality thresholds and role ownership.
- `VillageActivityRules` (shared): pure validation/quality/reward calculations.
- `VillageActivityService` (server): player activity lifecycle, anti-double-complete state, reward application and routing to role-specific handlers.
- `VillageNpcBuilder` (server): native character-grade NPC construction.
- `FishingActivityService` (server): bite/catch timing state and fishing spot interaction.
- `VillageGardenActivityService` (server): public garden round state and bed visuals.
- `CoastalDeliveryActivityService` (server): parcel state, destination and optional time bonus.
- `BuilderRepairActivityService` (server): repair selection/progress/visible state.
- `TraderRequestActivityService` (server): safe item request selection and inventory hand-in.

Role-specific services expose narrow methods to the coordinator rather than directly modifying unrelated systems.

## 9. State and durability

R6 avoids a profile migration unless absolutely required.

Durable outcomes use existing profile fields and services:

- `coins` for currency;
- existing progression XP via `Progression`;
- existing profession XP where the role maps naturally;
- current inventory through `Inventory`;
- existing route/discovery recording where applicable.

Transient activity state lives server-side per player:

- active activity ID;
- start time where a skill bonus uses timing;
- selected target/destination;
- repair/garden/fishing attempt progress;
- current-session streaks.

A player leaving the server abandons the transient activity with no penalty. No duplicate completion reward may be possible after activity state is cleared.

## 10. Rewards

R6 reward bands are intentionally modest relative to the existing courier job (+150 coins / +75 XP).

Default activity completion:

- short village activity: 60 coins + 30 XP;
- medium traversal activity: 100 coins + 50 XP;
- coastal delivery: 140 coins + 70 XP.

Skill bonus:

- `good`: +15% coins, rounded down;
- `perfect`: +30% coins, rounded down;
- no XP multiplier from quality in R6.

These values may be expressed through shared definitions so tests can enforce consistent reward math.

NPC requests that consume an inventory item must additionally compensate above the item's ordinary acquisition effort; the first request pool remains low-value to limit economy risk.

## 11. Player guidance and feedback

The UI should support gameplay without covering the screen.

R6 uses contextual feedback:

- ProximityPrompt for immediate world actions;
- existing message system for acceptance/completion text;
- small activity status indicator only while an activity is active;
- clear object-state changes in the world;
- optional timing/quality feedback only during fishing/delivery/repair skill moments.

No giant permanent quest panel is introduced.

NPC prompts use meaningful action text, for example `Ask about fishing`, `Start garden round`, `Take coastal delivery`, rather than every NPC simply showing `Talk`.

## 12. Failure and abuse handling

Server authority remains mandatory.

- Only the server starts/completes activities and applies rewards.
- A player may have at most one R6 village activity active at a time.
- A completion call is valid only for the target/destination assigned by the server.
- Repeated prompt triggering cannot duplicate rewards.
- Item hand-ins validate inventory server-side immediately before removal.
- Timing quality uses server timestamps/state, not client-provided scores.
- Leaving the server clears transient state.
- Failure to save a durable reward follows the repository's existing ProfileStore conventions and must never be papered over with client authority.

## 13. Compatibility and non-goals

R6 must preserve:

- ART R5 published-safe rendering and legacy fallback rules;
- existing home ownership/furniture/garden systems;
- existing player-to-player Trading Post transaction safety;
- existing courier job;
- bike, car and boat progression;
- coast swimming/boat gating;
- Mermaid Land and its five quests;
- single free-only GitHub Actions workflow;
- direct `main -> TinyWorld DEV` publishing;
- no automatic LIVE publish.

Non-goals for R6:

- no complex fish collection catalogue;
- no new paid monetisation;
- no combat;
- no global timed events;
- no major profile schema migration;
- no permanent cross-server village repair state;
- no reintroduction of runtime EditableMesh in published DEV.

## 14. Testing strategy

### Pure tests

Add tests for:

- activity definitions uniqueness and valid reward bands;
- quality thresholds and bonus math;
- one-active-activity lifecycle rules;
- target validation and idempotent completion rules;
- trader request eligibility/reward calculation;
- fishing timing grade calculation;
- delivery timing grade calculation;
- repair/garden completion calculations.

### Source/release contract

Add `tests/verify-v0.7.2-art-r6-source-contract.sh` and wire it into the single CI workflow/build contract.

It must assert at minimum:

- release identity is v0.7.2 / ART R6;
- NPCs are built through the dedicated native NPC builder, not generic runtime EditableMesh preview;
- five NPC activity roles are wired;
- published EditableMesh safety constraints from R5 remain present;
- the old 0.04-stud coplanar Grass overlay pattern is absent;
- activity coordinator and role services are wired into the runtime;
- no new workflow artifact/cache storage is introduced;
- DEV publish remains main-only and LIVE remains manual/deferred.

### Runtime compile/build

Existing CI continues to run:

- Luau specs;
- static analysis;
- StyLua check;
- runtime compile;
- release/source contracts;
- deterministic Rojo build;
- direct DEV publish only from `main`.

## 15. Visual/playtest acceptance

CI cannot prove the release feels good. After DEV publish, player evidence is required.

Minimum family playtest checklist:

1. No checkerboard/runtime-mesh failure.
2. No visible glitchy grass/flicker when walking and rotating the camera in civic centre and all four village districts.
3. All five NPCs look recognisably like characters and their role can be guessed before reading the prompt.
4. A player can complete at least three different R6 activities without instruction from a developer.
5. At least one activity visibly changes a world object state.
6. Rewards visibly update coins/XP and feel connected to existing progression.
7. Boat/coast activity remains safe and understandable.
8. Fountain, Trading Post and civic centre no longer dominate the screen with prototype-like geometry/signage.
9. No regression to homes, garden, courier, transport, coast or Mermaid Land.
10. Build stamp clearly identifies `v0.7.2 · ART R6`.

## 16. Release process

1. Implement on `release/v0.7.2-art-r6-full-game`.
2. Open one draft PR to `main`.
3. Keep PR publishing disabled.
4. Require the single TinyWorld CI workflow to pass on the exact final PR head.
5. Review final diff and retained-artifact count.
6. Mark PR ready and squash-merge only when green.
7. The resulting `main` push publishes the deterministic v0.7.2 build directly to TinyWorld DEV using `ROBLOX_DEV_API_KEY`.
8. Verify Roblox returned a new place version and the Actions run retained zero artifacts.
9. Family tests that exact published DEV version.

## 17. Definition of done

ART R6 is code-complete when all automated gates pass and DEV publishes successfully.

ART R6 is product-accepted only when the published DEV playtest demonstrates both sides of the release goal:

- the village is visually coherent and free of the known grass/rendering defects;
- the village provides a connected, understandable, replayable game loop rather than a collection of static features.
