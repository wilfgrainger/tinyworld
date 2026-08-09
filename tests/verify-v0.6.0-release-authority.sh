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
  "config/release.json"
)

for path in "${canonical[@]}"; do
  [[ -f "$path" ]] || fail "missing canonical authority file: $path"
done

grep -Fq 'v0.6.0' README.md || fail "README.md must identify v0.6.0"
grep -Fq 'v0.6.0' AGENTS.md || fail "AGENTS.md must identify v0.6.0"
grep -Fq 'v0.6.0' docs/README.md || fail "docs/README.md must identify v0.6.0"
grep -Fq 'v0.6.0' docs/progress.md || fail "docs/progress.md must identify v0.6.0"
grep -Fq 'v0.6.0' docs/roadmap/roadmap.md || fail "roadmap must identify v0.6.0"
jq -e '.productVersion == "0.6.0" and .profileSchema == 11' config/release.json >/dev/null || fail "release metadata must be v0.6.0/schema 11"

# Historical mentions are allowed, but canonical files may not declare an
# older release/profile as current/active.
if grep -EHiq '(current|active)[^\n]{0,40}v0\.5\.[23]|v0\.5\.[23][^\n]{0,40}(current|active)' \
  README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; then
  fail "canonical documentation still declares a v0.5.x release current/active"
fi
if grep -EHiq '(current|active)[^\n]{0,50}(profile|schema)[^\n]{0,20}10|(profile|schema)[^\n]{0,20}10[^\n]{0,50}(current|active)' \
  README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; then
  fail "canonical documentation still declares profile/schema 10 current/active"
fi

# The v0.6.0 target state must be reachable from both human and agent entrypoints.
grep -Fq 'docs/product/target-state-v1.md' README.md || fail "README must link target state"
grep -Fq 'docs/product/target-state-v1.md' AGENTS.md || fail "AGENTS must point agents at target state"
grep -Fq 'product/target-state-v1.md' docs/README.md || fail "docs index must link target state"

echo "PASS: canonical release authority is v0.6.0 / profile schema 11"
