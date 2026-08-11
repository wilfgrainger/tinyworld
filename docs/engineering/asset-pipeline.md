# TinyWorld asset pipeline

## Principle

TinyWorld gameplay authority and TinyWorld product art are separate systems.

Semantic roots, invisible/simple collision, interaction anchors, persistence and server validation remain ordinary Roblox/Luau contracts. Hero presentation is replaceable production art mounted behind those contracts.

Native `Part` geometry is still useful for collision foundations, interaction anchors, simple background dressing and deliberately simple supporting objects. It is **not** the default finished-art strategy for hero content.

ART R4 exists because repeated v0.6.3 Studio evidence proved that layering visible runtime `Part` builders could not meet the hero visual tier reliably.

## ART R4 source of truth

Original TinyWorld production art is defined under:

```text
art/
  README.md
  specs/
    palette.json
    village-product-art.json
```

`art/specs/village-product-art.json` is canonical for ART R4 geometry/composition. The checked-in `src/shared/ProductionArtSpec.luau` is the Roblox runtime mirror used by Studio/DEV MeshPart generation.

Generated glTF under `dist/art-r4/` is a build output, not the art authority.

## One specification, two consumers

### Studio/DEV product-art preview

`ProductionMeshFactory` uses `AssetService:CreateEditableMesh()` and explicit polygon vertices/triangles. The resulting `EditableMesh` is converted to a `MeshPart` with `AssetService:CreateMeshPartAsync(Content.fromObject(...))`.

This is not a return to the ART R1-R3 approach. Hero visuals are custom mesh geometry, not arrangements of visible Roblox block Parts.

`EditableMeshPreviewFactory` composes those custom MeshParts into the same semantic product-art roles that later permanent assets use.

This path lets the owner judge actual product-art geometry in Studio before permanent Roblox asset IDs exist.

### Permanent Roblox-hosted production asset

`tools/art/build_asset_pack.py` compiles the same ART R4 specification deterministically to glTF 2.0.

The generated glTF can be imported in Studio or uploaded through the credential-safe Open Cloud uploader. A successful Roblox upload returns the only acceptable source of `robloxAssetId`.

`ProductionVisualService` prefers a real approved manifest asset. If none exists in Studio/DEV, it uses the same-spec MeshPart preview.

The semantic gameplay role does not change when the visual switches from DEV preview to permanent hosted Model.

## Visual state vocabulary

1. **fallback/prototype**: interaction scaffolding or temporary presentation that is not accepted as finished player-facing art.
2. **authored-native**: deliberately composed Roblox-native presentation. Acceptable for supporting/background content only when Studio evidence meets its tier.
3. **production-preview-r4**: original TinyWorld custom MeshPart art produced from the canonical ART R4 specification for Studio/DEV evaluation.
4. **uploaded-candidate**: a real Roblox-hosted Model exists and is recorded in the manifest but has not yet passed DEV visual acceptance.
5. **approved-production**: the exact production asset/version has required provenance and observed acceptance evidence.

Metadata describes state. It never proves quality by itself.

## Manifest v3

`assets/manifests/assets.json` is the authority for permanent Roblox-hosted product art.

Schema v3 requires:

- semantic `id`;
- real positive `robloxAssetId`;
- owner;
- original source path;
- source SHA-256;
- licence/provenance statement;
- intended prefab role;
- version;
- status;
- quality tier;
- DEV approval boolean;
- LIVE approval boolean.

Invented, guessed and placeholder Roblox IDs are forbidden.

An empty `assets` array is valid during ART R4 Studio development. It means permanent hosted assets have not yet been truthfully published/approved. It does **not** mean Studio is using the old primitive fallback: Studio/DEV can render `production-preview-r4` custom MeshParts from the canonical art spec.

Once an asset record exists, its Roblox ID must be a real positive integer returned by Roblox.

## Runtime replacement contract

`ProductionVisualService` mounts product art behind semantic roots.

A visual replacement must preserve:

- server-owned gameplay authority;
- builder/service-facing semantic role;
- interaction anchors;
- ownership and persistence behavior;
- collision/touch/query policy;
- scale/pivot convention;
- recognisability without explanatory labels;
- performance budget;
- mobile readability.

Imported/uploaded Models contain no trusted executable behavior. Runtime strips unexpected executable descendants defensively before using a loaded production Model.

