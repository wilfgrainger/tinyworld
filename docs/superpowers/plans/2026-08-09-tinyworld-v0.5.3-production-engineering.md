# TinyWorld v0.5.3 Production Engineering Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a credential-free, reproducible Rojo build and release-evidence foundation while explicitly documenting the GitHub/Roblox/Studio ownership boundary.

**Architecture:** Keep the current `default.project.json` DataModel mapping and server-authoritative game architecture unchanged. Add versioned release/environment/asset declarations, two equivalent build entrypoints, a fail-closed contract guard, and a PR/main CI workflow that builds and uploads the exact place artifact without Roblox credentials.

**Tech Stack:** POSIX shell, PowerShell, JSON, `jq`, SHA-256, GitHub Actions, Rokit, Rojo 7.7.0, existing Luau test/analysis/compile toolchain.

## Global Constraints

- Product version is exactly `0.5.3`; release name is `Production Engineering Foundation`.
- The existing profile schema remains exactly `10`; no profile migration is introduced.
- `config/release.json` is the source of truth for exact Rojo `7.7.0`, Rokit
  `1.2.0`, and Rokit's immutable installer commit; `rokit.toml` pins the
  matching Rojo package.
- The build source remains exactly `default.project.json` for this release.
- DEV and LIVE environment files contain no real IDs or secrets and remain explicitly unconfigured.
- No workflow in this plan reads Roblox credentials, calls Roblox Open Cloud, publishes a place, or mutates a DataStore.
- The build artifact is `dist/TinyWorld-v0.5.3.rbxlx`; generated `dist/` output is not committed.
- The release record is `dist/release.json` and includes product version, source commit, branch, exact `buildTimestampUtc`, Rojo version, project file, profile schema, artifact filename, and SHA-256.
- Dirty builds fail by default; `TINYWORLD_ALLOW_DIRTY_BUILD=1` is permitted only for local test fixtures and never set by CI.
- The existing server-authoritative, visual-quality, physical-affordance, and v0.5.2 runtime contracts remain unchanged.
- Open Cloud deployment, package uploads, real universe/place IDs, DataStore namespace wiring, runtime automation, and LIVE promotion are deferred and documented as such.

---

### Task 1: Add release, environment, asset, and repository contracts

**Files:**
- Create: `config/release.json`
- Create: `config/environments/dev.json`
- Create: `config/environments/live.json`
- Create: `assets/manifests/assets.json`
- Create: `.gitignore`
- Create: `scripts/verify-release-contract.sh`
- Test: `scripts/verify-release-contract.sh` itself as the fail-closed contract gate

**Interfaces:**
- `config/release.json` exports `productVersion`, `releaseName`, `profileSchema`, `rojoVersion`, `rokitVersion`, `rokitInstallerCommit`, `projectFile`, and `artifactFile`.
- Each environment file exports `name`, `releaseChannel`, `configured`, `universeId`, `placeId`, and `publishing`.
- `assets/manifests/assets.json` exports `schemaVersion` and an `assets` array.
- `scripts/verify-release-contract.sh` exits `0` only when all declarations, pins, required files, ignore rules, and no-secret rules are valid.

- [ ] **Step 1: Write the failing contract check**

Create `scripts/verify-release-contract.sh` with `set -euo pipefail`. Resolve the repository root from the script location, require `jq`, and fail with a named error if any of these paths are missing: `default.project.json`, `rokit.toml`, `config/release.json`, `config/environments/dev.json`, `config/environments/live.json`, `assets/manifests/assets.json`, `scripts/build.sh`, and `scripts/build.ps1`.

The guard must validate these exact JSON predicates:

```sh
jq -e '
  .productVersion == "0.5.3" and
  .releaseName == "Production Engineering Foundation" and
  .profileSchema == 10 and
  .rojoVersion == "7.7.0" and
  .rokitVersion == "1.2.0" and
  .rokitInstallerCommit == "2f2618428ef31279e2fc80b0b1d73485bc929ddd" and
  .projectFile == "default.project.json" and
  .artifactFile == "TinyWorld-v0.5.3.rbxlx"
' config/release.json

jq -e '
  .name == "TinyWorld DEV" and .releaseChannel == "dev" and
  .configured == false and .universeId == null and .placeId == null and
  .publishing == "deferred"
' config/environments/dev.json

jq -e '
  .name == "TinyWorld LIVE" and .releaseChannel == "production" and
  .configured == false and .universeId == null and .placeId == null and
  .publishing == "deferred"
' config/environments/live.json

jq -e '.schemaVersion == 1 and (.assets | type == "array")' assets/manifests/assets.json
```

