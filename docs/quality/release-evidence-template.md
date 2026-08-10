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
| Pure Luau behaviour | `luau tests/run.luau` | PENDING | |
| Shared analysis | `luau-analyze src/shared/*.luau tests/*.luau` | PENDING | |
| Formatting | `stylua --check src tests` | PENDING | |
| Server syntax | recursive `luau-compile` | PENDING | |
| Client syntax | recursive `luau-compile` | PENDING | |
| Release contract | `./scripts/verify-release-contract.sh` | PENDING | |
| Build contract | `./tests/build-contract.sh` | PENDING | |
| Rojo artifact | `./scripts/build.sh` / CI | PENDING | |
| Diff whitespace | `git diff --check` | PENDING | |

## Studio single-client evidence

Record build SHA and exact route.

- no critical Output errors;
- profile load/save/rejoin;
- onboarding;
- first 2/10/30-minute route;
- home interactions;
- catalogue purchase;
- place/rotate/store furniture;
- garden/careers;
- transport;
- each impossible world;
- character expression;
- privacy.

Result: **PENDING until observed**.

## Studio multi-client evidence

- visit permissions;
- placed furniture replication;
- low-value trade happy path;
- trade timeout/stale confirmation;
- conflicting/hostile remote requests;
- concurrent profile/session behaviour where testable.

Result: **PENDING until observed**.

## Device evidence

For each target device record model, graphics setting, player count, FPS, memory, join time and UI observations.

- phone touch/portrait/landscape;
- controller focus/input;
- labels-off recognisability;
- performance route from `performance-budgets.md`.

Result: **PENDING until observed**.

## Published DEV evidence

Requires configured DEV universe/place and approved credential outside source control.

Record:

- exact artifact SHA promoted;
- published place/version;
- DEV DataStore namespace;
- smoke test result;
- device test result;
- approval identity/date.

Result: **PENDING while DEV publishing is deferred**.

## LIVE promotion

LIVE may use only the exact artifact approved in DEV. Record:

- exact artifact SHA;
- human approval;
- rollback artifact/SHA;
- migration compatibility review;
- release metadata/thumbnails/icon checks.

Result: **PENDING until explicitly approved and performed**.

## Evidence honesty rule

CI proves source/build properties only. It does not prove visual quality, FPS, multiplayer behaviour, device ergonomics or published-place correctness.