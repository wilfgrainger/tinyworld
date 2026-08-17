# ART R9 Gameplay-First World Reset Design

**Status:** Approved product direction; durable design pending final owner review  
**Date:** 17 August 2026  
**Controlling issue:** #52 — ART R9 Gameplay-First World Reset  
**Design branch:** `design/r9-gameplay-first-reset`  
**Implementation dependency:** v0.7.6 / PR #50 must integrate first; implementation branches from the resulting current `main`  
**Programme name:** `ART R9` is an art/product revision name, not semantic version `v0.9.0`

## 1. Goal

Make TinyWorld enjoyable to inhabit **before** asking missions, quests or progression systems to carry the experience.

The immediate player promise is:

> **I can join TinyWorld, move around, climb, explore, swim, ride, meet characters and find interesting places, and the world already feels like a finished Roblox game before I choose a mission.**

R9 is not a rewrite of TinyWorld's trustworthy engineering. It preserves server-authoritative progression, persistence, ownership, activities, homes, portals, trade boundaries, release evidence and existing published-safe rendering constraints. It replaces the player-facing assumptions that created a flat, static, overbuilt world.

## 2. Authority and contract order

R9 follows this authority chain:

1. GitHub issue #52 for current operational decisions/state;
2. `AGENTS.md`;
3. `docs/product/target-state-v1.md`;
4. durable product/engineering/quality contracts relevant to the changed surface;
5. this R9 design;
6. the later R9 implementation plan;
7. historical release material as evidence only.

`docs/README.md` currently contains stale current-release precedence pointing at v0.6.3. That is a documentation defect, not authority to revert R9 to historical scope. The first R9 documentation task must correct that drift so future implementation agents cannot be routed to an obsolete release record.

## 3. Mandatory Roblox skill lenses

R9 implementation and review must apply the relevant `TabooHarmony/roblox-brain` skills used by TinyWorld's production audit.

### `roblox-building`

The map has named roots, zones, landmarks, paths, spawns/return paths and bounds. Geometry is built/read back in bounded phases. Traversal is playtested. Player scale is explicit. Ordinary walking paths target **8–12 studs** where possible and never intentionally narrow below the skill's 6-stud baseline on a required route.

### `roblox-architecture`

Every mutable behaviour has one owner. R9 does not create a new global framework, event bus or dependency container. Pure deterministic layout/topology rules belong in `src/shared`; server builders own physical presentation; services own runtime behaviour and cleanup.

### `roblox-code-review`

Review actual vertical slices, not builder names or metadata. For example: player sees bike → mounts → input changes traversal → server-owned state changes → reset/death cleans up. A `TinyWorldRecognizableSilhouette=true` attribute is not evidence.

### `roblox-performance`

Profile before optimizing. R9 must not solve visual emptiness by blindly multiplying Parts, lights, particles or per-frame tasks. Mobile FPS, memory, load, streaming and script hot paths remain measured evidence gates.

### `roblox-ui-design`

The world remains the dominant visual surface. R9 may simplify UI where required but does not add permanent mission/dashboard surfaces to compensate for weak physical design. Touch/controller states and representative viewports are verified.

### `roblox-animation-vfx`

Animation is bounded, owned and cleaned up. NPC/ambient motion uses proper animation/routine ownership rather than decorative per-frame noise. Particles/glow are not used to fake life or object readability.

### `roblox-networking` + `roblox-security`

Transport and future co-op behaviour assume hostile clients. The client expresses intent/input; the server validates ownership/state/context and decides progression/reward outcomes. R9 does not create client-authored economy or completion state.

### `roblox-growth-design`

R9 fixes the action→payoff and first-session experience before LiveOps/retention machinery. No invented metrics. The release records observed player confusion/enjoyment and first-payoff evidence.

### `roblox-publish-checklist`

No visual/runtime/device PASS without evidence. Unsupported/unobserved gates are `NOT RUN`/`UNVERIFIED`, never inferred PASS.

## 4. Current source diagnosis

The family playtest maps directly to current architecture.

### 4.1 Flatness is encoded into the canonical layout

`src/shared/R8VillageLayoutRules.luau` defines `GROUND_Y = 0`. Its point/plot helpers put the entire ordinary village on that elevation. Residential clusters, destinations and routes therefore begin life as a planar coordinate system.

