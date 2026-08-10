# TinyWorld asset pipeline

## Principle

Native-part authored prefabs are a valid production medium and fallback **only when the resulting object meets its visual tier**. They are not a permanent excuse to avoid production art for hero objects, and they are not permission to attach obviously inferior geometry to the player.

Production Roblox-hosted assets are introduced only through `assets/manifests/assets.json`.

## Safe fallback rule

When an approved asset is unavailable, choose the best safe existing presentation in this order:

1. preserve the Roblox-native/default presentation if it is already coherent;
2. use an existing TinyWorld authored prefab that passes its quality tier;
3. build a bounded native-part replacement only when it is visibly better and still passes the tier;
4. leave the feature visually deferred rather than shipping obvious placeholder geometry.

For player characters specifically, preserving the player's normal Roblox avatar is preferable to rectangular Part hair/shoes.

No fallback is automatically acceptable because it has `TinyWorldArtRole` metadata.

## Manifest requirements

Every production entry requires:

- semantic `id`;
- real positive `robloxAssetId`;
- owner;
- source;
- licence/provenance statement;
- intended prefab role;
- version;
- status;
- DEV approval boolean;
- LIVE approval boolean.

Invented/placeholder Roblox IDs are forbidden. Empty manifests are valid and mean TinyWorld is using approved native/default presentation rather than fabricating asset identities.

## Replacement contract

A production model/mesh may replace a fallback only if it preserves:

- builder return contract;
- semantic art role;
- interaction anchors;
- ownership/gameplay authority;
- collision/touch/query policy;
- recognisability without explanatory labels;
- performance budget;
- mobile readability.

Visual replacement may not move economic or interaction authority into an asset script.

## Asset quality tiers

### Hero

Player character presentation, homes, vehicles, key furniture, civic buildings, fountain/jobs board, portal landmarks and signature keepsakes.

Hero assets receive the highest silhouette, material, animation/audio and observed-evidence attention. A hero fallback that still reads as primitive placeholder geometry fails even if it is functional.

### Interactive supporting

Ordinary furniture, activity equipment, parcels, gardening tools and portal traversal props. Must remain immediately recognisable and tactile.

### Background

Scenery and ambient dressing. Lower detail is acceptable but shape/material language must remain coherent and budgets strict.

## World text and asset replacement

Replacing a model with production art must not reintroduce floating explanation panels. Proper names may use small diegetic signs integrated into the asset. Interactions remain contextual prompts or intentional UI.

Large always-on-top ordinary-world BillboardGui information walls are not an asset fallback.

## Provenance

Before a third-party asset enters the manifest, record the legal source/licence and ownership. Do not copy external skill, marketplace or reference-game assets because they are convenient.

The visual direction may use broad qualities such as Roblox life-sandbox readability, tactile warmth and fantastical contrast, but production assets must remain original TinyWorld expression.

## DEV/LIVE progression

1. native/default presentation proves the gameplay contract without visibly degrading the experience;
2. candidate asset receives provenance review;
3. manifest entry created with real ID;
4. DEV visual/performance evidence recorded;
5. entry marked DEV approved;
6. launch/release review grants LIVE approval;
7. exact approved build is promoted.

For a player-facing release, source presence does not satisfy visual approval. Required Studio/device evidence must be observed before merge-ready status where the active acceptance record requires it.

## Evidence

Production asset evidence includes:

- labels-off recognisability;
- character fit/appearance where applicable;
- interaction anchors;
- collision behaviour;
- mobile/device contrast;
- performance impact;
- exact candidate/build identity.

Static manifest presence is not visual approval.