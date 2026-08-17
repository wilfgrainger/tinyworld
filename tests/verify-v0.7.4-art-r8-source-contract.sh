#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ART R8 source contract failed: $1" >&2
  exit 1
}

jq -e '.tree.ReplicatedStorage.TinyWorldAssets.R8["$path"] == "assets/models/r8"' default.project.json >/dev/null \
  || fail "default.project.json must map assets/models/r8 to ReplicatedStorage.TinyWorldAssets.R8"

test -f assets/manifests/r8-models.json \
  || fail "assets/manifests/r8-models.json is required"

test -f src/server/R8AssetLibrary.luau \
  || fail "src/server/R8AssetLibrary.luau is required"

grep -F 'function R8AssetLibrary.requirePrefab' src/server/R8AssetLibrary.luau >/dev/null \
  || fail "R8AssetLibrary.requirePrefab is required"
grep -F 'function R8AssetLibrary.clonePrefab' src/server/R8AssetLibrary.luau >/dev/null \
  || fail "R8AssetLibrary.clonePrefab is required"
grep -F 'R8 required prefab missing:' src/server/R8AssetLibrary.luau >/dev/null \
  || fail "published R8 must fail loudly when a required prefab is missing"

echo "ART R8 source contract passed"
