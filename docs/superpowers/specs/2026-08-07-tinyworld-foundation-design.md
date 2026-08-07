# TinyWorld Foundation Design

## Product vision

TinyWorld is a persistent Roblox life sandbox with the breadth and discovery fantasy of *Ready Player One*, but with a warm, accessible, family-friendly centre. Players build a permanent virtual life in a home village, visit other public villages, trade, take jobs, run businesses, participate in civic life, and travel through portals into increasingly strange themed worlds.

**North-star promise:** Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.

## Audience and tone

TinyWorld should be easy for younger Roblox players to understand while having enough collection, progression, economy, discovery, and social depth to retain older players. Everyday village life is familiar and cosy; portal worlds become more surprising, fantastical, and mechanically unusual as a player advances.

## Core loop

1. Return to a persistent home and village.
2. Collect daily rewards and choose useful activities: missions, work, gardening, trading, social play, business, or exploration.
3. Earn coins, XP, resources, collectibles, and progression unlocks.
4. Improve the player's house, rooms, garden, wardrobe, vehicles, profession progress, and collections.
5. Enter portals for themed stories, missions, co-op challenges, competitions, and rare rewards.
6. Bring rewards back into village life and show or trade what was earned.
7. Progress toward higher player levels, stranger worlds, rarer possessions, and prestige housing.

## Persistent identity

Each player has a permanent profile containing, at minimum:

- player level and XP;
- coin balance;
- home and house tier;
- rooms, garden state, furniture, cosmetics, and collections;
- owned vehicles;
- profession progress;
- mission and story progress;
- social/privacy preferences;
- achievements and rare discoveries.

Villages are also intended to persist over long periods. A village can develop history, elections, public upgrades, businesses, events, and shared spaces rather than resetting whenever a server closes.

## Homes and land

A player's plot is their permanent personal base. Homes begin small and expand through many tiers over the lifetime of the account. Early progression should deliver visible upgrades quickly; long-term prestige progression can eventually reach manor, estate, and castle-scale homes.

For the first playable slice, house progression has five tiers:

1. Starter Nook
2. Cosy Cottage
3. Family Home
4. Garden House
5. Grand Villa

Later tiers are intentionally outside v0.1.

Villages are publicly visitable. Private homes and land require permission. Intended privacy modes include Private, Friends, Invited Guests, and Open House.

## Economy and trading

Coins are the primary soft currency. Coins come from missions, professions, businesses, gardening, events, exploration, daily/weekly rewards, and player trade.

Player-to-player trading is a major system. Trades must use a secure two-sided confirmation flow. Valuable achievements and selected premium items may be account-bound to protect the economy.

Robux monetisation must not create raw pay-to-win power. Premium purchases should focus on cosmetics, furniture, house styles, vehicle variants, convenience, additional design/save capacity, and small bounded advantages that never block free players from reaching equivalent gameplay power.

## Player level

Account level is a universal progress track independent of professions and wealth. XP can be earned from many valid play styles so TinyWorld does not force one optimal lifestyle. Level gates may unlock worlds, activities, transport classes, professions, cosmetic status, and story chapters.

Professions are one progression system among several, not the game itself. Players may become farmers, designers, builders, pilots, shop owners, explorers, or other roles while still progressing through the universal account level.

## Transport

Players can acquire bikes, cars, boats, aircraft, and later fantastical transport. Transport should matter to play, not only appearance: faster or specialised vehicles can reach activities and locations more conveniently. Core gameplay destinations must remain achievable for free players.

## Village life

Planned village systems include gardening, plant care, jobs, player businesses, seasonal responsibilities, public events, a village treasury, mayoral elections, ceremonial village titles, and shared upgrades. Systems such as winter tax should produce visible communal outcomes rather than feeling like arbitrary loss. For example, tax contributions might fund winter lights, public transport, or a seasonal ice rink.

## Portal worlds

Portals connect familiar village life to themed story worlds. Each world may have its own fiction, rules, hazards, resources, missions, and visual identity. Early worlds should be understandable and playful; later worlds can become increasingly bizarre.

Portal content may include cooperative missions and individual scoring. Weekly global challenges can reward participation while also maintaining leaderboards for high-skill competition.

A long-running mystery can connect portal worlds through hidden symbols, clues, secret rooms, community discoveries, and major shared milestones.

## Engagement principles

Regular play should be rewarded without punishing absence. TinyWorld can use daily rewards, streak-like bonuses, weekly goals, and catch-up mechanics, but missing a day must not permanently disadvantage a player.

The game should support many legitimate play styles: home design, social life, trading, business, professions, gardening, collecting, vehicles, exploration, missions, competition, and mystery-solving.

## v0.1 foundation scope

This first engineering slice deliberately proves only the base progression model. It includes:

- a Rojo-ready project structure;
- a versioned player profile with coins, level, XP, and house tier;
- deterministic XP/level progression logic;
- five house tiers with coin and level requirements;
- safe, server-authoritative house upgrade logic;
- Roblox DataStore persistence adapter for the core profile;
- a tiny Studio-visible demo hook using a ProximityPrompt so the mechanic can be exercised before art assets exist;
- automated unit tests for pure progression and house-upgrade rules.

Not included in v0.1: portals, plots, house models, vehicles, trading, professions, businesses, village persistence, elections, daily rewards, UI polish, or Robux purchases. Those are future vertical slices built on this foundation.

## Architecture

Pure game rules live in `src/shared` and do not depend on Roblox services. Server modules own authoritative state and persistence. Client code never decides currency, XP, or upgrade outcomes. Roblox service adapters remain thin so most gameplay logic can be tested outside a live place.

The project uses Rojo conventions: shared modules map to `ReplicatedStorage`, server code to `ServerScriptService`, and client code to `StarterPlayerScripts`.

## Safety and integrity rules

- Never trust client-supplied balances, levels, prices, ownership, or rewards.
- Currency and progression changes are server-authoritative.
- DataStore operations use protected calls and `UpdateAsync`-style persistence.
- A failed save must never silently overwrite a known-good profile with an empty/default one.
- Premium purchases must not bypass fundamental progression integrity.
- Trading will require atomic validation and two-party confirmation when implemented.
