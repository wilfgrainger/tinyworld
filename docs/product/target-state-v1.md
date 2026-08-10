# TinyWorld v1 Target State

**Status:** Canonical product north-star contract  
**Source:** TinyWorld Target-State Upgrade Blueprint, reviewed 9 August 2026 against `main` after merge commit `3c355e15b51f79ce759422844a08ed7c5dc77877`  
**Baseline inherited:** v0.6.0 Target-State Consolidation, with v0.6.1 Visual Rescue as the active corrective presentation layer

## Purpose

TinyWorld is moving from a strong vertical slice toward a credible v0.9 production beta and v1.0 Roblox life-sandbox release.

The target is **not** a rewrite. TinyWorld should preserve its current server-authoritative architecture, deterministic shared rules, leased ProfileStore, prefab and interaction-anchor boundaries, release-evidence discipline, deterministic sixteen-home village, recognisable-object visual contract, compact HUD, and credential-free Rojo build foundation.

v0.6.1 adds a corrective visual rule to that foundation: ordinary village life must be readable from physical form and context, hero presentation must not degrade into primitive fallback geometry, and required player-facing visual evidence must be observed before a visual release becomes merge-ready.

The next phase must deepen the game rather than replace the engineering model.

> **Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

TinyWorld should become a **persistent life sandbox with adventure worlds**, not a portal-adventure game with a decorative house.

Ordinary village life must support a satisfying session even if the player never enters a portal.

---

## Audience

### Primary

Children, families, and younger Roblox players who enjoy imaginative life play, decorating, collecting, exploring, and shared social play.

### Secondary

Older players who enjoy collection, decorating, social sandbox play, light progression, and authored exploration.

### Accessibility of the fantasy

The experience must remain understandable without prior simulator, RPG, or Roblox economy knowledge. Core actions should be learned by interacting with the world rather than by reading dense instructions.

---

## Player fantasy

A player should feel:

> “This is my little life, my home, my village, and I can step through the impossible whenever I want.”

The village, home, items, careers, relationships, portal discoveries, and cosmetic identity must reinforce the feeling that the player is building an ongoing personal life rather than completing disconnected activities.

---

## The three nested loops

### Minute-to-minute loop

A player should continuously be able to:

1. notice something;
2. approach it;
3. interact physically;
4. receive visible feedback;
5. change their world or progress;
6. decide what to do next.

Representative verbs include:

- cook;
- water a plant;
- put an object away;
- buy furniture;
- change an outfit;
- deliver a parcel;
- ride somewhere;
- decorate a room;
- collect a resource;
- visit a neighbour;
- discover a hidden interaction.

### Session loop

A normal 15–30 minute session should support:

1. return home;
2. see what changed;
3. complete one ordinary-life activity;
4. make visible progress;
5. visit a destination or another player;
6. optionally enter an impossible world;
7. return with something that changes ordinary life.

### Long-term loop

Across sessions the player should build:

- a more expressive home;
- a larger useful item collection;
- career mastery;
- discovered places;
- portal keepsakes;
- village relationships;
- cosmetic identity;
- personal stories and routines.

Portals must feed the home and village loop. They must not become a separate progression game.

---

## v1.0 non-negotiables

A v1.0 release must provide:

- one polished persistent village;
- a maximum of sixteen resident homes visible at once;
- four visually distinct neighbourhoods;
- one deeply functional home system;
- at least four authored portal worlds;
- at least four useful career or ordinary-life activity loops;
- meaningful free cosmetic expression;
- safe visiting and trading;
- mobile-first input and performance;
- no pay-to-win;
- no anonymous interaction geometry;
- no primitive avatar add-on used merely because approved character art is absent;
- no ordinary village destination whose primary identity is a floating information wall;
- no essential feature that exists only as menu text.

These are product requirements, not aspirational examples.

---

## Launch content floor

The minimum v1.0 content target is:

### Home and furnishing

At least **80 home/furnishing items** across:

- bedroom;
- kitchen;
- bathroom;
- living;
- storage;
- garden;
- decoration;
- lighting.

At least **20 items must have meaningful interactions**, not merely static placement.

### Impossible worlds

