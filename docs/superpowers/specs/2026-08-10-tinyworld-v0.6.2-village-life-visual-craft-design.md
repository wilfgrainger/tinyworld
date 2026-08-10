# TinyWorld v0.6.2 Village Life & Visual Craft — design

**Status:** approved for implementation  
**Date:** 10 August 2026  
**Base:** merged v0.6.1 Visual Rescue  
**Release:** v0.6.2 Village Life & Visual Craft  
**Profile schema:** 11 unless implementation uncovers a concrete durable-state requirement that cannot be represented compatibly.

## 1. Decision

v0.6.2 absorbs the complete currently-defined v0.7.0 Village Life scope and the remaining actionable recommendations from the Claude review handoff.

The existing v0.7.0 milestone is deliberately vacated. A later v0.7.0 delivery scope will be authored from the family/girls review rather than inheriting assumptions from the current roadmap.

v0.6.2 therefore becomes the consolidation release that turns the v0.6.x foundation into a more satisfying ordinary-life game while continuing the visual-craft reset begun in v0.6.1.

## 2. Sources and inherited decisions

This design reconciles three authorities:

1. merged v0.6.1 Visual Rescue and its visual-evidence discipline;
2. the current `docs/roadmap/v0.7.0-village-life.md` scope;
3. the Claude review handoff, including `BRANCH-NOTES.md`, the proposed Village Life & Visual Craft roadmap, and its acceptance contract.

The Claude review's central diagnosis is retained: TinyWorld's gameplay/server foundation is ahead of its presentation. Remaining work must improve visual, spatial and interaction quality rather than merely increase feature count.

## 3. Release outcome

A normal 15–30 minute TinyWorld session should feel like a small life rather than a collection of technically-working prompts.

A player can:

- recognise and move between distinct village destinations;
- complete repeatable ordinary-life activities;
- earn visible progress through those activities;
- use shops and home systems through physical, understandable interactions;
- see a village that feels inhabited through restrained authored ambient motion/routines;
- return home and make a visible change;
- use the compact v0.6.1 HUD without the world being buried under interface chrome;
- understand important objects with labels hidden;
- optionally notice the impossible-world layer without portals becoming the only reason to play.

## 4. Non-negotiable inherited visual contract

v0.6.2 keeps every v0.6.1 presentation rule:

- preserve the player's normal Roblox avatar until approved TinyWorld character assets exist;
- no primitive welded hair/shoes or equivalent character fallback;
- no large always-on-top ordinary-world information walls;
- no permanent telemetry/developer dashboard in normal play;
- compact world-first HUD;
- destination and hero-object comprehension must survive labels-off review;
- source/CI evidence never counts as proof that something looks good in Studio;
- unobserved visual quality remains unfinished, not silently marked PASS.

## 5. Claude recommendations carried into v0.6.2

### 5.1 HUD and telemetry

Keep normal-play HUD compact and transient. Studio diagnostics remain separate and explicitly developer-only. Do not reintroduce a web-dashboard layout.

### 5.2 Sixteen-home village cap

Retain the deterministic maximum of sixteen resident homes. Village-life expansion must deepen this world rather than solve scale by adding more visible plots.

### 5.3 Authored village spatial craft

Reduce uniform/grid-like reading through existing builder boundaries:

- stronger neighbourhood identity;
- differentiated path shape and approach;
- landmark-led navigation;
- purposeful prop clusters;
- small height/terrain/edge changes where they improve composition;
- clear sightlines to civic destinations;
- authored arrival moments at hero destinations.

Do not replace the world architecture or introduce a second village system.

### 5.4 Production prefab/art pipeline

Native-part prefabs remain useful engineering fallbacks and interaction scaffolds, but they are not automatically accepted as finished hero art.

The asset pipeline must:

- keep semantic asset IDs separate from Roblox IDs;
- reject invented IDs;
- record owner/source/provenance/version/approval;
- preserve interaction anchors, art roles, collision/query safety and server authority when visuals are replaced;
- distinguish fallback/prototype, authored-native and approved-production visual states;
- prevent metadata alone from certifying visual quality.

No external asset or dependency is introduced without an approved source and provenance.

### 5.5 Distinct civic silhouettes

Town Hall, Village Shop, Home Store, Courier Depot, Workshop and Market/Trading Post must each have a distinct physical identity. Text labels may assist navigation but cannot be the thing that makes the building identifiable.

### 5.6 Diegetic interactions, not generic kiosks

Replace or avoid generic box/kiosk interactions where an ordinary-life object can carry the interaction:

- parcel rack/crate/counter for Courier;
- shelves/counter/display objects for shops;
- workbench/tool/display area for Workshop;
- physical board for Town Hall/community information;
- garden/produce objects for growing activity;
- furniture/display samples for Home Store.

