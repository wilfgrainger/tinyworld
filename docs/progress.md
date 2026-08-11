# TinyWorld progress

## Current repository release

**v0.6.3 Production Art & World Craft** is the active corrective release on `release/v0.6.3-production-art-world-craft` / PR #8.

It builds on merged v0.6.2 and profile schema 11. Gameplay scope is frozen while the ordinary village receives a production-art/world-craft pass driven by the 11 August 2026 Studio screenshots.

v0.7.0 remains reserved for the family/girls review and intentionally has no delivery scope yet.

## Why v0.6.3 exists

Post-merge v0.6.2 Studio evidence confirmed that the compact HUD and player-avatar correction worked, but the world still showed clear prototype/test-map qualities:

- slab-dominated hero roofs;
- bright flat cyan windows;
- naked glowing practical-light spheres;
- large empty green/paved areas;
- repeated/grid-like plot reading;
- primitive civic/home architecture.

Those are now explicit release blockers rather than aesthetic suggestions.

## Current work

| Area | Status | Evidence |
| --- | --- | --- |
| Docs-first repository review | Complete | `docs/audits/v0.6.3-documentation-review.md` |
| Approved v0.6.3 design | Complete | production-art/world-craft spec committed |
| Superpowers implementation plan | Complete | task-by-task plan committed |
| v0.6.3 release/source guards | RED by design | waiting on art implementation |
| Release/build metadata | Moving to 0.6.3 | schema remains 11 |
| Architectural detail helper | Not yet implemented | source contract requires it |
| Hero-home exterior | Not yet implemented | v0.6.2 screenshot is before FAIL |
| Civic destination craft | Not yet implemented | source + Studio evidence required |
| Village landscape recomposition | Not yet implemented | source + Studio evidence required |
| Remaining primitive ambient actors | Known defect | `VillageSceneryBuilder` birds/butterflies to be removed |
| Hero-home interior | Not yet implemented | Studio evidence required |
| Exact-candidate build/PR evidence | Not yet frozen | CI required |

## Preserved foundation

v0.6.3 must preserve:

- profile schema v11 and fail-closed migrations;
- deterministic sixteen-home cap;
- v0.6.2 Courier/Gardener/Designer/Village Explorer loops;
- authoritative Home Store/furniture placement;
- RemoteGuard;
- DEV/LIVE persistence separation;
- durable trade journal/mutation locks;
- four impossible-world foundations;
- analytics adapter;
- compact world-first HUD;
- normal Roblox avatar presentation;
- credential-free Rojo build and exact-artifact evidence model.

## Current links

- [Canonical documentation index](README.md)
- [v1 target state](product/target-state-v1.md)
- [v0.6.3 roadmap](roadmap/v0.6.3-production-art-world-craft.md)
- [v0.6.3 acceptance](releases/v0.6.3/acceptance.md)
- [v0.6.3 design](superpowers/specs/2026-08-11-tinyworld-v0.6.3-production-art-world-craft-design.md)
- [v0.6.3 plan](superpowers/plans/2026-08-11-tinyworld-v0.6.3-production-art-world-craft.md)
- [v0.6.3 Studio route](v0.6.3-production-art-world-craft-test.md)

## Evidence rule

Automated source/build, Studio single-client, Studio multi-client, real-device, published DEV and LIVE promotion remain separate evidence classes.

The generated concept board is target/reference intent only. The user-supplied v0.6.2 Studio screenshots are the observed before baseline. v0.6.3 visual success requires new comparable screenshots from the exact candidate.