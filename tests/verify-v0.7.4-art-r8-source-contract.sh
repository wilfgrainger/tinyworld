#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ART R8 source contract failed: $1" >&2
  exit 1
}

jq -e '.tree.ReplicatedStorage.TinyWorldAssets.R8["$path"] == "assets/models/r8"' default.project.json >/dev/null \
  || fail "default.project.json must map assets/models/r8 to ReplicatedStorage.TinyWorldAssets.R8"
test -f assets/manifests/r8-models.json || fail "assets/manifests/r8-models.json is required"
test -f src/server/R8AssetLibrary.luau || fail "src/server/R8AssetLibrary.luau is required"
grep -F 'function R8AssetLibrary.requirePrefab' src/server/R8AssetLibrary.luau >/dev/null || fail "R8AssetLibrary.requirePrefab is required"
grep -F 'function R8AssetLibrary.clonePrefab' src/server/R8AssetLibrary.luau >/dev/null || fail "R8AssetLibrary.clonePrefab is required"
grep -F 'R8 required prefab missing:' src/server/R8AssetLibrary.luau >/dev/null || fail "published R8 must fail loudly when a required prefab is missing"

required_ids=(street-bench street-lamp street-planter street-fence-section street-mailbox nature-tree-small nature-tree-large nature-hedge-section architecture-window-assembly architecture-porch-assembly)
for id in "${required_ids[@]}"; do
  jq -e --arg id "$id" '.models[] | select(.id == $id and .devApproved == true)' assets/manifests/r8-models.json >/dev/null || fail "missing DEV-approved authored model manifest entry: $id"
done
jq -c '.models[] | select(.devApproved == true)' assets/manifests/r8-models.json | while read -r item; do
  path="$(jq -r '.path' <<<"$item")"; expected="$(jq -r '.sha256' <<<"$item")"
  test -f "$path" || fail "manifest model file missing: $path"
  actual="$(sha256sum "$path" | awk '{print $1}')"
  test "$actual" = "$expected" || fail "manifest hash mismatch: $path"
done
test -f docs/ART_AUTHORING.md || fail "docs/ART_AUTHORING.md is required"

# Layout / ground authority.
test -f src/server/R8VillageLayout.luau || fail "src/server/R8VillageLayout.luau is required"
test -f src/server/R8GroundBuilder.luau || fail "src/server/R8GroundBuilder.luau is required"
grep -F 'R8VillageLayout.create' src/server/Main.server.luau >/dev/null || fail "Main must create the canonical R8 village layout"
grep -F 'R8GroundBuilder.build' src/server/Main.server.luau >/dev/null || fail "Main must build the R8 ground"
if grep -F 'VillageGroundRebuildBuilder.apply' src/server/Main.server.luau >/dev/null; then fail "legacy VillageGroundRebuildBuilder must not render alongside R8 ground"; fi
if grep -F 'Vector3.new(size.X, 0.04, size.Y)' src/server/R8GroundBuilder.luau >/dev/null; then fail "R8 ground must not reintroduce near-coplanar 0.04-stud overlays"; fi

# Coast authority.
test -f src/server/R8CoastBuilder.luau || fail "src/server/R8CoastBuilder.luau is required"
grep -F 'R8CoastBuilder.build' src/server/Main.server.luau >/dev/null || fail "Main must build the R8 coast"
if grep -F 'world.coast = CoastBuilder.build' src/server/Main.server.luau >/dev/null; then fail "legacy CoastBuilder must not render alongside R8 coast"; fi
if grep -F 'HillSlope' src/server/R8CoastBuilder.luau >/dev/null; then fail "R8 coast must not use legacy HillSlope slab geometry"; fi
grep -F 'layout.safeShoreCFrame' src/server/R8CoastBuilder.luau >/dev/null || fail "R8 coast safe shore must come from canonical layout"
grep -F 'layout.worldRecoveryCFrame' src/server/R8CoastBuilder.luau >/dev/null || fail "R8 coast recovery must come from canonical layout"

# Authored streetscape composition.
test -f src/server/R8VillageCompositionBuilder.luau || fail "src/server/R8VillageCompositionBuilder.luau is required"
grep -F 'R8VillageCompositionBuilder.apply' src/server/Main.server.luau >/dev/null || fail "Main must apply R8 authored village composition"
if grep -F 'R7WorldCompositionBuilder.apply' src/server/Main.server.luau >/dev/null; then fail "R7 world composition must be retired from active R8 runtime"; fi
grep -F 'R8AssetLibrary.clonePrefab' src/server/R8VillageCompositionBuilder.luau >/dev/null || fail "R8 village composition must consume authored prefabs"
for marker in PlazaRing ResidentialEdges RouteLandmarks HarbourApproach; do
  grep -F "$marker" src/server/R8VillageCompositionBuilder.luau >/dev/null || fail "R8 composition missing authored placement group: $marker"
done

rojo build default.project.json --output /tmp/TinyWorld-r8-asset-validation.rbxlx >/dev/null
echo "ART R8 source contract passed"
