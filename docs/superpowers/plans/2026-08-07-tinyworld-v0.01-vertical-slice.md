# TinyWorld v0.01 Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a 15–30 minute Roblox Studio vertical slice that demonstrates TinyWorld’s entire future game loop in miniature: village life, persistent home/garden, progression, profession, transport, portal adventure, trading, and civic contribution.

**Architecture:** Deterministic rules remain in `src/shared` and are covered by Luau CLI tests. Roblox-specific world generation and interaction authority live in focused server services under `src/server`; the client renders a HUD from replicated attributes only. The existing v0.1 branch is expanded in place so the current draft PR becomes the v0.01 test build.

**Tech Stack:** Roblox Studio, Luau, Rojo, Roblox DataStoreService, ProximityPrompt/primitive-generated world geometry, GitHub Actions, Luau 0.732 CLI.

## Global Constraints

- TinyWorld v0.01 is a whole-game miniature, not production scale.
- All economy, progression, inventory, mission, ownership, and trade mutations are server-authoritative.
- Existing profile data normalises into schema version 2 without losing coins, level, XP, or house tier.
- No live Robux purchase IDs or purchase prompts are introduced.
- v0.01 has one village, four plots, one crop, one profession, one transport upgrade, one portal mission, one two-player trade format, and one civic contribution mechanic.
- DataStore load failures fail closed.
- Manual Roblox Studio smoke testing remains mandatory before merge.

---

## File map

### Shared rules
- `src/shared/ProfileSchema.luau`: schema v2 defaults/migration.
- `src/shared/Inventory.luau`: Carrot/SugarCrystal quantities.
- `src/shared/GardenRules.luau`: bed stages and growth readiness.
- `src/shared/DailyReward.luau`: UTC day eligibility/reward application.
- `src/shared/Profession.luau`: Courier XP/level progression.
- `src/shared/TransportRules.luau`: Tiny Bike purchase/ownership.
- `src/shared/PortalRules.luau`: Giant Kitchen completion reward.
- `src/shared/TradeRules.luau`: supported offers and atomic one-item exchange.
- Existing `Progression`, `HouseCatalog`, `HouseUpgrade` stay authoritative.

### Server runtime
- `src/server/ProfileStore.luau`: serialise all schema-v2 fields.
- `src/server/PlayerStateService.luau`: replicated attributes/leaderstats/messages.
- `src/server/WorldBuilder.luau`: village + Giant Kitchen primitive geometry.
- `src/server/PlotService.luau`: four plot assignment, physical houses, garden beds, privacy prompt.
- `src/server/GardenService.luau`: plant/water/harvest prompts.
- `src/server/DailyRewardService.luau`: fountain claim.
- `src/server/JobService.luau`: Courier parcel lifecycle.
- `src/server/TransportService.luau`: Tiny Bike purchase/toggle/speed.
- `src/server/PortalService.luau`: teleport, crystal session, completion.
- `src/server/TradeService.luau`: two-pad trading post.
- `src/server/VillageService.luau`: 50-coin communal contribution.
- `src/server/Main.server.luau`: composition/player lifecycle only.

### Client
- `src/client/Main.client.luau`: code-built HUD and attribute listeners.

### Tests
- Expand `tests/run.luau` and add one spec per shared rule module.

### Task 1: Schema v2 and inventory

**Files:**
- Modify: `src/shared/ProfileSchema.luau`
- Create: `src/shared/Inventory.luau`
- Create: `tests/Inventory.spec.luau`
- Modify: `tests/ProfileSchema.spec.luau`
- Modify: `tests/run.luau`

**Interfaces:**
- `ProfileSchema.new(): PlayerProfile`
- `ProfileSchema.normalize(value: any): PlayerProfile`
- `Inventory.get(profile, itemName): number`
- `Inventory.add(profile, itemName, amount): boolean`
- `Inventory.remove(profile, itemName, amount): boolean`

