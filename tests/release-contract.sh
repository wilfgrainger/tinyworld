#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
FIXTURE_ROOT="$TEMP_DIR/repository"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

mkdir -p "$FIXTURE_ROOT"
git -C "$ROOT_DIR" archive HEAD | tar -x -C "$FIXTURE_ROOT"
cp "$ROOT_DIR/.github/workflows/rojo-build.yml" "$FIXTURE_ROOT/.github/workflows/rojo-build.yml"

[[ ! -e "$FIXTURE_ROOT/.git" ]]

CONFIG_PATH="$FIXTURE_ROOT/config/release.json"
WORKFLOW_PATH="$FIXTURE_ROOT/.github/workflows/rojo-build.yml"
GUARD_PATH="$ROOT_DIR/scripts/verify-release-contract.sh"
CONFIG_CHECKSUM="$(cksum "$ROOT_DIR/config/release.json")"
WORKFLOW_CHECKSUM="$(cksum "$ROOT_DIR/.github/workflows/rojo-build.yml")"

run_guard() {
  TINYWORLD_REPO_ROOT="$FIXTURE_ROOT" bash "$GUARD_PATH"
}

bash "$ROOT_DIR/scripts/verify-release-contract.sh" >/dev/null
run_guard >/dev/null

NO_RG_BIN="$TEMP_DIR/no-rg-bin"
mkdir -p "$NO_RG_BIN"
for command_name in awk cut dirname grep head jq; do
  ln -s "$(command -v "$command_name")" "$NO_RG_BIN/$command_name"
done

if ! PATH="$NO_RG_BIN" TINYWORLD_REPO_ROOT="$FIXTURE_ROOT" "$(command -v bash)" "$GUARD_PATH" >/dev/null 2>&1; then
  echo "ERROR: release guard requires rg instead of standard grep" >&2
  exit 1
fi

cp "$CONFIG_PATH" "$TEMP_DIR/release.json"
cp "$WORKFLOW_PATH" "$TEMP_DIR/rojo-build.yml"

jq '.rokitVersion = "0.0.0"' "$TEMP_DIR/release.json" > "$CONFIG_PATH"
if run_guard >/dev/null 2>&1; then
  echo "ERROR: release guard accepted an unpinned Rokit version" >&2
  exit 1
fi
cp "$TEMP_DIR/release.json" "$CONFIG_PATH"

printf '\non:\n  pull_request:\n  push:\n    branches:\n      - main\n' >> "$WORKFLOW_PATH"
if run_guard >/dev/null 2>&1; then
  echo "ERROR: release guard accepted duplicate top-level on mappings" >&2
  exit 1
fi
cp "$TEMP_DIR/rojo-build.yml" "$WORKFLOW_PATH"

awk '
  {
    marker = "${rokit_installer_commit}"
    marker_index = index($0, marker)
    if (marker_index > 0) {
      print substr($0, 1, marker_index - 1) "main" substr($0, marker_index + length(marker))
    } else {
      print
    }
  }
' "$TEMP_DIR/rojo-build.yml" > "$WORKFLOW_PATH"
if run_guard >/dev/null 2>&1; then
  echo "ERROR: release guard accepted a mutable Rokit installer URL" >&2
  exit 1
fi
cp "$TEMP_DIR/rojo-build.yml" "$WORKFLOW_PATH"

awk '
  {
    dollar = sprintf("%c", 36)
    marker = "| bash -s -- \"" dollar "rokit_version\""
    marker_index = index($0, marker)
    if (marker_index > 0) {
      print substr($0, 1, marker_index - 1) "| bash -s -- --version \"" dollar "rokit_version\""
    } else {
      print
    }
  }
' "$TEMP_DIR/rojo-build.yml" > "$WORKFLOW_PATH"
if run_guard >/dev/null 2>&1; then
  echo "ERROR: release guard accepted a Rokit installer --version flag" >&2
  exit 1
fi
cp "$TEMP_DIR/rojo-build.yml" "$WORKFLOW_PATH"

awk '
  {
    marker = "$HOME/.rokit/bin"
    marker_index = index($0, marker)
    if (marker_index > 0) {
      print substr($0, 1, marker_index - 1) "$HOME/.local/bin" substr($0, marker_index + length(marker))
    } else {
      print
    }
  }
' "$TEMP_DIR/rojo-build.yml" > "$WORKFLOW_PATH"
if run_guard >/dev/null 2>&1; then
  echo "ERROR: release guard accepted the obsolete Rokit self-install path" >&2
  exit 1
fi
cp "$TEMP_DIR/rojo-build.yml" "$WORKFLOW_PATH"

awk '
  {
    marker = "rokit install --no-trust-check"
    marker_index = index($0, marker)
    if (marker_index > 0) {
      print substr($0, 1, marker_index - 1) "rokit install" substr($0, marker_index + length(marker))
    } else {
      print
    }
  }
' "$TEMP_DIR/rojo-build.yml" > "$WORKFLOW_PATH"
if run_guard >/dev/null 2>&1; then
  echo "ERROR: release guard accepted a plain Rokit install command" >&2
  exit 1
fi

[[ "$CONFIG_CHECKSUM" == "$(cksum "$ROOT_DIR/config/release.json")" ]]
[[ "$WORKFLOW_CHECKSUM" == "$(cksum "$ROOT_DIR/.github/workflows/rojo-build.yml")" ]]
