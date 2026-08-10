# Visual quality bar

## Recognizability

Every key player-facing object must pass all four checks with explanatory labels hidden:

1. **Silhouette:** can a player identify the category from shape?
2. **Scale:** does it read correctly beside the avatar and nearby props?
3. **Material:** do colour and surface imply its identity and use?
4. **Feedback:** does interaction create visible, audible, or motion feedback?

A missing dimension fails the object contract. Text, prompt labels, neon rings, semantic metadata and arbitrary colour coding cannot compensate.

## Player character bar

The player character is hero-tier content.

Pass:

- existing Roblox avatar/clothing/accessories are preserved when no approved TinyWorld character asset exists;
- any TinyWorld-specific character asset has deliberate silhouette/fit and approved provenance;
- character presentation remains coherent front/side and during movement.

Fail:

- rectangular Part hair attached to the head;
- cuboid Part shoes attached to the feet;
- existing avatar quality is reduced merely so a wardrobe option appears to do something.

## Village bar

- The centre is not a symmetric grid of generic boxes.
- Each civic destination has a distinct roofline/facade/props/approach.
- Four residential neighbourhoods are distinguishable through terrain, planting, paths, clutter and outlook.
- Landmarks remain visible above roofs and routes remain traversable.
- Dressing is deterministic, bounded and safe for mobile readability.
- Daily Fountain reads as a fountain from basin/water/form, not a glowing reward sphere.
- Profession/jobs area reads as a physical jobs board, not a floating career paragraph.
- Village Shop and Home Store remain distinguishable labels-off.

## World-text bar

Pass:

- physical form communicates category first;
- proper names use small diegetic signs where helpful;
- ProximityPrompt copy appears locally when relevant;
- deeper details live in intentional panels.

Fail:

- large always-on-top BillboardGui information rectangles in ordinary village play;
- floating system-language panels such as Home Gate, Home Style, Home Supply, Daily Fountain, Village Fund or Profession Board;
- text is required to explain an otherwise anonymous hero object.

## Home bar

The hero starter/Cosy home visibly contains bedroom, kitchen, living, bathroom, storage and garden life. Interactions attach to recognisable objects and provide bounded state feedback. Higher tiers preserve progression silhouettes.

Priority objects for v0.6.1: bed, wardrobe, sofa, cooker, sink, bath/shower, table/chairs, storage, lamp and garden planter.

## UI bar

Normal play shows compact coins/level progress, one useful current task when needed, one coherent navigation surface, short toasts and contextual prompts.

Pass:

- world remains the dominant visual field;
- Home/Wardrobe/Journal access feels like one game navigation system;
- ordinary panels default to warm/light surfaces with dark text and restrained accents;
- touch/controller/readability contracts remain intact.

Fail:

- full-width website-like navigation/status header;
- permanent developer/system category dashboard;
- multiple large independent launch buttons competing around the viewport;
- gold/orange dominates the entire screen rather than acting as an accent;
- large dark slabs cover the world unnecessarily.

## Hero tier bar

Hero assets include player character presentation, starter home, Town Hall, Village Shop, Home Store, Courier Depot, fountain, jobs board, primary vehicle, portal entrances and signature keepsakes.

A hero object must look production-intentional. Native Roblox parts are allowed only when composed into a convincing object. `TinyWorldArtRole` or other metadata never proves visual craft by itself.

## Evidence

Source guards can prove forbidden mechanisms/names are absent and boundaries exist. They cannot prove composition, recognisability or feel.

For v0.6.1 player-facing work, required observed Studio/device rows block merge-ready status until actually run.

Required benchmark/evidence views are defined by `docs/releases/v0.6.1/acceptance.md` and `docs/quality/benchmarks/v0.6.1/README.md` once created.

## Production-quality gate

This is a pass/fail craft gate, not monetisation.

| Check | Pass | Fail |
| --- | --- | --- |
| Authored silhouettes | Required homes, destinations, vehicles, character presentation and touched objects read from shape with labels off. | A generic block/sign/colour is required to explain the object. |
| Quality materials | Contextual wood, brick, slate, glass, fabric-like treatment, metal, water and foliage reinforce identity. | Arbitrary colour coding/anonymous material dominates a primary object. |
| Composed lighting | Daylight, shadows, warm practicals and restrained glow preserve hierarchy/mobile contrast. | Flat exposure, blown neon or darkness hides routes/silhouettes. |
| Tactile feedback | Input produces bounded motion, light, object state, sound or short toast. | Only text/telemetry changes. |
| Restrained UI | Compact HUD/contextual prompts/modals leave the world dominant. | Website-header/dashboard/telemetry walls dominate normal play. |
| Character quality | Normal Roblox avatar is preserved or improved with approved assets. | Primitive block hair/shoes or inferior fallback is attached. |
| Diegetic world text | Names/details are integrated physically or shown contextually. | Large always-on-top information walls explain ordinary destinations. |
| No arbitrary coloured geometry | Every hero/player-facing object has visible physical/art meaning. | A coloured cube/ring/sphere substitutes for a finished object/verb/destination. |
| Labels-off recognition | Exact Studio route records required uncoached recognitions. | Required category needs floating labels/telemetry/coaching. |

One failed required row fails the v0.6.1 visual craft gate.