- [ ] Add failing tests proving v1 core fields survive normalisation; schema becomes version 2; new fields receive safe defaults; inventory refuses unsupported items/negative operations.
- [ ] Run `luau tests/run.luau` and confirm the new tests fail because schema-v2 fields/modules do not exist.
- [ ] Implement schema-v2 fields: `inventory={Carrot=0,SugarCrystal=0}`, `courierLevel=1`, `courierXp=0`, `ownsTinyBike=false`, `bikeActive=false`, `gardenBeds` with three `{stage="empty",readyAt=0}` records, `lastDailyDay=""`, `portalCompletions=0`, `villageContribution=0`, `homePrivacy="Open"`.
- [ ] Implement inventory allow-list and integer add/remove functions.
- [ ] Run the complete suite and confirm PASS.

### Task 2: Garden, daily reward, profession, transport, portal, and trade rules

**Files:**
- Create: `src/shared/GardenRules.luau`
- Create: `src/shared/DailyReward.luau`
- Create: `src/shared/Profession.luau`
- Create: `src/shared/TransportRules.luau`
- Create: `src/shared/PortalRules.luau`
- Create: `src/shared/TradeRules.luau`
- Create corresponding `tests/*.spec.luau`
- Modify: `tests/run.luau`

**Interfaces:**
- `GardenRules.plant(bed, now): (boolean,string)`
- `GardenRules.water(bed, now): (boolean,string)`
- `GardenRules.refresh(bed, now): string`
- `GardenRules.harvest(profile, bed, now): (boolean,string)`
- `DailyReward.dayKey(timestamp?): string`
- `DailyReward.claim(profile, dayKey): (boolean,string)`
- `Profession.addCourierXp(profile, amount): number`
- `TransportRules.buyTinyBike(profile): (boolean,string)`
- `PortalRules.completeGiantKitchen(profile): ()`
- `TradeRules.exchange(profileA, itemA, profileB, itemB): (boolean,string)`

- [ ] Write failing behavior tests for every interface, including duplicate daily claims and trades that do not mutate either profile on validation failure.
- [ ] Run suite and verify failures are due to missing modules.
- [ ] Implement minimal deterministic rules matching the v0.01 design values.
- [ ] Run suite and confirm all shared-domain tests PASS.

### Task 3: Profile persistence and replicated state

**Files:**
- Modify: `src/server/ProfileStore.luau`
- Create: `src/server/PlayerStateService.luau`

**Interfaces:**
- `ProfileStore.load/get/save/release/saveAll`
- `PlayerStateService.setup(player, profile)`
- `PlayerStateService.sync(player, profile)`
- `PlayerStateService.message(player, text)`

- [ ] Expand serialisation to include every schema-v2 field using copied tables, never Instance values.
- [ ] Keep `GetAsync`/`UpdateAsync` protected with `pcall`; keep load failure fail-closed.
- [ ] Move leaderstats/attribute replication out of `Main.server` into `PlayerStateService`.
- [ ] Replicate attributes for XP, house tier/name, inventory quantities, Courier level, bike ownership/active state, portal completions, contribution, privacy, and last status message.

### Task 4: Procedural village and plots

**Files:**
- Create: `src/server/WorldBuilder.luau`
- Create: `src/server/PlotService.luau`

**Interfaces:**
- `WorldBuilder.build(): WorldRefs`
- `PlotService.new(worldRefs, onProfileChanged): PlotService`
- `PlotService:assign(player, profile): number?`
- `PlotService:release(player)`
- `PlotService:rebuildHouse(player, profile)`
- `PlotService:getGardenBedPart(player, bedIndex): BasePart?`

- [ ] Generate one self-contained `TinyWorldGenerated` model and delete an old generated model before rebuilding.
- [ ] Build roads/grass, square, fountain, town hall, delivery depot/shop, transport shop, trading post, portal plaza, four plots, and an adventure zone far from the village.
- [ ] Build procedural houses whose footprint/height visibly increase across five tiers.
- [ ] Build three garden-bed parts per plot and owner signs.
- [ ] Add a privacy prompt cycling `Open → Friends → Private`; server state owns the mode.

