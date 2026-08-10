#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

canonical=(
  "README.md"
  "AGENTS.md"
  "docs/README.md"
  "docs/progress.md"
  "docs/roadmap/roadmap.md"
  "docs/roadmap/v0.6.1-visual-rescue.md"
  "docs/releases/v0.6.1/acceptance.md"
  "config/release.json"
)

for path in "${canonical[@]}"; do
  [[ -f "$path" ]] || fail "missing canonical authority file: $path"
done

product_version="$(jq -er '.productVersion' config/release.json)"
release_name="$(jq -er '.releaseName' config/release.json)"
profile_schema="$(jq -er '.profileSchema' config/release.json)"

[[ "$product_version" == "0.6.1" ]] || fail "productVersion must be 0.6.1"
[[ "$release_name" == "Visual Rescue" ]] || fail "releaseName must be Visual Rescue"
[[ "$profile_schema" == "11" ]] || fail "profile schema must remain 11"

for path in README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; do
  grep -Fq 'v0.6.1' "$path" || fail "$path must identify v0.6.1"
done

grep -Fq 'docs/product/target-state-v1.md' README.md || fail "README must link target state"
grep -Fq 'docs/product/target-state-v1.md' AGENTS.md || fail "AGENTS must point agents at target state"
grep -Fq 'product/target-state-v1.md' docs/README.md || fail "docs index must link target state"
grep -Fq 'roadmap/v0.6.1-visual-rescue.md' docs/README.md || fail "docs index must link v0.6.1 roadmap"
grep -Fq 'releases/v0.6.1/acceptance.md' docs/README.md || fail "docs index must link v0.6.1 acceptance"

if grep -EHiq '(current|active)[^\n]{0,50}v0\.6\.0|v0\.6\.0[^\n]{0,50}(current|active)' \
  README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; then
  fail "canonical documentation still declares v0.6.0 current/active"
fi

if grep -EHiq '(current|active)[^\n]{0,50}(profile|schema)[^\n]{0,20}10|(profile|schema)[^\n]{0,20}10[^\n]{0,50}(current|active)' \
  README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; then
  fail "canonical documentation still declares profile/schema 10 current/active"
fi

echo "PASS: canonical release authority is v0.6.1 Visual Rescue / profile schema 11"