At least **4 portal worlds**, each with:

- a distinct visual identity;
- one unique traversal or activity mechanic;
- at least one discoverable secret;
- a bounded objective;
- a memorable physical reward;
- a return-home payoff.

### Everyday life

At least **4 careers or ordinary-life activities**.

### Travel

At least **3 vehicle or travel modes**, but only where each materially changes traversal. Do not add travel modes only to increase a catalogue count.

### Collection

At least **30 discoverable or collectible keepsakes**.

### Character expression

Multiple free avatar and outfit combinations that feel like genuine character choices rather than palette toggles.

These numbers change only through an explicit product decision recorded in canonical documentation.

---

## First-session contract

### First 2 minutes

The player should understand that TinyWorld gives them:

- a character;
- a home;
- a village to inhabit;
- things they can physically interact with;
- optional mystery beyond ordinary life.

The game should not front-load a long tutorial or a wall of systems.

### First 10 minutes

A new player should be able to:

1. complete character setup;
2. understand the coin, level, and task HUD;
3. receive or enter their own home;
4. successfully interact with at least three home objects;
5. visit one village destination;
6. earn something through an activity;
7. make one visible home or character change;
8. see one mystery or portal tease without being forced into it.

### First 30 minutes

A player should have experienced both ordinary-life agency and a meaningful choice about what to pursue next. They should have made at least one persistent, visible change to their life.

### Returning player

A returning player should quickly see continuity: their home, inventory, progress, placed objects, and meaningful discoveries should still be intact.

---

## Home target state

The home must be a **play space**, not a room-shaped menu.

The long-term home system must support:

- room taxonomy;
- player-owned furniture;
- inventory-to-placement flow;
- preview and rotation;
- valid and invalid placement feedback;
- server validation;
- room and plot bounds;
- collision rules;
- placement-count budgets;
- persistence;
- remove and store flows;
- visitor visibility;
- guest permissions;
- storage;
- home upgrade tiers;
- catalogue acquisition;
- reusable furniture interaction contracts.

By v0.9 the home should support representative verbs including:

- sit;
- sleep or rest;
- open and close;
- switch on and off;
- store and retrieve;
- cook;
- wash;
- bathe or shower;
- plant;
- water;
- harvest;
- read or play;
- dress or change;
- display or collect;
- decorate or place;
- craft or create.

Not every item needs a unique system. Reusable interaction components should provide consistent behaviours.

A placement-heavy home must use incremental mutation. Rebuilding an entire house for every decoration change is not the target architecture.

---

## Village target state

The village already provides the spatial composition. v1.0 must give destinations meaningful ordinary-life reasons to exist.

### Town Hall

Use for village identity, community information, and future village events. It must not become a telemetry dashboard.

### Village Shop

Use for ordinary consumables and low-stakes objects. Rotating cosmetic stock may be added only after the live-ops and analytics design exists.

### Home Store

Use for furniture, room sets, previews, and catalogue browsing. Purchases should result in physical owned items.

### Courier Depot

Courier work should become a replayable route system with visible parcels, route variety, delivery feedback, career XP, and bounded rewards.

### Workshop

Use for bikes, vehicles, maintenance, and visual customisation. Transport upgrades must not create pay-to-win power.

### Market or Trading Post

Keep trading physical and understandable. Valuable trading must not expand before persistence and recovery are durable.

### Ambient life

TinyWorld does not need hundreds of AI NPCs. A small number of believable, authored routines should make destinations feel inhabited without unnecessary performance or safety complexity.

Suitable examples include a shopkeeper, courier, gardener, harbour worker, birds, pets, and critters.

---

## Impossible-world target state

Portal worlds must be authored adventures, not reskinned collection rooms.

Every launch portal world must contain:

1. a clear entrance reveal;
2. a visual rule unlike the village;
3. one unique traversal or interaction mechanic;
4. at least one discoverable secret;
5. a bounded objective;
6. a memorable physical reward;
7. a return-home payoff.

### Giant Kitchen

The player is toy-sized in a functioning oversized kitchen. Candidate mechanics include climbing drawers, bouncing on a sponge, crossing moving utensils, riding rolling objects, and collecting ingredients or crystals.

