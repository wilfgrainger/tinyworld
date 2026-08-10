# Art direction

## Target

TinyWorld uses a warm, storybook-like Roblox-native style: readable proportions, tactile materials, original stylised silhouettes, soft colour families and enough asymmetry/local clutter to feel authored rather than generated.

Native-part construction is a production-safe fallback while approved art assets are absent. It is not permission to use anonymous interaction boxes as finished content.

## Recognisable-object contract

A key player-facing object must remain recognisable with labels hidden. It passes only when all four dimensions are present:

- **Silhouette:** outline communicates category/purpose.
- **Scale:** proportions make sense beside an avatar/room/building.
- **Material:** surface treatment supports identity rather than arbitrary colour coding.
- **Feedback:** prompt plus bounded motion/light/sound/state acknowledges interaction.

Labels clarify names/details; they never rescue unclear geometry.

## Scale language

Use the Roblox avatar as the common ruler.

- internal doors: roughly 1.35-1.6 avatar heights;
- chair seat height: roughly knee/hip level;
- table/counter work surface: roughly waist/chest level;
- beds: clearly avatar-length and wide enough to read as usable;
- civic doors/landmarks may be larger for legibility but must remain plausible;
- hero portal/world props may intentionally break scale, but the scale break must be the fantasy rather than an accident.

Exact production dimensions remain builder-specific; these ratios are the acceptance intent.

## Architectural shape language

Homes:

- pitched/characterful rooflines;
- framed windows with depth;
- readable doors/porches/steps;
- warm facade materials;
- small asymmetries such as planters, awnings, chimneys or local props.

Civic destinations:

- one dominant silhouette cue visible from the approach;
- physical props that communicate function before signage;
- coherent entrance and interaction zone;
- landmark height/shape sufficient to navigate by memory.

## Prop density

Prefer a few readable groups over evenly scattered clutter.

Hero rooms/destinations should contain enough practical objects to imply use: shelves, tools, food, books, parcels, planting, storage or local decoration. Background dressing must never block traversal or turn into collision noise.

## Materials and colour

- warm neutrals for architecture;
- greens/earth tones for landscape;
- destination accents used consistently but not as the only identity cue;
- wood, brick, slate, fabric, glass, metal, water and foliage where physically meaningful;
- reserve Neon/glow for magic, selected/active state and brief feedback;
- do not make every interactive object luminous.

## Lighting

Target readable soft daylight, visible shadow, warm practical lights and restrained magical contrast. Windows/lamps may create warmth; portals/impossible worlds may use richer colour but must preserve silhouettes and text contrast.

Avoid flat uniform light and saturation that turns the village into a glowing UI diagram.

## Detail tiers

### Hero assets

Homes, vehicles, civic buildings, signature furniture, portal landmarks and major keepsakes. Highest silhouette/material/animation/audio care.

### Interactive supporting assets

Ordinary furniture, career equipment and traversal props. Strong recognisability and tactile feedback, moderate detail.

### Background assets

Scenery/ambient dressing. Lower detail acceptable, strict collision/query/performance rules.

## Motion, sound and VFX

Use animation/audio to improve tactility, not to hide weak shapes.

Examples:

- wardrobe/door opens;
- lamp changes light/material state;
- cooker/hob warms;
- water/shower briefly runs;
- leaves/bells/ambient creatures move gently;
- portal arrival/collection has bounded positional sound/VFX.

Particles/lights follow performance budgets. No constant visual fireworks in ordinary village life.

## Physical safety

Decoration is anchored, non-collidable, non-touching and non-queryable. Explicit interaction anchors are queryable. Stable world/plot surfaces remain collision foundations.

## Production asset replacement

Every authored model carries semantic art-role/affordance data. An approved mesh/model may replace a native fallback only if it preserves builder contract, interaction anchors, collision/query safety, recognisability, gameplay authority and performance budget. See `engineering/asset-pipeline.md`.

## Originality and IP

TinyWorld may borrow broad qualities such as warmth, readability, tactile play and adventurous contrast. It must not reproduce identifiable characters, locations, props, logos, names, layouts or distinctive visual/UI expression from Toca Boca, Ready Player One, Disney Dreamlight Valley or another game/film.

All production asset provenance is recorded before use.

## Craft quality gate

A release passes visual craft only when:

- major silhouettes remain recognisable labels-off;
- material choices communicate physical identity;
- lighting supports composition/readability;
- interactions provide tactile acknowledgement;
- normal UI remains restrained;
- no arbitrary coloured cubes/rings exist as finished player-facing content;
- child/family labels-off recognition evidence is recorded;
- production assets, if used, pass provenance and device/performance checks.

Static source review cannot mark this gate PASS.