Also require `rojo = "rojo-rbx/rojo@7.7.0"` in `rokit.toml`, require `dist/`, `.rokit/`, `.worktrees/`, and `.superpowers/` in `.gitignore`, and reject credential-shaped values such as `ROBLOX_*API_KEY`, `ROBLOSECURITY`, `clientSecret`, or `privateKey` inside `config/` and `assets/`.

- [ ] **Step 2: Run the guard to verify the expected RED state**

Run:

```sh
./scripts/verify-release-contract.sh
```

Expected: FAIL because the v0.5.3 declarations, ignore file, and build entrypoints do not exist yet. The failure must identify missing paths rather than silently succeeding.

- [ ] **Step 3: Add the minimal declarations and ignore rules**

Add the exact release JSON:

```json
{
  "productVersion": "0.5.3",
  "releaseName": "Production Engineering Foundation",
  "profileSchema": 10,
  "rojoVersion": "7.7.0",
  "rokitVersion": "1.2.0",
  "rokitInstallerCommit": "2f2618428ef31279e2fc80b0b1d73485bc929ddd",
  "projectFile": "default.project.json",
  "artifactFile": "TinyWorld-v0.5.3.rbxlx"
}
```

Add DEV and LIVE declarations with the predicates above, and add:

```json
{
  "schemaVersion": 1,
  "assets": []
}
```

Add `.gitignore` entries for generated builds, local tool links, Superpowers workspaces, and local linked worktrees:

```text
dist/
.rokit/
.worktrees/
.superpowers/
*.rbxl
*.rbxlx
```

Do not add IDs, API keys, cookies, or asset IDs.

- [ ] **Step 4: Run the guard to verify GREEN**

Run:

```sh
./scripts/verify-release-contract.sh
```

Expected: FAIL only because `scripts/build.sh` and `scripts/build.ps1` are still absent. After those entrypoints are created in Task 2, the same command must print a concise PASS line and exit `0`.

- [ ] **Step 5: Commit**

```sh
git add .gitignore config assets scripts/verify-release-contract.sh
git commit -m "build: define v0.5.3 release contracts"
```

### Task 2: Implement deterministic build entrypoints and release metadata

**Files:**
- Create: `scripts/build.sh`
- Create: `scripts/build.ps1`
- Create: `tests/build-contract.sh`

