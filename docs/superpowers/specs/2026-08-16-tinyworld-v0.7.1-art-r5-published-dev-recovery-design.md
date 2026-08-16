# TinyWorld v0.7.1 ART R5 Published DEV Recovery

Status: Approved design
Date: 16 August 2026
Branch: `release/v0.7.1-art-r5-recovery`
Target: TinyWorld DEV only

## 1. Problem

TinyWorld v0.7.0 successfully built and published to DEV, but real-player testing exposed a severe presentation failure: purple/blue checkerboard mesh fragments and floating broken visual geometry appeared throughout the village.

The failure is architectural, not a minor polish defect.

Current source establishes the failure path:

- `ProductionAssetRegistry` contains no approved persistent Roblox production assets.
- `ProductionVisualService` treats the `DEV` release channel as eligible for `EditableMeshPreviewFactory`, even when running as a published Roblox server.
- `EditableMeshPreviewFactory` and `ProductionMeshFactory` generate presentation geometry at runtime through EditableMesh and convert it to MeshParts.
- `ProductionVillageVisuals` hides the existing legacy visual geometry before the replacement visual has proved that it mounted successfully.

The result is that a published DEV server can hide working presentation and then depend on an experimental preview path for player-facing art.

## 2. Recovery objective

ART R5 makes published DEV visually fail-safe.

A player must never see checkerboard/debug/failure geometry merely because production art is missing or cannot load.

The recovery rule is:

```text
approved persistent production asset available
    -> mount it
    -> verify successful replacement
    -> hide legacy presentation

approved production asset absent or mount fails
    -> retain legacy presentation unchanged
```

Runtime EditableMesh preview is a Studio authoring facility only. It is not a published-game fallback.

## 3. Scope

ART R5 is a recovery release, not the full premium art rebuild.

Included:

- make EditableMesh preview Studio-only;
- prevent published DEV from entering preview visual state;
- preserve legacy visuals unless a replacement has mounted successfully;
- make missing production assets an expected clean fallback rather than a broken state;
- cover hero village buildings, market, fountain, portals, trees, hedges and supporting props through the safe replacement rule;
- ensure Bike, Boat, Car, companions and the future spaceship prestige affordance cannot expose preview-only presentation in published DEV;
- update release identity to `v0.7.1` / `ART R5`;
- add automated source/contracts proving the bad R4 published-preview path cannot return;
- preserve the existing single free-only GitHub Actions workflow and direct `main -> DEV` publishing path.

Excluded:

- broad village redesign;
- new gameplay or progression;
- profile-schema changes;
- LIVE publishing;
- automatic creation or upload of permanent Roblox art assets;
- claiming premium visual acceptance from CI alone.

The next premium-art pass can progressively replace fallback visuals with approved persistent Roblox assets once ART R5 establishes a trustworthy published baseline.

## 4. Architecture

### 4.1 ProductionVisualService

`ProductionVisualService` becomes environment-strict.

For a published server:

1. Look up the role in `ProductionAssetRegistry`.
2. If an approved persistent asset exists, attempt to load and prepare it.
3. Return a successful mounted replacement only after a valid model is available.
4. If no approved asset exists or loading fails, return a clean no-replacement result.
5. Never invoke `EditableMeshPreviewFactory`.

For Roblox Studio:

1. Prefer an approved persistent asset when available.
2. If unavailable, permit `EditableMeshPreviewFactory` for art-authoring preview.
3. Mark preview output explicitly as Studio preview.

`ReleaseInfo.channel == "DEV"` must no longer authorize preview geometry. Environment capability comes from Studio state, not release channel.

### 4.2 Transactional visual replacement

Replacement is transactional from the caller's point of view.

Current unsafe order:

```text
hide legacy -> attempt replacement
```

ART R5 order:

```text
attempt replacement -> validate replacement -> hide legacy
```

If replacement fails, the caller makes no destructive visual change.

`ProductionVillageVisuals.mountFixed` and equivalent replacement helpers own this ordering consistently.

### 4.3 Safe fallback semantics

An empty `ProductionAssetRegistry` is valid and means that published DEV uses the existing authored legacy presentation.

Missing art is therefore represented as:

```text
replacementMounted = false
legacyVisible = true
```

It must not be represented by placeholder cubes, checkerboard textures, floating fragments, or half-hidden semantic models.

