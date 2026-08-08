# TinyWorld v0.0.3 Living Village Design

**Date:** 2026-08-08  
**Target branch:** `feat/v0.0.3-living-village`  
**Baseline:** local `main`, containing the v0.0.1 foundation and the v0.0.2 alpha candidate

## Goal

Turn the v0.0.2 village from a visually bounded prototype into a stable, capacity-aware living world. v0.0.3 fixes the reported walking grass flicker, removes the four-plot structural limit, surrounds the village with woods, cliffs, and sea, and gives that boundary a small repeatable exploration route.

The existing v0.0.1 gameplay contract and v0.0.2 presentation work remain intact: homes, gardens, the fountain, Courier work, Tiny Bike, privacy, trade, Village Fund, onboarding, and the Giant Kitchen portal are not replaced or monetised.

## User experience

When a player enters the village, the central landmarks remain readable, but the world no longer ends at an arbitrary square of green. Player plots occupy deterministic slots around the village core. Beyond them, the player can see and visit three safe landmarks: the Woodland Trail, the Cliff Lookout, and the Sea Dock. Rock cliffs and the sea communicate the playable boundary without invisible walls or an unfinished horizon.

The player can complete a Boundary Explorer route once per UTC day by visiting all three landmarks and returning to the Explorer Board. The route awards `+250 coins` and `+100 XP`; it is server-authoritative, idempotent for the day, and free for every player.

## Root-cause fix for grass flicker

The current generated world uses a large `VillageGround` part with `Enum.Material.Grass`, four `PlotBase` parts also using `Enum.Material.Grass`, and additional decorative surfaces layered above those parts. The broad material surfaces are the highest-risk source of the reported movement shimmer, and the generated layout makes it difficult to distinguish ground from decoration.

v0.0.3 establishes these geometry rules:

1. Large walkable slabs use `Enum.Material.Ground` with the existing green palette, not the animated Roblox grass material.
2. A broad walkable region has one authoritative collision/top surface; decorative overlays are non-collidable and remain visually separated from it.
3. The `VillageGround` and every `PlotBase` use the stable ground material and have explicit surface-height ownership.
4. Small foliage can still use `LeafyGrass` or modeled green parts, but no broad gameplay floor depends on animated grass texturing.
5. A static material guard prevents the named broad ground surfaces from reverting to `Enum.Material.Grass`.

The runtime acceptance test will compare a fresh v0.0.3 Play session while walking across the public core, a plot, and a boundary transition. If the visual shimmer remains after the material/layer correction, the next diagnosis will inspect camera distance and lighting independently; no unrelated visual change will be used as a substitute for evidence.

## Capacity-aware world layout

The current four hard-coded plot origins become a deterministic shared layout contract in `src/shared/WorldLayoutRules.luau`.

- `WorldLayoutRules.create(maxPlayers)` returns exactly `max(4, floor(maxPlayers))` plot slots.
- The first four slots preserve the current v0.0.2 positions so existing Studio screenshots and player orientation remain familiar.
- Additional slots are placed in square rings around the central village core at a spacing that prevents plot-base overlap.
- The returned layout includes the plot spacing, the maximum plot extent, the boundary extent, and the three landmark positions.
- The boundary extent is calculated from the outermost generated slot, so the world expands with the configured server capacity.
- The layout is deterministic for a given capacity. It is generated once when the server builds the place, not separately for each player.
- The server reads the configured Roblox `Players.MaxPlayers` value at startup. A server restart is required after changing that setting; the layout does not resize underneath active players.

`WorldBuilder` uses this layout to build plot slots. `PlotService` assigns any free slot and no longer contains a four-plot-specific message or capacity assumption. Houses remain created only for occupied slots; shared plot pads, prompts, and garden beds are created once per available slot.

The capacity tests cover at least 1, 4, 8, 16, 32, and 50 requested players, verify exact slot counts, verify unique non-overlapping plot bounds, verify stable first-four positions, and verify that the boundary lies outside every plot.

## Boundary environment

`src/server/BoundaryBuilder.luau` owns the perimeter and consumes the layout contract. It builds one shared boundary per server:

- **Sea:** a non-collidable `Water` belt outside the playable land with a sand transition, sized from the layout boundary extent.
- **Cliffs:** stepped `Rock`/`Basalt` formations at the outer land edge. They are anchored and collidable, with enough gaps for the Sea Dock and public viewpoint.
- **Woods:** bounded rings of tree trunks, canopies, shrubs, and safe walking clearings between the plot ring and cliff edge. The number of decorations scales with perimeter segments, not with player count multiplied by decoration count.
- **Landmarks:** readable, color-coded marker pads and prompts at the Woodland Trail, Cliff Lookout, and Sea Dock. Each has a safe arrival/interaction position and a label that remains within the existing bounded BillboardGui rules.

