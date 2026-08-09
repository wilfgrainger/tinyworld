# World content pipeline

## Pipeline

1. Pure shared layout rules choose bounded deterministic slots, neighbourhoods, anchors, art seed, and budgets.
2. World orchestration requests a named prefab for a semantic role.
3. The prefab builder creates an authored native-part model and returns explicit interaction anchors.
4. Server services bind prompts and retain authority over validation, rewards, ownership, and persistence.
5. Quality guards verify source boundaries; Studio play verifies appearance, traversal, and interaction.

## Prefab contract

Every player-facing prefab has:

- a stable semantic builder function and named return fields;
- a `TinyWorldArtRole` attribute;
- a `TinyWorldPhysicalAffordance` attribute;
- a recognizable silhouette, avatar-readable scale, meaningful material, and visible feedback;
- explicit anchors marked `TinyWorldInteractionAnchor = true` where prompts are required.

Decoration parts are anchored, non-collidable, non-touching, and non-queryable. Prompt anchors are the only queryable exception.

## Determinism and budgets

World variation comes from a fixed seed and a small set of authored variants. Builders do not call unseeded `math.random()`. Counts for plots, dressing, lights, particles, and ambient hooks remain bounded and are checked against shared visual budgets.

## Fallback and replacement

If an optional visual asset is unavailable, the builder uses the repository's bounded native-part recipe for that semantic role. It does not create an arbitrary coloured cube or neon ring. A future mesh replacement must preserve the builder's return shape, attributes, prompt anchors, collision safety, and service ownership.

## Verification

Pure tests verify shared rules. PowerShell source guards verify module and boundary presence. Luau analysis and compilation verify syntax where tools are available. Studio screenshots and play routes provide visual and runtime evidence; local source checks do not substitute for them.
