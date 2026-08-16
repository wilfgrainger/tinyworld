#!/usr/bin/env bash
set -euo pipefail

config="${TINYWORLD_DEV_CONFIG:-config/environments/dev.json}"
manifest="${TINYWORLD_RELEASE_MANIFEST:-dist/release.json}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

[[ -f "$config" ]] || fail "DEV environment config not found: $config"

configured="$(jq -r '
  if (.configured | type) == "boolean" then
    .configured
  else
    error("configured must be boolean")
  end
' "$config")" || fail "invalid DEV environment config: $config"

if [[ "$configured" != "true" ]]; then
  echo "DEV publishing deferred: TinyWorld DEV is not configured"
  exit 0
fi

publishing="$(jq -er '.publishing | select(type == "string")' "$config")" || fail "configured DEV environment must declare publishing mode"
[[ "$publishing" == "open-cloud" ]] || fail "configured DEV publishing mode must be open-cloud"

universe_id="$(jq -er '.universeId | select((type == "number") or (type == "string")) | tostring | select(test("^[0-9]+$"))' "$config")" \
  || fail "configured DEV environment requires a numeric universeId"
place_id="$(jq -er '.placeId | select((type == "number") or (type == "string")) | tostring | select(test("^[0-9]+$"))' "$config")" \
  || fail "configured DEV environment requires a numeric placeId"

[[ -f "$manifest" ]] || fail "release manifest not found: $manifest"
artifact="$(jq -er '.artifact | select(type == "string") | select(test("^[A-Za-z0-9._-]+\\.rbxlx$"))' "$manifest")" \
  || fail "release manifest must name a local .rbxlx artifact"
artifact_path="$(dirname "$manifest")/$artifact"
[[ -f "$artifact_path" ]] || fail "release artifact missing: $artifact_path"

[[ -n "${ROBLOX_DEV_API_KEY:-}" ]] || fail "ROBLOX_DEV_API_KEY is required when DEV publishing is configured"

endpoint="https://apis.roblox.com/universes/v1/${universe_id}/places/${place_id}/versions?versionType=Published"
response="$(curl --fail-with-body --silent --show-error --location \
  --request POST \
  "$endpoint" \
  --header "x-api-key: ${ROBLOX_DEV_API_KEY}" \
  --header "Content-Type: application/xml" \
  --data-binary "@${artifact_path}")" || fail "Roblox DEV place publishing request failed"

version="$(jq -er '.versionNumber | select(type == "number")' <<<"$response")" \
  || fail "Roblox DEV publishing response did not contain a numeric versionNumber"

echo "Published TinyWorld DEV place version ${version}"