The boundary is scenery plus navigation guidance, not a second duplicated world per player. The part budget is deterministic from the configured capacity and does not create player-specific forests, cliffs, or water.

## Boundary Explorer route

`src/shared/ExplorationRules.luau` owns the deterministic mission state. The profile schema advances to version 4 with these fields:

- `boundaryExplorationDay: string` — the UTC day for the current visit mask;
- `boundaryExplorationMask: number` — a three-bit mask for Woodland Trail (`1`), Cliff Lookout (`2`), and Sea Dock (`4`);
- `boundaryCompletions: number` — the number of daily Boundary Explorer routes claimed.

The normalization path preserves all v0.0.1–v0.0.2 fields and defaults these new fields safely for old profiles. A new day resets only the exploration mask when the player next visits or claims; it does not reset any coins, inventory, house, garden, job, transport, portal, civic, privacy, or onboarding state.

`src/server/ExplorationService.luau` connects the three landmark prompts and the Explorer Board prompt:

1. Visiting a landmark marks its bit once for the current UTC day and syncs the player HUD.
2. Revisiting the same landmark is harmless and reports the current route count.
3. The board refuses an incomplete route and reports the missing count.
4. A complete route awards `+250 coins` and `+100 XP`, increments `boundaryCompletions`, clears the current mask, saves the profile, and reports completion.
5. Repeating the board after completion on the same day cannot award a second reward.

The client HUD adds a compact `Explore: x/3` line and uses the existing suggested-goal/status-message presentation. It remains presentation-only; all visit validation, rewards, and profile mutations stay on the server.

## Files and boundaries

Create:

- `src/shared/WorldLayoutRules.luau` — pure capacity/geometry calculations using numeric point records.
- `src/shared/ExplorationRules.luau` — pure daily landmark-mask and reward rules.
- `src/server/BoundaryBuilder.luau` — shared woods/cliffs/sea/landmark geometry.
- `src/server/ExplorationService.luau` — ProximityPrompt wiring, profile synchronization, and reward save.
- `tests/WorldLayoutRules.spec.luau` — deterministic capacity, spacing, and boundary tests.
- `tests/ExplorationRules.spec.luau` — visit, incomplete, completion, duplicate, and new-day tests.
- `docs/v0.0.3-living-village-test.md` — Studio and Computer Use acceptance route.
- `docs/superpowers/plans/2026-08-08-tinyworld-v0.0.3-living-village.md` — implementation plan.

Modify:

- `src/server/WorldBuilder.luau` — use stable ground, consume layout, and delegate perimeter/landmark construction.
- `src/server/PlotService.luau` — assign generated slots without the four-plot assumption.
- `src/server/Main.server.luau` — initialize the layout-aware boundary and exploration service.
- `src/shared/ProfileSchema.luau` — migrate to version 4 and normalize exploration fields.
- `src/server/PlayerStateService.luau` — replicate exploration progress and completion count.
- `src/client/Main.client.luau` — display v0.0.3 identity and exploration progress.
- `tests/run.luau` — register the new specs.
- `tests/verify-roblox-materials.ps1` — guard stable broad-ground materials and boundary surface references.
- `README.md`, `docs/progress.md` — document v0.0.3 and the new acceptance gates.

## Safety and product constraints

- All rewards, visits, capacity assignment, ownership, and profile mutations are server-authoritative.
- No client code receives authority over coins, XP, inventory, plots, exploration masks, or completion counts.
- No Robux products, fake product IDs, ads, pay-to-win upgrades, or purchase prompts are introduced.
- Existing v0.0.1/v0.0.2 schema data must survive migration unchanged.
- The boundary is generated once per server and uses bounded deterministic part counts.
- The current Rojo project structure and local Luau verification remain the source-of-truth workflow.
- The place must be synced and published only from the resulting Git branch; no manual Studio code edits are allowed.

## Acceptance gates

The v0.0.3 candidate is not complete until all of these have evidence:

1. Shared rule tests pass for layout capacity, exploration state, profile v4 migration, and all existing v0.0.1/v0.0.2 rules.
2. All server and client Luau files parse and analyze cleanly; material/runtime guards pass; Rojo builds the place.
3. The current branch is `feat/v0.0.3-living-village`, the v0.0.1/v0.0.2 baseline remains on local `main`, and the working tree is clean after intentional commits.
4. A fresh Computer Use Studio Play screenshot shows the v0.0.3 HUD, stable core ground, surrounding woods, cliffs, sea, and a capacity-generated plot ring.
5. The live route demonstrates all three landmark visits, the incomplete-route guard, successful Boundary Explorer reward, and same-day duplicate protection.
6. A fresh stop/rejoin restores the v4 exploration fields and all prior v0.0.2 progression.
7. Studio Output contains no current red runtime errors after a clean Play run.
8. The final handoff distinguishes self-tested one-player behavior from any two-player, fresh-account, or remote-device gate that still needs a human.