### Task 5: Village interactions

**Files:**
- Create: `src/server/GardenService.luau`
- Create: `src/server/DailyRewardService.luau`
- Create: `src/server/JobService.luau`
- Create: `src/server/TransportService.luau`
- Create: `src/server/VillageService.luau`

**Interfaces:** each service receives `worldRefs`, `ProfileStore`, `PlayerStateService`, and any specific dependencies; services mutate profiles only on the server.

- [ ] Garden prompts cycle the three-bed state machine and reward harvested Carrots/XP.
- [ ] Fountain prompt claims `200 coins + 50 XP + 1 Carrot` once per UTC day.
- [ ] Courier depot prompt starts one active delivery; destination prompt completes it for `150 coins + 75 XP + 100 Courier XP`.
- [ ] Transport prompt purchases Tiny Bike for `300 coins` or toggles it; active bike sets humanoid WalkSpeed to 24, inactive/default to 16.
- [ ] Town Hall prompt contributes exactly 50 coins when affordable, increments personal contribution, and updates server communal-fund sign.

### Task 6: Giant Kitchen portal adventure

**Files:**
- Create: `src/server/PortalService.luau`
- Modify: `src/server/WorldBuilder.luau`

**Interfaces:**
- Portal service keeps transient per-player mission state `{active:boolean,collected:{[number]:boolean}}`.

- [ ] Add giant table, plate, fork/spoon shapes, three crystal pads, arrival/exit pads, and portal parts.
- [ ] Village portal starts a fresh mission and teleports character to the kitchen arrival.
- [ ] Crystal prompts mark only the triggering player’s mission session.
- [ ] Exit refuses incomplete sessions; completed sessions call `PortalRules.completeGiantKitchen`, increment profile rewards, clear session, sync state, and teleport home.

### Task 7: Atomic two-player Trading Post

**Files:**
- Create: `src/server/TradeService.luau`

**Interfaces:**
- Server session contains `players[1..2]`, `offers`, `confirmed`, and `version`.

- [ ] Join pads assign two distinct players to sides A/B.
- [ ] Offer prompts cycle supported items `Carrot → SugarCrystal → none` only when owned.
- [ ] Any offer change increments session version and clears both confirmations.
- [ ] Confirm prompts record confirmation for the current version.
- [ ] When both confirm, invoke `TradeRules.exchange`; on success sync both profiles and clear the session; on failure clear confirmations without partial mutation.
- [ ] Player removal from the server clears their side/session safely.

### Task 8: HUD, composition, automated verification, and Studio checklist

**Files:**
- Replace: `src/client/Main.client.luau`
- Replace: `src/server/Main.server.luau`
- Modify: `README.md`
- Modify: `.github/workflows/luau-tests.yml` only if new shared modules require coverage path changes.

**Interfaces:**
- Client reads attributes only.
- `Main.server` composes services and contains no duplicated game rules.

- [ ] Build a compact HUD showing Coins, Level/XP, House, Carrots, Sugar Crystals, Courier level, Bike state, suggested goal, and last server message.
- [ ] Compose world/services after startup, then load/assign/sync each player; release plot/profile on leave; save all on shutdown.
- [ ] Keep house upgrade as a real village interaction near each plot and rebuild the physical house after successful upgrade.
- [ ] Update README with exact Rojo/Studio steps and a 15-minute smoke-test script covering all acceptance criteria.
- [ ] Run `luau tests/run.luau` in CI and require zero failures.
- [ ] Run `luau-analyze src/shared/*.luau tests/*.luau` in CI and require exit 0.
- [ ] Inspect PR diff for client-authoritative economy paths, fake Robux IDs, missing schema serialisation fields, and unrelated scope creep.
