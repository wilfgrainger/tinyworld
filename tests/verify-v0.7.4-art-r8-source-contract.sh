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

required_ids=(
  street-bench
  street-lamp
  street-planter
  street-fence-section
  street-mailbox
  nature-tree-small
  nature-tree-large
  nature-hedge-section
  architecture-window-assembly
  architecture-porch-assembly
)

for id in "${required_ids[@]}"; do
  jq -e --arg id "$id" '.models[] | select(.id == $id and .devApproved == true)' assets/manifests/r8-models.json >/dev/null \
    || fail "missing DEV-approved authored model manifest entry: $id"
done

jq -c '.models[] | select(.devApproved == true)' assets/manifests/r8-models.json | while read -r item; do
  path="$(jq -r '.path' <<<"$item")"
  expected="$(jq -r '.sha256' <<<"$item")"
  test -f "$path" || fail "manifest model file missing: $path"
  actual="$(sha256sum "$path" | awk '{print $1}')"
  test "$actual" = "$expected" || fail "manifest hash mismatch: $path"
done

test -f docs/ART_AUTHORING.md \
  || fail "docs/ART_AUTHORING.md is required"

echo "ART R8 source contract passed"
