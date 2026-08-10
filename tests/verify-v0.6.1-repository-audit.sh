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

    if [[ "$line" =~ [[:blank:]]+$ ]] && [[ -n "${line//[[:blank:]]/}" ]]; then
      fail "trailing whitespace found at $path:$line_number"
    fi

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

# One-shot/remediation machinery must never survive the release branch.
if git ls-files | grep -Eq '^\.github/(v061-|scripts/v061_.*patch\.py|workflows/v061-.*remediation)'; then
  git ls-files | grep -E '^\.github/(v061-|scripts/v061_.*patch\.py|workflows/v061-.*remediation)' >&2 || true
  fail "temporary v0.6.1 remediation machinery remains tracked"
fi

# Normal repository workflows are read-only. Any future write workflow needs an explicit reviewed exception.
if grep -RFEq 'contents: write' .github/workflows 2>/dev/null; then
  grep -RFEn 'contents: write' .github/workflows >&2 || true
  fail "write-enabled GitHub workflow remains after remediation"
fi

# Current authority must not silently point backwards.
for path in README.md AGENTS.md docs/README.md docs/progress.md docs/roadmap/roadmap.md; do
  grep -Fq 'v0.6.1' "$path" || fail "$path does not name v0.6.1"
  if grep -Eiq '(current|active).{0,60}v0\.6\.0|v0\.6\.0.{0,60}(current|active)' "$path"; then
    fail "$path still describes v0.6.0 as current/active"
  fi
done

# Active target-state language must be implementation-agent neutral.
if grep -Fq '## Codex execution contract' docs/product/target-state-v1.md; then
  fail "target-state still has Codex-specific execution contract"
fi
grep -Fq '## Implementation-agent execution contract' docs/product/target-state-v1.md \
  || fail "target-state implementation-agent contract missing"

# Known visual regressions cannot survive under another file name.
[[ ! -e src/server/CharacterAppearanceBuilder.luau ]] || fail "primitive CharacterAppearanceBuilder returned"
if grep -RFq 'TinyWorldHairFallback' src; then fail "primitive hair fallback marker returned"; fi
if grep -RFq 'TinyWorldShoesFallback' src; then fail "primitive shoe fallback marker returned"; fi

# Secret/publishing surface: broad literal scan, with documentation examples excluded.
if grep -RIEq --exclude-dir=.git --exclude='verify-v0.6.1-repository-audit.sh' \
  '(\.ROBLOSECURITY|ROBLOX_COOKIE)[[:space:]]*[:=][[:space:]]*[^$<{[:space:]]+' \
  src scripts .github config assets 2>/dev/null; then
  fail "credential-shaped literal found in executable/config surfaces"
fi

printf 'PASS: repository line audit read %d tracked files, %d text files, %d text lines; %d long-line notes, %d active markers\n' \
  "$tracked_files" "$text_files" "$text_lines" "$long_lines" "$notes"
