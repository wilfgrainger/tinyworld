# TinyWorld v0.7.0 Family Review Design

**Status:** proposed for user review
**Date:** 2026-08-16
**Milestone:** v0.7.0
**Source:** detailed family/girls play-review supplied on 2026-08-16

## 1. Product intent

v0.7.0 turns TinyWorld from a visually improved village into a world that feels explorable, inhabited and worth progressing through.

The release should make ordinary movement and ownership feel trustworthy first, then layer discovery on top. The central player promise is:

> Walk anywhere that looks walkable, swim where there is water, build a home that visibly becomes yours, meet useful TinyWorld residents, and discover a secret boat-gated route into Mermaid Land.

This review is the previously reserved family/girls scope for v0.7.0. It must extend the existing TinyWorld systems rather than create parallel replacements.

## 2. Scope decomposition

The review describes several independent systems. Implementing them as one mega-change would be high risk, so v0.7.0 is decomposed into four slices with explicit sequencing.

### Slice A — World fundamentals and ownership clarity

1. Hills and terrain that appear traversable must be walkable without invisible blockers or drop-through geometry.
2. Ocean/coastal water must be real swimmable Roblox water or an equivalent physically safe swimming volume. Entering water must not drop the player into an endless void.
3. Swimming range must have a readable gameplay boundary. Players may swim near shore, but the distant route to the secret whirlpool requires the Tiny Boat.
4. Plot claiming must be simplified around a clear square grass parcel, an obvious contextual claim action, and strong ownership identity after claim.
5. New-player onboarding must explicitly cover movement, plot claim, first home, and the existence of transport without spoiling the whirlpool secret.

### Slice B — Village life and transport quality

1. Add ambient walking villagers using approved Roblox/avatar assets rather than primitive Part-built characters.
2. Add or deepen useful NPC roles: trader, gardener, fisherman, boat keeper and builder/home helper.
3. Replace weak hero-vehicle presentation with readable authored TinyWorld vehicles. Bike must read immediately as a bicycle; car must read as a car; boat remains the traversal gate to the outer sea.
4. Add coherent drivable road space for the Tiny Car without compromising pedestrian village readability.

### Slice C — Hidden Mermaid Land discovery

1. Add a hidden whirlpool in the outer sea. It behaves as a transition mechanism but is presented diegetically, not as a generic portal.
2. A player must own/use the Tiny Boat to reach the outer-sea discovery zone.
3. Crossing the whirlpool trigger takes the player to a distinct Mermaid Land / underwater destination.
4. Mermaid Land contains five finite authored quests and mermaid NPCs.
5. Quest rewards may grant approved avatar cosmetics, coins and XP. Economy/progression rewards remain server-authoritative.
6. The discovery is intentionally not explained in onboarding. Environmental clues can hint at it, but first discovery should feel earned.

### Slice D — Long-term home and companion progression

1. Home progression starts from a shed-scale starter home and upgrades through visibly meaningful tiers toward a castle/palace end state.
2. High prestige can expose a future spaceship-pad affordance, but inter-world spaceship travel is not implemented in this slice unless separately approved.
3. Tiny pets unlock at approximately level 10, initially cat and dog, with home integration such as a cat flap.
4. Pets must use approved character assets and must not be represented as primitive block animals.

## 3. Selected architecture

### 3.1 Extend existing systems, do not fork them

The repository already has authoritative Tiny Boat ownership/travel and Tidepool Cove behaviour. v0.7.0 should evolve those boundaries into a real coastal traversal model rather than introducing a second boat ownership/state machine.

Existing server authority remains the rule for:

- boat ownership and access;
- plot ownership;
- quest completion;
- coin and XP rewards;
- home progression;
- pet unlock eligibility.

Deterministic rules belong in `src/shared`; Roblox service/world adapters belong in `src/server`; presentation and input intent belong in `src/client`.

### 3.2 World traversal model

Introduce a small explicit traversal-domain model with named zones:

- `VillageLand`
- `ShoreSwim`
- `OuterSeaBoat`
- `WhirlpoolApproach`
- `MermaidLand`

The zone model exists to make requirements testable, not to add a framework. Pure rules determine whether a traversal transition is allowed from player/profile state. Roblox adapters observe actual character/boat position and execute transitions.

Near-shore water supports normal Roblox swimming. A non-lethal outer boundary prevents players from falling below/escaping the authored world. The boat is the intended way to cross from near-shore exploration into the outer-sea route.

### 3.3 Mermaid transition

The whirlpool is a server-observed world trigger. It must verify that the player reached the trigger through a valid Tiny Boat traversal state before transitioning. The client never claims successful discovery or awards itself rewards.

Whether Mermaid Land is represented as a separated region in the same place or a separate place must remain an implementation detail behind a destination interface. For v0.7.0, prefer the smallest option that preserves reliable testing and does not prematurely introduce production multi-place deployment complexity.

