#!/usr/bin/env bash
set -euo pipefail

DEFAULT_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="${TINYWORLD_REPO_ROOT:-$DEFAULT_REPO_ROOT}"
if [[ ! -d "$REPO_ROOT" ]]; then
  echo "ERROR: repository root does not exist: $REPO_ROOT" >&2
  exit 1
fi
REPO_ROOT="$(cd "$REPO_ROOT" && pwd -P)"
cd "$REPO_ROOT"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: required command missing: jq" >&2
  exit 1
fi

required_paths=(
  "default.project.json"
  "rokit.toml"
  "config/release.json"
  "config/environments/dev.json"
  "config/environments/live.json"
  "assets/manifests/assets.json"
  "scripts/build.sh"
  "scripts/build.ps1"
  ".github/workflows/rojo-build.yml"
  "docs/engineering/production-engineering.md"
  "docs/roadmap/v0.5.3-production-engineering.md"
  "docs/releases/v0.5.3/acceptance.md"
  "docs/superpowers/specs/2026-08-09-tinyworld-v0.5.3-production-engineering-design.md"
  "docs/superpowers/plans/2026-08-09-tinyworld-v0.5.3-production-engineering.md"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "ERROR: missing required path: $path" >&2
    exit 1
  fi
done

documentation_index="docs/README.md"
for required_link in \
  "engineering/production-engineering.md" \
  "roadmap/v0.5.3-production-engineering.md" \
  "releases/v0.5.3/acceptance.md"; do
  if ! grep -Fq "$required_link" "$documentation_index"; then
    echo "ERROR: $documentation_index missing required link: $required_link" >&2
    exit 1
  fi
done

workflow_path=".github/workflows/rojo-build.yml"

require_workflow_match() {
  local description="$1"
  local pattern="$2"

  if ! grep -Eq "$pattern" "$workflow_path"; then
    echo "ERROR: workflow contract missing $description" >&2
    exit 1
  fi
}

require_workflow_match "exact name Rojo build" '^name:[[:space:]]+Rojo build[[:space:]]*$'
if ! awk '
  function indentation(line) {
    match(line, /^[[:space:]]*/)
    return RLENGTH
  }

  function trim(line) {
    sub(/^[[:space:]]+/, "", line)
    sub(/[[:space:]]+$/, "", line)
    return line
  }

  {
    line = trim($0)
    if (line == "" || line ~ /^#/) {
      next
    }

    depth = indentation($0)
    if (depth == 0) {
      in_push = 0
      in_branches = 0
      if (line == "on:") {
        on_count += 1
        in_on = on_count == 1
        on_child_depth = -1
      } else {
        in_on = 0
      }
      next
    }

    if (!in_on) {
      next
    }

    if (on_child_depth == -1) {
      on_child_depth = depth
    }

    if (depth == on_child_depth) {
      in_push = 0
      in_branches = 0
      if (line == "pull_request:") {
        pull_request_count += 1
      }
      if (line == "push:") {
        push_count += 1
        in_push = 1
        push_depth = depth
        push_child_depth = -1
      }
      next
    }

    if (!in_push) {
      next
    }

    if (depth <= push_depth) {
      in_push = 0
      in_branches = 0
      next
    }

    if (push_child_depth == -1) {
      push_child_depth = depth
    }

    if (depth == push_child_depth) {
      in_branches = 0
      if (line == "branches:") {
        branches_count += 1
        in_branches = 1
        branches_depth = depth
        branch_item_depth = -1
      }
      next
    }

    if (!in_branches) {
      next
    }

    if (depth <= branches_depth) {
      in_branches = 0
      next
    }

    if (branch_item_depth == -1) {
      branch_item_depth = depth
    }

    if (depth == branch_item_depth) {
      if (line == "- main") {
        main_branch_count += 1
      } else {
        unexpected_branch = 1
      }
    }
  }

  END {
    exit !(on_count == 1 && pull_request_count == 1 && push_count == 1 && branches_count == 1 && main_branch_count == 1 && !unexpected_branch)
  }
' "$workflow_path"; then
  echo "ERROR: workflow must have exactly one top-level on mapping with pull_request and push.branches containing only main" >&2
  exit 1
fi
require_workflow_match "Ubuntu runner" '^[[:space:]]*runs-on:[[:space:]]*ubuntu-latest[[:space:]]*$'
require_workflow_match "actions/checkout@v6" 'uses:[[:space:]]*actions/checkout@v6[[:space:]]*$'
require_workflow_match "Rokit version read from release config" "rokit_version=.*jq[[:space:]]+-er[[:space:]]+'.rokitVersion'[[:space:]]+config/release\\.json"
require_workflow_match "Rokit installer commit read from release config" "rokit_installer_commit=.*jq[[:space:]]+-er[[:space:]]+'.rokitInstallerCommit'[[:space:]]+config/release\\.json"
require_workflow_match "immutable Rokit Linux installer URL" 'https://raw\.githubusercontent\.com/rojo-rbx/rokit/\$\{rokit_installer_commit\}/scripts/install\.sh'
require_workflow_match "Rokit installer positional version argument" 'bash[[:space:]]+-s[[:space:]]+--[[:space:]]+"\$rokit_version"'
require_workflow_match "Rokit self-install GITHUB_PATH export" 'echo[[:space:]]+"\$HOME/\.rokit/bin"[[:space:]]*>>[[:space:]]*"\$GITHUB_PATH"'
require_workflow_match "Rokit self-install shell PATH export" 'export[[:space:]]+PATH="\$HOME/\.rokit/bin:\$PATH"'
require_workflow_match "rokit install" '^[[:space:]]*rokit[[:space:]]+install[[:space:]]*$'
require_workflow_match "release guard step" 'run:[[:space:]]*\./scripts/verify-release-contract\.sh[[:space:]]*$'
require_workflow_match "shell build step" 'run:[[:space:]]*\./scripts/build\.sh[[:space:]]*$'
require_workflow_match "workflow/ref concurrency group" 'group:[[:space:]]*\$\{\{[[:space:]]*github\.workflow[[:space:]]*\}\}-\$\{\{[[:space:]]*github\.ref[[:space:]]*\}\}'
require_workflow_match "actions/upload-artifact@v4" 'uses:[[:space:]]*actions/upload-artifact@v4[[:space:]]*$'
require_workflow_match "artifact name" 'name:[[:space:]]*tinyworld-v0\.5\.3-\$\{\{[[:space:]]*github\.sha[[:space:]]*\}\}[[:space:]]*$'
require_workflow_match "place artifact path" '^[[:space:]]*dist/TinyWorld-v0\.5\.3\.rbxlx[[:space:]]*$'
require_workflow_match "release manifest path" '^[[:space:]]*dist/release\.json[[:space:]]*$'
require_workflow_match "missing artifact failure" 'if-no-files-found:[[:space:]]*error[[:space:]]*$'
require_workflow_match "14-day retention" 'retention-days:[[:space:]]*14[[:space:]]*$'

if grep -Fq '$HOME/.local/bin' "$workflow_path"; then
  echo "ERROR: workflow must not use the obsolete Rokit self-install path: \$HOME/.local/bin" >&2
  exit 1
fi

if ! awk '
  /^permissions:[[:space:]]*$/ { in_permissions = 1; next }
  in_permissions && /^[^[:space:]]/ { in_permissions = 0 }
  in_permissions && /^[[:space:]]*$/ { next }
  in_permissions && /^[[:space:]]+contents:[[:space:]]*read[[:space:]]*$/ { contents_read += 1; next }
  in_permissions { invalid_permission = 1 }
  END { exit !(contents_read == 1 && !invalid_permission) }
' "$workflow_path"; then
  echo "ERROR: workflow permissions must contain only contents: read" >&2
  exit 1
fi

guard_step_line="$(grep -n -E 'run:[[:space:]]*\./scripts/verify-release-contract\.sh[[:space:]]*$' "$workflow_path" | head -n 1 | cut -d: -f1)"
build_step_line="$(grep -n -E 'run:[[:space:]]*\./scripts/build\.sh[[:space:]]*$' "$workflow_path" | head -n 1 | cut -d: -f1)"
if (( guard_step_line >= build_step_line )); then
  echo "ERROR: workflow must run the release guard before the shell build" >&2
  exit 1
fi

jq -e '
  .productVersion == "0.5.3" and
  .releaseName == "Production Engineering Foundation" and
  .profileSchema == 10 and
  .rojoVersion == "7.7.0" and
  .rokitVersion == "1.2.0" and
  .rokitInstallerCommit == "2f2618428ef31279e2fc80b0b1d73485bc929ddd" and
  .projectFile == "default.project.json" and
  .artifactFile == "TinyWorld-v0.5.3.rbxlx"
' config/release.json >/dev/null

jq -e '
  .name == "TinyWorld DEV" and .releaseChannel == "dev" and
  .configured == false and .universeId == null and .placeId == null and
  .publishing == "deferred"
' config/environments/dev.json >/dev/null

jq -e '
  .name == "TinyWorld LIVE" and .releaseChannel == "production" and
  .configured == false and .universeId == null and .placeId == null and
  .publishing == "deferred"
' config/environments/live.json >/dev/null

jq -e '.schemaVersion == 1 and (.assets | type == "array")' assets/manifests/assets.json >/dev/null

if ! grep -Fqx 'rojo = "rojo-rbx/rojo@7.7.0"' rokit.toml; then
  echo "ERROR: rokit.toml must pin rojo-rbx/rojo@7.7.0" >&2
  exit 1
fi

for rule in 'dist/' '.rokit/' '.worktrees/' '.superpowers/'; do
  if ! grep -Fqx "$rule" .gitignore; then
    echo "ERROR: .gitignore missing required rule: $rule" >&2
    exit 1
  fi
done

if ! command -v rg >/dev/null 2>&1; then
  echo "ERROR: required command missing: rg" >&2
  exit 1
fi

if rg -n -i 'ROBLOX_[A-Z0-9_]*API_KEY|ROBLOSECURITY|clientSecret|privateKey' config assets >/dev/null; then
  echo "ERROR: credential-shaped value found in config/ or assets/" >&2
  exit 1
else
  rg_status=$?
  case "$rg_status" in
    1)
      ;;
    *)
      echo "ERROR: credential scan failed with rg exit code $rg_status" >&2
      exit 1
      ;;
  esac
fi

if rg -n -i 'secrets|roblox|opencloud|publish|datastore|upload-place' "$workflow_path" >/dev/null; then
  echo "ERROR: forbidden publishing or credential token found in $workflow_path" >&2
  exit 1
else
  workflow_rg_status=$?
  case "$workflow_rg_status" in
    1)
      ;;
    *)
      echo "ERROR: workflow credential scan failed with rg exit code $workflow_rg_status" >&2
      exit 1
      ;;
  esac
fi

echo "PASS: release contract is valid"