ProximityPrompt remains an action affordance, not a substitute for the object.

### 5.7 One genuinely playable hero home

The starter/hero home must support a coherent route through recognisable rooms and objects, with visible feedback for interactions. Text-only confirmation is not enough for core home verbs.

The home route should include at minimum:

- enter home;
- sit/rest;
- use one kitchen or water/light interaction;
- use storage/open-close interaction;
- use wardrobe/style preference surface honestly;
- buy/place/store at least one furnishing;
- rejoin with placed state intact.

### 5.8 Visible interaction feedback

Where a player performs a physical verb, the world should respond physically where practical: movement, light, water, open/close state, placement, carried object, material state, animation or concise VFX/audio-ready state.

A toast can confirm an outcome but must not be the only evidence that the ordinary-world verb occurred.

### 5.9 Golden route polish

Maintain one release-defining golden route and improve it before broadening:

`spawn -> understand village -> own home -> home interaction -> Courier pickup -> delivery -> reward -> Home Store -> buy -> place -> revisit/rejoin`

Every element on this route receives the strongest visual and interaction scrutiny.

### 5.10 Visual benchmarks and Studio evidence

Required screenshots/evidence are committed only when captured from the exact candidate. Generated placeholders never satisfy visual evidence.

Automated checks may be green while the release remains visually unaccepted.

## 6. Village Life scope moved from v0.7.0

### 6.1 Repeatable activities

Deepen four ordinary-life activity tracks so each has a real loop rather than a status line.

#### Courier

- physical parcel pickup;
- visible carried parcel state;
- multiple bounded destination choices/routes;
- destination feedback;
- server-owned reward and profession XP;
- anti-repeat/rate controls sufficient to prevent trivial reward spam;
- route result visible in world/HUD feedback.

#### Farmer/Gardener

Preserve existing persisted profession compatibility. Player-facing copy may use friendly gardening language without a schema-breaking rename.

- plant/grow/water/harvest route using existing inventory/content definitions;
- visible plant state where current builders support it;
- server-owned harvest/reward/XP;
- bounded cadence so repeated prompt spam is not the optimal loop.

#### Designer

- earn profession progress from legitimate home-expression actions;
- use authoritative purchase/ownership/placement flow;
- avoid XP farming from repeated invalid or no-op placement;
- make the result visibly change the home.

#### Village Explorer

- authored village trail across distinct neighbourhood/destination landmarks;
- progress based on server-observed visits/proximity, not client-declared completion;
- one bounded route reward/XP outcome;
- discovery should encourage movement rather than menu completion.

If a fourth persisted profession field does not already exist, Village Explorer may remain an activity track in v0.6.2 rather than forcing a schema bump merely for naming symmetry.

### 6.2 Destination depth

#### Town Hall

- village identity/community information through a physical board or interior object;
- no telemetry wall;
- useful reason to visit, such as village trail/community route state.

#### Village Shop

- ordinary low-stakes consumable/resource interaction;
- physical shelves/counter/display language;
- server-owned item ID, price and reward/ownership rules.

#### Home Store

- furniture browsing/purchase tied to physical samples/display language;
- purchase produces owned content through existing server authority;
- placement remains the payoff.

#### Courier Depot

- clear depot silhouette;
- parcel pickup point reads as parcel/logistics object;
- route variety and visible carry state.

#### Workshop

- Tiny Bike/transport and maintenance/customisation identity;
- no pay-to-win transport power;
- workshop should read through tools/bench/vehicle context rather than a generic prompt box.

#### Market / Trading Post

- retain physical trading identity and hardened durable transaction path;
- do not expand high-value trading merely to create more content;
- do not weaken mutation locks/journal/recovery.

### 6.3 Ambient life

Add only restrained deterministic ambient life that is cheap, safe and comprehensible:

- environmental motion, small creatures, or destination routines where existing authored visual quality supports them;
- no generative AI/NPC chat;
- no large NPC simulation system;
- no new ambient character represented by obviously unfinished anonymous blocks;
- performance-sensitive additions remain subject to device evidence.

### 6.4 Home content

Expand production-quality coverage behind the existing definition/placement system rather than inventing another furniture architecture.

Priorities are not raw item count. Priorities are:

1. recognisable silhouettes;
2. useful interaction coverage;
3. coherent room sets;
4. visible feedback;
5. placement quality;
6. mobile/controller usability.

The existing 80+ definition floor remains a catalogue/content contract, not proof that 80 visuals are production-quality.

### 6.5 Social visiting

Improve home visiting without weakening child/family safety:

