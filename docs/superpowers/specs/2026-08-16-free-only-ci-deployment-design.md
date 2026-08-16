# TinyWorld Free-Only CI and Deployment Design

Status: Approved direction, implementation pending
Date: 2026-08-16
Repository: `wilfgrainger/tinyworld`

## Goal

Run TinyWorld's source validation, Rojo build and future Roblox DEV deployment without any paid CI/CD service or billable GitHub Actions storage dependency.

The pipeline must remain useful under a £0 operating-cost constraint. If a future change would require paid infrastructure, the pipeline must fail closed rather than silently consume it.

## Current problem

The repository is public and its three current GitHub Actions workflows use standard GitHub-hosted Linux runners. The Rojo workflow also uploads generated `.rbxlx` build output into GitHub Actions artifact storage. Rapid development caused those retained artifacts to consume the account's included Actions storage.

The repository's DEV and LIVE Roblox environment declarations are still intentionally unconfigured, so Roblox publishing is not yet active.

## Design decision

### 1. CI remains on GitHub Actions standard public-repository runners

PR and `main` validation stays on `ubuntu-latest` and uses no self-hosted, larger or premium runner classes.

The repository must not introduce paid third-party CI services for the normal TinyWorld pipeline.

### 2. Actions artifact and cache storage is prohibited

Normal CI must not use:

- `actions/upload-artifact`;
- `actions/cache`;
- workflow-generated persistent Actions artifacts or caches.

Build output exists only inside the ephemeral runner unless it is being immediately published to an approved external destination.

PRs run tests, release-authority checks and a Rojo build, then discard the generated output when the runner exits.

### 3. `main` builds are ephemeral too

A push to `main` performs the same source gates and produces the deterministic `.rbxlx` plus `dist/release.json` only inside the runner.

No routine `main` build is retained in Actions storage.

### 4. DEV deployment will be direct-to-Roblox

Once `config/environments/dev.json` contains approved non-secret Universe/Place IDs and is marked configured, a successful `main` build may publish the exact generated `.rbxlx` directly to the TinyWorld DEV place through Roblox Open Cloud Place Publishing.

The Roblox API key remains a GitHub Actions secret and must never be committed to the repository.

Untrusted PR workflows never receive publishing credentials and never publish.

Until DEV is configured, the deployment step must skip cleanly after build validation rather than inventing IDs or weakening the environment contract.

### 5. LIVE remains explicitly manual

This change does not enable automatic LIVE publishing.

LIVE promotion remains a separately approved operation. The future promotion path must preserve TinyWorld's exact-artifact principle without returning to GitHub Actions artifact storage. If durable release evidence is required, use a normal GitHub Release asset associated with an approved version/tag, not Actions artifact storage.

### 6. Free-only policy is tested

A repository guard will inspect active workflow files and fail if a future workflow reintroduces known Actions storage primitives such as `actions/upload-artifact` or `actions/cache`.

The guard will also require standard GitHub-hosted Ubuntu runners for the current CI jobs.

This is a repository-level guard. Account-level billing budgets remain an external GitHub setting and are not represented as code.

## Pipeline flow

```text
Pull request
  -> Luau tests / analysis / formatting / compile
  -> release-authority checks
  -> Rojo deterministic build
  -> verify manifest + SHA-256
  -> discard runner filesystem

main push
  -> same validation
  -> Rojo deterministic build
  -> verify manifest + SHA-256
  -> if DEV configured: publish exact in-runner .rbxlx directly to Roblox DEV
  -> otherwise: report DEV publishing deferred
  -> discard runner filesystem

LIVE
  -> no automatic path in this change
  -> explicit human approval remains mandatory
```

## Failure behaviour

- Test/build failure: no deployment.
- Missing DEV configuration: build succeeds, deployment is skipped and reported as deferred.
- Missing DEV secret after DEV is explicitly configured: deployment fails closed.
- Roblox publishing error: workflow fails; no LIVE fallback occurs.
- Reintroduction of Actions artifact/cache storage: free-only policy test fails.

## Security boundary

- Workflow permissions stay least-privilege.
- PRs have no Roblox publishing secret access.
- Universe and Place IDs may be committed in environment config because they are identifiers, not credentials.
- Roblox API credentials remain outside source control.
- LIVE credentials are not introduced by this change.

## Testing

Implementation will use a contract-first change:

1. Update/add a shell policy test that fails against the current `actions/upload-artifact` workflow.
2. Remove Actions artifact storage from the Rojo workflow.
3. Make the policy test pass.
4. Run the existing build contract and all three GitHub workflows on the change branch.
5. Verify the PR Rojo run produces zero workflow artifacts.
6. After merge, verify the `main` Rojo run also produces zero workflow artifacts.

Direct Roblox DEV publishing cannot be positively exercised until DEV IDs and the GitHub secret are deliberately configured. Its unconfigured/deferred path will be testable in CI.

## Out of scope

- Setting GitHub account billing budgets.
- Purchasing GitHub Actions capacity.
- Automatic LIVE deployment.
- Inventing or discovering Roblox Universe/Place IDs.
- Storing Roblox credentials in Git.
- Changing game runtime behaviour, profile schema, economy or art scope.