Return-home rewards can include recipes, kitchen props, and display keepsakes.

### Moonlit Meadow

A magical nocturnal meadow where plants and paths respond to light. Candidate mechanics include activating glowing flowers, following fireflies, growing temporary plant bridges, and finding hidden moon seeds.

Return-home rewards can include garden plants, moon lamps, and decorative flora.

Add two additional original worlds before v1.0. Do not add ten shallow portals.

---

## UI and UX target state

Keep the current philosophy: compact HUD, journal, contextual prompts, and short toasts. The 3D world remains the primary information surface.

Do not use a full-width website-style navigation/header or permanent system-dashboard panel in ordinary play. Home, Wardrobe, Journal and other deep surfaces should open intentionally through one coherent compact navigation surface and one modal owner.

The Journal should become the intentional deep-information surface rather than expanding the permanent HUD.

Recommended launch sections:

- Today;
- Bag;
- Home;
- Careers;
- Collection;
- Places.

Before introducing a larger UI framework, build TinyWorld-native reusable UI boundaries for tokens, scale rules, buttons, panels, modals, and focus.

Hard acceptance rules:

- the core experience works on touch;
- no hover-only interaction;
- minimum 44 × 44 effective touch target;
- safe areas are respected;
- critical UI remains visible on small phone aspect ratios;
- journal tabs do not clip;
- readable text does not depend on `TextScaled` everywhere;
- furniture placement works on touch;
- controller navigation has explicit focus order.

---

## Character-expression target state

Before v1.0, character expression should include:

- multiple body or appearance presets;
- hair;
- tops;
- bottoms;
- shoes;
- simple accessories;
- saved outfits;
- wardrobe interaction;
- meaningful free starter variety.

Use Roblox-safe asset ownership and moderation rules. Do not create a paid identity tax. When no approved TinyWorld character asset exists, preserve the player's normal Roblox avatar rather than bolting primitive Part hair or shoes onto it. Saved preferences may remain future-facing without forcing visibly inferior geometry.

---

## Safety and social target state

TinyWorld must define and enforce:

- home visit permissions;
- friend and guest behaviour;
- trading boundaries;
- Roblox filtered-text rules;
- no custom unfiltered text;
- no coercive purchase mechanics;
- no unsafe private-communication design;
- reporting and muting expectations where social features expand;
- family playtesting criteria.

Safe social behaviour is a release requirement, not a post-launch enhancement.

---

## Economy and monetisation principles

TinyWorld remains **no pay-to-win**.

Do not add fake Roblox IDs or speculative developer products.

Any monetisation implementation requires a separate approved design covering:

- cosmetics;
- optional home sets;
- expressive vehicle variants;
- convenience that does not create gameplay power;
- purchase-receipt idempotency;
- refund and retry behaviour;
- child and family appropriateness;
- pricing review.

The game should first prove that players want to live in TinyWorld.

---

## Architecture principles that must survive product expansion

Do not migrate to Knit, React, Roact, ProfileService, Wally, or another framework simply because the project is growing.

Preserve the current boundaries unless a concrete requirement proves they are insufficient:

- `src/shared`: deterministic rules and contracts;
- `src/server`: authority and orchestration;
- server builders: authored physical world;
- `src/client`: presentation.

Introduce focused read-only content definitions as content grows, including item, furniture, activity, world, and shop definitions.

The player profile should persist owned state, not duplicate display metadata.

---

## Persistence and inventory target state

The current fixed inventory is suitable for a vertical slice but not for v1.0.

The scalable direction is:

```text
inventory:
  stacks: itemId -> quantity
  instances: instanceUuid -> { itemId, metadata }
```

Use stacks for ordinary resources.

Use unique instances only when required for:

- placed-furniture identity;
- customisation;
- durability or state;
- high-value trading;
- provenance.

Do not make every ordinary resource a UUID.

Before the next profile schema expansion, introduce an explicit deterministic and idempotent migration chain. Unknown future schema versions must fail closed rather than being normalized away.

DEV and LIVE must use distinct DataStore namespaces before DEV publishing is enabled.

---

## Remote and security target state

