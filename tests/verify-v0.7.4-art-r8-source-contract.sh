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

echo "ART R8 source contract passed"
