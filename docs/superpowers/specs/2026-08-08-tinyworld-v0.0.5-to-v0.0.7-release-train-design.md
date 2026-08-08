# TinyWorld v0.0.5–v0.0.7 Release Train Design

**Date:** 2026-08-08  
**Status:** Working design for implementation  
**Branch target:** `main`  
**Product:** TinyWorld persistent Roblox life sandbox

## North star and review conclusion

TinyWorld’s product north star remains:

> Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.

The review of `main` against the original proposal confirms that the functional direction is still correct. The current slice already expresses the important promises: a personal identity, a private home in a public village, daily work and rewards, progression, gardening, transport, trading, a portal route, living-world discoveries, and a village boundary of woods, cliffs, and sea.

The material gap is presentation quality. The functional landmarks currently read as a coloured primitive-first prototype. The original proposal asks for a cosy, colourful, storybook-like diorama that makes a player understand the game quickly and want to keep playing. The next three releases therefore improve the existing promise in sequence rather than adding unrelated systems:

1. Make the existing world beautiful and legible.
2. Make persistence safe enough for larger sessions.
3. Make the result consistent, measurable, and ready for a girls-at-scale playtest.

The persistence audit also found a concrete reliability risk: many services call `ProfileStore.save` immediately after a mutation, while shutdown loops synchronously over all profiles. The earlier Studio warning that a DataStore request was added to a queue is consistent with this design. Queue/session hardening is therefore a required part of v0.0.6, not optional polish.

## Design assumption

The user was offered three v0.0.5 presentation directions and did not provide a contrary selection while asking the active goal to continue. This design uses the recommended **storybook village diorama** direction as the working assumption. It is the closest match to the supplied proposal imagery and the girls’ feedback that the functional elements are beginning to work but the world needs a much higher visual bar. The direction can be superseded before implementation if the user explicitly chooses another lead.

## Release boundaries

### v0.0.5 — Storybook beautification (cosmetic-only)

The purpose of v0.0.5 is to improve first impression, spatial readability, and emotional desirability without changing the game rules.

#### In scope

- Establish a reusable visual language for the village: warm materials, clear silhouettes, layered façades, rounded readable signage, intentional colour coding, and restrained magical accents.
- Improve civic architecture and dressing around the fountain, Town Hall, Village Shop, Courier Depot, Transport stand, Trading Post, and portal.
- Improve houses and plots with façade layering, roof/trim details, entrances, paths, gates, fences, gardens, flowers, trees, owner-sign space, and a stronger public/private read.
- Improve the arrival route from fountain to road spokes and destination silhouettes.
- Improve the woodland, cliff, sand, and sea transitions so the boundary reads as an intentional frame around the village.
- Improve lighting, atmosphere, water/landmark accents, and colour grading without requiring external assets.
- Improve the HUD’s visual hierarchy and responsive readability while preserving its server-fed attribute contract.
- Add deterministic cosmetic budgets so the visual pass remains bounded by player capacity and does not create unreviewed object growth.
- Keep all gameplay prompts, reward values, progression thresholds, profile schema, ownership rules, privacy rules, trade rules, and transport semantics unchanged.

#### Explicit non-goals

- No new currencies, rewards, XP rules, jobs, products, gamepasses, or Robux wiring.
- No new persistent profile fields unless a compatibility-preserving presentation need is proven; cosmetic builders should be data-free.
- No free-form player building or decoration persistence.
- No imported asset-pack pipeline or unverified third-party assets.
- No cars, planes, boats, pets, elections, seasonal events, or second portal world.
- No client authority over economy, ownership, privacy, or progression.

#### Acceptance bar

A first-time player should be able to answer these questions in the opening view without instruction:

- Where am I?
- Where is my home?
- Where can I go today?
- Which place is the shop, job, transport, social space, and portal?
- What looks special enough to explore?

The scene must feel more like a small illustrated world than a collection of standalone signboards. The result must remain readable on a smaller viewport and must not introduce visible flicker, z-fighting, prompt obstruction, or unbounded decorative geometry.

### v0.0.6 — Queue, session, and scale foundation

The purpose of v0.0.6 is to make saved progress trustworthy and make larger multiplayer testing meaningful.

#### Persistence contract

