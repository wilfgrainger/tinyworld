#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "FAIL: $1" >&2; exit 1; }

tracked_files=0
text_files=0
text_lines=0
long_lines=0
notes=0

is_text_path() {
  case "$1" in
    *.md|*.luau|*.lua|*.json|*.toml|*.yml|*.yaml|*.sh|*.ps1|*.py|*.txt|*.project.json|.gitignore|.luaurc|AGENTS.md|README.md)
      return 0 ;;
    *) return 1 ;;
  esac
}

while IFS= read -r -d '' path; do
  tracked_files=$((tracked_files + 1))
  [[ -f "$path" ]] || fail "tracked path is not a regular file: $path"
  is_text_path "$path" || continue
  text_files=$((text_files + 1))
  [[ -s "$path" ]] || fail "tracked text file is empty: $path"

  case "$path" in
    *.md)
      first_nonblank="$(awk 'NF { print; exit }' "$path")"
      [[ "$first_nonblank" == \#* ]] || fail "Markdown file does not begin with a heading: $path"
      ;;
  esac

  line_number=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))
    text_lines=$((text_lines + 1))
    [[ "$line" != *$'\r' ]] || fail "CRLF/carriage-return found at $path:$line_number"
    case "$path" in
      *.md) ;;
      *)
        if [[ "$line" =~ [[:blank:]]+$ ]] && [[ -n "${line//[[:blank:]]/}" ]]; then
          fail "trailing whitespace found at $path:$line_number"
        fi
        ;;
    esac
    if (( ${#line} > 220 )); then long_lines=$((long_lines + 1)); fi
    case "$path" in
      src/*|README.md|AGENTS.md|docs/product/*|docs/engineering/*|docs/quality/*|docs/roadmap/roadmap.md|docs/progress.md|docs/README.md)
        if [[ "$line" =~ (TODO|FIXME|HACK|PLACEHOLDER) ]]; then
          echo "NOTE: active-surface marker at $path:$line_number: $line"
          notes=$((notes + 1))
        fi
        ;;
    esac
  done < "$path"
done < <(git ls-files -z)

# Temporary remediation machinery must never survive.
if git ls-files | grep -Eq '^\.github/(v06[123]-|scripts/v06[123]_.*patch\.py|workflows/v06[123]-.*remediation)'; then
  git ls-files | grep -E '^\.github/(v06[123]-|scripts/v06[123]_.*patch\.py|workflows/v06[123]-.*remediation)' >&2 || true
  fail "temporary remediation machinery remains tracked"
fi

# Normal workflows are read-only.
if grep -RFEq 'contents: write' .github/workflows 2>/dev/null; then
  grep -RFEn 'contents: write' .github/workflows >&2 || true
  fail "write-enabled GitHub workflow remains"
fi

# Canonical authority is current.
for path in README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; do
  grep -Fq 'v0.6.3' "$path" || fail "$path does not name v0.6.3"
  if grep -Eiq '(current|active).{0,70}v0\.6\.[012]|v0\.6\.[012].{0,70}(current|active)' "$path"; then
    fail "$path still describes an older v0.6.x release as current/active"
  fi
done

grep -Fq 'reserved for the family/girls review' docs/roadmap/v0.7.0-village-life.md \
  || fail "v0.7.0 reservation language missing"

# Durable current guidance must not carry stale patch-release authority.
durable_docs=(
  docs/product/art-direction.md
  docs/product/village.md
  docs/product/homes.md
  docs/product/ui-ux.md
  docs/engineering/architecture.md
  docs/engineering/data-model.md
  docs/engineering/asset-pipeline.md
  docs/engineering/production-engineering.md
  docs/engineering/tooling.md
  docs/engineering/world-content-pipeline.md
  docs/quality/definition-of-done.md
  docs/quality/visual-quality-bar.md
  docs/quality/playtesting.md
)
for path in "${durable_docs[@]}"; do
  if grep -Eiq '(current|active).{0,70}v0\.6\.[012]|v0\.6\.[012].{0,70}(current|active)' "$path"; then
    fail "durable current guidance leaks stale release authority: $path"
  fi
done

# Executable build contracts target v0.6.3 only.
for path in tests/build-contract.sh tests/build-contract.ps1; do
  grep -Fq 'TinyWorld-v0.6.3.rbxlx' "$path" || fail "$path does not target v0.6.3"
  if grep -Eq 'TinyWorld-v0\.6\.[012]\.rbxlx' "$path"; then
    fail "$path still targets an older v0.6.x artifact"
  fi
done
grep -Fq './tests/build-contract.sh' .github/workflows/rojo-build.yml \
  || fail "Rojo workflow does not execute shell build contract"

grep -Fq 'bash ./tests/verify-v0.6.3-repository-audit.sh' .github/workflows/release-authority.yml \
  || fail "Release authority does not execute v0.6.3 repository audit"

# Active target-state guidance remains agent-neutral.
if grep -Fq '## Codex execution contract' docs/product/target-state-v1.md; then
  fail "target-state still has Codex-specific execution contract"
fi
grep -Fq '## Implementation-agent execution contract' docs/product/target-state-v1.md \
  || fail "target-state implementation-agent contract missing"

# Known player-character regression cannot return.
[[ ! -e src/server/CharacterAppearanceBuilder.luau ]] || fail "primitive CharacterAppearanceBuilder returned"
if grep -RFq 'TinyWorldHairFallback' src; then fail "primitive hair fallback marker returned"; fi
if grep -RFq 'TinyWorldShoesFallback' src; then fail "primitive shoe fallback marker returned"; fi

# v0.6.3 rendered visual mechanisms are mandatory.
grep -Fq 'ProductionArtCleanup.apply(world.root)' src/server/Main.server.luau || fail "production cleanup is not active"
grep -Fq 'CivicCraftBuilder.apply(world.root)' src/server/Main.server.luau || fail "civic craft is not active"
grep -Fq 'VillageLandscapeBuilder.build(world.root, world.layout)' src/server/Main.server.luau || fail "production landscape is not active"
grep -Fq 'hideSpawnPad' src/server/ProductionArtCleanup.luau || fail "visible spawn-pad correction missing"
grep -Fq 'removePrimitiveAmbientCharacters' src/server/ProductionArtCleanup.luau || fail "legacy ambient actor cleanup missing"
grep -Fq 'replaceLegacyPracticalLights' src/server/ProductionArtCleanup.luau || fail "legacy practical-light cleanup missing"

if grep -Fq 'Vector3.new(width + 2, 1, depth + 2)' src/server/HomePrefabBuilder.luau; then
  fail "v0.6.2 hero-home slab roof recipe returned"
fi
if grep -Fq '"PorchLamp",' src/server/HomePrefabBuilder.luau || grep -Fq '"HomeLantern",' src/server/HomePrefabBuilder.luau; then
  fail "v0.6.2 naked home practical light recipe returned"
fi

# Existing v0.6.2 gameplay contracts cannot drift during an art release.
grep -Fq 'id = "VillageExplorer"' src/shared/ActivityDefinitions.luau || fail "Village Explorer activity missing"
if grep -Fq 'id = "HarborHelper"' src/shared/ActivityDefinitions.luau; then fail "obsolete HarborHelper activity returned"; fi
grep -Fq 'home_design = 16' src/shared/RouteRules.luau || fail "home_design route bit missing"
grep -Fq 'ProfileSchema.VERSION = 11' src/shared/ProfileSchema.luau || fail "schema changed during art release"
[[ -f src/server/TradeJournal.luau ]] || fail "durable trade journal missing"

# Credential/publishing surface remains closed.
if grep -RIEq --exclude-dir=.git --exclude='verify-v0.6.3-repository-audit.sh' \
  '(\.ROBLOSECURITY|ROBLOX_COOKIE)[[:space:]]*[:=][[:space:]]*[^$<{[:space:]]+' \
  src scripts .github config assets 2>/dev/null; then
  fail "credential-shaped literal found in executable/config surfaces"
fi
if grep -RIEq --exclude='verify-release-contract.sh' --exclude-dir='.git' \
  '(upload-place|opencloud.*publish|publish.*opencloud)' .github scripts 2>/dev/null; then
  fail "publishing automation is not approved in v0.6.3"
fi

printf 'PASS: v0.6.3 repository audit read %d tracked files, %d text files, %d text lines; %d long-line notes, %d active markers\n' \
  "$tracked_files" "$text_files" "$text_lines" "$long_lines" "$notes"
