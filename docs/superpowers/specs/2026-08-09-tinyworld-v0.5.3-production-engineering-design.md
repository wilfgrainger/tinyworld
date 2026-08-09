# TinyWorld v0.5.3 Production Engineering Foundation

**Status:** Approved implementation scope
**Release:** v0.5.3
**Date:** 2026-08-09
**Repository:** `wilfgrainger/tinyworld`

## Purpose

v0.5.3 establishes the first safe slice of TinyWorld's production engineering
model. It makes the reproducibility boundary explicit and gives the repository
a deterministic, credential-free build path without pretending that Roblox
cloud state, Studio-authored state, or production publishing already belongs
to GitHub.

The release is deliberately a foundation release, not an Open Cloud publishing
release. A clean checkout must be able to validate the repository contracts and,
when the pinned Rojo tool is available, construct a named place artifact and a
machine-readable release record.

## Decisions

### 1. Reproducible-build-first hybrid

TinyWorld uses a hybrid boundary:

- GitHub is authoritative for Luau, rules, configuration, documentation, tests,
  Rojo project definitions, build tooling, release metadata, environment
  declarations, and the asset-manifest registry.
- Roblox is authoritative for published places, DataStores, cloud asset IDs,
  packages, permissions, analytics, moderation, and platform configuration.
- Git-declared/Roblox-hosted resources are represented by named manifest entries
  and environment contracts, not scattered magic IDs or undocumented Studio
  state.

The current `default.project.json` mapping remains the build boundary for this
release. No broad DataModel refactor is justified until the inventory proves a
missing source input.

### 2. Build once, record the result

The canonical local build commands are:

```sh
./scripts/verify-release-contract.sh
./scripts/build.sh
```

Windows developers may use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1
```

Both build entrypoints use `default.project.json` and the exact
`config/release.json` `rojoVersion` property; `rokit.toml` pins the matching
Rojo package. The output is ignored by Git and contains:

```text
dist/TinyWorld-v0.5.3.rbxlx
dist/release.json
```

`release.json` records the product version, source commit, branch,
`buildTimestampUtc`, Rojo version, project file, profile schema, artifact
filename, and SHA-256. The
place artifact is the release candidate; the metadata is its traceability
record. The initial definition of reproducible is functional equivalence from a
clean checkout, not byte identity of files containing build-time metadata.

### 3. Environment declarations fail closed

`config/environments/dev.json` and `config/environments/live.json` define the
intended deployment channels without inventing unknown universe/place IDs.
Both are explicitly unconfigured in v0.5.3. The build and validation tooling
must never infer a target, use a production secret, or publish merely because
an environment file exists.

The future DEV publisher will require a configured DEV environment and a
DEV-only credential. The future LIVE promotion will require a separately
configured LIVE environment, a separately scoped credential, an approved
artifact, and an explicit promotion action.

### 4. Validation is separate from deployment

The existing Luau workflow remains the source/runtime static gate. A new
credential-free build workflow validates the release contract, installs the
repository's pinned Roblox toolchain through Rokit using the immutable
`config/release.json` `rokitInstallerCommit` and `rokitVersion` values. The
installer receives `rokitVersion` as its first positional argument, then builds the place, and
uploads the artifact and release metadata as CI artifacts.

The new workflow does not:

- read Roblox API keys;
- call Roblox Open Cloud;
- publish DEV or LIVE;
- mutate DataStores;
- infer Studio state;
- claim runtime, multiplayer, published-place, or device acceptance.

### 5. Asset registry starts as an explicit boundary

`assets/manifests/assets.json` is the named registry for future external or
Roblox-hosted assets. v0.5.3 does not invent asset IDs. An empty registry is a
valid foundation state, and every later required entry must document its type,
source, ownership, Roblox ID, release, and replacement/required status before a
production deployment workflow consumes it.

## Components

| Component | Responsibility | v0.5.3 outcome |
| --- | --- | --- |
| `config/release.json` | Product/build identity and schema/tool pins | Added and validated |
| `config/environments/*.json` | Non-secret DEV/LIVE target declarations | Added, explicitly unconfigured |
| `assets/manifests/assets.json` | Named external asset registry | Added with no fabricated IDs |
| `scripts/verify-release-contract.sh` | Fast fail-closed repository contract check | Added and run in CI |
| `scripts/build.sh` | Linux/macOS/Git Bash build and manifest generation | Added |
| `scripts/build.ps1` | PowerShell build and manifest generation | Added |
| `.github/workflows/rojo-build.yml` | PR/main credential-free build evidence | Added |
| `docs/engineering/production-engineering.md` | Canonical operating model | Added |
| `docs/releases/v0.5.3/acceptance.md` | Release evidence and human-gate boundary | Added |

## Failure behavior

- Missing or malformed release/environment/asset metadata fails validation.
- A release version that does not match the v0.5.3 contract fails validation.
- A missing `default.project.json`, `rokit.toml`, or build entrypoint fails
  validation.
- A build without the expected Rojo version fails before producing a release
  claim.
- A dirty source tree fails a release build unless an explicit local override
  is provided; CI never uses the override.
- A missing required external tool fails with an actionable install message.
- No configured environment can be used as a publishing target by the v0.5.3
  build scripts because publishing is not part of their interface.

## Testing and evidence

The release must provide:

1. Existing pure Luau tests, analysis, and server/client compilation.
2. A local release-contract guard with a zero exit code.
3. A CI Rojo build job that uploads `TinyWorld-v0.5.3.rbxlx` and
   `release.json`.
4. `git diff --check` and a clean working tree after verification.

The following remain human/environment gates and must be recorded as not run
until actually performed:

- Studio opening the built artifact;
- one-player runtime behavior;
- Server & Clients multiplayer behavior;
- a published DEV place;
- mobile/controller/device behavior;
- family playtesting;
- Roblox asset moderation and cloud package availability.

## Explicitly deferred

The following are future phases, not hidden requirements of v0.5.3:

- actual DEV and LIVE universe/place IDs;
- Open Cloud place publishing;
- GitHub environment secrets and production approvals;
- DEV/LIVE DataStore namespace wiring;
- same-artifact DEV promotion and LIVE promotion;
- automated Roblox runtime/multiplayer tests;
- package upload/update governance;
- source-art export pipelines and licensing records for production art;
- rollback automation and migration compatibility checks beyond the existing
  profile contract.

These are deferred because implementing them without the real Roblox ownership,
universe, place, DataStore, asset, and credential inventory would create a
workflow that looks professional but cannot safely publish the right game.

## Success definition

From a clean checkout, a developer or Codex can install the documented pinned
tools, run the release-contract guard, and run the canonical build to produce a
traceable TinyWorld place artifact without opening Studio or possessing any
Roblox production credential. The repository clearly states what this proves
and what it does not prove.
