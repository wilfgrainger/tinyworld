# TinyWorld v0.01 Vertical Slice Design

## Purpose

TinyWorld v0.01 is not a feature-complete production game. It is a **whole-game miniature**: one playable example of each major TinyWorld pillar, connected into a coherent loop that can be tested in Roblox Studio before we invest in scale, art production, content volume, or monetisation.

The slice succeeds if a new tester can play for 15–30 minutes and understand the future game without explanation:

**live in a village → care for a home → earn and progress → travel → adventure → return with rewards → socialise/trade → improve the village and yourself.**

## Player fantasy

The player arrives in a cosy TinyWorld village where everyday life feels familiar. They receive a personal plot and starter home, collect a daily welcome reward, grow a small garden, work a delivery job, buy a faster travel option, upgrade their house, visit the trading post, contribute to village life, then step through a mysterious portal into the first bizarre adventure world: **The Giant Kitchen**.

The Giant Kitchen should make the player feel tiny. Table legs are towers, plates are platforms, cutlery becomes architecture, and Sugar Crystals are valuable portal resources. The player completes a simple collect-and-return mission and brings the reward back to the village.

## v0.01 pillars

### 1. Persistent player identity

The saved player profile includes:

- schema version;
- coins;
- universal level and XP;
- house tier;
- inventory quantities for Carrots and Sugar Crystals;
- delivery profession level/XP;
- owned transport flag for the Tiny Bike;
- garden state for three beds;
- daily reward day key;
- portal mission completions;
- village contribution total;
- home privacy mode.

All progression and economy mutations are server-authoritative.

### 2. Village

A procedural village is generated entirely from Roblox primitives so v0.01 has no external asset dependency. It contains:

- central spawn/town square;
- welcome fountain and daily reward point;
- town hall and village contribution point;
- delivery depot and delivery destination;
- transport shop;
- trading post;
- portal plaza;
- four player plots arranged around the village;
- signs/labels that make the slice understandable without bespoke art.

The generated geometry is intentionally simple but spatially readable. Future art can replace it without changing gameplay services.

### 3. Personal plot and physical house progression

Up to four players in the Studio test server are assigned visible plots. Each plot contains:

- a physical house generated from the player’s current tier;
- three garden beds;
- a plot sign displaying the owner;
- a home access point that communicates the current privacy mode.

The existing five-tier house progression remains:

1. Starter Nook
2. Cosy Cottage
3. Family Home
4. Garden House
5. Grand Villa

In v0.01 each tier is represented by a visibly larger procedural house. House upgrading spends coins and respects level requirements. Rebuilding a house after upgrade affects only that owner’s plot.

Privacy modes represented in the slice are `Private`, `Friends`, and `Open`. The home-entry prompt validates access on the server. This is a representative permission system, not a complete anti-trespass solution.

### 4. Garden loop

Each plot has three persistent garden beds. A bed moves through:

`empty → planted → watered → ready → harvested`

For v0.01 the crop is a Carrot. Planting is free, watering is an interaction, and a watered bed becomes ready after a short test-friendly growth duration. Harvesting grants one Carrot and a small XP reward, then returns the bed to empty.

Garden state is saved as simple stage/timestamp data so the future game can add crops, seasons, fertiliser, weather, and businesses without replacing the profile model.

### 5. Daily reward

The fountain provides one reward per UTC calendar day:

- 200 coins;
- 50 XP;
- one Carrot.

There is no punishing streak in v0.01. The purpose is to prove return-session reward state and communicate the future engagement loop.

### 6. Profession and job loop

The first profession is **Courier**.

A player accepts a parcel at the delivery depot, carries an obvious parcel marker, and delivers it to the village shop. Completion grants:

- 150 coins;
- 75 universal XP;
- 100 Courier XP.

Courier profession level uses a small independent progression curve. The HUD displays Courier level so players can see that professions are a progression system alongside, not instead of, universal level.

Only one delivery may be active per player.

### 7. Transport

The transport shop sells the **Tiny Bike** for 300 coins. In v0.01 this is deliberately implemented as a safe, dependable movement upgrade rather than a physics-heavy vehicle: owning/activating the Tiny Bike grants a visible bike status and increases humanoid movement speed while active.

The player can toggle it at the transport shop. This proves ownership, purchase, utility, and transport progression while avoiding fragile wheel physics in the first Studio test. Future slices can replace it with physical bikes/cars while retaining the ownership contract.

### 8. Portal adventure: The Giant Kitchen

The portal at the village plaza sends a player to a separate adventure area within the same Roblox place, positioned far from the village. This avoids multi-place publishing complexity while proving the travel/adventure loop.

The Giant Kitchen contains:

- giant table/furniture geometry;
- oversized plate/cutlery forms;
- three Sugar Crystal collection points;
- simple platforming/navigation;
- a return portal.

The mission is:

1. enter the Giant Kitchen;
2. collect three Sugar Crystals;
3. return to the exit portal;
4. receive 300 coins, 200 XP, and one permanent Sugar Crystal inventory item;
5. increment portal completion count.

Temporary mission pickups reset each run. Permanent rewards are server-authoritative and saved.

### 9. Trading

Player-to-player trading is represented by a deliberately small but real atomic trade at the Trading Post.

Two trade pads form a session. Each player joins one side. Each side can offer exactly one unit of either Carrot or Sugar Crystal, then confirm. The server completes the swap only when:

- two distinct players occupy the session;
- both offers are valid and owned;
- both players have confirmed the current offer version.

Changing an offer clears confirmations. Completion subtracts and grants on the server in one validated operation. This design is intentionally narrow but establishes the security shape required by a future full trading UI.

