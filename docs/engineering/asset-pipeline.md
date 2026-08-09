# TinyWorld asset pipeline

## Principle

Native-part authored prefabs are a valid, testable fallback. They are not a permanent excuse to avoid production art for hero objects.

Production Roblox-hosted assets are introduced only through `assets/manifests/assets.json`.

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

Invented/placeholder Roblox IDs are forbidden. Empty manifests are valid and mean TinyWorld is using its native fallbacks.

## Replacement contract

A production model/mesh may replace a fallback only if it preserves:

- builder return contract;
- semantic art role;
- interaction anchors;
- ownership/gameplay authority;
- collision/touch/query policy;
- recognisability without labels;
- performance budget;
- mobile readability.

Visual replacement may not move economic or interaction authority into an asset script.

## Asset quality tiers

### Hero

Homes, vehicles, key furniture, civic buildings, portal landmarks, signature keepsakes. These receive the highest silhouette, material and animation attention.

### Interactive supporting

Ordinary furniture, activity equipment and portal traversal props. Must remain immediately recognisable and tactile.

### Background

Scenery and ambient dressing. Lower detail is acceptable but shape/material language must remain coherent and budgets strict.

## Provenance

Before a third-party asset enters the manifest, record the legal source/licence and ownership. Do not copy external skill, marketplace or reference-game assets because they are convenient.

## DEV/LIVE progression

1. native fallback proves gameplay contract;
2. candidate asset receives provenance review;
3. manifest entry created with real ID;
4. DEV visual/performance evidence recorded;
5. entry marked DEV approved;
6. launch/release review grants LIVE approval;
7. exact approved build is promoted.

## Evidence

Production asset evidence includes labels-off recognisability, interaction anchors, collision behaviour, mobile/device contrast and performance impact. Static manifest presence is not visual approval.