### 4.4 Preview isolation

`EditableMeshPreviewFactory` and/or `ProductionMeshFactory` will contain an explicit Studio guard so accidental direct invocation from a published server also fails closed.

The guard must occur before any runtime preview mesh is created.

### 4.5 Other ART R5 mesh users

ART R5 must audit direct `ProductionMeshFactory` usage added during v0.7.0, including hero vehicles, companions and the future prestige pad.

Published DEV may not depend on preview-only runtime EditableMesh generation for these objects. Each direct user must either:

- use a safe existing authored presentation in published servers; or
- have a deterministic non-preview fallback that cannot produce broken mesh/debug rendering.

This audit is part of ART R5 acceptance, not deferred work.

## 5. Data flow

### Published DEV

```text
world builder
  -> semantic / legacy presentation exists
  -> ProductionVillageVisuals requests replacement
  -> ProductionVisualService checks persistent registry
      -> approved persistent asset loads: mount replacement, then hide legacy
      -> no valid asset: return no replacement, leave legacy untouched
```

### Studio

```text
world builder
  -> semantic / legacy presentation exists
  -> ProductionVillageVisuals requests replacement
  -> persistent asset if available
  -> otherwise Studio-only EditableMesh preview
  -> successful replacement allows legacy presentation to be hidden
```

## 6. Error handling

ART R5 is fail-safe by default.

- Missing registry entry: informational degraded-art condition, retain legacy visuals.
- Persistent asset load error: warn with role, retain legacy visuals.
- Preview requested outside Studio: reject before geometry creation.
- Preview mesh creation failure in Studio: warn and retain legacy visuals.
- Replacement model exists but has no valid visible BasePart/MeshPart content: treat as failed replacement and retain legacy visuals.
- Production credentials and Roblox asset IDs remain external/registry-driven; no guessed IDs are introduced.

No error path may hide the last known-good player-facing visual.

## 7. Automated acceptance

The single `TinyWorld CI` workflow must prove all of the following before merge:

1. Unit tests pass.
2. Shared analysis passes.
3. StyLua passes.
4. Server/client Luau compile passes.
5. ART R5 source contract passes.
6. Existing release and free-only build contracts pass.
7. Deterministic `v0.7.1` Rojo build succeeds.
8. PR builds do not publish.
9. `main` publishes directly to DEV with zero retained Actions artifacts.

The ART R5 source/test contract must explicitly verify:

- published DEV cannot authorize EditableMesh preview based on release channel;
- preview factory is Studio-gated;
- replacement callers hide legacy visuals only after success;
- empty registry keeps legacy presentation valid;
- all direct production-mesh users are covered by a published-safe path;
- no second Actions workflow, artifact upload or cache storage is reintroduced;
- release stamp identifies `TinyWorld DEV · v0.7.1 · ART R5`.

## 8. Player-facing acceptance

CI is necessary but not sufficient.

After the merge publishes to DEV, the exact deployed place version must be tested in the Roblox client. The recovery release passes only when screenshots and play confirm:

- zero purple/blue checkerboard artefacts;
- zero floating broken mesh fragments;
- no hero building disappears because production art is unavailable;
- village, market, fountain, portals, trees, hedges and supporting props remain visually coherent;
- Bike, Car, Boat, companions and prestige-pad presentation do not show runtime-preview corruption;
- existing coast, Mermaid Land, NPC, home, progression and interaction gameplay still works;
- build stamp visibly identifies v0.7.1 ART R5.

Visual quality may still be below the long-term premium target. That is acceptable for ART R5 only if the published world is stable, coherent and free of broken presentation. Premium replacement work follows from this safe baseline.

## 9. Release and safety boundaries

- Target is DEV only.
- LIVE remains human-gated and untouched.
- Profile schema remains compatible.
- No new economy authority or client-authoritative state.
- No persistent GitHub Actions artifact/cache storage.
- One authoritative workflow remains.
- No production secret or credential is committed.
- Do not claim the visual recovery complete until real published-client evidence is reviewed.

## 10. Definition of done

ART R5 is complete when the code makes published preview corruption structurally impossible, all automated gates pass, v0.7.1 publishes successfully to DEV, and real Roblox client evidence shows the checkerboard/floating-art catastrophe is gone without breaking existing gameplay.
