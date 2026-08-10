# Art direction

## Target

TinyWorld uses a warm, playful Roblox-native visual language with readable proportions, tactile materials, original stylised silhouettes, soft colour families and enough asymmetry/local clutter to feel authored rather than generated.

The target is not photorealism. The target is **clear, charming, physical and intentional**.

Team shorthand:

**Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder.**

These are broad qualities only. TinyWorld must not reproduce identifiable characters, buildings, props, maps, UI, names, logos or other distinctive visual expression from those or any other IP.

## Ordinary life versus impossible life

The village, homes and everyday activities are the grounded layer:

- clear architecture;
- recognisable life objects;
- warm materials;
- readable roads/paths;
- restrained effects;
- obvious entrances and interaction zones.

Impossible worlds are the contrast layer:

- stronger scale breaks;
- richer colour;
- surreal composition;
- authored magical motion;
- restrained glow/VFX;
- visual rules that would feel unusual in the ordinary village.

Do not make ordinary TinyWorld look magical everywhere merely for consistency. Wonder needs contrast.

## Recognisable-object contract

A key player-facing object must remain recognisable with explanatory labels hidden. It passes only when all four dimensions are present:

- **Silhouette:** outline communicates category/purpose.
- **Scale:** proportions make sense beside an avatar/room/building.
- **Material:** surface treatment supports identity rather than arbitrary colour coding.
- **Feedback:** prompt plus bounded motion/light/sound/state acknowledges interaction.

Labels clarify names/details; they never rescue unclear geometry.

A semantic `TinyWorldArtRole` attribute is useful engineering metadata. It is not visual evidence.

## Hero, supporting and background tiers

### Hero

Highest craft priority:

- player character presentation;
- starter/Cosy home;
- Town Hall;
- Village Shop;
- Home Store;
- Courier Depot;
- daily fountain;
- profession/jobs board;
- primary vehicles;
- portal entrances/landmarks;
- signature keepsakes.

A hero object cannot ship as anonymous fallback geometry simply because external art is unavailable.

### Interactive supporting

Furniture, activity equipment, parcels, gardening tools, shop fixtures and traversal props. They may use simpler native-part construction, but must remain immediately recognisable and tactile at interaction distance.

### Background

Terrain, fences, simple foliage, distant structures and ambient dressing. Simpler native-part construction is acceptable within collision/performance budgets.

## Native-part rule

Native Roblox parts are a valid production medium when they are composed into a convincing object. They are not a licence to use one coloured cuboid as the finished noun.

A native-part hero should use enough shape/material hierarchy to communicate what it is from normal play distance. Prefer a few meaningful shape groups over dozens of tiny detail parts.

## Character presentation

The player character is hero-tier content.

Hard rules:

- do not weld primitive rectangular Part hair to the head;
- do not weld cuboid Part shoes to the feet;
- do not degrade the player's existing Roblox avatar merely to demonstrate that a wardrobe system exists;
- when no approved TinyWorld character asset exists, preserve the player's Roblox avatar/accessories/clothing and retain style preference data for future approved assets;
- any production TinyWorld hair/clothing/accessory asset enters through the asset pipeline with provenance/approval.

No visual change is better than a visibly inferior character fallback.

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
- framed windows with visible depth;
- readable doors/porches/steps;
- warm facade materials;
- small asymmetries such as planters, awnings, chimneys or local props.

Civic destinations:

- one dominant silhouette cue visible from the approach;
- physical props that communicate function before signage;
- coherent entrance and interaction zone;
- landmark height/shape sufficient to navigate by memory;
- interiors/shop windows where useful to communicate purpose.

A shop cannot be the same box as another shop with different floating text.

## World text and signage

### Forbidden in ordinary village play

- large always-on-top BillboardGui information rectangles;
- floating paragraphs listing features/prices/status;
- developer/system labels such as Home Gate, Home Style, Home Supply, Daily Fountain, Village Fund or Profession Board used as the primary world identity;
- text that exists only because the 3D object is unclear.

### Allowed

- short ProximityPrompt action/object copy when the player is close enough to interact;
- small text integrated into a physical shop sign, plaque, noticeboard or jobs board;
- owner/name plates where identity genuinely requires text;
- Studio-only diagnostics;
- rare fantasy-specific floating text when floating text itself is the authored magical effect.

Diegetic signage should use physical boards/surfaces. `AlwaysOnTop` is not the default for world signs.

## Landmark specifics

### Daily fountain

Must read as a fountain through basin + pedestal/spout + water. Reward state is contextual interaction, not a glowing sphere with explanatory copy.

### Profession/jobs board

Must read as a jobs/notice board through a frame, pinned/card-like surfaces and physical context. A local prompt may open job choice; floating career lists are not the landmark.

### Home Store

Must communicate homewares/furniture through display furniture, showroom/window/counter language before text.

### Courier Depot

Must communicate delivery work through parcels, sorting storage, loading awning/cart/route-board context.

## Prop density

Prefer a few readable groups over evenly scattered clutter.

Hero rooms/destinations should contain enough practical objects to imply use: shelves, tools, food, books, parcels, planting, storage or local decoration. Background dressing must never block traversal or become collision noise.

## Materials and colour

- warm neutrals for architecture;
- greens/earth tones for landscape;
- destination accents used consistently but not as the only identity cue;
- wood, brick, slate, fabric-like treatment, glass, metal, water and foliage where physically meaningful;
- reserve Neon/glow for magic, selected/active state and brief feedback;
- do not make every interactive object luminous;
- gold/orange is an accent, not the dominant interface/world fill.

## Lighting

Target readable soft daylight, visible shadow, warm practical lights and restrained magical contrast. Windows/lamps may create warmth; portals/impossible worlds may use richer colour but must preserve silhouettes and text contrast.

Avoid flat uniform light and saturation that turns the village into a glowing UI diagram.

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

TinyWorld may borrow broad qualities such as readability, warmth, tactile play and adventurous contrast. It must not reproduce identifiable characters, locations, props, logos, names, layouts or distinctive visual/UI expression from Brookhaven, Toca Boca, Ready Player One, Disney Dreamlight Valley or another game/film.

All production asset provenance is recorded before use.

## Craft quality gate

A release passes visual craft only when:

- major silhouettes remain recognisable labels-off;
- hero characters/objects look intentional rather than placeholder/fallback;
- material choices communicate physical identity;
- lighting supports composition/readability;
- interactions provide tactile acknowledgement;
- normal UI remains restrained and world-first;
- no primitive Part hair/shoes exist in normal play;
- no large ordinary-world information walls exist;
- no arbitrary coloured cubes/rings exist as finished player-facing content;
- child/family labels-off recognition evidence is recorded where required;
- production assets, if used, pass provenance and device/performance checks.

For player-facing releases from v0.6.1 onward, static source review cannot mark this gate PASS and required visual rows block merge-ready status until observed.