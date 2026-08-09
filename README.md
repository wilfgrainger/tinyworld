# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, grow a virtual life, visit and trade with other players, take jobs, improve their village, and enter increasingly strange portal worlds for missions and rare resources.

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

## v0.01: whole-game miniature

The current branch is designed as a 15–30 minute vertical slice of the entire TinyWorld vision rather than a single-mechanic prototype. It contains one representative example of each major pillar:

- a generated village with four initial player plots and capacity-aware expansion;
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

## v0.0.2 alpha visual candidate

The `feat/v0.0.2-alpha` branch keeps the v0.01 gameplay contract and raises the presentation bar toward the original TinyWorld proposal: a cosy voxel-like village, readable story-card UI, expressive homes, a visible daily work loop, transport, social trade, and a Giant Kitchen portal that feels like an impossible place worth reaching.

The [v0.0.2 family alpha test](docs/v0.0.2-alpha-test.md) records the ten visual/usability checks, the gameplay regression route, and the remaining Studio/device evidence. This is a controlled candidate for testing, not a public release.

The long-term north star is a safe, durable creator-led opportunity that could become a meaningful day job for the young people building TinyWorld. That requires a game people want to return to, with real creative ownership and social value. Future monetization must remain optional and fair: cosmetics, expression, decoration, and bounded convenience may be considered; gameplay power, progression, rare resources, and the core life loop must remain equally playable for free. The alpha contains no purchase prompts, live product IDs, or ads.

## v0.0.3 living village

The `feat/v0.0.3-living-village` slice turns the prototype square into a readable, capacity-aware village world:

- the original four plot positions are preserved, while additional plot slots are generated from Roblox's configured `Players.MaxPlayers` capacity in deterministic perimeter rings;
- a single stable `Ground` floor replaces the broad Grass collision slabs that could shimmer against plot surfaces;
- one shared boundary model scales around the outermost plots with woods, cliffs, rock/basalt steps, sand transition, and sea;
- the Woodland Trail, Cliff Lookout, and Sea Dock form a free daily Boundary Explorer route worth `+250 coins` and `+100 XP` once per UTC day;
- the v0.0.3 HUD exposes boundary progress and route completions without changing the server-authoritative economy or the no-pay-to-win direction.

The [v0.0.3 living-village test](docs/v0.0.3-living-village-test.md) is the authoritative route for this slice. This is still a controlled development candidate, not a public release.

## v0.0.4 living-world MVP

The v0.0.4 slice preserves the v0.01, v0.0.2, and v0.0.3 contracts while making the village feel inhabited and giving the player a short collection-and-home-improvement loop:

- the Tiny Bike is now a visible, server-owned rideable mount with mount/dismount state and faster movement while mounted;
- three bounded life-kit pickups—Meadow Seed, Seashell, and Wood Token—are collected once per UTC day and persist safely in the profile;
- the village has a nursery, three non-player cabins, planters, flowers, lanterns, a bike showcase, and more readable home windows and tier dressing;
- a Home Charm consumes one of each life-kit item and adds a visible planter, flower cluster, and lantern to the player's home;
- all added dressing remains anchored, non-collidable, and bounded by the capacity-aware v0.0.3 layout so the stable Ground/plot surfaces remain the collision foundation;
- no combat system or high-fantasy progression is added: the intended tone is a grounded, colourful village with a small sense of wonder.

The [v0.0.4 living-world test](docs/v0.0.4-living-world-test.md) is the authoritative route for this MVP. It is a controlled development candidate until the Studio, two-client, publish, and family/device gates are separately evidenced.

## v0.0.5–v0.0.7 release train

The next three releases deliberately deepen the existing slice before adding more game systems:

- **v0.0.5 — Storybook beautification:** a cosmetic-only pass over the arrival route, civic buildings, plots, homes, boundary, portal, lighting, and HUD. Existing rewards, progression, ownership, privacy, trade, transport, and profile data remain unchanged. Follow the [v0.0.5 cosmetic test](docs/v0.0.5-cosmetic-test.md).
- **v0.0.6 — Persistence and scale foundation:** coalesced profile saves, conditional session leases, retry/backoff, bounded shutdown flushing, non-sensitive diagnostics, and capacity-aware visual budgets. Follow the [v0.0.6 persistence and scale test](docs/v0.0.6-persistence-scale-test.md).
- **v0.0.7 — Playtest readiness:** visual consistency, evidence separation, and the structured [girls-at-scale playtest](docs/v0.0.7-girls-scale-playtest.md).
- **v0.0.8 — Return loop:** UTC daily/weekly route contracts, deterministic task rotation, bounded completion rewards, duplicate protection, and a visible return-loop HUD. Follow the [v0.0.8 return-loop test](docs/v0.0.8-return-loop.md).

The [v0.0.5–v0.0.7 release-train design](docs/superpowers/specs/2026-08-08-tinyworld-v0.0.5-to-v0.0.7-release-train-design.md) and [implementation plan](docs/superpowers/plans/2026-08-08-tinyworld-v0.0.5-to-v0.0.7-implementation.md) justify the backlog through v1.0.0. v0.0.8 is the first retention experiment: it measures whether a fair, bounded return loop strengthens the existing life rather than distracting from it. The ordering keeps visual desirability ahead of larger testing, persistence safety ahead of scale claims, and retention/social proof ahead of any real cosmetic monetisation.