### 4.2 The authoritative ground is literally a large flat slab

`src/server/R8GroundBuilder.luau` creates `AuthoritativeVillageBase` as a single rectangular Grass Part approximately 380×380 studs, then overlays flat road/plaza/courtyard Parts at nearly the same Y.

This is the structural cause of the “baseplate/building site” read. Extra props cannot correct it.

### 4.3 R8 dressing is sparse and formulaic

`src/server/R8VillageCompositionBuilder.luau` adds a small repeated set of lamps, benches, planters, trees, hedges and mailboxes around fixed cluster centres and route midpoints, all using the same `groundY`.

This is useful dressing over a good world but insufficient to create topography, enclosure, discovery or neighbourhood character on its own.

### 4.4 NPCs are anchored sculptures, not characters

`src/server/VillageNpcBuilder.luau` manually constructs all body/face/hair/clothing/role pieces as anchored Parts. A `Humanoid` is appended, but the model is not a normal rig with animated joints. `VillageNpcService` builds each role once at a fixed activity location.

The result can have detailed metadata and still look like a statue. R9 replaces this presentation path rather than adding more Part detail to it.

### 4.5 Ambient life is intentionally absent

`AmbientLifeService` is currently a no-op to avoid shipping primitive animals. That safety decision is correct. R9 does not reverse it by adding low-quality creature blocks.

### 4.6 Tiny Bike behaviour intentionally creates the reported failure

`TransportService` explicitly does not seat the player. While active it pivots the bike model under the player's `HumanoidRootPart` from a Heartbeat connection and accelerates walking speed. The bike is therefore following the avatar rather than acting as the traversed vehicle.

Issue #51 owns replacing this with an actual ridden bicycle interaction.

## 5. Design principles

### 5.1 Simpler wins

When two visual solutions communicate the same thing, choose the one with:

- fewer separate shapes;
- fewer simultaneous colours;
- clearer silhouette;
- clearer physical purpose;
- easier traversal;
- lower performance cost;
- less explanatory text.

Complexity is justified only by player value.

### 5.2 Brookhaven is a readability benchmark, not a source library

The team may ask “how would a strong Roblox life-sandbox make this obvious?” for scale, navigation, rideability and immediate comprehension.

TinyWorld must not reproduce Brookhaven's proprietary assets, code, map, buildings, UI, characters, names, logos or distinctive expression.

### 5.3 Ordinary world first, wonder second

The village is grounded, readable and warm. Impossible worlds retain stronger surreal colour, glow and scale breaks. If ordinary TinyWorld is visually screaming everywhere, portal contrast disappears.

### 5.4 Physical form before labels

A player should identify broad categories such as home, shop, fountain, bike, dock, fisherman and mountain route without floating explanatory UI.

### 5.5 Fun exists without a quest selected

R9 is successful only if ordinary movement and discovery create voluntary actions: “I want to climb that,” “I want to ride this,” “I want to see what's in those trees,” “I want to swim over there,” “I want to follow that character.”

## 6. Selected architecture

R9 preserves existing game/service authority and introduces a new **R9 visible-world authority**. It does not stack R9 presentation on top of visibly active R6/R7/R8 presentation.

### 6.1 Pure topology contract

Create an R9 deterministic shared layout/topology definition that describes **semantic zones and elevations**, not only flat X/Z coordinates.

Required concepts:

- `VillageCentre`;
- `MeadowLane`;
- `HarbourRow`;
- `WoodlandRise`;
- `OrchardEnd`;
- `MountainRise`;
- `HarbourWaterEdge`;
- canonical destination anchors;
- canonical activity anchors;
- route nodes/widths;
- safe spawn/recovery points;
- shoreline/swim/raft bounds.

Coordinates remain deterministic and server-authoritative. Services must not invent duplicate destination coordinates.

The shared rules must be testable without Roblox services.

### 6.2 Compatibility adapter

Existing services that consume the current world layout should receive a compatibility view derived from the R9 topology. The adapter exists to preserve proven service contracts during the visual rebuild.

Do **not** keep both R8 and R9 coordinate authorities active.

### 6.3 One visible ground authority

R9 removes the giant flat authoritative grass slab as the visible landscape.