As placement, shops, avatar customisation, and social features expand, remote security must be systematic.

Server-side remote validation should cover:

- type validation;
- finite-number validation;
- integer and range validation;
- string-length validation;
- enum and ID allow-list validation;
- per-player action rate limiting;
- distance checks;
- ownership checks;
- cleanup on `PlayerRemoving`;
- structured security warnings.

For purchases, placement, rewards, vehicles, crafting, and similar systems, the client sends an ID or intent only. The server decides price, reward, ownership, unlock conditions, and authoritative outcome.

---

## Trading target state

Do not expand high-value trading until TinyWorld has a durable protocol that can recover from partial persistence failure.

The durable design should include:

- unique transaction ID;
- immutable agreed-offer snapshot;
- server-side locks on offered item instances;
- transaction journal record;
- idempotent commit state;
- recovery on rejoin;
- audit entry with user and item identifiers;
- server-owned final contents;
- timeout and cancellation;
- duplicate-completion protection.

---

## Performance target state

Production quality must be measured on real devices.

Initial target gates:

### Mobile

- sustained minimum 30 FPS on the agreed low or mid target device;
- no repeated >33 ms script frame during ordinary play;
- memory target under 500 MB on the agreed test device;
- acceptable spawn and load target under 15 seconds on a normal connection.

### Desktop

- target 60 FPS;
- ordinary script frame budget under 16.6 ms where practical.

### Network

- no gameplay RemoteEvent fired every render frame;
- batch state updates;
- measure send and receive behaviour;
- record remote-spam tests.

### World

- configure StreamingEnabled when measured world growth requires it;
- anchor static decor;
- disable unnecessary decorative query and touch;
- document particle, light, mesh, and texture budgets as production assets arrive.

Thresholds may be tuned against real device evidence, but they must not disappear merely because a test is inconvenient.

---

## Analytics target state

Before production beta, TinyWorld should define a small stable event taxonomy that answers product questions without collecting everything.

At minimum cover:

- join;
- new versus returning;
- onboarding started;
- onboarding completed;
- home entered;
- first home interaction;
- first earned currency;
- first purchase;
- first furniture placement;
- first career activity completion;
- first portal entered;
- first portal completed;
- first visit;
- first trade;
- session duration;
- last meaningful activity or churn point.

Do not log sensitive free-form text or emit per-frame analytics.

---

## Visual and asset target state

Native-part authored prefabs remain a valid production medium and prototyping tool only when the resulting object meets its visual tier. Hero content includes player character presentation, starter home, civic destinations, primary vehicles and portal landmarks. A hero fallback that still reads as anonymous placeholder geometry fails even if semantic metadata calls it authored.

When an approved asset is unavailable, preserving a coherent Roblox-native/default presentation is better than inventing a visibly inferior fallback.

Production art should progressively move toward:

- stylised authored meshes or convincing native-part compositions for hero objects;
- richer furniture silhouettes;
- original props;
- animation where it adds tactile quality;
- restrained VFX;
- positional sound;
- small ambient motion.

Large always-on-top information walls are not an art fallback. Proper names may use small physical signs; actions remain contextual.

Do not turn everything into Neon.

Every production asset should have recorded semantic identity, Roblox asset ID, owner, source, licence or provenance, prefab role, version, status, and environment approval.

A mesh or model may replace a native prefab only if it preserves builder contracts, art role, interaction anchors, collision and query safety, gameplay authority, recognizability, and performance budget.

TinyWorld may borrow broad design qualities such as Roblox life-sandbox readability, tactile warmth, and adventurous contrast. Team shorthand is Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder. Those are design-principle references only; TinyWorld must not reproduce identifiable characters, locations, buildings, props, logos, UI layouts, names, or distinctive visual expression from another game or film.

---

## Release train

| Release | Primary purpose | Player-visible outcome |
|---|---|---|
| **v0.6.0** | Target-State Consolidation | Merged scalable home/content/data/security/UI/world foundation |
| **v0.6.1** | Visual Rescue | Remove prototype presentation, establish world-first visual language, and prove one golden ordinary-life route |
| **v0.7.0** | Village Life | Shops, careers, routines, and shared village activities become satisfying on the v0.6.1 visual baseline |
| **v0.8.0** | Impossible Worlds | Portal worlds become authored adventures that meaningfully feed home life |
| **v0.9.0** | Production Beta | Security, analytics, performance, accessibility, DEV publishing, and content depth reach launch-candidate quality |
| **v1.0.0** | Launch | Complete coherent life-sandbox experience with evidenced quality gates |