- `ProfileStore` becomes the single authoritative persistence adapter.
- Each loaded profile has an in-memory dirty/version state and one bounded pending-save record rather than one DataStore request per mutation.
- Repeated mutations coalesce into the latest normalized snapshot.
- Saves are attempted on a short debounce, on explicit high-value checkpoints, on player removal, and during bounded shutdown flushing.
- Transient failures use capped exponential backoff with jitter; a failed attempt remains visible in diagnostics and does not silently discard the in-memory profile.
- A server session token is acquired with `UpdateAsync` before a profile is considered writable.
- A profile with a live competing session is not overwritten or replaced with fresh data. Loading fails closed with a safe retry/kick route.
- Session release is conditional on the owning token and is attempted only after the final save succeeds or after the failure is surfaced as unresolved.
- `BindToClose` flushes pending profiles within an explicit deadline and reports which profiles were unresolved.
- Service call sites request a save/checkpoint through the adapter; they do not directly issue DataStore operations.

#### Scale contract

- World geometry is built once per server, not once per player.
- Plot, boundary, decoration, prompt, and label budgets are explicit and testable.
- `Players.MaxPlayers` feeds layout capacity and is not merely accepted as an unused argument.
- Server & Clients tests cover the supported Studio capacities available to the place, with a documented distinction between local multi-client evidence and production-scale evidence.
- Runtime diagnostics expose queue depth, save state, session state, and build counts without exposing profile contents or secrets.

#### Explicit non-goals

- No external backend or HTTP service.
- No cross-server session coordination beyond the DataStore lease contract.
- No claim that Studio Server & Clients proves production latency, memory, or cross-server behaviour.
- No rewrite of the existing gameplay services beyond routing their persistence requests through the hardened adapter.

### v0.0.7 — Consistency and girls-at-scale readiness

The purpose of v0.0.7 is to make the slice worthy of a structured external playtest and produce evidence that can guide the next product decisions.

#### In scope

- A final consistency pass across homes, civic areas, boundary landmarks, transport, portal, prompts, and HUD.
- Removal of prototype residue: duplicate labels, construction-like boxes, awkward collision edges, exposed surfaces, blocked prompt zones, and inconsistent colour/material choices.
- A visible Tiny Bike presentation that reads as a bike in-world while preserving the existing mount/speed semantics.
- A deterministic, clearly separated playtest reset/test-profile route that cannot be mistaken for production persistence.
- A structured feedback capture template for first impression, comprehension, desire, confusion, replay intent, social behaviour, and requested next content.
- A repeatable scale-playtest checklist covering functional path, persistence path, session conflict, queue health, and visual/performance observations.
- Evidence separation between source/tests, Studio runtime, published place, multiplayer session, and qualitative feedback.

#### Exit condition

v0.0.7 is ready for the girls-at-scale session only when local verification is green, the current Rojo-synced Studio build has been played, the published place has been confirmed at the intended commit, and the evidence checklist has named owners for any remaining runtime-only checks.

## Cosmetic architecture

The visual pass must preserve the current source boundaries:

- `src/shared` holds palette tokens, layout constants, deterministic visual budgets, and any Roblox-service-free presentation rules.
- `src/server` owns world construction, lighting configuration, authoritative prompts, and server-created cosmetic geometry.
- `src/client` owns HUD presentation and read-only player attributes.
- Existing service contracts remain stable unless a test demonstrates a defect that is necessary to preserve the current gameplay contract.

Preferred implementation shape:

- Extend `VisualPalette` with semantic tokens rather than scattering new colours.
- Extend `VisualTheme` with a bounded, consistent lighting/atmosphere configuration.
- Introduce focused visual helper functions or builders for façade layers, roof trim, windows, gardens, trees, signs, and civic dressing.
- Keep decorative parts anchored and non-interactive unless they are an existing gameplay surface.
- Give each decorative model a predictable name and parent so Studio inspection and cleanup remain possible.
- Keep geometry away from prompt anchors and player spawn/route volumes.
- Use stable surfaces and separated layers to avoid z-fighting and the previously observed grass/plot-border flicker.

## Persistence architecture

The hardened adapter should make these states explicit:

```text
unloaded -> loading -> active/clean -> active/dirty -> queued -> saving
                                      ^                 |
                                      |                 v
                              save failed <--- retry/backoff

active -> releasing -> released
loading -> conflict/failed (fail closed)
```

Required invariants:

1. At most one local active profile object exists for a player in a server.
2. A server can write only while it owns the session token for that profile.
3. A save request never causes a newer in-memory mutation to be overwritten by an older snapshot.
4. A transient DataStore error never becomes a fresh default profile.
5. A player is not fully released from memory until the release sequence has made a bounded final save attempt.
6. A shutdown cannot spin indefinitely on one profile or issue an unbounded number of writes.
7. Queue diagnostics are observable without turning every gameplay action into a DataStore request.