**Interfaces:**
- `./scripts/build.sh` builds the current configured release into `dist/`.
- `./scripts/build.sh --check` validates the required tools and exits without writing an artifact.
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1` performs the equivalent Windows build.
- `tests/build-contract.sh` executes the shell entrypoint against a temporary Rojo stub and verifies the generated artifact metadata without requiring Rojo locally.

- [ ] **Step 1: Write the failing build behavior test**

Create `tests/build-contract.sh` with `set -euo pipefail`. It must:

1. Create a temporary directory and remove it on exit.
2. Create a temporary `rojo` executable that returns `rojo 7.7.0` for `--version`, parses the `--output` argument for `build`, and writes a small deterministic XML place fixture to that output path.
3. Prepend the stub directory to `PATH`.
4. Run `TINYWORLD_ALLOW_DIRTY_BUILD=1 ./scripts/build.sh`.
5. Assert that `dist/TinyWorld-v0.5.3.rbxlx` and `dist/release.json` exist.
6. Assert with `jq` that the manifest contains `productVersion == "0.5.3"`, `rojoVersion == "7.7.0"`, `artifact == "TinyWorld-v0.5.3.rbxlx"`, a 64-character lowercase `sha256`, and `profileSchema == 10`.
7. Recompute the artifact SHA-256 and assert it equals the manifest value.

Run it before the build scripts exist:

```sh
./tests/build-contract.sh
```

Expected: FAIL because `scripts/build.sh` is absent.

- [ ] **Step 2: Implement the POSIX build entrypoint**

Implement `scripts/build.sh` with these exact behaviors:

- Resolve `ROOT_DIR`, read `config/release.json` using `jq`, and set `OUTPUT_DIR` to `${TINYWORLD_BUILD_DIR:-$ROOT_DIR/dist}`.
- Accept only `--check` and `--output <directory>`; reject unknown options.
- Require `jq`, `git`, `sha256sum` or `shasum`, and `rojo` with actionable errors.
- Read the expected Rojo version from `config/release.json` and accept only the
  exact `rojo 7.7.0` official output form (or the bare configured version);
  reject suffixes and additional version text.
- In normal build mode, reject any non-empty `git status --porcelain` unless `TINYWORLD_ALLOW_DIRTY_BUILD=1`.
- Create the output directory, invoke `rojo build "$ROOT_DIR/default.project.json" -o "$artifact_path"`, compute SHA-256, and write `release.json` using `jq -n`.
- Use UTC ISO-8601 for `buildTimestampUtc`.
- Resolve the source commit with `git rev-parse HEAD` and branch from `git branch --show-current`, falling back to `GITHUB_HEAD_REF`, `GITHUB_REF_NAME`, and finally `detached`.
- Write metadata only after the Rojo command succeeds.
- Print the artifact path and digest at the end.

The manifest shape must be:

```json
{
  "productVersion": "0.5.3",
  "releaseName": "Production Engineering Foundation",
  "commit": "<full git sha>",
  "branch": "<branch or detached>",
  "buildTimestampUtc": "<UTC ISO-8601>",
  "rojoVersion": "7.7.0",
  "projectFile": "default.project.json",
  "profileSchema": 10,
  "artifact": "TinyWorld-v0.5.3.rbxlx",
  "sha256": "<64 lowercase hex characters>"
}
```

- [ ] **Step 3: Run the shell build test to verify GREEN**

Run:

```sh
./tests/build-contract.sh
```

Expected: PASS, with the stub producing a fixture artifact and the manifest digest matching the recomputed digest.

- [ ] **Step 4: Implement the PowerShell equivalent**

Implement `scripts/build.ps1` with the same inputs, checks, metadata fields, dirty-tree rule, output names, and failure ordering. Use `ConvertFrom-Json`, `Get-Command`, `Get-FileHash -Algorithm SHA256`, `git rev-parse`, and `rojo build <project> --output <artifact>`. The script must support `-CheckOnly` and `-OutputDirectory`, reject unknown tool versions, and write UTF-8 JSON without a BOM where PowerShell permits.

- [ ] **Step 5: Run available checks**

Run:

```sh
./scripts/verify-release-contract.sh
./tests/build-contract.sh
git diff --check
```

Expected: all three commands exit `0`. Record that real Rojo build execution remains a CI/tooling gate if `rojo` is not installed locally.

- [ ] **Step 6: Commit**

```sh
git add scripts/build.sh scripts/build.ps1 tests/build-contract.sh
git commit -m "build: create traceable TinyWorld place artifacts"
```

### Task 3: Add credential-free CI Rojo build evidence

**Files:**
- Create: `.github/workflows/rojo-build.yml`

**Interfaces:**
- Workflow name: `Rojo build`.
- Triggers: `pull_request` and pushes to `main`.
- Permissions: `contents: read` only.
- Artifact name: `tinyworld-v0.5.3-${{ github.sha }}`.
- Uploaded paths: `dist/TinyWorld-v0.5.3.rbxlx` and `dist/release.json`.

- [ ] **Step 1: Add the workflow with no publishing surface**

Create a single Ubuntu job with these steps in order:

1. `actions/checkout@v6`.
2. Read `rokitVersion` and `rokitInstallerCommit` from `config/release.json`, invoke the immutable raw installer URL at that commit with `rokitVersion` as its first positional argument, add `$HOME/.local/bin` to `GITHUB_PATH`, and run `rokit install` so the existing `rokit.toml` supplies the Rojo version.
3. Run `./scripts/verify-release-contract.sh`.
4. Run `./scripts/build.sh`.
5. Upload the two `dist/` files with `actions/upload-artifact@v4`, `if-no-files-found: error`, and `retention-days: 14`.

The workflow must not contain `secrets`, `ROBLOX`, `OpenCloud`, `publish`, `DataStore`, `upload-place`, or any Roblox API call. It must use a concurrency group keyed by workflow and ref so duplicate build evidence for the same ref does not race.

- [ ] **Step 2: Add a source-level workflow contract check**

Extend `scripts/verify-release-contract.sh` to require `.github/workflows/rojo-build.yml`, the workflow name, both triggers, the artifact upload action, and the exact artifact path. Reject `ROBLOX_`, `ROBLOSECURITY`, `OpenCloud`, `DataStore`, and `publish` tokens in the workflow file.

- [ ] **Step 3: Verify the workflow contract locally**

Run:

```sh
./scripts/verify-release-contract.sh
git diff --check
```

Expected: PASS. The actual Rokit/Rojo build will be verified by GitHub Actions after the branch is published.

- [ ] **Step 4: Commit**

```sh
git add .github/workflows/rojo-build.yml scripts/verify-release-contract.sh
git commit -m "ci: build and archive TinyWorld release candidates"
```

### Task 4: Make v0.5.3 the canonical engineering release record

**Files:**
- Create: `docs/engineering/production-engineering.md`
- Create: `docs/roadmap/v0.5.3-production-engineering.md`
- Create: `docs/releases/v0.5.3/acceptance.md`
- Modify: `docs/README.md`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `docs/engineering/architecture.md`

**Interfaces:**
- `docs/engineering/production-engineering.md` is the durable source-of-truth and build/release boundary.
- `docs/roadmap/v0.5.3-production-engineering.md` explains what this release implements and the sequenced DEV/LIVE phases.
- `docs/releases/v0.5.3/acceptance.md` records exact local/CI evidence and explicitly open Roblox/runtime gates.
- `docs/README.md`, `README.md`, and `AGENTS.md` point new Codex sessions to v0.5.3 engineering authority while preserving v0.5.2 product acceptance.

- [ ] **Step 1: Write the failing documentation-link check**

Extend `scripts/verify-release-contract.sh` to require all three v0.5.3 canonical documents and the v0.5.3 design spec/plan, and to require the documentation index to link the v0.5.3 acceptance and engineering documents.

Run the guard and observe the expected RED state before the documents exist.

- [ ] **Step 2: Add the canonical operating model**

Write `docs/engineering/production-engineering.md` with the source-of-truth categories, current Rojo boundary, build commands, artifact manifest, CI/deployment separation, credential rules, environment declarations, evidence classes, and explicit v0.5.3 deferrals. It must say that Studio remains valuable for authoring/playtesting but is not an undocumented release master.

- [ ] **Step 3: Add roadmap and acceptance records**

Write the roadmap with phases: inventory, reproducible build, release metadata, DEV Open Cloud deployment, runtime/multiplayer evidence, explicit LIVE promotion, and later asset/package governance. Write the acceptance record with checkboxes for local guard, Luau gates, CI artifact, clean diff, and separate human gates for Studio, multiplayer, published DEV, device, and family acceptance.

- [ ] **Step 4: Update authority links without rewriting history**

Update the documentation index and root README so that v0.5.2 remains identified as the current product/presentation release and v0.5.3 is identified as the current engineering/release foundation. Update `AGENTS.md` to require reading the v0.5.3 acceptance/engineering records for build or release work, while keeping the v0.5.2 acceptance record authoritative for product behavior. Do not delete historical `docs/superpowers/` records.

- [ ] **Step 5: Run documentation and contract checks**

Run:

```sh
./scripts/verify-release-contract.sh
git diff --check
```

Expected: PASS with all links and required files present.

- [ ] **Step 6: Commit**

```sh
git add AGENTS.md README.md docs scripts/verify-release-contract.sh
git commit -m "docs: establish v0.5.3 release engineering authority"
```

### Final verification and handoff

- [ ] Run the full available Luau test/analysis/compile commands from `AGENTS.md`.
- [ ] Run every applicable v0.5.2 source guard plus the v0.5.3 release-contract and build-contract checks.
- [ ] Run `git diff --check`, `git status --short`, and confirm generated `dist/` output is ignored.
- [ ] Review the branch diff against the merged v0.5.2 line for unrelated gameplay or visual changes.
- [ ] Publish the branch from the current merged `main` tree and open a PR titled `feat: v0.5.3 production engineering foundation`.
- [ ] Request Codex review and wait for the `Luau tests` and `Rojo build` checks.
- [ ] Keep DEV/LIVE publishing explicitly absent from the PR description and list it as the next gated phase.
