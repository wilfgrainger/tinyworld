# TinyWorld progress

## Current repository release

**v0.6.0 Target-State Consolidation** is the active release candidate.

It consolidates the complete actionable Target-State Upgrade Blueprint into one pull request while preserving the v0.5.x server-authoritative village baseline.

## Source status

| Area | Source status | Evidence status |
| --- | --- | --- |
| v1 target-state/game-bible contracts | Implemented | Source review complete |
| Profile schema v11 + migration registry | Implemented | Automated tests in CI |
| Generic item/furniture/content definitions | Implemented | Automated content-floor tests in CI |
| Home Store + authoritative furniture placement | Implemented | Studio/save/rejoin/two-client evidence pending |
| 80-item home catalogue + reusable interactions | Implemented | Labels-off/device craft evidence pending |
| RemoteGuard + onboarding hardening | Implemented | Automated validation tests; hostile Studio route pending |
| DEV/LIVE persistence separation | Implemented | Source guard; published DEV evidence pending |
| Durable low-value trade journal/protocol | Implemented | Unit tests; multi-client recovery evidence pending |
| Responsive Home/wardrobe UI | Implemented | Phone/controller evidence pending |
| Four impossible worlds | Implemented | Studio visual/traversal evidence pending |
| Ambient village life | Implemented | Studio/performance evidence pending |
| Analytics taxonomy/adapter | Implemented | Published analytics observation pending |
| Performance/accessibility/asset contracts | Implemented | Real-device/runtime evidence pending |
| v0.6.0 build/release contract | Implemented | Current GitHub Actions must pass |

## Current release links

- [Canonical documentation index](README.md)
- [v1 target state](product/target-state-v1.md)
- [v0.6.0 roadmap](roadmap/v0.6.0-target-state-consolidation.md)
- [v0.6.0 acceptance record](releases/v0.6.0/acceptance.md)
- [v0.6.0 Superpowers design](superpowers/specs/2026-08-09-tinyworld-v0.6.0-target-state-consolidation-design.md)
- [v0.6.0 implementation plan](superpowers/plans/2026-08-09-tinyworld-v0.6.0-target-state-consolidation.md)

## Evidence rule

Automated source/build evidence, one-player Studio, multi-client Studio, real-device, published DEV and LIVE promotion are separate gates. None substitutes for another.

This repository can be source-complete for v0.6.0 while runtime/device rows remain PENDING. They may be marked PASS only after the exact candidate artifact is observed through the documented route.

## Historical baseline

v0.5.2 Village Soul remains the historical product/presentation acceptance baseline that established the compact HUD, sixteen-home village, physical affordances and visual-quality discipline. v0.5.3 remains the historical production-engineering baseline that established the credential-free Rojo artifact/evidence pipeline. Neither is the active release after v0.6.0.