## Backlog and justification

### Must ship before the girls-at-scale gate

- Cosmetic scene language and first-impression route — directly addresses the original visual brief and girls’ feedback.
- Plot/home identity dressing — reinforces “every player belongs somewhere” and “your house tells your story.”
- Civic readability and destination silhouettes — makes the daily loop self-explanatory.
- Boundary transition pass — makes “explore impossible worlds” visually credible.
- Profile session lease — prevents concurrent sessions from overwriting each other.
- Coalescing save queue and retry policy — directly addresses the observed DataStore queue warning.
- Bounded shutdown flush — protects progress when Studio/server sessions end.
- Capacity/build budgets — makes scale claims measurable.
- Studio multi-client route and evidence template — prevents a green unit suite being mistaken for live-scale proof.

### Immediately after the gate

- Qualitative retention experiments and rotating weekly routes.
- Safer party/visit flow and clearer social affordances.
- More expressive homes and a bounded décor inventory.
- A second portal world only after the first route demonstrates repeatable demand.

### Later, dependency-gated

- Expanded professions and transport.
- Real cosmetic monetisation after desirability and fairness evidence.
- Live content configuration and rollback.
- Family safety, moderation, reporting, and operational controls before public scale.
- Launch-candidate performance and abuse testing before v1.0.0.

### Deliberately rejected for this train

- Pay-to-win progression.
- Fake product/gamepass IDs.
- Ads before the core loop and safety model are proven.
- Large imported assets that obscure ownership, licensing, or performance costs.
- Systems added only because they sound broad rather than because they strengthen the north star.

## Roadmap through v1.0.0

| Release | Scope | Exit evidence |
| --- | --- | --- |
| 0.0.5 | Storybook cosmetic overhaul | Before/after Studio evidence, visual guards, gameplay regression suite, no persistence/schema drift |
| 0.0.6 | Persistence queue/session hardening and scale foundations | Queue/session tests, failure tests, bounded save diagnostics, multi-client build-budget evidence |
| 0.0.7 | Consistency pass and girls-at-scale readiness | Published-place verification, clean Studio route, evidence-ready playtest plan |
| 0.0.8 | Return loop: weekly routes and rotating tasks | Repeat-session feedback and retention signals without reward inflation |
| 0.0.9 | Social slice: parties, visits, safer trade, shared activities | Multiplayer comprehension and abuse-boundary evidence |
| 0.1.0 | Invited public alpha | Recovery, observability, onboarding, and small-cohort operations |
| 0.2.0 | Second portal world | Reusable world contract and repeatable portal content pipeline |
| 0.3.0 | Home expression | Bounded rooms, décor, gardens, and home showcase with persistence tests |
| 0.4.0 | Profession expansion | A small number of distinct, fair ways to become better |
| 0.5.0 | Traversal expansion | Additional vehicles only where they create destinations and stories |
| 0.6.0 | Fair cosmetic economy | Real Roblox products, clear value, no gameplay power advantage |
| 0.7.0 | Live content tools | Safe rotation, rollback, and content verification |
| 0.8.0 | Safety and family controls | Privacy defaults, reporting, moderation, and operational response |
| 0.9.0 | Launch candidate | Peak-load, persistence, economy, abuse, and recovery audit |
| 1.0.0 | Durable launch | Stable core loop, safe social play, fair economy, repeatable content, and sustainable operations |

## Verification and handoff evidence

Each release must preserve the distinction between levels of proof:

- Static source guards prove contracts such as Roblox-safe materials and bounded builders.
- Luau CLI tests prove deterministic rules and persistence queue/session models.
- Compile/analyze checks prove syntax and type-level compatibility.
- Studio Play proves local runtime integration with the current Rojo sync.
- Server & Clients proves bounded local multiplayer behaviour only.
- Publish output proves that Studio saved the current place; it does not by itself prove the live experience matches until the published target is reopened/verified.
- The girls’ session proves qualitative product response, not production-scale capacity.
- Production-scale and cross-server claims remain unproven until separately exercised.

The v0.0.7 playtest handoff will include:

1. Commit SHA and branch state.
2. Exact Rojo/Studio launch steps.
3. Functional route: onboarding → home → daily reward → garden → courier job → shop → transport → boundary → portal → trade.
4. Persistence route: mutate → stop → rejoin → verify → session-conflict attempt.
5. Scale route: supported Server & Clients counts, observed queue depth, errors, and visual/performance notes.
6. Qualitative questions and a place to record verbatim player feedback.
7. Known limits and any checks that still require a human in Studio.