The v0.0.9 social and functional-home slice adds a bounded Village Walk, privacy-aware visits, safer trade, and concrete buy/use home essentials. Follow the [v0.0.9 social and functional-home test](docs/v0.0.9-social-home-test.md); deeper rooms, decor collections, and home showcase remain the v0.3.0 gate.

The v0.1.0 invited-alpha slice adds aggregate-only recovery, save-pressure, onboarding, and small-cohort readiness signals. Follow the [v0.1.0 invited-alpha test](docs/v0.1.0-invited-alpha-test.md); Roblox access, published-place verification, two-client behavior, and family/device evidence remain separate gates.

The v0.2.0 portal-worlds slice makes the original portal promise repeatable: Giant Kitchen remains intact and Moonlit Meadow adds a second concrete world through the same bounded collect/return pipeline. Follow the [v0.2.0 portal-worlds test](docs/v0.2.0-portal-worlds-test.md).

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

See [Development progress](docs/progress.md) for dated setup and testing milestones.

When the build is ready for family testing from phones, tablets, consoles, or other PCs, follow the [remote family playtest guide](docs/remote-playtest.md). Keep the Dev experience limited to named playtesters until the prototype is ready for wider access.

## 15-minute v0.01 smoke test

### 0. First-run character setup

- On a profile that has not completed setup, confirm a welcome panel appears before normal play.
- Enter a 3–16 character display name, choose **Boy** or **Girl**, then choose the free **Meadow**, **Harbor**, or **Sunset** starter outfit.
- Press **Begin TinyWorld** and confirm the panel closes only after the server accepts and saves the setup.
- Confirm the HUD and plot label use the in-game display name while the Roblox username remains unchanged.
- Stop and press Play again. The setup panel should be skipped and the chosen name/outfit should persist.

### 1. Arrival and home

- Press Play.
- Confirm a generated TinyWorld village appears around the central spawn.
- Confirm the HUD appears in the top-left.
- Confirm your username is assigned to an available plot; the first four plots keep the original layout and larger servers receive additional perimeter plots.
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

### 8. Living village boundary

- Walk outward from the central village and find the **Woodland Trail**, **Cliff Lookout**, and **Sea Dock**.
- Confirm the HUD reports `Explore: 0/3 boundary landmarks` before the route and advances once per landmark.
- Return to the **Boundary Explorer** board before completing the route; it must refuse the incomplete claim.
- Visit all three landmarks and return to the board.
- Expected: **+250 coins, +100 XP**, the HUD route count increases by one, and a second same-day claim is refused.
- Confirm the edge reads as woods, cliffs, sand, and sea, with no broad Grass/plot surface flicker while walking.

### 9. Two-player trade

Use Studio's multi-client testing mode with at least two players.

- Both players go to the Trading Post.
- Player 1 joins side A; Player 2 joins side B.
- Each player uses **Choose Offer** to select an item they actually own: Carrot or Sugar Crystal.
- Each presses **Confirm Trade**.
- The exchange should happen only after both confirm the same offer version.
- Changing an offer clears confirmations.
- The server validates both inventories again before the atomic exchange.

### 10. Persistence

- Stop Play.
- Start Play again with API Services enabled.
- Confirm coins, level/XP, house tier, inventory, Courier progression, bike ownership, garden state, daily claim day, portal completions, contribution, privacy, and Boundary Explorer day/mask/completion state survive the session.

## Automated verification

With Luau CLI installed:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
```

GitHub Actions runs the same shared-domain verification. The pure rule suite covers profile migration, inventory, garden lifecycle, daily rewards, universal progression, Courier progression, house upgrades, Tiny Bike purchasing, Giant Kitchen rewards, atomic trade validation, capacity-aware plot layout, and the daily boundary route. CI also syntax-compiles all runtime server and client Luau files.

## Source structure

```text
src/shared/   deterministic rules and data contracts
src/server/   persistence, generated world, boundary, plots, jobs, garden, transport, portal, trade, village services
src/client/   presentation-only HUD

tests/        Luau CLI behaviour tests
docs/         Superpowers design specs and implementation plans
```

## Important prototype limits

v0.0.3 represents the whole game but does not pretend to be production scale. It has one village, four initial prototype plots plus deterministic capacity-aware expansion up to the Roblox server's configured player capacity, one crop, one profession, one transport upgrade, one portal world, one portal mission, one trade format, one civic contribution, and one daily boundary route. v0.0.8 adds a bounded daily/weekly return contract on top of those same actions. The boundary grows with the outer plot ring and is built once per server; this is layout scalability evidence, not a claim of unrestricted map or DataStore scale.

The future roadmap can scale those proven contracts into multiple villages/worlds, permanent village membership, player businesses, fashion, pets, decoration placement, cars/planes, mayor elections, ceremonial titles, seasonal systems, global challenges, live Robux cosmetics/convenience, and the long-running TinyWorld mystery.

## Data-safety note

The current DataStore adapter is suitable for a controlled development slice, not a public alpha. Before public testing we should add session locking, retry/backoff policy, stronger migration coverage, telemetry, and recovery tooling so overlapping servers and transient Roblox failures cannot corrupt or lose recent progress.
