# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, grow a virtual life, visit and trade with other players, take jobs, improve their village, and enter increasingly strange portal worlds for missions and rare resources.

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## v0.01: whole-game miniature

The current branch is designed as a 15–30 minute vertical slice of the entire TinyWorld vision rather than a single-mechanic prototype. It contains one representative example of each major pillar:

- a generated village with four player plots;
- persistent coins, universal Level/XP, inventory, house tier, Courier progress, transport ownership, garden state, daily reward state, portal progress, civic contribution, and home privacy;
- five visibly different procedural house tiers;
- three persistent Carrot garden beds per plot;
- a once-per-day village fountain reward;
- a Courier profession with a visible parcel delivery loop;
- a purchasable/toggleable Tiny Bike movement upgrade;
- the **Giant Kitchen** portal world with three Sugar Crystals and a return mission;
- a two-player, two-sided Trading Post for Carrots and Sugar Crystals;
- a Village Fund contribution mechanic representing future taxes/public works;
- a code-built HUD showing progression and suggested next goals;
- a Premium Preview sign documenting the no-pay-to-win direction without fake/live Robux product IDs.

The geometry is intentionally made from Roblox primitives. This lets us test whether TinyWorld is fun and understandable before replacing the prototype village with production art.

## What you need tomorrow

1. A Roblox account.
2. Roblox Studio.
3. Git installed locally.
4. Rojo CLI and the Rojo Studio plugin.
5. This repository cloned to your computer.

There is no separate paid Roblox developer licence required to start building or testing.

## First Studio setup

From the repository root:

```sh
rojo serve
```

Then:

1. Open Roblox Studio and create/open a blank Baseplate place.
2. Open the Rojo plugin and connect it to the running Rojo server.
3. Sync the project into Studio.
4. **Publish the place as a private/test Roblox experience.** DataStore testing in Studio requires a published experience.
5. Back in Studio, open **File → Experience Settings → Security**.
6. Enable **Studio Access to API Services** and save the setting. Use a separate test experience rather than a live production game because Studio accesses the same DataStores.
7. Press **Play**.

Important: the profile service intentionally fails closed if Roblox cannot read saved data. If the place is unpublished or API Services are disabled, the player may be removed rather than receiving a fake fresh profile. That is deliberate data-safety behaviour.

## 15-minute v0.01 smoke test

### 1. Arrival and home

- Press Play.
- Confirm a generated TinyWorld village appears around the central spawn.
- Confirm the HUD appears in the top-left.
- Confirm your username is assigned to one of the four plots.
- Walk to your plot and verify a **Starter Nook** exists physically.
- Use the privacy kiosk to cycle **Open → Friends → Private → Open**.

### 2. Daily reward and garden

- At the central fountain, claim the daily reward.
- Expected: **+200 coins, +50 XP, +1 Carrot**.
- Try claiming again; it should refuse a second reward for the same UTC day.
- At one of your three garden beds: Plant Carrot → Water Carrot → wait about five seconds → Check/Harvest Carrot.
- Expected harvest: **+1 Carrot, +10 XP**.

### 3. Courier profession

- Go to the Courier Depot and choose **Take Parcel**.
- A parcel should appear on your character and the HUD should show an active parcel.
- Deliver it to the Village Shop.
- Expected: **+150 coins, +75 universal XP, +100 Courier XP**.
- After the fountain + first delivery, a fresh account should have enough XP to reach player Level 2.

### 4. Transport

- Go to the Transport Shop.
- The **Tiny Bike costs 300 coins**.
- Buy it when affordable; it activates automatically and raises movement speed from 16 to 24.
- Use the same prompt again to park/activate it.
- A small `TINY BIKE • ACTIVE` badge appears while active.

The Tiny Bike is deliberately a reliable movement upgrade in v0.01 rather than a wheel-physics vehicle. Physical bikes/cars/aircraft can later implement the same ownership contract.

### 5. Giant Kitchen portal

- Enter the purple Giant Kitchen portal.
- Confirm you arrive in the oversized kitchen zone.
- Find all **3 Sugar Crystals**. One is on the giant table, reached using the prototype steps.
- Go to the return portal.
- It must refuse to finish if fewer than 3 crystals have been collected.
- After all 3, return to the village.
- Expected permanent reward: **+300 coins, +200 XP, +1 Sugar Crystal**, plus one portal completion.

### 6. House upgrade

- Return to your plot and use **Upgrade Home**.
- The real server rules check both required Level and coin price.
- On success the physical house should rebuild immediately to the next tier.

House tiers:

| Tier | Name | Required Level | Upgrade Price |
| --- | --- | ---: | ---: |
| 1 | Starter Nook | 1 | Free |
| 2 | Cosy Cottage | 2 | 250 coins |
| 3 | Family Home | 4 | 750 coins |
| 4 | Garden House | 7 | 1,500 coins |
| 5 | Grand Villa | 10 | 3,000 coins |

### 7. Village Fund

- At Town Hall, contribute 50 coins.
- Confirm your coins decrease, personal contribution increases, and the communal server sign updates.

This is the miniature version of future taxes, public works, mayoral decisions, elections, and persistent village history.

### 8. Two-player trade

Use Studio's multi-client testing mode with at least two players.

- Both players go to the Trading Post.
- Player 1 joins side A; Player 2 joins side B.
- Each player uses **Choose Offer** to select an item they actually own: Carrot or Sugar Crystal.
- Each presses **Confirm Trade**.
- The exchange should happen only after both confirm the same offer version.
- Changing an offer clears confirmations.
- The server validates both inventories again before the atomic exchange.

### 9. Persistence

- Stop Play.
- Start Play again with API Services enabled.
- Confirm coins, level/XP, house tier, inventory, Courier progression, bike ownership, garden state, daily claim day, portal completions, contribution, and privacy survive the session.

## Automated verification

With Luau CLI installed:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
```

GitHub Actions runs the same shared-domain verification. The pure rule suite covers profile migration, inventory, garden lifecycle, daily rewards, universal progression, Courier progression, house upgrades, Tiny Bike purchasing, Giant Kitchen rewards, and atomic trade validation. CI also syntax-compiles all runtime server and client Luau files.

## Source structure

```text
src/shared/   deterministic rules and data contracts
src/server/   persistence, generated world, plots, jobs, garden, transport, portal, trade, village services
src/client/   presentation-only HUD

tests/        Luau CLI behaviour tests
docs/         Superpowers design specs and implementation plans
```

## Important prototype limits

v0.01 represents the whole game but does not pretend to be production scale. It has one village, four simultaneous prototype plots, one crop, one profession, one transport upgrade, one portal world, one portal mission, one trade format, and one civic contribution.

The future roadmap can scale those proven contracts into multiple villages/worlds, permanent village membership, player businesses, fashion, pets, decoration placement, cars/planes, mayor elections, ceremonial titles, seasonal systems, global challenges, live Robux cosmetics/convenience, and the long-running TinyWorld mystery.

## Data-safety note

The current DataStore adapter is suitable for a controlled development slice, not a public alpha. Before public testing we should add session locking, retry/backoff policy, stronger migration coverage, telemetry, and recovery tooling so overlapping servers and transient Roblox failures cannot corrupt or lose recent progress.
