# TinyWorld v0.7.3 ART R7 Premium Visual World Pass Design

**Status:** Approved
**Date:** 2026-08-16
**Controlling issue:** #17
**Workstreams:** #18, #19, #20, #21, #22

## Goal

Transform the stable, functional R6 village into a visually compelling premium Roblox world with a distinctive TinyWorld identity while preserving the complete R6 gameplay experience and the R5 published-safe rendering boundary.

## Visual direction

Use the supplied reference screenshots only as inspiration for qualities, never as source assets or something to copy. TinyWorld's original expression should emphasize:

- bright, cheerful, saturated-but-coherent colour
- soft and rounded stylised forms
- strong focal landmarks and authored camera compositions
- richer visual density without clutter
- toy-world readability at Roblox gameplay distances
- clear district identity and route legibility
- charming differentiated houses
- activity spaces whose purpose reads before prompts appear
- expressive character-grade NPC silhouettes, faces, outfits and role props

Target first impression: **cute, colourful, welcoming, polished, fun, memorable, premium**.

## Mandatory implementation order

### 1. General map

Recompose the central village and its surrounding routes first so every later visual pass integrates into one authored world. Strengthen the fountain plaza as the hero hub, make routes to homes/market/garden/harbour visually obvious, eliminate broad dead flat zones near the core loop, improve shoreline composition, and use layered landscaping, props and modest vertical variation without damaging traversal.

The R6 grass correction remains non-negotiable: do not reintroduce coplanar grass overlays or z-fighting.

### 2. Houses and civic buildings

Rebuild the weakest exterior silhouettes and façade hierarchy after the map composition is settled. Major building categories should be recognisable without reading signs. Use pitched/stepped roof silhouettes, overhangs, trims, window depth, porches, awnings, lights and restrained lived-in props. Preserve functional interiors, ownership, prompts and home progression.

### 3. Activity spaces

Make the five R6 activity zones visually invite participation before a prompt appears:

- Mara: premium market/trader stall, canopy, goods, crates and compact signage
- Pip: layered garden beds, tools, watering/seed/flower dressing
- Finn: fishing nook/dock with rope, tackle, bucket, crates, buoy and shoreline detail
- Skye: harbour/boat launch with pier language, route board, parcels and stronger boat presentation
- Milo: builder/crafter work area with bench, timber, tools and repair materials

Existing R6 activity rules, multiplayer arbitration, rewards and canonical locations remain authoritative unless a safe locator adjustment is required for visual integration.

### 4. NPCs

Upgrade Mara, Pip, Finn, Skye and Milo only after their environment is stable. Improve proportions, faces, headwear/hair, clothing hierarchy and role props. Reduce mannequin/totem appearance and oversized label dependence. At medium distance the role should read from silhouette, colour and props before text.

NPC names, dialogue roles, activity routing and `VillageActivityLocations` placement authority remain unchanged.

### 5. Full candidate verification and real-client acceptance

Engineering gates prove build integrity, not beauty. The exact final candidate must pass unit/spec tests, analysis, formatting, compile, R7 source contract, release/build/free-only contracts and retained-artifact checks. Merge under the release-wide authorization already granted, then verify the post-merge `main` workflow and returned Roblox DEV place version.

Human visual acceptance happens only against the published Roblox client. Required views:

1. village centre wide shot
2. fountain plaza hero shot
3. harbour / Skye area
4. Finn / fishing area
5. Pip / garden area
6. residential / house row angle
7. Mara / market angle
8. NPC close-up
9. mobile HUD in village centre
10. warm-light/evening view if available

## Architecture

R7 should improve existing authored native Roblox builders rather than introduce another rendering technology. Prefer focused new visual builders composed by `Main.server.luau` when an existing builder is already too broad. Keep decorative geometry anchored, non-colliding and non-query/non-touch where practical. Use `VisualTheme` for shared palette/material decisions and `VillageActivityLocations` for canonical NPC/activity placement.

Published DEV remains on native Parts and approved persistent assets only. Studio-only EditableMesh preview must never become a published dependency.

## Non-goals

- no major new gameplay system
- no Mermaid Land expansion
- no new world/vehicle programme
- no economy redesign
- no profile migration
- no automatic LIVE publication
- no runtime published EditableMesh preview
- no copied buildings, characters, props, UI, logos or layouts from reference games

## Acceptance criteria

### General map

- central village has a deliberate hero composition around the fountain
- routes/districts read without giant developer-style signs
- no broad empty green plane dominates core screenshots
- landscaping uses varied layered silhouettes rather than repetitive cubes
- shoreline/coast feels authored
- no grass z-fighting regression
- traversal and gameplay anchors remain usable

### Houses

- major building categories read by silhouette and façade before signage
- rooflines no longer read as slab prototypes
- windows/doors/trims/porches add visible depth
- residential zone feels inhabited and coherent
- functional interiors/ownership/progression remain intact

### Activities

- five zones are visually distinct at medium distance
- props communicate activity purpose without giant text boards
- scenery does not obstruct prompts or routes
- fishing bite visuals and Skye progression rules remain synchronized with R6 logic
- multiplayer arbitration remains intact

### NPCs

- all five NPCs have recognisable character silhouettes
- faces/headwear/clothing read at normal gameplay distance
- role reads before floating text
- props do not block prompts or movement
- canonical placement and published-safe rendering remain intact

### Overall

The published R7 screenshots must show a dramatic qualitative improvement over R6 in map composition, architecture, activity dressing and character presentation. The release may be engineering-green and still be recorded as a human visual failure.