After v0.5.3, avoid competing product and engineering version numbers. A repository release should have one version with product, engineering, and evidence sections beneath it.

---

## Release-process target state

The production path should become:

```text
commit
  -> CI tests
  -> Rojo artifact
  -> release manifest + SHA
  -> required Studio/device visual evidence for player-facing changes
  -> publish exact artifact to DEV when configured/approved
  -> published runtime/multiplayer/device evidence
  -> explicit human approval
  -> promote exact approved artifact to LIVE
```

Do not rebuild different source for LIVE after approval.

Before v1.0, document last-known-good artifact, rollback triggers, rollback operator, DataStore compatibility, migration rollback limitations, and an emergency-disable strategy for risky systems.

---

## Evidence rule

Source inspection, CI, Studio testing, multiplayer testing, and published-device evidence are different evidence classes.

Never claim:

- visual quality from source inspection alone;
- runtime correctness from CI alone;
- multiplayer correctness from a one-client Studio run;
- device quality without device evidence.

The game should look intentional even when explanatory labels are hidden. For player-facing visual releases from v0.6.1 onward, required Studio/device visual rows may be NOT RUN while a PR is draft but block merge-ready status until observed.

---

## Explicit anti-goals

TinyWorld is:

- not an idle clicker;
- not a combat-first experience;
- not a portal lobby;
- not a menu-driven house decorator;
- not a pay-to-win simulator;
- not a clone of Brookhaven, Toca Boca, Ready Player One, Disney Dreamlight Valley, or another existing IP.

Do not:

- rewrite working services into a fashionable framework;
- add dozens of dependencies;
- turn the home into a menu;
- turn the village into a hub between portals;
- add combat because generic Roblox RPG guidance contains combat examples;
- add rarity or pity mechanics unless the product explicitly needs them;
- add generic simulator pets or click multipliers;
- add pay-to-win boosts;
- add fake game-pass or developer-product IDs;
- add ten shallow portal worlds;
- add high-value trading without durable recovery;
- place raw analytics or debug state in normal UI;
- use labels to explain unclear 3D objects;
- use large always-on-top ordinary-world information walls as a substitute for visual design;
- attach primitive block hair or shoes to the player merely to demonstrate character customisation;
- use anonymous neon rings, spheres or cubes as finished content;
- conflate successful CI with a good Roblox experience.

---

## Implementation-agent execution contract

Every future implementation branch derived from this target state must begin by reading:

1. `AGENTS.md`;
2. `docs/README.md`;
3. this document;
4. the relevant product document;
5. the relevant engineering document;
6. the release-specific acceptance file;
7. the release-specific Superpowers spec and plan.

An implementation agent must:

- use Superpowers brainstorming and specification before expanding product scope;
- use TDD for deterministic shared rules;
- preserve server authority;
- avoid invented Roblox IDs;
- avoid production credentials in source;
- keep changes within one release slice;
- update acceptance and documentation with implementation;
- record evidence honestly;
- never substitute static inspection for Studio evidence;
- never claim device quality without device evidence;
- never introduce a large framework without an explicit architectural reason.

---

## Definition of v1.0 success

TinyWorld is ready for v1.0 when a new player can enter on a phone, create a character, understand the village, walk into a believable home, use objects, earn something through ordinary life, buy and place something meaningful, visit another player safely, choose to explore an impossible world, return with a memorable reward, and rejoin later to find their life intact.

The game should look intentional even when every label is hidden.

The server should remain the authority even when every client request is hostile.

The repository should let a fresh authorised implementation agent understand exactly what to build without reconstructing the product vision from historical chats.

For every LIVE build the release process must be able to answer:

> **What source produced this? What artifact was tested? What evidence passed? Who approved promotion? How do we roll it back?**

That is the target state.
