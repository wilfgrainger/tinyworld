# Free-Only CI and DEV Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove GitHub Actions artifact/cache storage from TinyWorld and add a safe direct-to-Roblox DEV publishing path that remains disabled until real DEV configuration and a secret exist.

**Architecture:** PR and `main` workflows continue on standard `ubuntu-latest` public-repository runners. Rojo output is ephemeral. `main` may call a focused `scripts/publish-dev.sh` helper that reads `config/environments/dev.json`; unconfigured DEV skips cleanly, configured DEV requires `ROBLOX_DEV_API_KEY` and posts the exact `.rbxlx` to Roblox Open Cloud Place Publishing.

**Tech Stack:** GitHub Actions, Bash, jq, curl, Rojo 7.7.0, Roblox Open Cloud Place Publishing API.

## Global Constraints

- £0 normal CI/CD operating cost.
- No `actions/upload-artifact` or `actions/cache` in active workflows.
- Standard GitHub-hosted Ubuntu runners only.
- PRs never publish and never receive Roblox publishing credentials.
- DEV may publish only from `main` after all build gates pass.
- LIVE remains manual and is not introduced by this change.
- Missing configuration skips DEV publishing; configured DEV with a missing secret fails closed.
- Roblox credentials never enter source control.

---

### Task 1: Free-only pipeline policy contract

**Files:**
- Modify: `tests/build-contract.sh`

**Interfaces:**
- Consumes: active files under `.github/workflows/`.
- Produces: a shell guard that rejects Actions artifact/cache primitives and non-standard current runner labels.

- [ ] **Step 1: Write the failing contract checks**

Replace the current 1-day artifact checks with checks that fail if any active workflow contains `actions/upload-artifact` or `actions/cache`, and require each current job's `runs-on` to remain `ubuntu-latest`.

- [ ] **Step 2: Run the Rojo workflow on the branch to verify RED**

Expected: `Verify build contract` fails because `.github/workflows/rojo-build.yml` still uses `actions/upload-artifact@v4`.

- [ ] **Step 3: Commit the RED test**

Commit message: `test: prohibit Actions storage in TinyWorld CI`.

### Task 2: Remove persistent Actions storage

**Files:**
- Modify: `.github/workflows/rojo-build.yml`

**Interfaces:**
- Consumes: existing build and release scripts.
- Produces: a deterministic build that leaves output only on the runner filesystem.

- [ ] **Step 1: Delete the `Upload release evidence` step**

Keep checkout, Rokit install, build-contract verification, release-contract verification, and `./scripts/build.sh` unchanged.

- [ ] **Step 2: Verify the build contract turns GREEN**

Expected: Rojo workflow passes and its run has zero Actions artifacts.

- [ ] **Step 3: Commit**

Commit message: `fix: remove Actions artifact storage`.

### Task 3: Direct DEV publisher with safe deferred mode

**Files:**
- Create: `scripts/publish-dev.sh`
- Create: `tests/publish-dev-contract.sh`

**Interfaces:**
- Consumes: `config/environments/dev.json`, `dist/release.json`, generated `.rbxlx`, optional `ROBLOX_DEV_API_KEY` environment variable.
- Produces: exit 0 with `DEV publishing deferred` when `configured` is false; otherwise validates numeric IDs and API key and POSTs the exact release artifact to Roblox.

- [ ] **Step 1: Write failing publisher contract**

The test creates fixture configs and a fake `curl` binary. It must prove: unconfigured config exits 0 without calling curl; configured config with missing key fails; malformed/null IDs fail; configured valid fixture calls the endpoint `https://apis.roblox.com/universes/v1/<universeId>/places/<placeId>/versions?versionType=Published`, supplies `x-api-key`, uses `Content-Type: application/xml`, and sends the manifest-selected `.rbxlx` with `--data-binary`.

- [ ] **Step 2: Verify RED**

Run: `bash tests/publish-dev-contract.sh`
Expected: FAIL because `scripts/publish-dev.sh` does not exist.

- [ ] **Step 3: Implement `scripts/publish-dev.sh`**

Behavior:

