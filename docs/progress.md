# TinyWorld progress

## Current repository release

**v0.6.2 Village Life & Visual Craft** is the active release on `release/v0.6.2-village-life-visual-craft` / PR #7.

It builds on merged v0.6.1 Visual Rescue and profile schema 11. It absorbs the previously planned v0.7.0 Village Life scope plus the remaining Claude visual-craft recommendations.

v0.7.0 is reserved for the family/girls review and intentionally has no delivery scope yet.

## Implemented source slices

| Area | Source status | Player-facing evidence |
| --- | --- | --- |
| v0.6.2 design/plan/roadmap/acceptance | Implemented | documentation/source only |
| Canonical activities | Implemented: Courier, Gardener, Designer, Village Explorer | Studio route still required |
| Courier route variety | Implemented: four server-selected destinations | Studio parcel/destination route NOT RUN |
| Gardener presentation | Implemented over persisted Farmer compatibility | Studio grow/harvest route NOT RUN |
| Village Explorer presentation | Implemented over existing server-observed trail | Studio trail NOT RUN |
| Designer route progress | Implemented on successful new placement only | Studio Home Store/place route NOT RUN |
| Primitive ambient character fallback | Removed | no replacement creature accepted without assets/evidence |
| Release/build authority 0.6.2 / schema 11 | In progress | CI final exact-head evidence pending |
| Hero-home/golden route | Contract in progress | Studio/rejoin evidence NOT RUN |
| Claude visual-craft hero destination review | Source contract in progress | labels-off Studio evidence NOT RUN |

## Preserved foundation

v0.6.2 deliberately preserves:

- profile schema v11 and fail-closed migrations;
- deterministic sixteen-home village cap;
- generic item/furniture/content definitions;
- authoritative Home Store and furniture placement;
- RemoteGuard;
- DEV/LIVE persistence separation;
- durable trade journal/mutation locks;
- four impossible-world foundations;
- analytics adapter;
- credential-free Rojo build and exact-artifact evidence model.

Any regression in those areas blocks the release.

## Current release links

- [Canonical documentation index](README.md)
- [v1 target state](product/target-state-v1.md)
- [v0.6.2 roadmap](roadmap/v0.6.2-village-life-visual-craft.md)
- [v0.6.2 acceptance record](releases/v0.6.2/acceptance.md)
- [v0.6.2 Superpowers design](superpowers/specs/2026-08-10-tinyworld-v0.6.2-village-life-visual-craft-design.md)
- [v0.6.2 implementation plan](superpowers/plans/2026-08-10-tinyworld-v0.6.2-village-life-visual-craft.md)

## Evidence rule

Automated source/build evidence, one-player Studio, multi-client Studio, real-device, published DEV and LIVE promotion remain separate gates.

For v0.6.2, the requested execution stops at a pushed PR with required automated checks green. That does not convert unobserved Studio/device rows to PASS. Those remain explicit follow-on release evidence.

## Historical baseline

v0.6.1 Visual Rescue is the merged presentation baseline. v0.6.0 Target-State Consolidation remains the underlying technical/product foundation. Earlier release records remain historical evidence, not current authority.
