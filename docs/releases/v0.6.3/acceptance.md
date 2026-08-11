# v0.6.3 Production Art & World Craft acceptance

**Release:** v0.6.3  
**Profile schema:** 11  
**Status:** corrective implementation in progress after first v0.6.3 Studio candidate FAIL; current corrected candidate still requires exact-candidate Studio/device evidence.

## Release contract

- [ ] canonical authority identifies v0.6.3 Production Art & World Craft;
- [ ] schema remains 11 with no migration;
- [ ] v0.6.2 gameplay/server-authority contracts remain intact;
- [ ] v0.7.0 remains reserved for the family/girls review;
- [ ] no new framework/dependency/fake asset ID/production credential/automatic LIVE publish path is introduced.

## Known v0.6.2 failures that v0.6.3 must remove

- [ ] hero home is no longer dominated by an oversized flat/slab roof;
- [ ] ordinary home/civic windows no longer read as bright cyan pasted rectangles;
- [ ] ordinary practical lights no longer read as naked yellow glowing spheres;
- [ ] elevated village view no longer reads as repeated plots on one huge green plane;
- [ ] civic centre no longer reads as isolated primitive blocks/platforms in empty paving;
- [ ] Town Hall, Village Shop, Home Store, Courier Depot, Workshop and Market/Trading Post have distinct production-intentional architecture;
- [ ] no Part-built bird/cat/butterfly actor remains in normal village presentation.

## First v0.6.3 Studio candidate review — 11 August 2026

The user opened what appeared to be the first v0.6.3 candidate and supplied normal player-height screenshots.

Observed result: **FAIL**.

The screenshots show that source-side craft increased but the rendered result still does not meet the release bar:

- Town Hall / civic roof planes visibly overlap or cross rather than forming one coherent roof assembly;
- legacy roof geometry remained visible beneath/alongside the additive craft pass;
- several civic buildings still read primarily as rectangular masses with trim applied afterwards;
- Market/Trading Post still reads as slab/canopy primitives and the large status sign dominates the scene;
- one large uninterrupted green ground surface remains visually dominant at player height;
- added props/flowers do not compensate for the large-form composition problem;
- screenshots contain no reliable v0.6.3 candidate/version stamp.

Corrective action is defined by `docs/superpowers/specs/2026-08-11-tinyworld-v0.6.3-studio-fail-correction-design.md` and its implementation plan.

This historical FAIL remains recorded even after the source is corrected. A later candidate must be photographed again rather than overwriting this evidence.

## Architecture source contract

- [ ] `ArchitecturalDetailBuilder` supplies pitched roof, framed window, door, porch, chimney and practical lantern primitives;
- [ ] HomePrefabBuilder uses those primitives while preserving semantic anchors;
- [ ] Home Store uses those primitives while preserving supply/style/gallery prompts;
- [ ] civic builder changes preserve service-facing anchors;
- [ ] final civic replacement pass removes known legacy roof masses before composing final hero roofs;
- [ ] Market final pass uses smaller supported stalls and a reduced status sign rather than a giant canopy/sign composition;
- [ ] decorative visual parts are non-touch/non-query/non-collide where practical;
- [ ] practical PointLights have bounded range/brightness.

## Landscape source contract

- [ ] deterministic four-neighbourhood composition remains;
- [ ] Meadow Lane has stream/bridge/cottage-garden/flower-meadow language;
- [ ] Harbour Row has retaining-wall/dock-clutter/coastal-planting language;
- [ ] Woodland Rise has canopy/rock/narrow-path/woodland-fence language;
- [ ] Orchard End has orchard/vegetable-bed/nursery/terrace language;
- [ ] civic centre has fountain plaza, planted edges, seating, lamps and framed approaches;
- [ ] `VillageGround` is demoted to a fallback visual floor beneath district/civic ground composition;
- [ ] landscape work preserves safe walkable routes and visual budgets.

## Candidate identity contract

- [ ] Studio/DEV screenshots visibly show `TinyWorld DEV · v0.6.3 · PR #8`;
- [ ] stamp remains small, non-interactive and below the normal top-left HUD stack;
- [ ] candidate identity is sourced from a shared release-info module rather than duplicated UI text.

## Automated gates

| Gate | Status | Evidence |
| --- | --- | --- |
| Pure Luau specs | NOT RUN | exact corrected-head run to be recorded |
| Shared Luau analysis | NOT RUN | exact corrected-head run to be recorded |
| StyLua | NOT RUN | exact corrected-head run to be recorded |
| Recursive runtime compile | NOT RUN | exact corrected-head run to be recorded |
| Release authority | NOT RUN | exact corrected-head run to be recorded |
| v0.6.3 source contract | NOT RUN | `tests/verify-v0.6.3-source-contract.sh` |
| Repository/current-authority audit | NOT RUN | exact corrected-head run to be recorded |
| Shell build contract | NOT RUN | exact corrected-head run to be recorded |
| Release contract | NOT RUN | exact corrected-head run to be recorded |
| Rojo candidate build | NOT RUN | exact corrected-head run to be recorded |
| Traceability artifact/manifest | NOT RUN | artifact/hash to be recorded |

Automated PASS never satisfies the visual rows below.

## Exact-candidate Studio views

Use `docs/v0.6.3-production-art-world-craft-test.md`.

| View | Status | Architecture | Lighting | Landscape/composition | Labels-off | Prototype reading | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Elevated village overview | NOT RUN | | | | | | corrected candidate required |
| Civic centre at avatar height | NOT RUN | | | | | | corrected candidate required |
| Starter/hero home exterior | NOT RUN | | | | | | corrected candidate required |
| Town Hall + fountain approach | NOT RUN | | | | | | corrected candidate required |
| Village Shop + Home Store | NOT RUN | | | | | | corrected candidate required |
| Courier Depot + Workshop + Market | NOT RUN | | | | | | corrected candidate required |
| Starter-home interior | NOT RUN | | | | | | corrected candidate required |
| Phone normal HUD over world | NOT RUN | | | | | | corrected candidate required |

A required view fails if `prototype reading` is FAIL even when all source tests are green.

## Visual benchmark rule

The previously generated TinyWorld concept board is an aspirational art-direction reference only. It is not a Roblox screenshot and cannot satisfy any evidence row.

The 11 August 2026 user-supplied v0.6.2 Studio screenshots are the before baseline. The first v0.6.3 candidate screenshots are additional failed evidence showing that an additive craft pass was insufficient. The corrected v0.6.3 candidate must show an obvious qualitative step from both.

## Hero-home route

- [ ] exterior reads as a believable charming home;
- [ ] entrance/porch/window/light hierarchy is understandable without explanatory floating text;
- [ ] bedroom, kitchen, living, bathroom and storage zones are visually distinct enough to navigate;
- [ ] bedside lamp uses a recognisable fixture and visible light response;
- [ ] kitchen/sink/shower/storage interactions retain existing behavior;
- [ ] furniture placement/persistence behavior is unchanged.

## Device/performance evidence

- [ ] phone portrait HUD/panels remain usable;
- [ ] phone landscape HUD/panels remain usable;
- [ ] effective touch targets remain >=44x44 pixels;
- [ ] controller routes used by the golden route remain usable;
- [ ] sustained mobile target >=30 FPS or recorded FAIL;
- [ ] memory target <=500 MB or recorded FAIL;
- [ ] useful spawn target <=15 seconds or recorded FAIL.

## Merge-ready rule

A green PR is source/build green only. This player-facing visual release is not visually merge-ready while required Studio/device views are NOT RUN or FAIL unless an explicit exception is separately approved.

No merge is authorised by this file.