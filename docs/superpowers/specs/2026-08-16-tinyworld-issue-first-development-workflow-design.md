# TinyWorld Issue-First Development Workflow Design

**Status:** Approved design for implementation
**Date:** 2026-08-16
**Repository:** `wilfgrainger/tinyworld`
**First release using this model:** `v0.7.3 · ART R7`

## 1. Goal

Make GitHub Issues the operational source of truth for TinyWorld development from idea through Roblox DEV publication and human acceptance.

The workflow must make it possible to answer, from GitHub alone:

- what are we building?
- why are we building it?
- what design was approved?
- what work remains?
- what branch and PR implement it?
- what CI evidence exists?
- what Roblox DEV version contains it?
- has the family/player visual acceptance gate passed?

## 2. Core rule

Every meaningful feature, visual release, refactor, infrastructure change, bug fix, or release starts with a GitHub Issue before implementation begins.

The issue is the operational source of truth. Durable design documents may still exist under `docs/superpowers/specs/` when required by the engineering methodology, but the issue must summarize the approved design and link to the durable spec. The issue remains authoritative for current status, decisions, implementation progress, test evidence, publication evidence, and human acceptance.

A tiny emergency fix may use a compact issue, but it does not bypass issue-first tracking.

## 3. Issue structure

### 3.1 Release epic

Substantial releases use one release epic issue. The epic contains:

- release identity and target version
- problem statement and goal
- approved visual/product/technical direction
- scope and non-goals
- ordered child workstreams
- branch and PR links
- acceptance checklist
- CI and build evidence
- Roblox DEV publish evidence
- human/family acceptance result
- final completion summary

The release epic stays open until the complete candidate is published to Roblox DEV and the required human acceptance gate is reached.

### 3.2 Child issues

Independent workstreams that can be accepted separately receive child issues. Each child issue contains:

- objective
- exact scope
- relevant files/components
- acceptance criteria
- implementation checklist
- dependencies
- progress notes
- links to commits or PR

For ART R7 the required order is:

1. General map
2. Houses
3. Activities
4. NPCs
5. Final visual acceptance and DEV publish

Later workstreams must not be declared complete while an earlier required dependency remains unresolved.

## 4. Lifecycle

The standard lifecycle is:

`design → ready → in progress → CI green → DEV published → human acceptance → done`

GitHub issue comments record lifecycle transitions with evidence.

### Design

Capture requirements, reference screenshots, alternatives considered, decisions, scope, non-goals, and acceptance criteria.

### Ready

The design has been approved and the implementation plan is actionable.

### In progress

A branch exists and implementation has started. Progress is reflected in the issue checklist and concise comments at meaningful checkpoints.

### CI green

The exact candidate head has passed the repository's authoritative verification workflow. The issue records the exact commit SHA, workflow run, tests, build contract, and any visual/source contracts.

### DEV published

The exact merged `main` commit has successfully published through the repository's single free-only DEV publish workflow. Record the `main` SHA and Roblox DEV place version.

### Human acceptance

For player-facing or visual work, automated tests are insufficient. The issue records screenshots, test observations, defects, and pass/fail decision from the intended human testers.

### Done

The issue closes only when its defined acceptance criteria are satisfied. A release issue is not complete merely because CI or publishing succeeded.

## 5. Branch and PR rules

- implementation work uses a dedicated branch based on current `main`
- branch names should identify the issue/release purpose
- every PR references the controlling issue using `Closes #N`, `Fixes #N`, or an explicit `Issue: #N` relationship when the issue must remain open after merge
- PR descriptions summarize implementation, verification, risks, and what remains for human acceptance
- PRs are draft while materially incomplete
- the exact final PR head must be green before merge
- player-facing visual releases require explicit human authorization to merge unless the user has granted release-wide authorization in the controlling issue/conversation
- post-merge DEV publication evidence is posted back to the controlling issue

## 6. Design and decision recording

Designs must not live only in chat.

The controlling issue records:

- approved direction
- reference imagery or links where available
- visual language and quality bar
- architecture decisions
- rejected alternatives when material
- changed requirements and why

If a Superpowers design spec is required, the issue links the committed spec and includes a concise operational summary so contributors do not need to reconstruct context from chat history.

Any material change to scope or acceptance during execution is recorded in the issue before it is treated as the new plan.

## 7. Progress tracking

Progress is updated centrally through GitHub Issues rather than relying on chat memory.

Use checklists for discrete acceptance items. Add comments only at meaningful state changes, for example:

- design approved
- implementation branch created
- workstream complete
- significant defect discovered
- CI exact-head green
- PR merged
- Roblox DEV version published
- human test result

Do not create noisy per-commit status comments unless a commit materially changes acceptance status.

## 8. Visual release acceptance

Visual work has two independent gates:

### Engineering gate

Automated verification proves the build is syntactically valid, structurally safe, release metadata is correct, rendering safety contracts remain intact, and the candidate publishes correctly.

### Human visual gate

Real Roblox client screenshots/gameplay prove the experience meets the visual brief.

Visual acceptance must use predefined screenshot views when practical. A release can be engineering-green and still be visual-fail.

For ART R7, required screenshot views are:

1. village centre wide shot
2. fountain plaza hero shot
3. harbour / Skye area
4. Finn / fishing area
5. Pip / garden area
6. residential / house row angle
7. Mara / market angle
8. NPC close-up
9. mobile HUD in village centre
10. warm-light/evening view if available

## 9. CI and publishing evidence

The controlling issue must record, after successful publication:

- merged `main` commit SHA
- authoritative GitHub Actions workflow run ID/result
- test count/result
- source/release/build contract result
- built release identity
- retained Actions artifact count
- Roblox DEV place version returned by publishing

Secrets are never copied into issue text, comments, logs, docs, or PR bodies.

## 10. Repository enforcement

Implementation will codify this model in:

- `AGENTS.md`
- `docs/DEVELOPMENT_WORKFLOW.md`
- GitHub issue templates for release epics and work items
- GitHub pull request template referencing the controlling issue and evidence gates

The repository guidance will instruct future agents/contributors to read the controlling issue before modifying code and to keep the issue updated through publication and acceptance.

## 11. ART R7 adoption

ART R7 is the first release executed fully under this workflow.

Release identity: `v0.7.3 · ART R7 · Premium Visual World Pass`.

Visual direction: original TinyWorld interpretation of the supplied reference screenshots, emphasizing bright cheerful colour, soft/rounded stylised forms, strong landmark composition, richer visual density, clearer district identity, more charming houses, activity spaces that advertise their purpose visually, and character-grade NPC presentation. The references are inspiration, not assets to copy.

Required implementation order:

1. General map
2. Houses
3. Activities
4. NPCs
5. Full candidate verification, merge, DEV publish, and family screenshot test

R7 intentionally avoids major new gameplay systems. Existing R6 gameplay remains functional while its presentation is upgraded.

## 12. Success criteria

The workflow is successful when:

- future contributors can understand current work without chat history
- every active release/feature has a clear controlling issue
- design, progress, PR, CI, publication and acceptance evidence are traceable from that issue
- visual work cannot be called complete from CI alone
- Roblox DEV versions can be traced back to the exact issue, PR and commit
- ART R7 is managed end-to-end under this model
