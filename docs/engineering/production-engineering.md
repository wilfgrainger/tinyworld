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

Do not rebuild different source for LIVE after DEV approval.

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