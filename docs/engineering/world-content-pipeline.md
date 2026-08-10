# World content pipeline

## Pipeline

1. Pure shared definitions/layout rules choose stable IDs, bounded slots, neighbourhoods, anchors, content metadata, art seed and budgets.
2. World orchestration requests a named prefab/builder for a semantic role.
3. The builder creates an authored native-part/native-Roblox presentation or approved manifest-backed visual and returns semantic anchors/models.
4. Server services bind interactions and retain authority over validation, prices, rewards, ownership and persistence.
5. Source/build guards verify boundaries/prohibited mechanisms; Studio/device routes verify appearance, traversal, network behaviour and performance.

## Prefab contract

Every player-facing prefab has:

- stable semantic ID/builder function and named return fields;
- `TinyWorldArtRole`;
- `TinyWorldPhysicalAffordance`;
- recognisable silhouette, avatar-readable scale and meaningful material;
- explicit `TinyWorldInteractionAnchor = true` anchors where prompts are required;
- bounded collision/query/touch behaviour;
- no gameplay/economic authority hidden in the art asset.

Decoration is anchored, non-collidable, non-touching and non-queryable. Explicit interaction anchors are queryable.

Semantic metadata is an engineering contract, not proof of visual quality.

## Visual tier requirement

Before choosing a fallback recipe, classify the object:

### Hero

Player character presentation, starter home, civic buildings, fountain/jobs board, primary vehicles, portal entrances and signature keepsakes.

A hero fallback must itself look intentional. If preserving the Roblox-native/default presentation looks better than an available TinyWorld primitive fallback, preserve the better baseline.

### Interactive supporting

Furniture, activity equipment, parcels, gardening tools and traversal props. Simplified native-part construction is acceptable when recognisable/tactile.

### Background

Terrain, simple foliage, fences and distant dressing may use lower-detail recipes within budgets.

## World-text hierarchy

World builders communicate ordinary destination identity through:

1. silhouette/architecture;
2. materials/props/context;
3. small physical/diegetic sign where a proper name is useful;
4. local `ProximityPrompt` when interaction is possible.

Large always-on-top BillboardGui information rectangles are not a supported ordinary-world content primitive.

Dynamic text that genuinely belongs in the world, such as an owner name or trade ledger, is attached to a physical surface with a non-always-on-top `SurfaceGui` or is shown contextually.

## Content-definition boundary

`ItemDefinitions`, `FurnitureDefinitions`, `ActivityDefinitions`, `WorldDefinitions`, `ShopDefinitions` and `AppearanceDefinitions` own static content metadata. Builders consume semantic roles/IDs; profiles store player state/preferences only.

Adding or removing a visual fallback does not change server price/reward/ownership logic.

## Character presentation pipeline

Character style data remains definition/profile driven and server validated.

Visible presentation follows:

1. preserve the player's Roblox avatar as the safe baseline;
2. apply an approved TinyWorld asset only when its source/provenance/fit are acceptable;
3. never create primitive rectangular Part hair/shoes merely so every saved preference has an immediate visual representation.

A deferred visual preference is safer than degrading every character.

## Furniture pipeline

1. furniture definition declares category, price, prefab role, interaction verb and footprint;
2. server grants ownership through Home Store rules;
3. client previews locally;
4. server validates/canonicalises home-local placement;
5. `FurniturePrefabBuilder` renders a recognisable native-part/approved asset behind the placement ID;
6. `FurniturePlacementService` binds owner/guest-safe interaction and store affordance;
7. persisted placement re-renders after shell/theme rebuild/rejoin.

Hero/touched furniture receives the higher visual bar from the active art-direction contract.

## Impossible-world pipeline

Every launch world definition includes:

- entrance/reveal identity;
- visual rule unlike the village;
- unique traversal/activity mechanic;
- discoverable secret;
- bounded objective;
- physical keepsake/reward;
- home/village payoff.

Builders must create enough physical identity that the world is not merely a renamed collection room.

Impossible worlds may use stronger scale, glow and colour than ordinary village life because that contrast is part of the product fantasy.

## Determinism and budgets

Variation comes from fixed seeds and bounded authored variants. Builders avoid unseeded random generation for persistent composition. Plot, dressing, light, particle, ambient and model complexity stay within shared/quality budgets.

Ambient life remains deliberately small/deterministic unless measured performance supports expansion.

## Production asset manifest

`assets/manifests/assets.json` is the only approved Roblox-hosted production-asset registry. Each populated entry requires:

- semantic ID;
- real positive Roblox asset ID;
- owner/source;
- licence/provenance;
- prefab role;
- version/status;
- DEV approval;
- LIVE approval.

Invented IDs fail the release contract. Empty manifest means TinyWorld uses approved native/default presentation rather than inventing unavailable art.

## Fallback and replacement

If an optional visual asset is unavailable/unapproved, choose the best safe native/default presentation for that semantic role. Never substitute an arbitrary coloured cube/neon ring/primitive avatar add-on as finished content.

A mesh/model replacement must preserve:

- builder return/semantic contract;
- art role;
- interaction anchors;
- collision/query safety;
- gameplay authority;
- labels-off recognisability;
- performance/mobile budget.

## Verification

Pure tests verify deterministic definitions/rules. Release/source guards verify manifest/boundary presence and known prohibited mechanisms. Luau analysis/format/recursive compilation and Rojo build verify repository/build properties.

Studio/device evidence separately verifies visual quality, character appearance, traversal, prompt location, placement, multiplayer replication, memory/FPS/network behaviour and labels-off recognisability.

For v0.6.1 player-facing work, required observed visual rows block merge-ready status. Static inspection never substitutes for those gates.