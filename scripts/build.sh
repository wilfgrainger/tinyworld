#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${TINYWORLD_BUILD_DIR:-$ROOT_DIR/dist}"
CHECK_ONLY=0

usage() {
  echo "Usage: $0 [--check] [--output <directory>]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      CHECK_ONLY=1
      shift
      ;;
    --output)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --output requires a directory" >&2
        usage
        exit 1
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required command missing: $1" >&2
    exit 1
  fi
}

require_command jq
require_command git
if command -v sha256sum >/dev/null 2>&1; then
  SHA256_COMMAND="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  SHA256_COMMAND="shasum"
else
  echo "ERROR: required command missing: sha256sum or shasum" >&2
  exit 1
fi
require_command rojo

RELEASE_CONFIG="$ROOT_DIR/config/release.json"
PRODUCT_VERSION="$(jq -er '.productVersion' "$RELEASE_CONFIG")"
RELEASE_NAME="$(jq -er '.releaseName' "$RELEASE_CONFIG")"
PROFILE_SCHEMA="$(jq -er '.profileSchema' "$RELEASE_CONFIG")"
EXPECTED_ROJO_VERSION="$(jq -er '.rojoVersion' "$RELEASE_CONFIG")"
PROJECT_FILE="$(jq -er '.projectFile' "$RELEASE_CONFIG")"
ARTIFACT_NAME="$(jq -er '.artifactFile' "$RELEASE_CONFIG")"
ROJO_VERSION_OUTPUT="$(rojo --version)"

if [[ "$ROJO_VERSION_OUTPUT" != "rojo $EXPECTED_ROJO_VERSION" && "$ROJO_VERSION_OUTPUT" != "$EXPECTED_ROJO_VERSION" ]]; then
  echo "ERROR: rojo version must report exactly \"rojo $EXPECTED_ROJO_VERSION\" or \"$EXPECTED_ROJO_VERSION\"; got: $ROJO_VERSION_OUTPUT" >&2
  exit 1
fi

if [[ "$CHECK_ONLY" -eq 1 ]]; then
  echo "PASS: build prerequisites are available"
  exit 0
fi

if [[ "${TINYWORLD_ALLOW_DIRTY_BUILD:-}" != "1" ]] && [[ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]]; then
  echo "ERROR: working tree is dirty; set TINYWORLD_ALLOW_DIRTY_BUILD=1 to override" >&2
  exit 1
fi

COMMIT="$(git -C "$ROOT_DIR" rev-parse HEAD)"
if [[ ! "$COMMIT" =~ ^[0-9a-f]{40}$ ]]; then
  echo "ERROR: git rev-parse HEAD must return a full 40-character SHA; got: $COMMIT" >&2
  exit 1
fi

BRANCH="$(git -C "$ROOT_DIR" branch --show-current)"
if [[ -z "$BRANCH" ]]; then
  BRANCH="${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-detached}}"
fi

ARTIFACT_PATH="$OUTPUT_DIR/$ARTIFACT_NAME"
MANIFEST_PATH="$OUTPUT_DIR/release.json"
mkdir -p "$OUTPUT_DIR"
rojo build "$ROOT_DIR/$PROJECT_FILE" -o "$ARTIFACT_PATH"

if [[ "$SHA256_COMMAND" == "sha256sum" ]]; then
  ARTIFACT_SHA256="$(sha256sum "$ARTIFACT_PATH" | awk '{print $1}')"
else
  ARTIFACT_SHA256="$(shasum -a 256 "$ARTIFACT_PATH" | awk '{print $1}')"
fi

BUILD_TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
jq -n \
  --arg productVersion "$PRODUCT_VERSION" \
  --arg releaseName "$RELEASE_NAME" \
  --arg commit "$COMMIT" \
  --arg branch "$BRANCH" \
  --arg buildTimestampUtc "$BUILD_TIMESTAMP" \
  --arg rojoVersion "$EXPECTED_ROJO_VERSION" \
  --arg projectFile "$PROJECT_FILE" \
  --argjson profileSchema "$PROFILE_SCHEMA" \
  --arg artifact "$ARTIFACT_NAME" \
  --arg sha256 "$ARTIFACT_SHA256" \
  '{productVersion: $productVersion, releaseName: $releaseName, commit: $commit, branch: $branch, buildTimestampUtc: $buildTimestampUtc, rojoVersion: $rojoVersion, projectFile: $projectFile, profileSchema: $profileSchema, artifact: $artifact, sha256: $sha256}' \
  > "$MANIFEST_PATH"

echo "Artifact: $ARTIFACT_PATH"
echo "SHA-256: $ARTIFACT_SHA256"
