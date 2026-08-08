# TinyWorld v0.0.3 Living Village Implementation Plan

> For agentic workers: REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

Goal: Build v0.0.3 from the approved design: stable ground, capacity-aware plots, woods/cliffs/sea boundary, and the daily Boundary Explorer route.

Architecture: Pure layout and exploration rules live in src/shared and are tested with Luau CLI. Roblox geometry and prompt wiring remain server-only. WorldBuilder creates one shared capacity-aware world and delegates the perimeter to BoundaryBuilder; PlotService and ExplorationService consume generated contracts; the client only renders attributes.

Tech Stack: Luau CLI 0.650+, Roblox Studio, Rojo 7.7.0, PowerShell, Git.

## Global Constraints

- Server-authoritative rewards, visits, capacity assignment, ownership, and profile mutations.
- No client authority over coins, XP, inventory, plots, exploration masks, or completions.
- No Robux products, fake IDs, ads, pay-to-win, or purchase prompts.
- Preserve every v0.0.1/v0.0.2 profile field during migration.
- Build one shared deterministic boundary per server, not one per player.
- Large walkable slabs use Enum.Material.Ground; broad floors do not use Enum.Material.Grass.
- Read Players.MaxPlayers at server startup; capacity changes require a server restart.
- Sync and publish only from this Git branch through Rojo; no manual Studio code edits.
- Every production behavior change starts with a failing deterministic test.

---

### Task 1: Capacity-aware layout rules

Files:

- Create src/shared/WorldLayoutRules.luau
- Create tests/WorldLayoutRules.spec.luau
- Modify tests/run.luau

Interfaces:

- WorldLayoutRules.create(maxPlayers: number): Layout
- Layout.plotSlots: { { x: number, z: number } }
- Layout.plotSize, plotSpacing, coreHalfExtent, perimeterHalfExtent: number
- Layout.landmarks.woodlandTrail, cliffLookout, seaDock: numeric points
- WorldLayoutRules.boundsOverlap(a, b, size, padding?): boolean

- [ ] Write failing tests for capacities 1, 4, 8, 16, 32, 50; exact slot count max(4,floor(maxPlayers)); first four positions (-75,-75), (75,-75), (-75,75), (75,75); deterministic landmarks; no plot overlap with 8-stud padding; every plot inside the perimeter with 24-stud clearance.
- [ ] Register the spec and run the Luau suite; observe RED because the module is missing.
- [ ] Implement plotSize 60, plotSpacing 72, coreHalfExtent 60, square-ring slots, and perimeterHalfExtent equal to the furthest plot extent plus 48.
- [ ] Run the full Luau suite and observe GREEN.
- [ ] Commit with message feat: add capacity-aware village layout rules.

### Task 2: Profile v4 and exploration rules

Files:

- Create src/shared/ExplorationRules.luau
- Create tests/ExplorationRules.spec.luau
- Modify src/shared/ProfileSchema.luau
- Modify tests/ProfileSchema.spec.luau and tests/run.luau

Interfaces:

- ExplorationRules.MASKS = { WoodlandTrail = 1, CliffLookout = 2, SeaDock = 4 }
- ExplorationRules.TOTAL_MASK = 7
- ExplorationRules.visit(profile, dayKey, landmark): (boolean, string)
- ExplorationRules.claim(profile, dayKey): (boolean, string)
- ProfileSchema version 4 fields boundaryExplorationDay, boundaryExplorationMask, boundaryCompletions.

- [ ] Write failing tests for v3-to-v4 preservation, first/duplicate visits, incomplete claim, exact +250 coins/+100 XP completion, same-day duplicate protection, and new-day mask reset.
- [ ] Run the suite and observe RED.
- [ ] Normalize day string, mask 0..7, and non-negative completions. visit resets only the mask on a new day and rejects unknown IDs. claim requires mask 7, uses Progression.addXp(profile, 100), adds 250 coins, increments completions, clears the mask, and leaves the day key.
- [ ] Run all specs and observe GREEN.
- [ ] Commit with message feat: add Boundary Explorer profile rules.

### Task 3: Stable ground and scalable plots

Files:

- Modify src/server/WorldBuilder.luau, src/server/PlotService.luau, src/server/Main.server.luau
- Modify tests/verify-roblox-materials.ps1

Interfaces:

- WorldBuilder.build(maxPlayers: number?): World with layout and one plot entry per generated slot.
- PlotService iterates world.plots and makes no four-slot assumption.

