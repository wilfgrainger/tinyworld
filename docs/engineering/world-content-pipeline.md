# World content pipeline

## Pipeline

1. Pure shared definitions/layout rules choose stable IDs, bounded slots, neighbourhoods, anchors, content metadata, art seed and budgets.
2. World orchestration requests a named prefab/builder for a semantic role.
3. The builder creates an authored native-part fallback or approved manifest-backed visual and returns semantic anchors/models.
4. Server services bind interactions and retain authority over validation, prices, rewards, ownership and persistence.
5. Source/build guards verify boundaries; Studio/device routes verify appearance, traversal, network behaviour and performance.

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

## Content-definition boundary

`ItemDefinitions`, `FurnitureDefinitions`, `ActivityDefinitions`, `WorldDefinitions`, `ShopDefinitions` and `AppearanceDefinitions` own static content metadata. Builders consume semantic roles/IDs; profiles store player state only.

Adding a production asset does not change server price/reward/ownership logic.

## Furniture pipeline

1. furniture definition declares category, price, prefab role, interaction verb and footprint;
2. server grants ownership through Home Store rules;
3. client previews locally;
4. server validates/canonicalises home-local placement;
5. `FurniturePrefabBuilder` renders a recognisable fallback/approved asset behind the placement ID;
6. `FurniturePlacementService` binds owner/guest-safe interaction and store affordance;
7. persisted placement re-renders after shell/theme rebuild/rejoin.

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

Invented IDs fail the release contract. Empty manifest means native fallbacks remain authoritative.

## Fallback and replacement

If an optional visual asset is unavailable/unapproved, use the bounded native-part recipe for that semantic role. Never substitute an arbitrary coloured cube/neon ring as finished content.

A mesh/model replacement must preserve:

- builder return/semantic contract;
- art role;
- interaction anchors;
- collision/query safety;
- gameplay authority;
- labels-off recognisability;
- performance/mobile budget.

## Verification

Pure tests verify deterministic definitions/rules. Release/source guards verify manifest/boundary presence. Luau analysis/format/recursive compilation and Rojo build verify repository/build properties.

Studio/device evidence separately verifies visual quality, traversal, prompt location, placement, multiplayer replication, memory/FPS/network behaviour and labels-off recognisability. Static inspection never substitutes for those gates.