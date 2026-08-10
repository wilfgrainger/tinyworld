# TinyWorld progress

## Current repository release

**v0.6.1 Visual Rescue** is the active corrective release on `release/v0.6.1-visual-rescue` / PR #6.

It inherits the merged v0.6.0 Target-State Consolidation architecture and profile schema 11 while correcting the first observed presentation regressions before v0.7.0 Village Life expands further.

## Why v0.6.1 is active

Observed v0.6.0 screenshots exposed player-facing failures that source/CI had not proved or prevented:

- primitive Part hair/shoes attached to the player;
- large black always-on-top information panels across the village;
- HUD/navigation chrome competing with the 3D world;
- labels explaining systems that should be communicated by recognisable landmarks;
- hero buildings/objects still reading too strongly as fallback geometry.

Those are release blockers for a visual corrective release, not cosmetic backlog trivia.

## Source status

| Area | Source status | Evidence status |
| --- | --- | --- |
| v0.6.1 design/plan/roadmap/acceptance | Implemented | Source review in progress |
| Release identity 0.6.1 / schema 11 | In progress | CI authority/release gates being updated |
| Primitive character fallback removal | In progress | Studio character screenshot required |
| Ordinary floating information-wall removal | In progress | Labels-off Studio views required |
| Compact world-first HUD | In progress | Phone/controller screenshot/route required |
| Hero civic destination rebuild | Planned | Labels-off Studio views required |
| Starter-home/touched-object craft pass | Planned | Studio interior/exterior evidence required |
| Golden ordinary-life route | Planned | Exact Studio/rejoin route required |
| Visual benchmarks | Planned | Exact-candidate screenshots only |
| Full Markdown authority audit | In progress | Canonical docs being reconciled |
| Full repository line-by-line audit | Planned | Final branch audit ledger required |
| Graphite Mountain integrated review | Planned | Actual-diff review required |
| Cave Pony final audit | Planned | Actual-diff audit required |

## Preserved v0.6.0 foundation

v0.6.1 does not redesign these systems:

- profile schema v11 and migrations;
- generic item/furniture/content definitions;
- Home Store and authoritative furniture placement;
- RemoteGuard and onboarding security;
- DEV/LIVE persistence separation;
- durable low-value trade journal/protocol;
- four impossible-world foundations;
- analytics taxonomy/adapter;
- performance/accessibility/asset contracts;
- credential-free Rojo build and exact-artifact evidence model.

Any regression in those areas blocks the release.

## Current release links

- [Canonical documentation index](README.md)
- [v1 target state](product/target-state-v1.md)
- [v0.6.1 roadmap](roadmap/v0.6.1-visual-rescue.md)
- [v0.6.1 acceptance record](releases/v0.6.1/acceptance.md)
- [v0.6.1 Superpowers design](superpowers/specs/2026-08-10-tinyworld-v0.6.1-visual-rescue-design.md)
- [v0.6.1 implementation plan](superpowers/plans/2026-08-10-tinyworld-v0.6.1-visual-rescue.md)

## Evidence rule

Automated source/build evidence, one-player Studio, multi-client Studio, real-device, published DEV and LIVE promotion remain separate gates.

For v0.6.1, required player-facing visual/device evidence may be NOT RUN while the PR is draft, but it blocks merge-ready status. The release cannot repeat the pattern of treating source-complete visual work as acceptable while every real rendering row remains pending.

## Historical baseline

v0.6.0 Target-State Consolidation is merged history and remains the technical/product baseline beneath this corrective release. v0.5.2 Village Soul and v0.5.3 Production Engineering Foundation are earlier historical baselines. None is the active release after v0.6.1 begins.