- [ ] Extend the material guard to fail when VillageGround or PlotBase construction uses Enum.Material.Grass and require Enum.Material.Ground plus WorldLayoutRules; observe RED.
- [ ] Change VillageGround and PlotBase to Enum.Material.Ground with explicit surface heights; retain palette and prompt/economy behavior.
- [ ] Pass Players.MaxPlayers from Main.server.luau to WorldBuilder.build; replace the four-origin literal with layout.plotSlots; preserve the first four coordinates.
- [ ] Replace PlotService's four-plot message with: All player home plots are occupied; village activities still work. Verify all generated plots are assignable/releasable.
- [ ] Run material guard, Luau suite, parse checks, analysis, and Rojo build.
- [ ] Commit with message fix: stabilize ground and scale village plots.

### Task 4: Shared woods, cliffs, sea, and landmarks

Files:

- Create src/server/BoundaryBuilder.luau
- Modify src/server/WorldBuilder.luau, src/shared/VisualPalette.luau, tests/verify-roblox-materials.ps1

Interfaces:

- BoundaryBuilder.build(parent: Instance, layout): Boundary
- Boundary.landmarks.WoodlandTrail, CliffLookout, SeaDock expose part, prompt, position.
- Boundary.boardPrompt: ProximityPrompt; Boundary.root: Model.

- [ ] Extend the material guard to require Enum.Material.Water, Rock, and Sand plus BoundaryBuilder; observe RED.
- [ ] Build one boundary model with a Water sea belt, Sand transition, four stepped Rock/Basalt cliff runs, deterministic tree/clearing clusters, three landmark pads/prompts, and an ExplorerBoard prompt. Size from layout.perimeterHalfExtent; use fixed decorations per perimeter segment; sea is non-collidable and cliffs are anchored/collidable.
- [ ] Call BoundaryBuilder.build once from WorldBuilder.build and return the boundary contract; never build boundary geometry from a player callback.
- [ ] Run parser, material guard, and Rojo build.
- [ ] Commit with message feat: add scalable village woods cliffs and sea.

### Task 5: Server exploration service and v0.0.3 HUD

Files:

- Create src/server/ExplorationService.luau
- Modify src/server/Main.server.luau, src/server/PlayerStateService.luau, src/client/Main.client.luau

Interfaces:

- ExplorationService.new(world, ProfileStore, PlayerStateService) connects the three exact landmark prompts and board prompt.
- Attributes TinyWorldBoundaryMask and TinyWorldBoundaryCompletions.

- [ ] Add a focused source/test seam proving the service uses WoodlandTrail, CliffLookout, SeaDock and keeps reward logic server-side.
- [ ] On landmark trigger call ExplorationRules.visit(profile, DailyReward.dayKey(), landmarkId), sync, and report: Boundary route: x/3 landmarks visited. On board trigger call claim, sync/save success, and report clear incomplete/duplicate messages.
- [ ] Replicate both attributes; change title to TINYWORLD | v0.0.3 LIVING VILLAGE; add Explore: x/3; retain all existing HUD lines.
- [ ] Run specs, parse, analysis, guard, and Rojo build.
- [ ] Commit with message feat: add the Boundary Explorer daily route.

### Task 6: Docs, sync, publish, and live acceptance

Files:

- Create docs/v0.0.3-living-village-test.md
- Modify README.md and docs/progress.md

- [ ] Document fresh Play checks: HUD/version, core/plot/boundary ground, woods/cliffs/sea, landmark visits, incomplete board, successful reward, duplicate board, stop/rejoin, Output, and capacity evidence; separate fresh-account, two-player, and remote-device gates.
- [ ] Update README/progress with branch, mainline baseline, grass diagnosis/fix, capacity model, boundary, reward, and limitations.
- [ ] Run fresh tests/run.luau, all Luau parse checks, luau-analyze src/shared tests, material/runtime guard, Rojo build, and git diff --check.
- [ ] Confirm Rojo serves localhost:34872, sync the branch into Studio, start Play, and publish the code-synced place. Do not type source code into Studio.
- [ ] Use Computer Use to capture HUD, boundary, landmarks, reward, persistence, and clean Output screenshots. If normal movement/prompt holding cannot be reproduced, use only a documented runtime placement aid and retain a real-device gate.
- [ ] Commit with message docs: record TinyWorld v0.0.3 acceptance evidence.
- [ ] Audit a clean feat/v0.0.3-living-village branch, v0.0.1/v0.0.2 on local main, and truthful self-test versus external gates.
