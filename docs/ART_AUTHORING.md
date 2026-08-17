# TinyWorld Art Authoring

TinyWorld uses a hybrid Roblox/Rojo art pipeline. GitHub is the production source of truth.

## R8 authored model workflow

1. Create or edit a visual prefab as a Roblox `Model`.
2. Keep the model centred around a stable local origin with an intentional `PrimaryPart`.
3. Give gameplay attachment points stable names such as `FrontDoorAnchor`, `NpcAnchor`, `ActivityOrigin`, `FishingOrigin`, `DockBoardingAnchor` or `BoatSpawnAnchor`.
4. Export or sync the model as text `.rbxmx` beneath `assets/models/r8/`.
5. Add or update the matching entry in `assets/manifests/r8-models.json`.
6. Set `source`, `license`, `revision` and `devApproved` explicitly. Third-party content must have licence evidence before it can be DEV approved.
7. Calculate SHA-256 over the exact committed `.rbxmx` bytes and store it in the manifest.
8. Review the model, manifest, source contract and generated Rojo place in GitHub CI.
9. Only a committed model is production art. A Studio-only unsaved object is not a release asset.

## Runtime contract

Luau owns layout, collision, gameplay state, interaction wiring and deterministic placement. Hero visual form belongs in the authored model tree. A missing required R8 hero model is a release failure. Published DEV must not silently replace it with primitive fallback geometry.

## Editing existing assets

Prefer Roblox Studio plus Rojo sync/export or syncback where appropriate. Keep distinctive visual expression original to TinyWorld. Reference games and open-source projects may inform architecture and technique, but do not copy their distinctive models, layouts, UI or characters.

## Validation

Run:

```bash
luau tests/run.luau
bash tests/verify-v0.7.4-art-r8-source-contract.sh
rojo build default.project.json --output /tmp/TinyWorld-r8-check.rbxlx
```

The R8 source contract validates required files and manifest SHA-256 values. Published-client screenshots remain the final visual acceptance gate.
