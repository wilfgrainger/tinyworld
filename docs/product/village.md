# Village

## Scale and membership

One TinyWorld gameplay server displays and supports at most **sixteen resident homes**, and the Roblox place configuration must use a maximum player count of **16 or fewer**. Every admitted gameplay player receives one resident plot/home.

The server also fails closed if configuration drift ever allows a player beyond the generated residential capacity: that player is asked to rejoin another village rather than entering a broken no-home onboarding path. “Visitor” means an admitted resident visiting another player's home, not an overflow seventeenth resident.

A future multi-village or overflow-home architecture may raise this limit only through an explicit product/engineering design. Server capacity must never silently enlarge the sixteen-home residential composition.

## Visual identity

The ordinary village is the grounded/readable half of TinyWorld's visual identity. It should feel warm, playful and inhabited without becoming a glowing systems diagram.

The target combines broad qualities only:

- Brookhaven-level destination/navigation readability;
- Toca-style tactile object and interior clarity;
- original TinyWorld architecture and place identity;
- portals/impossible worlds carry the strongest Ready Player One-style wonder/scale contrast.

## Composition

The centre holds Town Hall, fountain, Village Shop, Home Store, Courier Depot, Transport Workshop, market/trading post and portal landmarks. Each destination must communicate function physically before signage.

Residential plots remain evenly distributed across four seeded neighbourhoods:

| Neighbourhood | Identity | Homes |
| --- | --- | ---: |
| Meadow Lane | Gardens, stream, bridge, meadow planting | 4 |
| Harbour Row | Descending paths, dock views, boats, fishing clutter | 4 |
| Woodland Rise | Tree canopy, rocks, fireflies, narrower paths | 4 |
| Orchard End | Orchard trees, vegetable beds, nursery green | 4 |

## World-text rule

Ordinary village destinations may not use large always-on-top BillboardGui information rectangles as their primary identity.

Use this order:

1. architecture/silhouette;
2. props/material/context;
3. physical/diegetic sign for a proper name when useful;
4. contextual ProximityPrompt when the player is near enough to act;
5. deeper panel only when multiple choices/details are required.

Floating system-language panels such as Home Gate, Home Style, Home Supply, Daily Fountain, Village Fund or Profession Board are prototype language and are forbidden in the finished ordinary village.

## Destination contracts

### Town Hall

Purpose: village identity/community information and future bounded events.

Physical cues: civic facade, doorway/steps, framed windows, a dominant roof/tower/clock cue, notice/community board and fountain/plaza relationship.

Verbs: inspect community board, learn village event/identity state. Do not turn Town Hall into a telemetry dashboard.

### Village Shop

Purpose: ordinary low-stakes consumables/resources.

Physical cues: shopfront, awning/windows, shelves/crates/counter and visible stock arrangement.

Verbs: browse/buy server-priced ordinary stock. Any rotating stock remains server-defined and is introduced only with live-ops/analytics approval.

The Village Shop must not be visually interchangeable with Home Store except for different text.

### Home Store

Purpose: furniture/room expression.

Physical cues: recognisable furniture displays/showroom/store counter, a room vignette or homewares display in/near the shopfront.

Verbs: browse, purchase, then place a physical owned item at home. The purchase must not terminate as a menu-only badge.

### Courier Depot

Purpose: replayable ordinary-life career route.

Physical cues: parcels, sorting shelves, loading awning, depot counter, route board/handcart/vehicle props.

Verbs: collect visible parcel, travel to destination, deliver, receive bounded server reward/career XP.

### Workshop

Purpose: bikes/boats/transport expression and maintenance/customisation.

Physical cues: tools, workbench, vehicle silhouettes, parts storage and a clear open work/garage area.

Verbs: inspect/buy/activate allowed transport and visual maintenance/customisation. Paid power advantages are not part of the target state.

### Market / Trading Post

Purpose: safe physical player exchange and village market character.

Physical cues: stalls/tables/crates/clearly separated trade sides.

Verbs: opt in, choose bounded offer, confirm, exchange through server authority. Unique/high-value trading remains disabled until durable recovery evidence passes.

### Daily Fountain

Purpose: a memorable daily-return landmark and reward interaction.

Physical cues: an actual fountain with basin, central pedestal/spout, visible water and plaza context.

Verb: collect the available daily reward through a local interaction prompt. Reward explanation/status belongs in short feedback, not a floating information wall.

A glowing sphere by itself does not satisfy this contract.

### Profession / Jobs Board

Purpose: communicate available ordinary-life careers.

Physical cues: timber/metal board frame, pinned/card-like surfaces, small visual job cues/icons and placement near an appropriate civic/work area.

Verb: choose or inspect a job through a local prompt/panel.

Do not float a paragraph such as `Courier · Farmer · Designer` over the street as the landmark.

### Village Fund

Purpose: bounded civic contribution.

Physical cues: contribution box/plaque/board integrated into Town Hall/plaza context.

Verb: contribute through server authority and receive short feedback.

Do not present Village Fund as an always-on-top system-status panel.

## Ordinary-life floor

A player who ignores portals must still be able to:

- decorate/use home;
- garden;
- deliver parcels;
- visit civic destinations;
- travel;
- change appearance without degrading their Roblox avatar;
- visit another home safely;
- collect/earn ordinary resources;
- make visible persistent progress.

If the village feels like an interval between portals, the product pillar fails.

## Ambient life

Start small and authored. A handful of birds/cats/simple workers or shop characters with deterministic bounded movement adds more life than a large AI/NPC swarm.

Ambient characters:

- do not require generative AI;
- do not introduce unrestricted chat;
- do not control economy/progression;
- remain within performance budgets;
- use recognisable shapes and simple routines.

## Navigation/time targets

The village is compact. A player should be able to reach the centre from any resident neighbourhood without a long empty commute. Exact travel times are measured in Studio/device playtests, but civic destinations must remain visually discoverable and ordinary traversal must not require teleport menus or floating instruction panels.

## Layout rules

- deterministic placement with the fixed release art seed;
- explicit plot neighbourhood/rotation/setback data;
- stable ground/plot bases as collision foundation;
- bounded dressing variants;
- no plot overlap;
- traversable paths for avatar/touch/controller play;
- civic landmarks visible enough to learn by memory;
- decoration non-touch/query unless explicitly interactive;
- hero destinations use enough silhouette/material/prop hierarchy to remain readable without explanatory labels.

## Authority

World builders return named semantic anchors/models. Services validate and execute progression, contribution, profession, plot, privacy, visit, trade, transport, portal and save mutations on the server.

## Evidence

v0.6.1 Studio/device playtesting records:

- all admitted players receive a resident home at the configured capacity;
- a deliberate capacity-misconfiguration test fails closed rather than producing a no-home player;
- unprompted destination recognition with explanatory labels hidden;
- traversal obstruction/time issues;
- ordinary-life activity comprehension;
- ambient-life performance;
- two-client visit/trade behaviour where changed/relevant;
- labels-off recognition of Town Hall, Village Shop, Home Store, Courier Depot, fountain and jobs board;
- screenshots of the exact candidate linked from the v0.6.1 acceptance record.

For v0.6.1, required player-facing visual evidence blocks merge-ready status until observed.