Visual code never owns price, reward, route completion, trade, ownership or persistence decisions.

## ART R4 mesh vocabulary

Current canonical shapes include:

- chamfered/bevelled solids;
- gable roof solids;
- hip roof solids;
- tapered frustums;
- faceted cylinders;
- faceted ellipsoids;
- extruded arch segments;
- framed-window meshes;
- curved fountain-water tubes.

The point is not high polygon count. The point is intentional silhouette.

A player should identify `house`, `shop`, `fountain`, `portal`, `tree`, `bench` or `market stall` before noticing the underlying modelling primitive.

## Hero quality tier

Hero content includes:

- starter/Cosy home exterior and interior;
- Town Hall;
- Village Shop;
- Home Store;
- Courier Depot;
- Workshop;
- Market/Trading Post;
- daily fountain;
- portal landmarks;
- primary vehicles;
- key furniture and signature keepsakes.

Hero content receives the highest silhouette, material, scale, lighting and observed-evidence attention.

A functional hero fallback that still looks like test geometry fails the release.

## Interactive supporting tier

Furniture, parcels, gardening equipment, street furniture, trees/planters and activity props may use simpler assets than heroes, but must still read immediately from normal play distance.

ART R4 uses a small reusable supporting mesh kit rather than scattering anonymous primitive geometry.

## Background tier

Terrain foundations, distant scenery, low fences, collision shells and other low-attention surfaces may remain native where they are coherent and performant.

Background simplicity may not visually overwhelm the hero layer or make the whole village read as a baseplate.

## Production asset publication

`scripts/upload-roblox-assets.py` is manual and dry-run by default.

Real execution requires runtime environment variables:

```text
ROBLOX_OPEN_CLOUD_API_KEY
TINY_WORLD_ASSET_CREATOR_ID
TINY_WORLD_ASSET_CREATOR_TYPE=user|group
```

No credential is committed.

The uploader:

1. validates a generated source asset;
2. hashes it;
3. uploads only explicitly selected roles;
4. waits for Roblox operation completion;
5. accepts only a real positive returned asset ID;
6. writes an `uploaded-candidate` manifest record with original TinyWorld provenance;
7. leaves `devApproved=false` and `liveApproved=false` until observed approval occurs.

A failed upload/moderation operation stops. It does not fabricate an ID or silently substitute known-bad hero art.

## Safe fallback rule

For player characters, preserving the normal Roblox avatar is better than an inferior TinyWorld fallback.

For ambient creatures, no creature is better than block/ball pseudo-character art.

For ART R4 required hero roles, missing production art is a degraded state. It must be reported as degraded and cannot satisfy visual acceptance merely because gameplay anchors still work.

## World text

Production art must not reintroduce floating explanation walls.

Proper names may use small diegetic signs integrated into the asset. Actions remain local prompts or intentional UI.

If a large label is required to explain what a hero object is, the object has failed its visual tier.

## Provenance and originality

ART R4 source art is original TinyWorld expression generated from repository-owned specifications.

Do not copy Creator Store models, marketplace assets or identifiable geometry from Brookhaven, Toca Boca, Ready Player One, Disney Dreamlight Valley or another reference merely because the visual direction mentions broad qualities from them.

Any future third-party input requires explicit legal source/licence review before entering the manifest.

## DEV to LIVE progression

1. canonical art spec exists in Git;
2. deterministic DEV MeshPart preview is reviewed in Studio;
3. source is compiled to deterministic upload format;
4. asset is uploaded and a real Roblox ID is captured;
5. manifest receives an `uploaded-candidate` record;
6. exact DEV asset receives visual/collision/performance evidence;
7. `devApproved` becomes true only after that evidence;
8. release review grants LIVE approval separately;
9. exact tested asset/build is promoted.

A code/source PASS does not satisfy Studio/device visual evidence.

## Evidence

Production-art evidence includes:

- exact candidate/revision stamp;
- labels-off recognisability;
- scale beside the Roblox avatar;
- interaction-anchor preservation;
- collision/traversal behavior;
- camera safety;
- mobile/device contrast;
- visual hierarchy;
- performance impact;
- source/asset provenance;
- exact asset/build identity where a permanent Roblox Model is used.

Static source or manifest presence never marks a hero object visually accepted.
