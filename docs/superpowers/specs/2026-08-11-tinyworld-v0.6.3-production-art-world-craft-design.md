# TinyWorld v0.6.3 Production Art & World Craft — design

**Status:** approved for implementation from the user-approved visual brief and 11 August 2026 Studio screenshots.  
**Date:** 11 August 2026  
**Base:** merged v0.6.2 Village Life & Visual Craft  
**Release:** v0.6.3 Production Art & World Craft  
**Profile schema:** 11. No persistence migration is planned.

## 1. Why this release exists

v0.6.1 and v0.6.2 removed several prototype mechanisms and deepened ordinary-life gameplay, but exact Studio screenshots of the merged v0.6.2 experience show that the ordinary village still reads as a development/test map rather than a polished life-sandbox world.

The failure is not primarily missing gameplay. It is production art, architecture, spatial composition and lighting.

Observed v0.6.2 screenshot failures include:

- houses and civic buildings dominated by rectangular wall masses and oversized flat/slab roofs;
- bright cyan window rectangles with little depth or believable glazing/trim hierarchy;
- large glowing yellow spheres used as ordinary practical lights/landmarks;
- enormous flat grass areas and long straight path/road geometry;
- grid-like/repetitive plot composition visible from elevation;
- civic spaces with large empty paved areas and isolated primitive objects;
- marketplace/shops that are recognisable but still read as assembled block recipes;
- weak terrain/elevation hierarchy and little authored framing of approaches;
- sparse environmental dressing and insufficient planting/fence/hedge/street-furniture clusters;
- portals and practical landmarks visually competing through simple saturated primitive shapes;
- an ordinary village whose source contracts are stronger than its rendered result.

Positive v0.6.2 evidence is retained:

- the primitive character hair/shoe fallback is gone;
- the Roblox avatar is coherent;
- the compact HUD is substantially improved;
- ordinary floating information walls are substantially reduced;
- the world has more physical interaction content than v0.6.0;
- the palette is directionally coherent.

v0.6.3 therefore freezes ordinary gameplay scope and spends engineering/art budget on making the existing village look like the product brief.

## 2. Visual north star

The approved shorthand remains:

**Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder, expressed as original TinyWorld design.**

This is a principles-only reference. TinyWorld must not copy identifiable buildings, maps, props, characters, UI, logos, names or other distinctive expression from those or any other IP.

The concept board created from the v0.6.2 code/brief is an **aspirational art-direction benchmark**, not release evidence. The next Studio screenshots should visibly look like the same product family as that benchmark even though exact geometry/details will differ.

## 3. Release outcome

When a player spawns in v0.6.3, the first impression should be:

> “This is a charming little village I want to explore and live in.”

not:

> “This is a Roblox test map containing working systems.”

The ordinary village must read as an authored place at ground level and from a moderate elevated camera.

## 4. Hard visual acceptance rules

### 4.1 Architecture

Hero homes and civic buildings may not use one oversized flat rectangular roof slab as the dominant silhouette.

Required architectural vocabulary where appropriate:

- pitched, stepped or layered rooflines;
- eaves/overhangs in believable proportion;
- roof ridges/gables/dormer-like secondary masses where they improve silhouette;
- visible entrance hierarchy;
- porches/steps/canopies/awnings with physical support;
- framed/recessed windows with sill/header/trim depth;
- doors distinct from windows;
- foundation/plinth/base detail;
- chimneys, vents, gutters/downpipes or equivalent small architecture details selectively;
- facade material hierarchy rather than one uninterrupted wall material;
- local asymmetry such as planters, signs, benches, crates, baskets, flower boxes or side extensions.

A building should still be recognisable when its sign is hidden.

### 4.2 Windows and doors

Windows may not be bright cyan rectangles pasted onto a wall.

Use:

- glass with restrained sky tint/transparency;
- frames and recessed depth;
- mullion/pane cues selectively;
- sill/trim;
- warm interior-light suggestion where useful;
- proportion appropriate to the building.

Doors require readable frame/threshold/handle or equivalent entry cues.

### 4.3 Lighting

Ordinary practical lighting may not be represented by a naked glowing sphere.

Use recognisable fixtures:

- lantern body/housing;
- post/bracket/arm;
- warm PointLight/SurfaceLight with bounded range/brightness;
- emissive material only inside the fixture;
- restrained bloom/glow.

Yellow/neon spheres are reserved only where a sphere is genuinely the authored object/effect.

### 4.4 Terrain and village composition

The village may not read as plots laid on one huge green plane.

Use the existing deterministic builder model to add authored variation:

- gentle height changes/terraces/berms where safe;
- curved/segmented paths rather than only long straight strips;
- path-edge material transitions;
- hedges/fences/walls to define gardens and streets;
- clustered trees rather than evenly spaced lollipops;
- flower/plant groups;
- pocket greens, seating areas and small civic gardens;
- rock/stream/orchard/woodland clusters tied to neighbourhood identity;
- visual framing of the approach to Town Hall/fountain/shops;
- reduced dead empty grass while preserving traversal/performance.

Four neighbourhoods must be distinguishable from a screenshot without reading their names.

### 4.5 Civic centre

The centre should compose around memorable landmarks rather than scattered systems.

Required hierarchy:

1. Town Hall / civic silhouette;
2. real fountain/plaza composition;
3. distinct Village Shop and Home Store shopfronts;
4. Courier Depot with parcel/loading language;
5. Workshop with garage/workbench/vehicle language;
6. Market / Trading Post with coherent stall cluster;
7. portals visually secondary until approached, except where intentionally framed as the mystery layer.

Large empty yellow/coloured platforms fail unless the physical object is intentionally a platform with a believable function/material.

### 4.6 Home exterior

At least the starter/hero home must look production-intentional from all normal player-facing angles.

Required:

- characterful roof silhouette;
- believable window/door depth;
- porch/step/entry composition;
- warm practical exterior light fixtures;
- foundation and facade hierarchy;
- small garden/planter/fence/path relationship;
- no giant roof overhang swallowing the facade;
- no repeated facade rectangles that make the home look generated from a primitive template.

### 4.7 Interiors

Hero-home interior should read as rooms made for living rather than furniture dropped into a shell.

Use:

- room zoning;
- wall/floor material variation kept coherent;
- warm local lights;
- furniture clusters that imply use;
- shelves/counters/storage details;
- window placement that relates to exterior;
- enough negative space for traversal without cavernous emptiness.

### 4.8 Props and vegetation

Avoid evenly scattered single primitives. Prefer authored groups:

- bench + lamp + planter;
- tree + hedge + flowers + rock;
- market stall + crate + basket + canopy;
- courier rack + parcels + cart/route board;
- workshop bench + tools/parts + bike/vehicle context.

Props remain bounded for mobile performance and non-query/non-touch unless interactive.

## 5. Scope

v0.6.3 is intentionally narrow.

### In scope

- ordinary-village world composition;
- residential exteriors and neighbourhood dressing;
- civic building silhouettes/facades;
- starter/hero home exterior/interior presentation;
- fountain, lamps, benches, planters, fences, hedges, paths, trees and environmental clusters;
- distinct physical Home Store/Village Shop/Courier/Workshop/Market presentation;
- portal-entrance ordinary-village framing where required;
- lighting/environment settings used by the ordinary village;
- visual-builder architecture/refactoring needed to make these changes maintainable;
- source guards that reject known bad visual mechanisms;
- docs/evidence contracts.

### Out of scope

- new professions;
- new economy systems;
- new portal worlds/mechanics;
- schema migration;
- new trading capabilities;
- monetisation;
- large NPC system;
- new UI framework;
- Wally/runtime dependency;
- production publishing credentials.

## 6. Code architecture

Preserve gameplay/service authority.

Prefer focused visual builders and reusable art primitives over growing `WorldBuilder` or `AuthoredPrefabBuilder` into an unreviewable monolith.

Recommended boundaries:

- `ArchitecturalDetailBuilder`: reusable roof, frame, porch, trim, chimney, lamp-fixture helpers;
- `VillageLandscapeBuilder`: deterministic path-edge/hedge/tree/flower/street-furniture clusters;
- existing semantic destination builders continue to return the same prompt/anchor contracts;
- `HomePrefabBuilder` retains home semantic contracts but uses improved architectural recipes;
- `VisualTheme` / shared palette remains the source of coherent colour/material intent;
- gameplay services remain unchanged unless an anchor must move with its visual object.

Do not introduce an art framework. These helpers remain ordinary focused Luau modules.

## 7. Deterministic art and performance

Art remains reproducible from Git/Rojo.

- no unseeded persistent random layout;
- no giant per-frame procedural world generation;
- static visual parts anchored;
- decorative parts non-touch/non-query/non-collide where possible;
- lights have bounded range and count;
- repeated scenery uses bounded variants;
- visual detail is concentrated on player routes and hero views rather than distributed uniformly.

## 8. Before/target evidence contract

The 11 August 2026 v0.6.2 Studio screenshots are the **before baseline** and record these observed FAIL classes:

- elevated village composition / empty grass / grid reading;
- civic-centre primitive/slab composition;
- hero-home slab roof / cyan windows / naked glowing light sphere.

The generated v0.6.2 concept board is **reference-only target intent**, not proof.

v0.6.3 acceptance requires new exact-candidate Studio screenshots from comparable views:

1. elevated village overview;
2. civic centre at avatar height;
3. hero-home exterior from street/porch;
4. Town Hall/fountain approach;
5. Village Shop + Home Store comparison;
6. Courier Depot/Workshop/Market cluster;
7. starter-home interior;
8. phone normal HUD over the improved world.

The before/after pair must show an obvious qualitative change. If a reviewer must inspect source to notice the improvement, the release fails its purpose.

## 9. Evidence scoring

For each required view, record:

- architecture/silhouette: PASS/FAIL;
- material/colour hierarchy: PASS/FAIL;
- lighting: PASS/FAIL;
- environmental composition: PASS/FAIL;
- labels-off comprehension: PASS/FAIL;
- placeholder/prototype reading: PASS/FAIL;
- major clipping/occlusion: PASS/FAIL.

Any required hero-view `placeholder/prototype reading = FAIL` blocks visual acceptance.

## 10. Success criterion

v0.6.3 succeeds when the exact Studio candidate visibly approaches the approved TinyWorld concept language:

- charming authored village;
- layered architecture;
- warm practical lighting;
- tactile props/interiors;
- distinct neighbourhoods;
- richer landscaping;
- compact HUD over a world worth looking at;
- mystery/portal layer providing contrast rather than compensating for a weak village.

Automated CI may become green before Studio evidence exists. That state is source/build green only, not visual acceptance.