### 3.4 Plot simplification

Keep the existing deterministic sixteen-home cap unless a later design explicitly changes server capacity. Simplify the visual parcel, not ownership authority:

- clear grass square;
- contextual claim prompt at the parcel edge;
- after claim, physical owner sign/house identity;
- no oversized always-on-top information wall;
- starter structure reads as a deliberate shed/cabin rather than placeholder geometry.

### 3.5 NPCs

NPCs are split into two categories:

- **ambient villagers:** path around authored village routes and create life;
- **service NPCs:** fixed or lightly roaming characters that own a clear interaction such as gardening help, boat service, building help, fishing or trading.

NPCs do not become economy authorities. They call server services that validate price, ownership, cooldown and reward rules.

## 4. Approaches considered

### Approach A — Extend current traversal and world services (selected)

Reuse Tiny Boat/profile state, existing plot/home services and current world builders; add narrow traversal/whirlpool/quest components.

**Pros:** smallest trustworthy change, preserves persistence compatibility, easiest to test and review.
**Cons:** requires cleaning up some early traversal abstractions as we touch them.

### Approach B — Rebuild the entire world as a new monolithic WorldBuilder

**Pros:** visually clean slate.
**Cons:** very high regression risk, throws away proven ownership/progression work, difficult to review, poor fit for incremental release evidence.

Rejected.

### Approach C — Build Mermaid Land first as an isolated portal world

**Pros:** quickest route to spectacular content.
**Cons:** leaves the current water/terrain/plot problems unfixed and makes the secret discovery feel disconnected from ordinary play.

Rejected as first implementation order. Mermaid Land remains a later slice after traversal fundamentals work.

## 5. Data and persistence

Do not introduce a schema migration merely for transient swimming/zone state.

Persist only durable outcomes that matter across sessions, for example:

- Mermaid Land first-discovery/completion state if needed;
- five quest completion flags/IDs;
- earned durable cosmetics;
- pet ownership/unlocks;
- home tier/progression when the home slice lands.

Any schema change must retain compatibility with the active schema bridge and be separately test-covered.

## 6. Error and recovery behaviour

1. Falling below the authored world or water floor must recover the player to a safe shoreline/last-safe point, never an endless void.
2. If a boat is destroyed or a character respawns, the existing authoritative boat state is reset/reconciled safely.
3. Invalid whirlpool entry without valid boat traversal does not transition or reward the player.
4. Failed destination transition returns the player safely and awards nothing.
5. Quest reward operations must be idempotent so reconnect/retry cannot duplicate rewards.
6. Plot claim collisions remain server-resolved; losing clients receive a clear contextual message.

## 7. Testing strategy

### Pure Luau tests first

Add failing deterministic tests before implementation for:

- traversal transition eligibility;
- swim-zone vs boat-only-zone rules;
- whirlpool access rules;
- Mermaid quest reward idempotency;
- plot claim eligibility where logic changes;
- pet level unlock rule when that slice begins.

### Source/build guards

Extend release/source contract tests to assert new authoritative modules and prevent accidental client authority.

### Roblox/Studio evidence

Automated tests cannot prove the player experience. v0.7.0 acceptance must include observed Studio/device evidence for:

- walking on hills;
- entering/exiting water and swimming;
- no endless-void failure at the coast;
- swim boundary behaviour;
- boat reaching the outer sea;
- discovering/entering the whirlpool;
- Mermaid Land arrival and return;
- plot claiming clarity;
- NPC movement/interactions;
- vehicle readability and driving.

## 8. First implementation slice

Implementation begins with **Slice A1: safe explorable coast** because every later sea/discovery feature depends on it.

The first code plan should be limited to:

1. deterministic traversal-zone rules;
2. world changes required for walkable hills and swimmable coastal water;
3. safe fall/water recovery;
4. near-shore swim boundary and boat-only outer-sea rule;
5. tests and release evidence rows for those behaviours.

It must not yet build the five Mermaid quests, pets, car, full home ladder or spaceship system.

## 9. Acceptance summary for the epic

v0.7.0 is successful when:

- terrain that looks walkable is actually walkable;
- water behaves like water and never becomes an accidental void;
- the Tiny Boat provides meaningful progression into the outer sea;
- the hidden whirlpool can be discovered and leads to a polished Mermaid Land;
- Mermaid Land has five finite, rewarding quests and mermaid NPCs;
- plots are simpler to claim and unmistakably owned;
- the village contains useful/ambient NPC life;
- hero vehicles are readable and functional;
- home progression has a clear shed-to-castle direction;
- level-gated Tiny Pets are integrated without primitive placeholder art;
- all authoritative progression/economy/security rules remain server-side;
- player-facing claims are backed by actual Studio/device evidence rather than source inspection alone.
