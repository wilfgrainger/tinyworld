#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

tracked_files=0
text_files=0
text_lines=0
long_lines=0
notes=0

is_text_path() {
  case "$1" in
    *.md|*.luau|*.lua|*.json|*.toml|*.yml|*.yaml|*.sh|*.ps1|*.py|*.txt|*.project.json|.gitignore|.luaurc|AGENTS.md|README.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

while IFS= read -r -d '' path; do
  tracked_files=$((tracked_files + 1))
  [[ -f "$path" ]] || fail "tracked path is not a regular file: $path"

  if ! is_text_path "$path"; then
    continue
  fi

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

    if [[ "$line" == *$'\r' ]]; then
      fail "CRLF/carriage-return found at $path:$line_number"
    fi

    case "$path" in
      *.md) ;;
      *)
        if [[ "$line" =~ [[:blank:]]+$ ]] && [[ -n "${line//[[:blank:]]/}" ]]; then
          fail "trailing whitespace found at $path:$line_number"
        fi
        ;;
    esac

    if (( ${#line} > 220 )); then
      long_lines=$((long_lines + 1))
    fi

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

# Temporary remediation machinery must never survive the release branch.
if git ls-files | grep -Eq '^\.github/(v062-|scripts/v062_.*patch\.py|workflows/v062-.*remediation)'; then
  git ls-files | grep -E '^\.github/(v062-|scripts/v062_.*patch\.py|workflows/v062-.*remediation)' >&2 || true
  fail "temporary v0.6.2 remediation machinery remains tracked"
fi

# Normal repository workflows are read-only.
if grep -RFEq 'contents: write' .github/workflows 2>/dev/null; then
  grep -RFEn 'contents: write' .github/workflows >&2 || true
  fail "write-enabled GitHub workflow remains"
fi

# Current authority must not silently point backwards.
for path in README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; do
  grep -Fq 'v0.6.2' "$path" || fail "$path does not name v0.6.2"
  if grep -Eiq '(current|active).{0,60}v0\.6\.1|v0\.6\.1.{0,60}(current|active)' "$path"; then
    fail "$path still describes v0.6.1 as current/active"
  fi
done

grep -Fq 'reserved for the family/girls review' docs/roadmap/v0.7.0-village-life.md \
  || fail "v0.7.0 reservation language missing"

# Executable build contracts are current release authority.
for path in tests/build-contract.sh tests/build-contract.ps1; do
  grep -Fq 'TinyWorld-v0.6.2.rbxlx' "$path" || fail "$path does not target the v0.6.2 artifact"
  if grep -Fq 'TinyWorld-v0.6.1.rbxlx' "$path"; then
    fail "$path still targets the v0.6.1 artifact"
  fi
done
grep -Fq './tests/build-contract.sh' .github/workflows/rojo-build.yml \
  || fail "Rojo workflow does not execute the shell build contract"

# Active target-state language remains implementation-agent neutral.
if grep -Fq '## Codex execution contract' docs/product/target-state-v1.md; then
  fail "target-state still has Codex-specific execution contract"
fi
grep -Fq '## Implementation-agent execution contract' docs/product/target-state-v1.md \
  || fail "target-state implementation-agent contract missing"

# Known visual regressions cannot return under another file name.
[[ ! -e src/server/CharacterAppearanceBuilder.luau ]] || fail "primitive CharacterAppearanceBuilder returned"
if grep -RFq 'TinyWorldHairFallback' src; then fail "primitive hair fallback marker returned"; fi
if grep -RFq 'TinyWorldShoesFallback' src; then fail "primitive shoe fallback marker returned"; fi
if grep -Eq 'local function (bird|cat)\(|Village(Bird|Cat)' src/server/AmbientLifeService.luau; then
  fail "primitive ambient creature fallback returned"
fi

# Current Village Life contracts cannot drift backwards.
grep -Fq 'id = "VillageExplorer"' src/shared/ActivityDefinitions.luau || fail "Village Explorer activity missing"
if grep -Fq 'id = "HarborHelper"' src/shared/ActivityDefinitions.luau; then
  fail "obsolete HarborHelper activity returned"
fi
grep -Fq 'home_design = 16' src/shared/RouteRules.luau || fail "home_design route bit missing"

# Secret/publishing surface: broad literal scan, with this audit excluded.
if grep -RIEq --exclude-dir=.git --exclude='verify-v0.6.2-repository-audit.sh' \
  '(\.ROBLOSECURITY|ROBLOX_COOKIE)[[:space:]]*[:=][[:space:]]*[^$<{[:space:]]+' \
  src scripts .github config assets 2>/dev/null; then
  fail "credential-shaped literal found in executable/config surfaces"
fi
if grep -RIEq --exclude='verify-release-contract.sh' --exclude-dir='.git' \
  '(upload-place|opencloud.*publish|publish.*opencloud)' .github scripts 2>/dev/null; then
  fail "publishing automation is not approved in v0.6.2"
fi

printf 'PASS: v0.6.2 repository audit read %d tracked files, %d text files, %d text lines; %d long-line notes, %d active markers\n' \
  "$tracked_files" "$text_files" "$text_lines" "$long_lines" "$notes"
