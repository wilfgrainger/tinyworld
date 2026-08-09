# Definition of done

A TinyWorld release is done only when behavior, presentation, safety, and evidence meet the active acceptance record.

## Required conditions

- The implementation matches the approved scope and leaves deferred systems out.
- New deterministic behavior has a test that was observed failing before implementation and passing afterward.
- Source guards fail closed when required modules, boundaries, or release contracts are absent.
- Existing server-authoritative economy, progression, ownership, privacy, trade, transport, portal, inventory, profile, and save contracts remain intact.
- Luau tests, analysis, server/client compilation, relevant source guards, and `git diff --check` pass wherever tools are available.
- Key objects pass the silhouette, scale, material, and feedback contract with labels hidden.
- Studio routes cover onboarding, home, village, vehicles, portals, trades, persistence, and Output review as applicable.
- Multi-client, published-place, and device evidence is captured or explicitly remains an open human gate.
- Documentation names the exact evidence available and does not present source inspection as runtime proof.

## Evidence classes

| Class | Proves | Does not prove |
| --- | --- | --- |
| Pure tests and static guards | Deterministic rules and source contracts | Roblox rendering or live interaction |
| Luau analysis and compilation | Parse/type/syntax health | Gameplay quality |
| Studio one-player route | Local runtime flow and visual inspection | Replication at scale or published behavior |
| Studio multi-client route | Local replication and social interaction | Published service/device behavior |
| Published-place/device route | Real service and input behavior | Long-term retention or broad scale |

Unavailable tooling or missing human evidence is reported as a concern, never silently treated as passing.
