# TinyWorld v0.0.2 Alpha Visuals Design

**Date:** 2026-08-08  
**Status:** Approved for implementation by the user's explicit `Go complete Goal` instruction  
**Baseline:** `feat/v0.1-foundation` playable v0.0.1 slice  
**Target branch:** `feat/v0.0.2-alpha`

## Goal

Turn the current TinyWorld v0.0.1 playable slice into a family-testable v0.0.2 alpha with a warm, polished, low-poly visual identity that feels closer to a small storybook adventure world while preserving the existing gameplay contract and keeping device cost reasonable.

The referenced PDF is not present in the repository or the accessible Codex workspace. This design therefore uses the supplied Studio screenshots, the existing TinyWorld proposal context, and the user's visual brief as the authoritative working target. The implementation will not copy external game assets or branding.

## Product constraints

- Preserve the current v0.01/v0.0.1 gameplay functionality and server-authoritative rules.
- Add ten visible presentation/usability improvements for family playtesting; do not introduce a new progression system in this slice.
- Use Roblox-native Parts, simple shapes, materials, lighting, UI primitives, and existing prompts rather than a large asset download.
- Keep the scene readable on a phone-sized viewport and avoid unbounded decorative instance generation.
- Keep the existing Rojo project layout and Luau CLI test harness.
- Label the new candidate as `v0.0.2` / alpha in the player-facing HUD and documentation.
- Keep PR #1 draft and do not change remote publication state as part of this local implementation.

## Visual direction

TinyWorld should read as a bright, welcoming diorama:

- warm cream, timber, terracotta, sky blue, meadow green, berry pink, and portal purple accents;
- soft daytime lighting with gentle atmosphere and restrained bloom;
- strong silhouettes and colour-coded destinations so children can navigate without reading every sign;
- rounded sign cards and clear type hierarchy for a friendly, tactile feel;
- small clusters of trees, flowers, stone edging, roof trim, windows, awnings, lamps, and garden details instead of a noisy high-density scene;
- saturated interactable objects with a consistent highlight language;
- no pay-to-win visual treatment and no visual element that hides an interaction or blocks the camera.

## Ten improvements

1. **Warm visual identity:** centralise a TinyWorld palette and reuse it across world geometry, homes, labels, prompts, and UI.
2. **Lighting and atmosphere:** configure a sunny daytime scene with soft shadows, warm ambient light, restrained fog, and a small bloom effect.
3. **Village plaza:** give the spawn/fountain area a circular focal space, stone edging, planted corners, and a clearer gathering point.
4. **Roads and terrain dressing:** add path borders, grass islands, flowers, shrubs, and a bounded number of decorative trees and stones.
5. **Readable building silhouettes:** upgrade each landmark from a coloured block into a simple facade with roof, door, windows, trim, and a sign.
6. **Better homes and plots:** add porches, steps, windows, lamps, flower boxes, and tier-appropriate roof/upper features without changing house prices or rules.
7. **Clear interaction points:** add consistent colour markers, highlight objects, and stronger labels around existing prompts.
8. **Courier presentation:** make the depot, parcel station, destination counter, and success state visually coherent without changing rewards.
9. **Polished HUD and onboarding:** restyle the HUD/onboarding panels, improve hierarchy and mobile sizing, and correct the stale home-upgrade goal.
10. **Portal and Giant Kitchen showcase:** add a framed portal, arrival platform, crystal pedestals, clearer steps, and a more readable return route.

## Architecture

### Shared rules

Create `src/shared/GoalRules.luau` as a pure rules module. It will own the suggested-goal decision tree so the HUD copy can be regression-tested without Roblox services. `PlayerStateService` will delegate to it. The rule will inspect the next `HouseCatalog` tier's required level and price before choosing the copy.

### Server presentation

Create `src/server/VisualTheme.luau` for Roblox-native palette constants and one-time lighting configuration. Keep visual construction in the existing `WorldBuilder` and `PlotService` boundaries:

- `WorldBuilder` owns village ground, plaza, roads, landmarks, prompts, portal, and Giant Kitchen dressing.
- `PlotService` owns the player's house and plot-specific details.
- `VisualTheme` owns shared colours and lighting, not gameplay state.

Decorative parts must be anchored, simple, and bounded. Existing interaction parts and prompt connections remain the authority; visual markers may decorate them but must not grant rewards or bypass validation.

### Client presentation

Keep the client read-only with respect to game state. `Main.client.luau` will render the existing replicated attributes with a cleaner responsive card, alpha version label, progress hierarchy, and status message. `Onboarding.client.luau` will reuse the same palette and UI treatment. No client-side prices, rewards, inventory writes, or progression decisions will be added.

## Runtime and performance guardrails

- Prefer a small number of reusable helper functions over per-object bespoke logic.
- Use simple Parts and Roblox materials; do not add remote meshes, texture packs, or runtime downloads.
- Keep decorative generation to the fixed village and fixed Giant Kitchen; never generate per-frame or per-player scenery.
- Keep shadows on important landmarks and disable unnecessary collision/query/touch on purely decorative pieces.
- Keep labels short, readable, and limited to important destinations.
- Preserve the current `Enum.Material` guard and Rojo build validation.

## Acceptance evidence

The candidate is ready for the girls' alpha test only when all of the following are true:

1. The stale goal regression has a red-to-green automated test and the screenshot state now says `Upgrade your home to Cosy Cottage.` when Chewy is Level 4 with enough coins.
2. Existing Luau specs still pass, with the new goal rules included.
3. Luau parse, shared/test analysis, material guard, and Rojo build pass.
4. Studio Play shows the v0.0.2 alpha HUD and the decorated village without red Output errors.
5. Fountain, garden, courier, bike, plot/home, privacy/visit, trade, and portal interactions remain playable.
6. The ten visual improvements are recorded in a family playtest checklist with an observation for each item.
7. The v0.0.1 baseline is merged into local `main`, and the candidate work is on `feat/v0.0.2-alpha`.

