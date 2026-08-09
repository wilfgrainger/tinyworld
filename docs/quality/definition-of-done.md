# Definition of done

A TinyWorld release is done only when behaviour, presentation, safety and evidence meet the active acceptance record. Repository implementation and runtime/device release approval are deliberately separate states.

## Required repository conditions

- Implementation matches the approved target/release scope.
- New deterministic behaviour was specified by a failing test before production logic and passes afterward.
- Pure tests, shared analysis, StyLua, recursive server/client compile, release/build contracts and `git diff --check` pass.
- Source guards fail closed when required modules, environment separation, asset provenance or release authority is absent.
- Server-authoritative economy, progression, inventory, furniture, privacy, trade, transport, portal, profile and save boundaries remain intact.
- Profile migrations are explicit, deterministic, tested and fail closed on unsupported future data.
- New RemoteEvents validate type/size/range/ID/rate/context/ownership as relevant and never accept client-authored price/reward/final state.
- DEV and LIVE persistence namespaces remain separate.
- Production asset IDs, if any, are real and provenance/approval metadata is complete.
- Documentation identifies the exact current release and evidence state without contradicting canonical authority.

## Required runtime/presentation conditions before a runtime gate becomes PASS

- Key objects pass silhouette, scale, material and feedback checks with labels hidden.
- First 2/10/30-minute routes are comprehensible without external coaching.
- Home purchase/place/move/store/rejoin behaviour works in Studio.
- Multi-client visits, privacy, furniture replication and trades behave correctly.
- Phone/controller routes meet touch/focus/readability requirements.
- Performance route meets or explicitly reports misses against budgets.
- Studio/published Output contains no unresolved critical errors.
- Family/child observation covers recognisability, social/purchase clarity and next-action comprehension where required.

## Evidence classes

| Class | Proves | Does not prove |
| --- | --- | --- |
| Pure tests/static guards | Deterministic rules/source contracts | Roblox rendering/live interaction |
| Analysis/format/compile | Parse/type/style/syntax health | Gameplay/visual quality |
| Rojo build/manifest | Reproducible candidate identity | Runtime correctness |
| Studio one-player | Local runtime/visual flow | Multi-client/published/device behaviour |
| Studio multi-client | Replication/social flows | Published service/device behaviour |
| Real-device | Input/readability/FPS/memory/load evidence | Published backend correctness by itself |
| Published DEV | Real platform/service behaviour for exact artifact | LIVE approval |
| LIVE promotion record | Exact approved artifact deployed | Long-term retention/scale |

Unavailable tooling or unobserved human evidence is **PENDING**, never silently treated as passing.

## Security abuse cases

At minimum, acceptance considers:

- malformed/oversized RemoteEvent payloads;
- NaN/infinite/out-of-range transforms;
- rapid repeated requests;
- fake furniture/shop IDs;
- client-authored price/reward attempts;
- non-owner home mutation;
- stale/duplicate trade confirmation/commit;
- lease conflict/save failure/future profile version.

## Final release discipline

The exact artifact tested in DEV is the artifact eligible for LIVE promotion. Feature additions after DEV approval require a new candidate/evidence cycle. Rollback compatibility with persisted schema must be reviewed before LIVE.