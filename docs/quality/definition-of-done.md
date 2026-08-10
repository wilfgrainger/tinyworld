# Definition of done

A TinyWorld release is done only when behaviour, presentation, safety and evidence meet the active acceptance record. Repository implementation and runtime/device release approval are deliberately separate states.

## Required repository conditions

- Implementation matches the approved target/release scope.
- New deterministic behaviour was specified by a failing test before production logic and passes afterward.
- Pure tests, shared analysis, StyLua, recursive server/client compile, release/build contracts and `git diff --check` pass.
- Source guards fail closed when required modules, environment separation, asset provenance, visual prohibitions or release authority are absent.
- Server-authoritative economy, progression, inventory, furniture, privacy, trade, transport, portal, profile and save boundaries remain intact.
- Profile migrations are explicit, deterministic, tested and fail closed on unsupported future data.
- New RemoteEvents validate type/size/range/ID/rate/context/ownership as relevant and never accept client-authored price/reward/final state.
- DEV and LIVE persistence namespaces remain separate.
- Production asset IDs, if any, are real and provenance/approval metadata is complete.
- Documentation identifies the exact current release and evidence state without contradicting canonical authority.
- Historical documents remain clearly historical and do not accidentally override active release guidance.

## Required v0.6.1 visual source conditions

- primitive welded Part hair/shoe fallback is absent from the active appearance path;
- player's existing Roblox avatar is preserved when no approved TinyWorld character asset exists;
- ordinary village builders do not use large always-on-top BillboardGui information walls;
- prototype system-label copy is not used as finished world identity;
- normal HUD is compact/world-first rather than a website-style header or telemetry dashboard;
- hero objects remain behind existing semantic/gameplay boundaries without moving authority into art code.

## Required runtime/presentation conditions before a player-facing release is done

- Key objects pass silhouette, scale, material and feedback checks with explanatory labels hidden.
- Player character presentation is at least as coherent as the normal Roblox avatar baseline.
- First 2/10/30-minute routes are comprehensible without external coaching.
- Home purchase/place/move/store/rejoin behaviour works in Studio.
- Multi-client visits, privacy, furniture replication and trades behave correctly where the release changes/depends on them.
- Phone/controller routes meet touch/focus/readability requirements.
- Performance route meets or explicitly reports misses against budgets.
- Studio/published Output contains no unresolved critical errors.
- Family/child observation covers recognisability, social/purchase clarity and next-action comprehension where required.
- Ordinary village destinations do not need floating information walls to explain what they are.

For v0.6.1 and later player-facing visual releases, required Studio/device rows may be NOT RUN while a PR is draft but **block merge-ready status until observed**.

## Evidence classes

| Class | Proves | Does not prove |
| --- | --- | --- |
| Pure tests/static guards | Deterministic rules/source contracts/prohibited mechanism absence | Roblox rendering/live interaction |
| Analysis/format/compile | Parse/type/style/syntax health | Gameplay/visual quality |
| Rojo build/manifest | Reproducible candidate identity | Runtime correctness |
| Studio one-player | Local runtime/visual flow | Multi-client/published/device behaviour |
| Studio multi-client | Replication/social flows | Published service/device behaviour |
| Real-device | Input/readability/FPS/memory/load evidence | Published backend correctness by itself |
| Published DEV | Real platform/service behaviour for exact artifact | LIVE approval |
| LIVE promotion record | Exact approved artifact deployed | Long-term retention/scale |

Unavailable tooling or unobserved evidence is **NOT RUN/PENDING**, never silently treated as passing.

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

No merge, DEV publish or LIVE promotion is implied by source completion alone.