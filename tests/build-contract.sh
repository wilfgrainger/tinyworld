#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

mkdir -p "$TEMP_DIR/bin"
cat > "$TEMP_DIR/bin/rojo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--version" ]]; then
  echo "${TINYWORLD_TEST_ROJO_VERSION:-rojo 7.7.0}"
  exit 0
fi
if [[ "${1:-}" != "build" ]]; then
  echo "unexpected rojo command: $*" >&2
  exit 1
fi
output_path=""
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output) output_path="${2:?missing output path}"; shift 2 ;;
    *) shift ;;
  esac
done
[[ -n "$output_path" ]] || { echo "missing rojo build output path" >&2; exit 1; }
printf '%s\n' '<roblox version="4"><Item class="DataModel" referent="RBX0" /></roblox>' > "$output_path"
EOF
chmod +x "$TEMP_DIR/bin/rojo"

cat > "$TEMP_DIR/bin/git" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "-C" ]]; then shift 2; fi
case "${1:-}" in
  status) exit 0 ;;
  rev-parse) echo "${TINYWORLD_TEST_GIT_COMMIT:-0123456789abcdef0123456789abcdef01234567}"; exit 0 ;;
  branch) echo "build-contract"; exit 0 ;;
  *) echo "unexpected git command: $*" >&2; exit 1 ;;
esac
EOF
chmod +x "$TEMP_DIR/bin/git"

cd "$ROOT_DIR"

check_output_is_rejected() {
  local version_output="$1"
  if TINYWORLD_TEST_ROJO_VERSION="$version_output" PATH="$TEMP_DIR/bin:$PATH" ./scripts/build.sh --check >/dev/null 2>&1; then
    echo "ERROR: rojo version output should be rejected: $version_output" >&2
    exit 1
  fi
}

check_output_is_accepted() {
  local version_output="$1"
  TINYWORLD_TEST_ROJO_VERSION="$version_output" PATH="$TEMP_DIR/bin:$PATH" ./scripts/build.sh --check >/dev/null
}

check_output_is_rejected "rojo 7.7.0-rc.1"
check_output_is_rejected "rojo 7.7.0+modified"
check_output_is_rejected "rojo 7.7.0 7.7.1"
check_output_is_rejected "ROJO 7.7.0"
check_output_is_accepted "Rojo 7.7.0"
check_output_is_accepted "rojo 7.7.0"
check_output_is_accepted "7.7.0"

if TINYWORLD_TEST_GIT_COMMIT="not-a-full-sha" PATH="$TEMP_DIR/bin:$PATH" TINYWORLD_ALLOW_DIRTY_BUILD=1 ./scripts/build.sh --output "$TEMP_DIR/invalid-commit" >/dev/null 2>&1; then
  echo "ERROR: build accepted commit metadata that is not a full 40-character SHA" >&2
  exit 1
fi

PATH="$TEMP_DIR/bin:$PATH" TINYWORLD_ALLOW_DIRTY_BUILD=1 ./scripts/build.sh

artifact_path="dist/TinyWorld-v0.7.5.rbxlx"
manifest_path="dist/release.json"
[[ -f "$artifact_path" ]]
[[ -f "$manifest_path" ]]

jq -e '
  .productVersion == "0.7.5" and
  .releaseName == "Finish the Rebuild" and
  .rojoVersion == "7.7.0" and
  .artifact == "TinyWorld-v0.7.5.rbxlx" and
  (.commit | test("^[0-9a-f]{40}$")) and
  (.sha256 | test("^[0-9a-f]{64}$")) and
  (.buildTimestampUtc | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")) and
  .profileSchema == 11
' "$manifest_path" >/dev/null

if command -v sha256sum >/dev/null 2>&1; then
  artifact_sha256="$(sha256sum "$artifact_path" | awk '{print $1}')"
else
  artifact_sha256="$(shasum -a 256 "$artifact_path" | awk '{print $1}')"
fi
[[ "$artifact_sha256" == "$(jq -r '.sha256' "$manifest_path")" ]]

workflow_count="$(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')"
[[ "$workflow_count" == "1" ]] || { echo "ERROR: expected exactly one active workflow, found $workflow_count" >&2; exit 1; }
[[ -f .github/workflows/tinyworld-ci.yml ]] || { echo "ERROR: canonical TinyWorld workflow missing" >&2; exit 1; }

if grep -R -n -E 'uses:[[:space:]]+actions/(upload-artifact|cache)@' .github/workflows --include='*.yml' --include='*.yaml'; then
  echo "ERROR: TinyWorld CI must not use persistent GitHub Actions artifact or cache storage" >&2
  exit 1
fi

while IFS= read -r runner; do
  [[ "$runner" == "ubuntu-latest" ]] || { echo "ERROR: non-standard runner configured: $runner" >&2; exit 1; }
done < <(sed -nE 's/^[[:space:]]*runs-on:[[:space:]]*([^[:space:]#]+).*/\1/p' .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null || true)

bash ./tests/verify-v0.7.5-art-r8.1-source-contract.sh
bash ./tests/publish-dev-contract.sh

echo "PASS: shell build contract matches v0.7.5 ART R8.1 Finish the Rebuild and enforces single free-only CI"
