# TinyWorld release evidence template

Copy this structure into each active release acceptance record. Never convert an unobserved gate into PASS.

## Build identity

- Release:
- Commit SHA:
- Branch/PR:
- Rojo version:
- Profile schema:
- Artifact filename:
- Artifact SHA-256:
- Build timestamp UTC:

## Automated source/build evidence

| Gate | Command/workflow | Result | Evidence |
|---|---|---|---|
| Pure Luau behaviour | `luau tests/run.luau` | NOT RUN | |
| Shared analysis | `luau-analyze src/shared/*.luau tests/*.luau` | NOT RUN | |
| Formatting | `stylua --check src tests` | NOT RUN | |
| Server syntax | recursive `luau-compile` | NOT RUN | |
| Client syntax | recursive `luau-compile` | NOT RUN | |
| Release authority | active release guard | NOT RUN | |
| Player-facing source contract | active visual/source guard where applicable | NOT RUN | |
| Release contract | `./scripts/verify-release-contract.sh` | NOT RUN | |
| Build contract | `./tests/build-contract.sh` | NOT RUN | |
| Rojo artifact | `./scripts/build.sh` / CI | NOT RUN | |
| Diff whitespace | `git diff --check` | NOT RUN | |

Automated checks prove only the properties they actually exercise. A source rule that bans a known placeholder mechanism does not prove the replacement looks good.

## Player-facing visual evidence

For any release changing character presentation, HUD, world art, buildings, furniture, interactions, portals or player-facing layout, define the required views/routes in the active acceptance record.

Record for each view:

- exact candidate SHA/artifact;
- Studio/published environment;
- viewport/device/graphics setting where relevant;
- whether explanatory labels/prompts were hidden;
- PASS/FAIL/BLOCKED/NOT RUN;
- screenshot/video/observation path;
- concise failure reason when not PASS.

**Merge-readiness rule:** required player-facing visual rows may be `NOT RUN` while a PR is draft, but a player-facing release cannot become merge-ready while required rows remain `NOT RUN`, `PENDING` or `FAIL` unless the user explicitly accepts a documented exception.

Generated mockups/reference-game images are design inputs, not release evidence.

## Studio single-client evidence

Record build SHA and exact route.

Typical checks:

- no critical Output errors;
- profile load/save/rejoin;
- onboarding;
- first 2/10/30-minute route;
- home interactions;
- catalogue purchase;
- place/rotate/store furniture;
- garden/careers;
- transport;
- impossible worlds;
- character expression/presentation;
- privacy;
- labels-off hero recognition where player-facing visuals changed.

Result: **NOT RUN until observed**.

## Studio multi-client evidence

- visit permissions;
- placed furniture replication;
- low-value trade happy path;
- trade timeout/stale confirmation/recovery as relevant;
- conflicting/hostile remote requests;
- concurrent profile/session behaviour where testable.

Result: **NOT RUN until observed**.

## Device evidence

For each target device record model, graphics setting, player count, FPS, memory, join time and UI observations.

- phone touch/portrait/landscape;
- controller focus/input;
- labels-off recognisability;
- visual occlusion/safe areas;
- performance route from `performance-budgets.md`.

Result: **NOT RUN until observed**.

## Published DEV evidence

Requires configured DEV universe/place and approved credential outside source control.

Record:

- exact artifact SHA promoted;
- published place/version;
- DEV DataStore namespace;
- smoke test result;
- device test result;
- approval identity/date.

Result: **NOT RUN while DEV publishing is deferred**.

## LIVE promotion

LIVE may use only the exact artifact approved in DEV. Record:

- exact artifact SHA;
- human approval;
- rollback artifact/SHA;
- migration compatibility review;
- release metadata/thumbnails/icon checks.

Result: **NOT RUN until explicitly approved and performed**.

## Evidence honesty rule

CI proves source/build properties only. It does not prove visual quality, FPS, multiplayer behaviour, device ergonomics or published-place correctness.

A visually focused release is not complete merely because every automated gate is green.