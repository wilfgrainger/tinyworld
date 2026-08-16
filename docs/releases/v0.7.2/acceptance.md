# TinyWorld v0.7.2 ART R6 Full Game Experience Acceptance

Status: DEV candidate acceptance record
Release: `v0.7.2 · ART R6 · Full Game Experience`
Target: TinyWorld DEV only

## Automated release gates

The exact final PR head must pass the single `TinyWorld CI` workflow with:

- 41+ Luau specs;
- deterministic shared analysis;
- StyLua formatting;
- runtime Luau compilation;
- ART R6 source contract;
- release authority contract;
- free-only build contract;
- deterministic `TinyWorld-v0.7.2.rbxlx` Rojo build;
- zero retained GitHub Actions artifacts or caches.

PR runs do not publish. After squash merge, the exact `main` build must pass the same gates and the `Publish TinyWorld DEV` step must return a Roblox place version.

## ART R6 product acceptance

### World presentation

- No checkerboard/runtime EditableMesh failure in published DEV.
- No camera-visible grass flicker or z-fighting caused by layered coplanar village lawn sheets.
- Hero fountain renders as a readable basin/pedestal/water feature while the daily reward interaction remains usable.
- Trading Post status presentation is compact rather than a giant developer board.
- Mara, Pip, Finn, Skye and Milo read as characters rather than generic prop stacks.
- Each NPC has role-specific visual cues and a small authored activity station.

### Gameplay

- Mara offers a low-value village item request and safely consumes the requested item on hand-in.
- Pip starts a three-bed public garden activity with visible bed-state changes.
- Finn starts a fishing activity with server-owned bite timing and accessible normal/good/perfect results.
- Skye gives a physical coastal parcel whose destination is beyond swimming range but inside the safe coast, making the Tiny Boat useful without bypassing traversal rules.
- Milo starts a three-step repair activity whose target visibly changes from damaged to repaired.
- One player can have only one R6 village activity active at a time.
- Completion rewards existing coins and XP; quality modifies coins only.
- Existing courier, personal garden, Trading Post, homes, furniture, transport, coast, Mermaid Land and profile schema v11 remain intact.

## Published DEV family playtest

Automated CI is not visual acceptance. After DEV publish, real Roblox-client evidence must confirm:

1. Walk and rotate the camera across the civic centre and all four village districts. No glitchy grass/flicker.
2. All five NPC roles are visually guessable before reading their prompt.
3. Complete at least three different R6 activities without developer instruction.
4. Observe at least one visible world-state change from an activity.
5. Confirm coins/XP update after completion.
6. Confirm the Tiny Boat coastal delivery is understandable and safe.
7. Check homes, garden, courier, transport, coast and Mermaid Land for obvious regression.
8. Confirm build stamp identifies `v0.7.2 · ART R6`.

The DEV candidate may be merged and published after automated verification, but visual acceptance remains open until this family playtest passes.