If only one tester is present, signage explains that the trade post is exercised using Studio’s multi-client test mode.

### 10. Village life / civic layer

Town Hall includes a **Village Fund** contribution prompt. A player may contribute 50 coins at a time. Their personal contribution total is saved; the current server’s communal fund is displayed on a town-hall sign.

This represents future taxes, mayoral projects, public works, elections, and village history without pretending v0.01 already has a production persistent village government.

The design rule is retained: communal payments must visibly fund communal outcomes in later versions.

### 11. Onboarding and HUD

A lightweight client HUD is generated in code and shows:

- Coins;
- Level and XP progress;
- House tier;
- Carrots;
- Sugar Crystals;
- Courier level;
- Tiny Bike ownership/active status;
- a current suggested goal;
- transient status messages from server interactions.

The suggested-goal sequence is non-blocking. It nudges the tester through the representative loop:

1. claim/visit home;
2. claim daily reward;
3. harvest a Carrot;
4. complete a delivery;
5. buy/activate Tiny Bike;
6. upgrade the house when requirements allow;
7. enter Giant Kitchen;
8. return with a Sugar Crystal;
9. try the Trading Post with a second Studio client;
10. contribute to the Village Fund.

Players are free to do these in another order.

### 12. Monetisation representation

v0.01 contains **no live Robux purchases** because product/game-pass IDs do not exist until the Roblox experience is configured. A Premium Preview sign in the village communicates the intended rule:

- premium purchases are cosmetics, styles, convenience, or bounded variants;
- free players retain equivalent gameplay power;
- no raw level/coin power is sold in the slice.

The code should not contain fake product IDs or accidental purchase prompts.

## Architecture

### Shared deterministic domain modules

`src/shared` contains pure or near-pure rules that can be tested with the Luau CLI:

- profile schema/normalisation;
- progression;
- house catalog/upgrades;
- inventory operations;
- garden state transitions;
- daily reward eligibility;
- profession progression;
- transport purchase rules;
- portal reward rules;
- trade validation/exchange.

### Server services

`src/server` owns Roblox state and authority:

- `ProfileStore`: persistence and in-memory player profiles;
- `PlayerStateService`: leaderstats/attributes and status messages;
- `WorldBuilder`: builds the village, plots, Giant Kitchen, signs, and interaction points;
- `PlotService`: assigns plots and rebuilds physical houses/gardens;
- `GardenService`: garden prompt interactions and growth;
- `DailyRewardService`: claim interaction;
- `JobService`: Courier lifecycle;
- `TransportService`: bike purchase/toggle and character speed;
- `PortalService`: teleport and mission session state;
- `TradeService`: two-player trading-post sessions;
- `VillageService`: communal contribution state;
- `Main.server`: composes services and player lifecycle.

Services communicate through server-owned profile tables and explicit callbacks rather than client-provided economic values.

### Client

The client owns presentation only. It builds a simple responsive HUD from replicated player attributes and displays prompts/status. It never grants rewards, decides prices, confirms inventory ownership, or performs trades locally.

## Data and error handling

- Existing v1 player data is migrated/normalised into schema version 2 with safe defaults for new fields.
- A DataStore load failure fails closed and prevents gameplay with unknown state.
- Save uses `UpdateAsync` with a serialisable copy.
- v0.01 remains a development persistence layer; session locking/retry/backoff/recovery tooling is required before public alpha.
- Interaction services ignore requests when a profile has not loaded.
- Duplicate rewards are prevented with daily keys, active-job flags, mission-session state, and server checks.
- Trade state is in-memory per server and never survives a server shutdown; player inventories remain persistent.

## Testing

CLI tests cover deterministic rules for:

- schema migration/defaults;
- inventory add/remove;
- garden transitions;
- daily claim eligibility;
- profession XP/level progression;
- transport purchase validation;
- portal mission reward application;
- trade offer validation and atomic exchange;
- existing XP and house upgrade rules.

GitHub Actions runs the unit suite plus `luau-analyze` for shared modules/tests.

A manual Studio smoke test remains mandatory because generated world geometry, ProximityPrompts, character movement, teleport positioning, multiplayer trade pads, and DataStore access require the Roblox runtime.

## Deliberate limits

v0.01 does not attempt production scale. It has one village layout, four plots, one crop, one profession, one transport upgrade, one portal world, one portal mission, one trade format, one civic contribution, and primitive-generated art. It does not implement player businesses, mayor elections, king/queen competitions, multiple villages, aircraft, full decoration placement, live Robux products, combat, pets, fashion systems, or global leaderboards.

Those features are not omitted from the vision. They are represented by contracts and extension points in the slice, then added by scaling a proven loop instead of multiplying unproven systems.

## Acceptance criteria

v0.01 is ready for the first Studio test when:

1. a player can join and receive/load a persistent profile;
2. a visible village and assigned physical home plot appear automatically;
3. the HUD reflects saved progression/inventory;
4. daily reward can be claimed only once per day;
5. a garden bed can be planted, watered, grown, and harvested;
6. a Courier delivery can be completed for universal and profession progression;
7. the Tiny Bike can be bought and toggled for faster movement;
8. house upgrades visibly rebuild the player’s house and respect level/coin gates;
9. the portal moves the player to Giant Kitchen and a three-crystal mission can be completed;
10. returning grants persistent portal rewards;
11. two Studio clients can exchange one supported item each through the Trading Post with dual confirmation;
12. players can contribute coins to the Village Fund;
13. leaving/rejoining preserves player progression;
14. automated tests and shared-module static analysis pass;
15. no client path can directly mint coins/XP/items or choose authoritative prices/rewards.