```bash
#!/usr/bin/env bash
set -euo pipefail

config="${TINYWORLD_DEV_CONFIG:-config/environments/dev.json}"
manifest="${TINYWORLD_RELEASE_MANIFEST:-dist/release.json}"

configured="$(jq -er '.configured | type == "boolean" and .' "$config" 2>/dev/null || true)"
if [[ "$configured" != "true" ]]; then
  echo "DEV publishing deferred: TinyWorld DEV is not configured"
  exit 0
fi

universe_id="$(jq -er '.universeId | select((type == "number") or (type == "string")) | tostring | select(test("^[0-9]+$"))' "$config")"
place_id="$(jq -er '.placeId | select((type == "number") or (type == "string")) | tostring | select(test("^[0-9]+$"))' "$config")"
artifact="$(jq -er '.artifact | select(type == "string" and endswith(".rbxlx"))' "$manifest")"
artifact_path="$(dirname "$manifest")/$artifact"
[[ -f "$artifact_path" ]] || { echo "ERROR: release artifact missing: $artifact_path" >&2; exit 1; }
: "${ROBLOX_DEV_API_KEY:?ROBLOX_DEV_API_KEY is required when DEV publishing is configured}"

response="$(curl --fail-with-body --silent --show-error --location \
  --request POST \
  "https://apis.roblox.com/universes/v1/${universe_id}/places/${place_id}/versions?versionType=Published" \
  --header "x-api-key: ${ROBLOX_DEV_API_KEY}" \
  --header "Content-Type: application/xml" \
  --data-binary "@${artifact_path}")"

version="$(jq -er '.versionNumber | numbers' <<<"$response")"
echo "Published TinyWorld DEV place version ${version}"
```

- [ ] **Step 4: Verify GREEN**

Run: `bash tests/publish-dev-contract.sh`
Expected: PASS.

- [ ] **Step 5: Commit**

Commit message: `feat: add direct Roblox DEV publisher`.

### Task 4: Wire DEV publishing to `main` only

**Files:**
- Modify: `.github/workflows/rojo-build.yml`
- Modify: `tests/build-contract.sh`

**Interfaces:**
- Consumes: `scripts/publish-dev.sh` and repository secret `ROBLOX_DEV_API_KEY`.
- Produces: main-only deployment hook after successful build; PR build remains credential-free.

- [ ] **Step 1: Extend the failing build contract**

Require a `Publish TinyWorld DEV` workflow step guarded by `github.event_name == 'push' && github.ref == 'refs/heads/main'`, and reject any PR-level secret use.

- [ ] **Step 2: Verify RED**

Expected: Rojo workflow fails before the new workflow step exists.

- [ ] **Step 3: Add the main-only workflow step**

Use:

```yaml
      - name: Publish TinyWorld DEV
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        env:
          ROBLOX_DEV_API_KEY: ${{ secrets.ROBLOX_DEV_API_KEY }}
        run: ./scripts/publish-dev.sh
```

Because current `dev.json` is unconfigured, a `main` run prints the deferred message and does not contact Roblox.

- [ ] **Step 4: Verify GREEN and zero artifacts**

Expected: PR workflows all pass; PR Rojo run contains zero artifacts. After merge, `main` workflows all pass; main Rojo run contains zero artifacts and DEV publishing reports deferred while the config remains unconfigured.

- [ ] **Step 5: Commit**

Commit message: `ci: publish main directly to Roblox DEV`.

### Task 5: Document zero-cost boundary

**Files:**
- Modify: `docs/engineering/production-engineering.md`

**Interfaces:**
- Consumes: implemented workflow behavior.
- Produces: operational documentation stating that normal CI uses free public standard runners, generated files are ephemeral, Actions storage is prohibited, DEV publishes directly when configured, and LIVE stays manual.

- [ ] **Step 1: Update production engineering documentation**

Remove language implying an Actions artifact is retained between stages and document the direct publish/deferred behavior.

- [ ] **Step 2: Final verification**

Verify all branch workflows succeed, repository workflows contain no `actions/upload-artifact`/`actions/cache`, PR Rojo artifacts are empty, and the diff is limited to the free-only pipeline scope.

- [ ] **Step 3: Commit**

Commit message: `docs: document free-only deployment pipeline`.
