# Experience pillars

Each pillar names an observable player behaviour, a failure condition and an evidence method. Content count or source presence alone does not satisfy a pillar.

## Build your life

**Promise:** the home is a playable expression of progress, not a menu backdrop.

Observable behaviour:

- player identifies/enters recognisable rooms;
- uses physical furniture/appliances;
- buys/owns/places/stores items;
- sees saved changes after rejoin;
- saves character/style preferences through a wardrobe/home-life surface without TinyWorld degrading the Roblox avatar baseline.

Failure: decorating is menu-only, placed objects are anonymous geometry, primitive character fallback is forced, or persistent changes do not survive safely.

Evidence: first 10/30-minute playtest, save/rejoin route, labels-off home-recognition route, character screenshot where appearance changes are in scope.

## Belong to a village

**Promise:** the village is small enough to learn, varied enough to remember and readable without a layer of floating system panels.

Observable behaviour:

- player can navigate among distinct civic destinations/neighbourhoods;
- recognises destination categories from architecture/props/context before proper-name text;
- completes ordinary-life activities without portal dependency;
- encounters bounded ambient life;
- visits another home with predictable privacy rules.

Failure: the village feels like a lobby, every destination requires waypoint/label decoding, or ordinary systems are represented primarily by always-on-top information walls.

Evidence: unprompted labels-off navigation/playtest observations, benchmark screenshots, two-client privacy/visit route.

## Explore impossible worlds

**Promise:** portals deliver authored contrast and feed ordinary life.

Observable behaviour:

- each world has an obvious visual rule unlike the grounded village;
- player engages a world-specific traversal/activity mechanic;
- discovers a secret or optional detail;
- completes a bounded objective;
- returns with a keepsake/resource/home payoff.

Failure: a portal is only a reskinned collection room, creates a disconnected progression game, or ordinary village content is so uniformly fantastical that portals have no visual contrast.

Evidence: Studio route for all four worlds plus return-home payoff observation and portal-entrance visual benchmarks.

## Discover secrets

**Promise:** attention to the environment produces gentle surprise.

Observable behaviour:

- player notices landmarks/environmental clues;
- can find optional collectibles or hidden interactions;
- builds a meaningful collection rather than raw counters.

Failure: discoveries exist only as UI notifications, floating explanations or unexplained telemetry.

Evidence: uncoached playtest notes and collection/places journal state.

## Feel safe and respected

**Promise:** TinyWorld protects player trust and avoids coercive design.

Observable behaviour:

- server rejects hostile price/reward/ownership/placement/trade input;
- save failures fail closed;
- home privacy behaves predictably;
- free character/style identity remains meaningful without visibly inferior forced fallback geometry;
- purchase-like UX is reserved for actual ownership transactions.

Failure: the client can mint state, inaccessible saves are replaced, social permissions are ambiguous, gameplay power is monetised or free/default identity is intentionally degraded.

Evidence: automated validator tests, hostile remote route, multi-client privacy/trade route and family playtest.

## Feel good in the hands

**Promise:** core play is readable and tactile on touch, mouse and controller.

Observable behaviour:

- >=44x44 effective touch targets;
- no hover-only critical action;
- deliberate controller focus;
- one coherent compact normal-play navigation surface;
- physical interactions acknowledge input through object state/motion/light/sound/short feedback;
- ordinary phone play remains readable and performant;
- the HUD leaves enough visual space for the world to communicate.

Failure: clipped UI, controller traps, per-frame network spam, interaction feedback exists only in text, or permanent HUD/dashboard chrome overwhelms the play space.

Evidence: phone/controller device matrix, benchmark screenshots and performance route.

## Feature test

A feature may ship only when it strengthens at least one pillar without weakening server authority, recognisability, world-first comprehension, mobile usability, safety or performance budgets. Features that merely increase counters, telemetry, labels or database surface do not meet the bar.

For player-facing visual releases from v0.6.1 onward, required observed Studio/device evidence is part of pillar acceptance rather than a post-merge aspiration.