- preserve owner privacy authority;
- visitors cannot mutate another player's home;
- destination/visit feedback remains filtered and non-free-form;
- no custom private chat layer;
- visiting should expose placed furniture/home expression correctly.

### 6.6 Balancing

Prices, rewards and progression remain server-authored. Avoid pretending balance is proven without playtest/analytics evidence.

Where source-only work adjusts values, keep changes conservative and document them as initial tuning rather than validated economy balance.

## 7. Architecture

Preserve current boundaries:

- `src/shared`: deterministic definitions/rules;
- `src/server`: authority/orchestration/services/builders;
- `src/client`: presentation/input;
- existing ProfileStore/schema/migration model;
- existing RemoteGuard;
- existing item/furniture definitions;
- existing trade journal/mutation locks;
- existing `UiTokens`, scaling, panel/modal/navigation patterns;
- existing release/build evidence system.

Add focused definitions/rules only where a concrete v0.6.2 loop needs them. Do not add Knit, React/Roact, Wally, ECS, NPC frameworks or another state-management layer.

## 8. Data and server authority

Client sends intent/IDs only. Server owns:

- route assignment/completion;
- prices;
- rewards;
- profession XP;
- inventory mutations;
- placement validity;
- visit/privacy decisions;
- trade commit/recovery;
- unlock conditions.

All new remote payloads use existing RemoteGuard patterns for shape, bounds, allow-lists, rate and proximity/ownership checks.

Schema 11 is preferred. Add schema 12 only if a concrete durable player state cannot be represented safely with existing extensible fields/structures. A version bump requires explicit migration tests and fail-closed future-version behavior.

## 9. UI/UX

- world remains visually dominant;
- one coherent compact navigation surface;
- deep information belongs in warm/light panels or diegetic surfaces;
- no hover-only requirement;
- >=44 x 44 effective touch targets;
- phone portrait/landscape actions remain reachable;
- controller focus remains explicit;
- route/activity state appears only when useful;
- error/empty/locked states use short player language rather than internal terminology.

## 10. Error and failure behavior

- invalid activity intent fails closed without reward;
- save/profile unavailable means no mutation/reward;
- duplicate completion is idempotent or rejected;
- distance/ownership failure does not partially mutate state;
- failed purchase leaves coins/inventory unchanged;
- failed placement leaves ownership intact;
- trade failure continues to use existing recoverable transaction rules;
- visual asset resolution failure falls back safely but does not claim production visual acceptance.

## 11. Verification strategy

### Automated

At minimum preserve/extend:

- pure Luau specs;
- `luau-analyze` shared rules/tests;
- StyLua;
- recursive runtime compile;
- release authority;
- v0.6.2 source contract;
- repository/current-version audit;
- shell/PowerShell build contracts;
- release contract;
- Rojo candidate build and manifest/hash;
- focused tests for new deterministic activity rules/reward limits/idempotency.

### Studio / device

Automated green does not satisfy:

- hero destination silhouettes;
- labels-off comprehension;
- starter-home physical interaction quality;
- carried parcel appearance;
- ambient-life visual quality;
- golden route;
- phone portrait/landscape;
- controller traversal;
- FPS/memory/spawn targets.

These remain NOT RUN until observed on the exact candidate.

## 12. Release acceptance

v0.6.2 automated/source candidate is acceptable for a green PR when:

- all required CI checks pass on exact head;
- current authority consistently identifies v0.6.2;
- the former v0.7.0 Village Life scope is represented in v0.6.2 docs/implementation;
- the v0.7.0 roadmap is explicitly reserved for the forthcoming family/girls review;
- all implemented activity mutations remain server-authoritative;
- no new framework/dependency/fake asset ID/credential is introduced;
- Claude visual-craft recommendations are represented by implementation or explicit observation-gated acceptance rows;
- build artifact and traceability manifest are generated.

The PR must still distinguish **green automated/source evidence** from **player-facing visual/device acceptance**. If Studio/device evidence is not run, the PR remains visually unaccepted even when CI is green.

## 13. Anti-scope

Do not pull v0.8 portal expansion or v0.9 production deployment into 0.6.2 merely because adjacent systems are visible.

Do not add:

- combat;
- generic pet/multiplier loops;
- paid power;
- high-value trade expansion;
- a new UI/game framework;
- custom unfiltered chat;
- invented Roblox asset IDs;
- production publishing credentials/actions;
- large NPC simulation;
- a second village/home/content architecture.

## 14. Completion boundary for this execution

This session stops when:

1. the v0.6.2 branch contains the approved implementation/docs/tests;
2. a v0.6.2 PR exists against `main`;
3. the PR's required automated checks are green on its exact head;
4. remaining Studio/device evidence is stated honestly rather than fabricated;
5. no merge is performed unless separately authorised.