The new world surface uses a deliberate combination of terrain and minimal authored collision foundations chosen for stability/readability. Terrain is preferred for broad landform, coast, rolling woodland and mountain mass where it produces the intended result efficiently. Stable invisible/simple foundations may remain where home/interaction gameplay requires precise collision.

Hard rule:

> There is exactly one visible ordinary-world ground/coast authority at runtime.

R6/R7/R8 ground/coast/route surfaces superseded by R9 are deleted/suppressed, not hidden underneath as visual lasagne.

### 6.4 Five spatial anchors

#### Village Centre

- relatively level and easy to understand;
- fountain/civic silhouettes establish orientation;
- several obvious exits lead to neighbourhoods/harbour/mountain;
- no giant empty lawn surrounding it.

#### Residential Lanes

- homes read as small streets/clusters;
- paths, planting, fences/walls and outlook create enclosure;
- 16-home capacity remains unchanged;
- each of the four canonical neighbourhood identities remains visible.

#### Woodland

- a genuinely wooded traversable zone rather than two trees near a plot;
- canopy clusters, undergrowth/rocks and a winding route create partial visual enclosure;
- at least one alternate small path/lookout/secret-ready space;
- required route remains touch/controller friendly and cannot become a collision maze.

#### Mountain/Rise

- visible from multiple ordinary village viewpoints;
- climbable with normal traversal;
- route uses bends, terraces/steps/slopes and intermediate visual rewards;
- summit has a safe lookout and reserved future quest anchor;
- not one giant ramp and not decorative inaccessible background.

#### Harbour/Water Edge

- land visibly descends toward the water;
- dock/fishing/raft relationships are physically legible;
- safe swim entry/exit points exist;
- Tiny Raft is moored in water when owned/available according to its service rules;
- coast/recovery safety remains authoritative.

### 6.5 Elevation language

R9 avoids arbitrary vertical noise. Elevation serves place identity and navigation:

- centre: low variation;
- homes: small rises/setbacks;
- woodland: rolling variation;
- mountain: strong deliberate ascent;
- harbour: deliberate descent.

Every required route must be traversed in Studio/device evidence with normal avatar movement. Decorative slopes that trap avatars fail.

## 7. Building and colour simplification

### 7.1 Building palette

Ordinary hero buildings should generally use:

- one main facade family;
- one roof family;
- one restrained accent family;
- physically meaningful glass/wood/metal/stone where needed.

This is not a literal maximum-three-colours shader rule. It is a composition rule against rainbow fragmentation.

### 7.2 Silhouette hierarchy

At normal third-person distance, the player should first read:

1. overall building category/shape;
2. entrance and main function cue;
3. larger windows/roof/porch elements;
4. local decorative detail.

Do not invert that order by creating dozens of equally loud micro-parts.

### 7.3 Houses

- preserve functional interior/ownership anchors;
- use simple recognisable house massing;
- pitched/characterful roof without oversized slab dominance;
- obvious entrance;
- windows with frame/depth/material hierarchy;
- small garden/context appropriate to neighbourhood;
- higher tiers remain recognisably progressed versions.

### 7.4 Civic destinations

Each civic destination keeps one dominant approach cue and physical function props. A sign may provide the proper name, but it does not explain an otherwise anonymous box.

## 8. NPC architecture

### 8.1 Replace the anchored-Part character path

The current Part-sculpture NPC path is not extended.

R9 NPCs use a proper Roblox-native rig with `Humanoid`/`Animator` semantics and an explicit movement/routine owner. The initial baseline should prefer an engine-native/default character presentation that does not require invented external asset IDs. Optional clothing/accessory assets are added only through TinyWorld's approved provenance pipeline.

If an approved visual asset is unavailable, a coherent normal Roblox character baseline is preferred over custom primitive body/hair geometry.

### 8.2 Keep gameplay authority separate

`VillageActivityService` and the existing role/activity services continue to own objective/reward logic.

NPC presentation/routine code may:

- move the character;
- play approved animations;
- orient toward a work point/player where appropriate;
- enable/relocate the interaction prompt with the NPC;
- reset a character to a safe routine anchor.

It may not decide coins, XP, inventory or quest completion.

### 8.3 One routine owner

Introduce one focused routine service/controller responsible for:

- attaching a routine to each NPC;
- bounded route/wander targets;
- timing/idle transitions;
- stuck/path failure recovery;
- Character/Humanoid death/reset replacement if relevant;
- cleanup on service stop/world teardown.

