# TinyWorld v0.2.0 portal worlds design

**Date:** 2026-08-09
**Status:** Implemented on `main` after the v0.1.0 invited-alpha operations slice

## Goal

Make the original portal promise real: the village contains more than one
impossible destination, and each destination can be built and completed through
the same server-authoritative mission pipeline. The second world is **Moonlit
Meadow**—an exaggerated, storybook nature space that complements the village
without turning TinyWorld into a combat/fantasy game.

## Contract

- `PortalRules.WORLDS` is the reusable world catalog. Every world declares its
  display name, collectible label/count, reward, inventory item, and completion
  message.
- `PortalService` connects any catalogued world to a start prompt, a bounded
  set of collectible prompts, and a return prompt. Sessions are per-player and
  cannot collect from a different world’s session.
- Giant Kitchen remains intact and uses the same generic path. Moonlit Meadow
  adds three visible Moonlit Seed objects, an arrival portal, a return portal,
  pond, trees, flowers, and a readable sign.
- Completion remains free and server-authoritative. The existing global portal
  completion count is preserved; no new schema field is required for this
  bounded replayable slice.
- The client reports generic mission finds and the active portal world instead
  of baking in Giant Kitchen-only copy.

## North-star guardrails

- The second world strengthens curiosity, discovery, and return value; it does
  not replace the cosy home/village life or add a disconnected combat loop.
- No Robux product, ad, paid gate, random paid reward, or progression power is
  added.
- Static builders remain bounded and use the existing Roblox-safe material
  palette. The live world is still a Studio/publish target, not a claim that
  two-client or production-scale behavior was measured.

## Exit evidence

- Portal rules tests prove both catalog entries and rewards.
- Source guard proves the generic pipeline and concrete second-world builder.
- Studio Play shows both village portal labels, starts Moonlit Meadow, exposes
  three reachable seed prompts, and returns without a source/runtime error.
- A full collect/return completion is evidence of one client’s integration; a
  family/remote session and published-place verification remain separate gates.
