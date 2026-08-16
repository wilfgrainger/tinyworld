# TinyWorld Issue-First Development Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make GitHub Issues the authoritative operational record for every meaningful TinyWorld change from approved design through CI, Roblox DEV publication, and human acceptance.

**Architecture:** Keep durable methodology in repository docs and templates while GitHub Issues hold current design, status, decisions, evidence and acceptance. `AGENTS.md` points contributors at the controlling issue first, `.github` templates make the relationship explicit, and PRs require an issue/evidence trail.

**Tech Stack:** GitHub Issues, GitHub pull requests, Markdown repository guidance, existing TinyWorld GitHub Actions workflow.

## Global Constraints

- Every meaningful feature, visual release, refactor, infrastructure change, bug fix, or release starts with a GitHub Issue before implementation.
- The controlling issue is authoritative for current design, status, decisions, implementation progress, test evidence, publication evidence and human acceptance.
- Visual/player-facing work is not complete from CI alone.
- Secrets never enter issues, docs, PR bodies or comments.
- Existing single free-only CI/direct DEV publication model remains unchanged.

---

### Task 1: Repository workflow guidance

**Files:**
- Modify: `AGENTS.md`
- Create: `docs/DEVELOPMENT_WORKFLOW.md`

**Interfaces:**
- Consumes: approved workflow design in `docs/superpowers/specs/2026-08-16-tinyworld-issue-first-development-workflow-design.md`.
- Produces: mandatory contributor rules and canonical lifecycle `design → ready → in progress → CI green → DEV published → human acceptance → done`.

- [ ] **Step 1:** Rewrite stale release-specific authority in `AGENTS.md` so the first action for meaningful work is locating/creating the controlling issue.
- [ ] **Step 2:** Preserve product, security, server-authority, rendering-safety and verification rules while removing obsolete v0.6.3-only statements.
- [ ] **Step 3:** Add `docs/DEVELOPMENT_WORKFLOW.md` with issue-first lifecycle, evidence requirements, visual acceptance rules, branch/PR rules and publish traceability.
- [ ] **Step 4:** Verify the two files do not contradict the approved workflow design.
- [ ] **Step 5:** Commit as `docs: codify issue-first development workflow`.

### Task 2: GitHub templates

**Files:**
- Create: `.github/ISSUE_TEMPLATE/release.yml`
- Create: `.github/ISSUE_TEMPLATE/work-item.yml`
- Create: `.github/pull_request_template.md`

**Interfaces:**
- Consumes: workflow lifecycle and evidence model.
- Produces: structured issue/PR entry points requiring controlling issue, design, acceptance and evidence.

- [ ] **Step 1:** Add release template fields for release identity, goal, approved design, workstreams, non-goals, engineering acceptance and human acceptance.
- [ ] **Step 2:** Add work-item template fields for parent issue, objective, exact scope, files/components, dependencies, checklist and acceptance.
- [ ] **Step 3:** Add PR template requiring controlling issue, implementation summary, verification evidence, risk notes, DEV publication expectation and human acceptance status.
- [ ] **Step 4:** Confirm templates never request credentials or secret values.
- [ ] **Step 5:** Commit as `chore: add issue-first GitHub templates`.

### Task 3: Governance verification and integration

**Files:**
- Test: existing `.github/workflows/tinyworld-ci.yml`
- Track: GitHub Issue `#16`

**Interfaces:**
- Consumes: Tasks 1-2.
- Produces: merged governance baseline on `main` for all future work.

- [ ] **Step 1:** Open a PR from `chore/issue-first-development-workflow` referencing Issue #16.
- [ ] **Step 2:** Run the authoritative existing CI workflow on the exact PR head.
- [ ] **Step 3:** Review the exact diff for stale release authority, contradictory rules and accidental runtime changes.
- [ ] **Step 4:** Post exact-head CI evidence to Issue #16.
- [ ] **Step 5:** Squash-merge the exact green head under the user's release-wide authorization.
- [ ] **Step 6:** Record merged main SHA and any resulting DEV publish run in Issue #16.
- [ ] **Step 7:** Keep Issue #16 open until ART R7 demonstrates the workflow end-to-end.
