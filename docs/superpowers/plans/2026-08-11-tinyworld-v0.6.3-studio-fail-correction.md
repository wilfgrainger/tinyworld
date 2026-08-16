# TinyWorld v0.6.3 Studio Fail Correction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans for this in-chat corrective pass. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct the exact visual failures observed in the first v0.6.3 Studio candidate without changing gameplay scope or merging to main.

**Architecture:** Keep the existing v0.6.3 builders and service anchors, but add a final replacement-oriented civic/ground pass that removes competing legacy hero geometry before composing the final visible result. Add an independent client-only candidate stamp so screenshots prove which release is being tested.

**Tech Stack:** Roblox Luau, Rojo 7.7.0, Luau 0.732 CI, StyLua 2.5.2, Rokit 1.2.0, schema 11.

## Global Constraints

- Work only on `release/v0.6.3-production-art-world-craft` / PR #8.
- Do not merge.
- Profile schema remains `11`.
- Preserve v0.6.2/v0.6.3 gameplay, persistence, economy, trade and interaction authority.
- No new gameplay systems or runtime frameworks.
- Exact Studio screenshots remain the visual acceptance authority.
- A hero view with prototype reading FAIL blocks release acceptance.

---

### Task 1: Add source guard for the observed Studio regression

**Files:**
- Modify: `tests/verify-v0.6.3-source-contract.sh`

**Interfaces:**
- Require a final civic replacement builder and DEV version stamp.
- Reject simultaneous legacy and replacement Town Hall / Village Shop roof geometry in final presentation code.

- [ ] Add guard requirements for `CivicHeroRebuildBuilder`, `VillageGroundRebuildBuilder`, and `ReleaseInfo`/build stamp.
- [ ] Keep existing visual source guards.
- [ ] Expected before implementation: RED.

### Task 2: Replace competing civic hero roof/silhouette geometry

**Files:**
- Create: `src/server/CivicHeroRebuildBuilder.luau`
- Modify: `src/server/Main.server.luau`

**Interfaces:**
- `CivicHeroRebuildBuilder.apply(root: Instance)`
- Consumes existing semantic models by name and never owns gameplay state.
- Removes only known visual descendants; interaction anchors/prompts remain untouched.

- [ ] Remove known legacy roof parts from Town Hall, Village Shop, Courier Depot and Workshop.
- [ ] Remove/replace conflicting craft roofs where necessary so exactly one visible roof assembly remains per hero building.
- [ ] Add coherent final roof assemblies using `ArchitecturalDetailBuilder.addPitchedRoof`.
- [ ] Add facade/entry structural detail only where it materially changes silhouette/readability.
- [ ] Rebuild the Market into several smaller supported stalls with clear gaps/circulation and no giant canopy mass.
- [ ] Apply this pass after the existing civic craft pass in `Main.server.luau`.

### Task 3: Break up the green-board ground composition

**Files:**
- Create: `src/server/VillageGroundRebuildBuilder.luau`
- Modify: `src/server/Main.server.luau`

**Interfaces:**
- `VillageGroundRebuildBuilder.apply(root: Instance)`
- `VillageGround` remains the physical fallback floor.
- New ground pieces are anchored, non-touch, non-query, non-colliding decorative layers.

- [ ] Tone the fallback ground so it recedes rather than dominates.
- [ ] Add deterministic neighbourhood lawn/soil/stone fields with angled/segmented edges.
- [ ] Add civic forecourt/verge fields and route-edge patches.
- [ ] Keep all overlays below/away from prompts and traversal geometry.
- [ ] Apply after `VillageLandscapeBuilder`.

### Task 4: Add always-visible DEV candidate stamp

**Files:**
- Create: `src/shared/ReleaseInfo.luau`
- Create: `src/client/BuildStamp.client.luau`

**Interfaces:**
- `ReleaseInfo.productVersion = "0.6.3"`
- `ReleaseInfo.channel = "DEV"`
- `ReleaseInfo.candidate = "PR #8"`

- [ ] Render a small non-interactive top-left pill below the Roblox inset.
- [ ] Text: `TinyWorld DEV · v0.6.3 · PR #8`.
- [ ] Do not overlap `StatusCluster`; place it beneath the existing HUD stack or in a narrow reserved row.
- [ ] Keep stamp independent of gameplay HUD state.

### Task 5: Resolve current StyLua failure

**Files:**
- Modify: `src/server/CivicCraftBuilder.luau`
- Modify: `src/server/HomeStoreDestinationBuilder.luau`

- [ ] Apply the formatter-required multiline form in `CivicCraftBuilder`.
- [ ] Apply the formatter-required single-line `HomeStorePlanterRight` call in `HomeStoreDestinationBuilder`.
- [ ] Make no behavioral change solely for formatting.

### Task 6: Verification and evidence boundary

**Files:**
- Modify: `docs/releases/v0.6.3/acceptance.md`
- Modify: `docs/v0.6.3-production-art-world-craft-test.md` only if candidate-stamp evidence wording needs tightening.

- [ ] Run/observe GitHub CI for the new head.
- [ ] Require Release authority PASS, Rojo build PASS, Luau specs PASS, analysis PASS, StyLua PASS, runtime compile PASS.
- [ ] Keep all Studio visual rows NOT RUN until the user opens the exact new candidate.
- [ ] Record the prior first-v0.6.3 Studio candidate as FAIL due to overlapping roofs, green-board composition and prototype hero geometry.
- [ ] Do not merge.

## Completion condition

Source/build can be called green only after CI passes. Visual success cannot be claimed until the user opens the exact updated candidate in Studio and supplies/reviews the eight required views.