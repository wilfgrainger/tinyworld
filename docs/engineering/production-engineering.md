# Production engineering

## v0.6.1 operating authority

v0.6.1 **Visual Rescue** is the current repository/build contract. The [v0.6.1 acceptance record](../releases/v0.6.1/acceptance.md) owns evidence status; the [v1 target state](../product/target-state-v1.md) owns product direction; merged v0.6.0 remains the technical/product baseline beneath this corrective release.

| State category | Authority | Rule |
| --- | --- | --- |
| Git-authoritative | Luau, tests, configuration, docs, Rojo project, tooling, release/environment declarations, asset manifest | Review/build/evidence from Git. |
| Roblox-authoritative | Published places, DataStores, hosted asset IDs, permissions, analytics/moderation/platform state | Never invent or overwrite from undocumented assumptions. |
| Git-declared / Roblox-hosted | Approved asset/deployment relationships | Declare in manifest/environment contracts; never scatter IDs/secrets through source. |

Studio is a runtime/visual evidence surface, not an undocumented release master.

## Toolchain/build

Pinned through repository contracts:

- Rojo 7.7.0;
- StyLua 2.5.2;
- Rokit 1.2.0;
- profile schema 11.

Required source/build gates:

```sh
luau tests/run.luau
luau-analyze src/shared/*.luau tests/*.luau
stylua --check src tests
find src/server -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
find src/client -type f -name '*.luau' -print0 | xargs -0 luau-compile >/dev/null
bash tests/verify-release-authority.sh
bash tests/verify-v0.6.1-visual-contract.sh
./scripts/verify-release-contract.sh
./tests/build-contract.sh
./scripts/build.sh
git diff --check
```

Windows build parity uses `scripts/build.ps1` and `tests/build-contract.ps1`.

The candidate output is:

```text
dist/TinyWorld-v0.6.1.rbxlx
dist/release.json
```

The manifest records source commit/branch, build timestamp, tool/project/profile versions, artifact filename and SHA-256. The artifact is a candidate until the active runtime/device evidence passes.

## Free-only CI and DEV deployment

TinyWorld's normal CI/CD path has a zero-paid-infrastructure constraint.

- Active CI jobs use standard `ubuntu-latest` GitHub-hosted runners in the public repository.
- Active workflows must not use `actions/upload-artifact` or `actions/cache`.
- PR builds are fully ephemeral: tests, release checks and the Rojo build run, then the runner filesystem is discarded.
- A `main` build is also ephemeral. After the build and release contracts pass, the workflow invokes `scripts/publish-dev.sh`.
- `scripts/publish-dev.sh` reads `config/environments/dev.json`. While `configured` is `false`, it exits successfully with `DEV publishing deferred` and never contacts Roblox.
- When DEV is deliberately configured, `universeId` and `placeId` must be numeric, `publishing` must be `open-cloud`, and the workflow must receive `ROBLOX_DEV_API_KEY` from GitHub Actions secrets. Missing or malformed configured values fail closed.
- PR workflows never run the publisher step and therefore never consume the DEV publishing secret.
- LIVE publishing is not automated by this pipeline.

The direct DEV publisher sends the exact in-runner `.rbxlx` selected by `dist/release.json` to Roblox Open Cloud Place Publishing and requires a numeric `versionNumber` response before reporting success.

This route deliberately avoids GitHub Actions artifact/cache storage. If an approved build later needs durable retention for LIVE promotion, use a separately approved release packaging mechanism such as a normal versioned GitHub Release asset rather than reintroducing Actions artifact storage. Routine `main` builds are not treated as durable LIVE-promotion packages.

Roblox Place Publishing has platform limitations for some serialized instance types. A release that depends on an unsupported serialized instance must use an approved alternate publishing route rather than claiming that a green source build proves a correct DEV publish.

## Visual evidence as a release gate

v0.6.1 corrects a process weakness exposed by the first observed v0.6.0 screenshots: source/build completion cannot stand in for rendered quality.

For player-facing visual work:

1. automated source/build checks remain mandatory;
2. required Studio/device rows may remain `NOT RUN` while the PR is draft;
3. the PR may not become merge-ready while required visual rows remain `NOT RUN`, `PENDING` or `FAIL`;
4. screenshots/route notes identify the exact candidate SHA/artifact;
5. a failed visual row creates bounded corrective work rather than being reclassified from source inspection.

The exact v0.6.1 visual rows are owned by `docs/releases/v0.6.1/acceptance.md`.

## DEV/LIVE environment safety

Repository environment declarations remain credential-free/unconfigured until explicit approval.

Persistence is separated by runtime namespace:

- DEV: `TinyWorld_DEV_PlayerProfile_v11`;
- LIVE: `TinyWorld_LIVE_PlayerProfile_v11`.

Studio defaults to DEV. Never let Studio testing write LIVE player data.

Future configured deployment requires separate DEV/LIVE place identity, scoped Open Cloud credentials stored outside source control and environment protection. Untrusted PRs must never receive publishing credentials.

## Target same-artifact promotion

```text
commit
  -> CI tests/analysis/format/compile
  -> exact Rojo artifact + SHA manifest
  -> Studio/device visual and runtime evidence for player-facing changes
  -> publish that exact artifact to DEV when configured/approved
  -> published runtime/multiplayer/device evidence
  -> explicit human approval
  -> promote the exact approved artifact to LIVE
```

Do not rebuild different source for LIVE after DEV approval. The routine free-only `main` pipeline discards its runner after DEV deployment, so it is not itself the durable LIVE promotion store. Before LIVE automation is enabled, an approved versioned release-package path must preserve the exact binary and SHA without returning to Actions artifact storage.

## Rollback contract

Before LIVE publishing is enabled, document/record:

- last-known-good artifact/SHA;
- rollback trigger/operator;
- exact rollback procedure;
- profile-schema compatibility;
- migrations that cannot be reversed;
- emergency disable strategy for risky systems.

A code rollback cannot blindly reverse persisted data migrations.

v0.6.1 does not change profile schema, which reduces rollback risk, but presentation changes still use an exact identifiable candidate.

## Asset release boundary

Roblox-hosted production assets enter only through `assets/manifests/assets.json` with real IDs and provenance. Empty manifest means approved native/default presentation remains authoritative.

A native fallback is not automatically visual approval. Hero-tier presentation must satisfy the visual-quality bar or preserve a better Roblox-native baseline instead.

Asset upload/publishing remains separately permissioned.

## Evidence classes

Keep these independent:

1. automated source/build;
2. Studio single-client;
3. Studio multi-client;
4. real-device/accessibility/performance;
5. published DEV;
6. LIVE promotion/rollback.

CI success proves only class 1. For v0.6.1 the required class 2/4 visual rows are explicit merge-readiness gates, not post-merge aspirations.