# TinyWorld documentation

This index is the canonical entrypoint for TinyWorld product, engineering, quality, roadmap and release documentation.

## Documentation authority

Read/resolve conflicts in this order:

1. **Current release acceptance:** [v0.6.1 Visual Rescue acceptance](releases/v0.6.1/acceptance.md) defines what the release must prove and which visual/runtime/device gates block merge-ready status.
2. **Target-state product contract:** [TinyWorld v1 Target State](product/target-state-v1.md) defines the product north star, launch content floor and v1 non-negotiables.
3. **Durable product/engineering/quality contracts:** the documents indexed below define ongoing rules and boundaries.
4. **Active release roadmap/spec/plan:** [v0.6.1 roadmap](roadmap/v0.6.1-visual-rescue.md), [design](superpowers/specs/2026-08-10-tinyworld-v0.6.1-visual-rescue-design.md) and [implementation plan](superpowers/plans/2026-08-10-tinyworld-v0.6.1-visual-rescue.md) define current scope and sequencing.
5. **Historical records:** v0.6.0 and earlier release/spec/plan material remains useful evidence/decision history but does not override current authority.

A roadmap/spec never proves a feature shipped. CI never proves visual quality. For v0.6.1, player-facing Studio/device evidence is required before merge-ready status.

## Current visual direction

TinyWorld aims for **Brookhaven-level readability + Toca-style tactile warmth + Ready Player One-style wonder**, expressed as original TinyWorld design rather than copied IP.

Ordinary village life should be grounded, warm and visually self-explanatory. Portals and impossible worlds provide the strongest fantasy contrast.

Current hard rules include:

- no primitive Part hair/shoe fallback;
- no large always-on-top ordinary-world information walls;
- no telemetry/dashboard language dominating normal play;
- labels supplement recognisable physical objects;
- hero objects have a higher craft bar than background fallback scenery;
- observed visual evidence is a release gate.

## Product

- [TinyWorld v1 Target State](product/target-state-v1.md)
- [Core loop](product/core-loop.md)
- [Content catalogue contract](product/content-catalog.md)
- [Safety and social contract](product/safety-social.md)
- [Vision](product/vision.md)
- [Experience pillars](product/experience-pillars.md)
- [Art direction](product/art-direction.md)
- [Village](product/village.md)
- [Homes](product/homes.md)
- [UI and UX](product/ui-ux.md)

## Engineering

- [Architecture](engineering/architecture.md)
- [Data model](engineering/data-model.md)
- [Runtime contracts](engineering/runtime-contracts.md)
- [Remote security](engineering/remote-security.md)
- [Asset pipeline](engineering/asset-pipeline.md)
- [Production engineering](engineering/production-engineering.md)
- [Tooling decisions](engineering/tooling.md)
- [World content pipeline](engineering/world-content-pipeline.md)

## Quality

- [Definition of done](quality/definition-of-done.md)
- [Visual quality bar](quality/visual-quality-bar.md)
- [Performance budgets](quality/performance-budgets.md)
- [Mobile/accessibility contract](quality/accessibility-mobile.md)
- [Playtesting](quality/playtesting.md)
- [Release evidence template](quality/release-evidence-template.md)

## Active delivery

- [Roadmap](roadmap/roadmap.md)
- [v0.6.1 Visual Rescue](roadmap/v0.6.1-visual-rescue.md)
- [v0.6.1 acceptance](releases/v0.6.1/acceptance.md)
- [v0.6.1 approved design](superpowers/specs/2026-08-10-tinyworld-v0.6.1-visual-rescue-design.md)
- [v0.6.1 implementation plan](superpowers/plans/2026-08-10-tinyworld-v0.6.1-visual-rescue.md)
- [v0.6.1 visual-rescue Studio route](v0.6.1-visual-rescue-test.md) once created during implementation

## Previous release

- [v0.6.0 Target-State Consolidation roadmap](roadmap/v0.6.0-target-state-consolidation.md)
- [v0.6.0 acceptance](releases/v0.6.0/acceptance.md)

v0.6.0 is merged history. Its unobserved runtime/device rows remain an honest record of what was not proved at that time; they do not block fixing proven v0.6.1 visual defects.

## Earlier historical releases

- [v0.5.3 Production Engineering Foundation](roadmap/v0.5.3-production-engineering.md)
- [v0.5.3 acceptance](releases/v0.5.3/acceptance.md)
- [v0.5.2 Village Soul](roadmap/v0.5.2-village-soul.md)
- [v0.5.2 acceptance](releases/v0.5.2/acceptance.md)
- [v0.5.2 Studio route](v0.5.2-village-soul-test.md)

Older dated Superpowers specs/plans are historical unless a current release record explicitly adopts them.