Do not add independent Heartbeat loops per decorative body part.

### 8.4 Initial authored routines

R9 needs only enough life to prove the system:

- trader/shop role: small counter/door/stand loop;
- gardener: short garden-bed/tool loop;
- fisherman: dock/fishing position loop;
- builder or harbour role: short workshop/dock loop.

Not every NPC needs constant wandering. Idling, turning, walking a short route and performing one recognisable job action is enough when it feels intentional.

### 8.5 Ambient creatures

Ambient creatures remain **asset-gated**. Do not resurrect primitive frozen birds.

R9 can pass without creature actors if NPCs, environment and water already provide believable motion. If birds/critters are introduced, they require:

- approved/provenance-safe model/rig;
- bounded movement volume/route;
- cleanup owner;
- performance budget;
- visible movement in exact-candidate evidence.

A bird mesh frozen in the sky is an automatic visual failure.

## 9. Traversal architecture

### 9.1 Walking/jumping/swimming

Normal avatar movement remains the baseline. R9 terrain must work with Roblox movement rather than requiring constant teleports to cross ordinary village space.

### 9.2 Tiny Bike

Issue #51 owns detailed implementation and acceptance.

R9 integration requires:

- clearly recognisable bicycle silhouette;
- avatar visibly mounted/seated/posed with bike;
- direct player-controlled travel;
- movement materially differs from walking;
- no Heartbeat follower-prop architecture;
- deterministic dismount/reset/death/world-transition cleanup;
- server-owned ownership/unlock/progression state.

### 9.3 Tiny Raft

Issue #42/v0.7.6 owns the immediate boat/raft implementation where it lands.

R9 world integration assumes:

- product name `Tiny Raft`;
- readable simple raft rather than a fake boat;
- default/mooring location is in water;
- player visibly rides/controls it;
- bounded water traversal and recovery;
- harbour layout supports the raft physically.

### 9.4 Authority model caution

Do not choose continuous transport networking by convenience. The implementation plan must inspect the experience's actual Roblox authority settings and pick a movement approach consistent with current TinyWorld architecture and Roblox networking/security guidance. Economy/ownership remains server-owned regardless.

## 10. UI design

R9 is mostly world work.

UI changes are limited to removing obstruction or supporting new traversal prompts. The permanent HUD remains compact. Mission UI is explicitly not introduced merely because the world has more destinations.

Required device behaviour:

- touch targets >= 44×44 effective pixels;
- safe-area compliance;
- phone portrait and landscape;
- explicit controller focus where a R9 surface changes it;
- no full-width website header;
- no permanent right-side telemetry/task wall.

## 11. Performance design

### 11.1 Budgets remain binding

- mobile sustained minimum: 30 FPS;
- mobile client memory target: <= 500 MB;
- useful join/spawn target: <= 15 seconds;
- desktop target: 60 FPS;
- no gameplay RemoteEvent every render frame;
- static decor anchored and unnecessary touch/query disabled.

### 11.2 Density strategy

World richness comes from **clustered composition and topography**, not uniform object multiplication.

Prefer:

- grouped tree canopies rather than evenly spaced trees across the map;
- a few strong rock/plant clusters;
- terrain mass for mountain/rolling land;
- reusable approved prefabs;
- fewer lights and no constant particles in ordinary village life.

### 11.3 Streaming

R9 must make the Workspace streaming decision explicit/reproducible where the existing v0.7.6 hardening work allows. Do not assume streaming makes an oversized world free. Measure instance/memory/load behaviour on the target device.

### 11.4 Profiling route

Record at minimum:

- spawn/centre;
- each four-home neighbourhood;
- woodland;
- mountain ascent and summit;
- harbour/swimming;
- bike traversal;
- raft traversal if in candidate;
- representative NPC routines;
- representative home;
- two-player ordinary-life session.

## 12. Deterministic test design

R9 adds pure tests for properties that can actually be proven outside Roblox.

### Layout/topology tests

Assert:

- exactly four residential neighbourhoods and <=16 resident slots;
- required semantic zones exist;
- canonical destinations/activities resolve to one authority;
- required routes meet minimum configured width;
- mountain route has increasing/decreasing authored elevation nodes rather than one flat segment;
- harbour route descends toward the shoreline;
- safe recovery/spawn points remain inside intended bounds;
- no plot overlap after applying R9 placement rules.

