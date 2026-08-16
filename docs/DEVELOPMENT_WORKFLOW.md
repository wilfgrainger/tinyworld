# TinyWorld Development Workflow

TinyWorld uses an issue-first development model. GitHub Issues are the operational source of truth from approved design through implementation, CI, Roblox DEV publication and human acceptance.

## Lifecycle

`design → ready → in progress → CI green → DEV published → human acceptance → done`

### Design

Create the controlling issue before implementation. Record the problem, goal, approved direction, scope, non-goals, alternatives that materially affected the decision, dependencies and acceptance criteria. Visual work should include reference imagery or links when available and explicitly state that references are inspiration rather than assets to copy.

If Superpowers or another methodology requires a durable spec under `docs/`, commit it and link it from the issue. The issue remains authoritative for current state and decisions.

### Ready

The design is approved, implementation order is clear and the plan is actionable. Large releases use one release epic plus independently testable child workstreams.

### In progress

Create a dedicated branch from current `main`. Post the branch/PR relationship to the issue. Update issue checklists at meaningful checkpoints rather than posting per-commit noise.

### CI green

The exact candidate head must pass the repository's authoritative workflow. Record the exact commit SHA, workflow run, test count/result, release/source/build contracts and any safety checks in the controlling issue.

Do not weaken safety or release contracts merely to get green CI.

### DEV published

Merge only the reviewed exact green head. The existing single free-only `main` workflow builds and publishes to Roblox DEV when configured. Post the merged `main` SHA, workflow run, built release identity, artifact count and returned Roblox DEV place version to the controlling issue.

LIVE promotion remains a separate human-gated process.

### Human acceptance

For player-facing or visual changes, CI proves engineering integrity, not quality. The issue defines the required real-client test or screenshot views. Record screenshots/observations and the pass/fail verdict. Visual work can be engineering-green and still fail human acceptance.

### Done

Close the issue only when its defined acceptance criteria have been met. Release epics remain open through publication and any required human acceptance.

## Issue structure

### Release epic

Use a release epic for substantial versions. Include:

- release identity and target version
- problem statement and goal
- approved design direction
- scope and non-goals
- ordered workstreams
- branch and PR links
- engineering acceptance checklist
- human/player acceptance checklist
- CI/build evidence
- Roblox DEV publish evidence
- final outcome

### Work item

Use a child/work-item issue for an independently testable component. Include:

- parent release or feature issue
- objective
- exact scope
- relevant files/components
- dependencies
- implementation checklist
- acceptance criteria
- progress/evidence

## Branch and PR rules

- Base implementation branches on current `main`.
- Name branches after the release/issue purpose.
- Every PR references the controlling issue. Use `Issue: #N` when the issue must remain open after merge; use `Closes #N` only when merge genuinely completes the issue.
- Keep PRs draft while materially incomplete.
- PR descriptions summarize implementation, verification, risks and remaining human acceptance.
- The exact final PR head must be green before merge.
- Player-facing visual releases require explicit merge authorization unless release-wide authorization has already been recorded.

## Evidence rules

At CI-green / publish time, record as applicable:

- exact candidate SHA
- merged `main` SHA
- authoritative workflow run ID and conclusion
- unit/spec count and result
- analysis/format/compile result
- source/release/build contract result
- built release identity
- retained GitHub Actions artifact count
- Roblox DEV place version
- real-client screenshot/gameplay acceptance result

Never copy credentials, API keys, tokens or other secret values into issues, docs, PR bodies, comments or source files.

## Visual release rules

Visual quality is judged from the real Roblox client. Source metadata and builder names do not prove visual success.

Before implementation, define a visual language and screenshot acceptance views. During review, check composition, silhouette, material hierarchy, density, readability, mobile screen occupation, traversal obstruction and consistency against player avatars.

Do not copy distinctive expression from reference games. Use references only to communicate qualities such as palette, softness, density, landmark composition or readability.

## Emergency fixes

Urgent fixes still start with a GitHub Issue. The issue may be compact, but it must state the symptom, intended smallest safe change, acceptance and evidence. Emergency is not an exception to traceability.

## Current example

`v0.7.3 · ART R7 · Premium Visual World Pass` is the first release executed end-to-end under this model. Its release epic and child issues demonstrate the expected pattern for future TinyWorld work.
