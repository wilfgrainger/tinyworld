#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

mkdir -p "$TEMP_DIR/bin" "$TEMP_DIR/dist"
printf '%s\n' '<roblox version="4"><Item class="DataModel" referent="RBX0" /></roblox>' > "$TEMP_DIR/dist/TinyWorld-test.rbxlx"
cat > "$TEMP_DIR/dist/release.json" <<'EOF'
{
  "artifact": "TinyWorld-test.rbxlx"
}
EOF

cat > "$TEMP_DIR/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" > "${TINYWORLD_TEST_CURL_LOG:?}"
printf '%s\n' '{"versionNumber":42}'
EOF
chmod +x "$TEMP_DIR/bin/curl"

run_publisher() {
  local config="$1"
  shift
  TINYWORLD_DEV_CONFIG="$config" \
  TINYWORLD_RELEASE_MANIFEST="$TEMP_DIR/dist/release.json" \
  TINYWORLD_TEST_CURL_LOG="$TEMP_DIR/curl.log" \
  PATH="$TEMP_DIR/bin:$PATH" \
  "$@" bash "$ROOT_DIR/scripts/publish-dev.sh"
}

cat > "$TEMP_DIR/unconfigured.json" <<'EOF'
{
  "name": "TinyWorld DEV",
  "releaseChannel": "dev",
  "configured": false,
  "universeId": null,
  "placeId": null,
  "publishing": "deferred"
}
EOF

rm -f "$TEMP_DIR/curl.log"
unconfigured_output="$(run_publisher "$TEMP_DIR/unconfigured.json" env)"
grep -Fq "DEV publishing deferred" <<<"$unconfigured_output"
[[ ! -e "$TEMP_DIR/curl.log" ]]

cat > "$TEMP_DIR/configured.json" <<'EOF'
{
  "name": "TinyWorld DEV",
  "releaseChannel": "dev",
  "configured": true,
  "universeId": "123456789",
  "placeId": "987654321",
  "publishing": "open-cloud"
}
EOF

if run_publisher "$TEMP_DIR/configured.json" env -u ROBLOX_DEV_API_KEY >/dev/null 2>&1; then
  echo "ERROR: configured DEV publishing accepted a missing API key" >&2
  exit 1
fi

cat > "$TEMP_DIR/bad-id.json" <<'EOF'
{
  "name": "TinyWorld DEV",
  "releaseChannel": "dev",
  "configured": true,
  "universeId": "not-a-number",
  "placeId": "987654321",
  "publishing": "open-cloud"
}
EOF

if run_publisher "$TEMP_DIR/bad-id.json" env ROBLOX_DEV_API_KEY=test-secret >/dev/null 2>&1; then
  echo "ERROR: configured DEV publishing accepted an invalid Universe ID" >&2
  exit 1
fi

rm -f "$TEMP_DIR/curl.log"
published_output="$(run_publisher "$TEMP_DIR/configured.json" env ROBLOX_DEV_API_KEY=test-secret)"
grep -Fq "Published TinyWorld DEV place version 42" <<<"$published_output"

grep -Fq "https://apis.roblox.com/universes/v1/123456789/places/987654321/versions?versionType=Published" "$TEMP_DIR/curl.log"
grep -Fq "x-api-key: test-secret" "$TEMP_DIR/curl.log"
grep -Fq "Content-Type: application/xml" "$TEMP_DIR/curl.log"
grep -Fq -- "--data-binary" "$TEMP_DIR/curl.log"
grep -Fq "@$TEMP_DIR/dist/TinyWorld-test.rbxlx" "$TEMP_DIR/curl.log"

echo "PASS: DEV publishing contract is deferred safely and publishes directly when configured"
