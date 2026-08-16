# TinyWorld v0.6.3 Studio Fail Correction — design

**Status:** approved by user from direct Studio screenshot review on 11 August 2026.  
**Release:** v0.6.3 Production Art & World Craft  
**Branch:** `release/v0.6.3-production-art-world-craft`  
**Profile schema:** 11, unchanged.

## Problem

The first v0.6.3 Studio candidate materially improves source-side art craft but still fails the release's visual acceptance bar. The observed candidate remains too close to a development map.

Direct screenshot evidence shows:

- overlapping/crossed roof planes around civic hero buildings;
- legacy civic roof masses still visible under/alongside new craft passes;
- civic buildings retaining large rectangular body masses with decorative detail layered on top;
- market/trading presentation still reading as slab/canopy primitives;
- one large uninterrupted green ground field dominating normal player-height views;
- destination props improving detail density without fixing the large-form composition;
- no reliable visible version/release marker proving which candidate is under test.

The root cause is not a lack of more props. It is an additive visual-patch strategy that preserved too much legacy hero geometry.

## Corrective design

### 1. Replace, do not stack, legacy civic roof geometry

A corrective civic pass must remove known legacy hero roof parts before adding replacement roofs. Town Hall and Village Shop require this explicitly; Courier Depot and Workshop must also remove any older roof/canopy mass that competes with the final silhouette.

Final hero roofs must have one coherent ridge/eave relationship, physically sit on the building, and avoid crossed, detached or oversized slab reading.

### 2. Recompose civic hero silhouettes

Keep gameplay anchors and service authority intact, but allow visual shells to be replaced behind them.

Town Hall must read first as a civic building with a coherent main roof, clock tower, portico and entrance hierarchy.

Village Shop must read as an everyday shop with a coherent shop roof, framed storefront and supported awning.

Courier Depot must read through loading/parcels/route language without a giant roof slab.

Workshop must read through garage/workbench/vehicle language with a coherent workshop roof.

Market/Trading Post must use several smaller supported stalls and clear circulation. No single giant table, canopy or sign may dominate the player-height view.

### 3. Break the green-board reading at large scale

The existing `VillageGround` may remain as the physical safety floor, but it must no longer be the dominant visible surface.

Add deterministic district ground composition above it using bounded, slightly varied lawn/soil/stone/planting fields and angled/segmented edges. Concentrate detail along player routes and hero approaches.

From the normal player-height route, the player should read streets, gardens, verges, civic forecourts and neighbourhood ground zones rather than one enormous continuous grass rectangle.

### 4. Large forms before props

Corrective priority is strictly:

1. ground composition;
2. building masses;
3. roofs;
4. entrances/windows;
5. destination-specific structure;
6. props and flowers last.

Do not solve the screenshot failure by merely increasing prop count.

### 5. Candidate version stamp

Every Studio/DEV test screenshot must visibly identify the candidate.

Add a small top-left stamp below the Roblox inset displaying at minimum:

`TinyWorld DEV · v0.6.3 · PR #8`

The stamp must be subtle, non-interactive, world-first, and not overlap the normal status HUD. It is always visible in Studio/DEV testing and may be suppressed for LIVE later through an explicit release decision.

### 6. Preserve authority and scope

- no gameplay expansion;
- no schema migration;
- no economy/trade/progression changes;
- no framework/dependency introduction;
- no fake Roblox asset IDs;
- no merge to `main` until exact-candidate Studio evidence passes;
- existing prompt/interaction anchors remain authoritative even when their visual shell is rebuilt.

## Acceptance

The corrective candidate must run the existing eight-view v0.6.3 Studio route.

The release remains FAIL if any required hero view still has `prototype reading = FAIL`, even when CI is green.

In particular, the next candidate must show:

- no crossed/stacked/detached civic roof planes;
- Town Hall, Village Shop, Home Store, Courier Depot and Workshop with coherent intentional silhouettes;
- Market as a believable group of stalls rather than slabs;
- materially less uninterrupted green-board surface in ordinary player-height views;
- visible `TinyWorld DEV · v0.6.3 · PR #8` candidate stamp;
- existing normal HUD, gameplay and interaction behavior unchanged.