### Visible-authority/source contracts

Assert the active bootstrap cannot render replaced R8 ground/coast/route presentation alongside R9 visible authority.

### NPC rule tests

Keep pure routine state transitions separate where useful, such as:

- idle → move → work → idle;
- timeout/stuck → recover;
- stop → no active routine;
- interaction/reward authority remains outside the routine core.

Do not pretend pure tests prove Humanoid animation/pathfinding visual quality.

### Transport regression

#51 must add deterministic state/lifecycle tests where possible and real-client evidence for actual riding.

## 13. Human and runtime acceptance

R9 does not pass from source review.

### World-first test

With ordinary explanatory labels hidden where practical, the family should be able to:

- identify village centre;
- identify their home area;
- identify woodland;
- identify and voluntarily attempt the mountain;
- identify harbour/water access;
- name several civic/ordinary objects by category.

### Fun-without-missions test

Before giving the tester a mission, observe free play for a bounded session.

PASS requires the family to identify at least **three voluntary enjoyable actions** such as climbing, biking, swimming, exploring woodland, following an NPC, entering/using home or visiting a landmark.

The exact actions are not prescribed. The point is that fun must emerge without task-list coaching.

### NPC test

- close-up looks like a coherent Roblox character, not an anchored sculpture;
- at least one NPC walks/performs its routine in normal client play;
- interaction prompt remains usable;
- movement failure does not leave the character permanently lost/stuck;
- no new critical console errors.

### Mountain test

- visible from meaningful village angles;
- ordinary avatar can reach summit;
- no invisible blocker/void route;
- route has more than one visual beat/viewpoint;
- summit provides safe standing/lookout space.

### Device test

Record phone portrait/landscape, controller where changed, FPS/memory/load, and world occlusion/readability.

### Final verdict

Family verdict is explicit `PASS` or `FAIL` against the exact published DEV candidate. A source/CI pass cannot override a player-facing fail.

## 14. Co-operative quests are a separate later design

The family approved a future direction where selected quests encourage bringing friends and some optional quests require **2–4 players**.

That feature is deliberately not implemented in the first R9 slice.

Future co-op design must preserve:

- solo-capable onboarding/basic ordinary life/basic earning;
- explicit participant requirement before start;
- server-owned membership/objective/completion/reward state;
- deterministic join/leave/disconnect/timeout/abandon behaviour;
- child/family-safe social design;
- no off-platform communication requirement;
- no coercive invite spam;
- physical collaboration rather than a menu-only “party required” gate.

Candidate future mechanics include simultaneous switches, group carrying/pushing, multi-position puzzles, group ascent/rescue and tasks where players divide roles.

This later work requires its own Superpowers design/spec before code.

## 15. Non-goals

The first R9 implementation does not add:

- a new economy;
- monetisation;
- LiveOps;
- generic simulator pets;
- combat;
- a large quest catalogue;
- the co-op quest framework;
- new portal-world programme;
- new application framework;
- copied reference-game content;
- fake asset/product IDs;
- automatic LIVE publication.

## 16. Release sequencing

1. Complete/integrate v0.7.6 Runtime Hardening / PR #50.
2. Rebase product state mentally and create the R9 implementation branch from resulting current `main`.
3. Correct stale documentation authority as the first implementation/documentation task.
4. Implement R9 topology/visible-world authority before decorative craft.
5. Recompose houses/civic presentation on the new world.
6. Implement proper NPC presentation/routines.
7. Integrate #51 bike and the landed #42 raft contract.
8. Verify CI/static/deterministic gates.
9. Publish exact candidate to DEV through existing release process.
10. Run family, phone, controller, multiplayer and performance acceptance.
11. Keep #52 open on any family/player-facing FAIL.

## 17. Design completion criteria

The design is ready for implementation planning when the release owner confirms:

- gameplay-first priority is correct;
- the five spatial anchors are correct;
- terrain/verticality replaces the flat visible base rather than layering over it;
- NPCs move to a proper Roblox-rig/routine architecture;
- #51 bike and #42 raft remain the transport boundaries;
- co-op quests remain deferred until the base game is fun/accepted;
- family acceptance is release-blocking.

No implementation code should be written from this spec until that review gate is confirmed.
