# v0.5.2 Village Soul acceptance

## Release contract

v0.5.2 is a presentation and world-content reset on profile version 10. It preserves server authority for coins, XP, inventory, plots, privacy, trades, homes, vehicles, portals, daily state, and saves. It adds no economy, monetisation gate, combat system, third-party asset dependency, or profile migration.

Release acceptance requires both local evidence and the human gates in the exact [Studio route](../../v0.5.2-village-soul-test.md). Local source evidence does not prove Studio, published-place, or device behavior.

## Premium-feel quality gate

“Premium” is a concrete v0.5.2 craft gate, not monetisation or paid content. Every row must pass; one failure blocks the release.

| Observable check | Pass | Fail |
| --- | --- | --- |
| Authored silhouettes | Required homes, civic destinations, vehicles, and touched objects are identifiable from shape with labels hidden. | A sign, arbitrary colour, or generic block is required. |
| Quality materials | Wood, brick, slate, glass, fabric, metal, water, and foliage support the objects they depict. | Anonymous or arbitrary material treatment dominates a primary object. |
| Composed lighting | Daylight, shadow, warm windows, and restrained glow create readable hierarchy on mobile. | Flat, dark, or blown-out lighting obscures routes or silhouettes. |
| Tactile feedback | Interactions acknowledge input through bounded motion, light, object state, sound, or short toast. | Only text or telemetry changes. |
| Restrained UI | Compact HUD, contextual prompts, journal, and short toasts leave play readable. | Telemetry walls or raw replicated state occupy normal play. |
| No arbitrary coloured cubes | Every player-facing object has a visible authored role and physical affordance. | A coloured cube substitutes for an object, verb, or destination. |
| Labels-off child-recognition test | The exact Studio route records every required uncoached recognition. | Any required recognition needs labels, telemetry, or coaching. |

## Automated acceptance

- [ ] `VisualQualityRules` exports a 16-home cap, three-second toast duration, four-neighbourhood count, and fail-closed recognizable-object validator.
- [ ] Layout tests prove a deterministic maximum of sixteen non-overlapping slots across all four neighbourhoods.
- [ ] Source guards prove compact HUD components, Studio-only raw debug UI, prefab boundaries, named neighbourhoods, and removal of generic world-construction paths.
- [ ] Prefab, physical-affordance, home-quality, client-presentation, and ambient-acceptance guards pass.
- [ ] Terrain acceptance proves four authored `WedgePart` elevation bands with bounded 4–8 stud heights and neighbourhood metadata.
- [ ] Home acceptance proves every starter/Cosy home has a physical kitchen counter and a usable non-catalog interaction, while the paid `KitchenCounter` item remains a progression unlock.
- [ ] Ambient acceptance proves warm-window/chimney effects bind to actual occupied house descendants, stay within the seeded global budget, and release on rebuild/vacate.
- [ ] Collectible acceptance proves Sugar Crystals and Moonlit Seeds are named authored prefab builds without Neon placeholder geometry.
- [ ] `tests/verify-v0.5.2-ambient-acceptance.ps1` proves seeded caps, smoke, warm windows/lights, water/foliage/bird/butterfly hooks, single-world wiring, evidence separation, and the premium-feel quality gate.
- [ ] Full Luau tests, analysis, server/client compilation, relevant PowerShell guards, and `git diff --check` pass where the tools are available.

Local commands:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
luau-compile src/server/*.luau >/dev/null
luau-compile src/client/*.luau >/dev/null
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-visual-contract.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/verify-v0.5.2-ambient-acceptance.ps1
git diff --check
```

The visual-contract guard is intentionally fail-closed: before later v0.5.2 implementation slices land, it reports missing compact HUD, layout, and prefab contracts.

## Studio visual acceptance

- [ ] A fresh screenshot shows the compact HUD and no permanent telemetry panel.
- [ ] With labels hidden, the player identifies at least one home and each civic destination from silhouette, scale, material, and feedback.
- [ ] Village composition is visibly authored and non-symmetrical.
- [ ] Meadow Lane, Harbour Row, Woodland Rise, and Orchard End have distinct identities.
- [ ] The starter/Cosy home visibly contains bedroom, kitchen, living, bathroom, storage, and garden life.
- [ ] A fresh starter/Cosy home lets the player approach and use the kitchen counter; the room reads as playable before catalog expansion.
- [ ] Bike, boat, parcels, crops, seeds, shells, furniture, trade trays, and shop stock read as physical objects.
- [ ] Occupied homes show bounded warm-window and/or chimney ambience where the device budget allows; effects follow the house rather than floating in the world.
- [ ] Ambient effects remain bounded and Output contains no release-blocking errors.
- [ ] Authored silhouettes pass with labels off; no destination or verb depends on an arbitrary coloured cube.
- [ ] Quality materials, composed lighting, tactile feedback, and restrained UI each pass the premium-feel quality gate.
- [ ] No telemetry walls appear in normal play.
- [ ] The labels-off child-recognition test passes exactly as written in the Studio route.

## Gameplay regression acceptance

- [ ] One-player route covers onboarding, home entry and interactions, garden growth, privacy, bike, boat, portal, and persistence.
- [ ] Two-client route covers visits/privacy and atomic trade setup and completion.
- [ ] Existing rewards, prices, progression, ownership, physical-item, and save behavior remain server-authoritative.

## Evidence status

| Evidence | Status | Notes |
| --- | --- | --- |
| Local source and pure tests | Pending | Record exact commands and commit after implementation |
| One-player Studio | Not run | Human gate; attach screenshot and Output review |
| Two-client Studio | Not run | Human gate |
| Published place | Not run | Human gate with API Services |
| Mobile/controller devices | Not run | Human gate |

No unchecked item is implied to pass. Update this record with dated, commit-specific evidence during release reconciliation.

Canonical release links: [documentation index](../../README.md), [progress](../../progress.md), [roadmap](../../roadmap/v0.5.2-village-soul.md), [Studio route](../../v0.5.2-village-soul-test.md), and [ambient acceptance guard](../../../tests/verify-v0.5.2-ambient-acceptance.ps1).
