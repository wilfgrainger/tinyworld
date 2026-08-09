# TinyWorld v0.1.0 invited-alpha operations design

**Date:** 2026-08-09
**Status:** Implemented on `main` after the v0.0.9 social/home slice
**North-star link:** Make TinyWorld safe and understandable enough for a small
invited family cohort to return to, while preserving a fair, creator-led future.

## Goal

v0.1.0 is an operational release, not a new content world. It turns the
existing playable loop into an invited-alpha candidate by making session health,
save pressure, onboarding state, and recovery requirements visible to the
operator without exposing profile contents or credentials.

## Boundaries

- The server remains authoritative. Clients only observe replicated attributes
  and existing messages.
- The release channel is explicitly `INVITED_ALPHA`; it is a label and
  readiness contract, not an access-control replacement for Roblox Audience or
  Play permissions.
- A recommended cohort of eight players is a test/operations limit. It does not
  replace `Players.MaxPlayers` or establish a production capacity claim.
- A healthy player is `ready` only when onboarding is complete, the profile
  session is active, and the save queue is empty. Onboarding-required and
  saving states are distinguishable from recovery-required state.
- Recovery-required state is fail-closed: the player sees a safe rejoin message,
  the profile is not silently overwritten, and the operator can see aggregate
  recovery counts. This release does not invent a rollback of already-lost
  Roblox DataStore writes.
- Aggregated workspace diagnostics contain counts and state labels only. No
  display names, user IDs, profile fields, tokens, or secrets are emitted.

## Implementation shape

1. `AlphaOpsRules` owns the pure release/channel/cohort/health contract and is
   covered by Luau CLI tests.
2. `AlphaOpsService` owns server-only lifecycle observation. It mirrors safe
   release and health attributes to each player and aggregate counts to the
   generated world root. It samples `ProfileStore.getDiagnostics()` on a
   bounded cadence and announces a recovery transition once per session.
3. `Main.server.luau` wires the service after profile and onboarding setup and
   stops the observer before bounded shutdown.
4. The HUD labels the current candidate `v0.1.0 INVITED ALPHA`; it does not turn
   internal diagnostics into a child-facing technical dashboard.
5. The release guide records the source gate, Studio route, recovery boundary,
   and the still-required two-client/published/family evidence.

## Exit evidence

- Deterministic health/cohort rules pass.
- Server and client Luau compile, all source guards pass, Rojo assembles the
  place, and the diff is clean.
- A current Rojo-synced Studio session shows the invited-alpha label and
  aggregate operational attributes, and a normal stop leaves no red source
  exception.
- Recovery warnings, DataStore queue pressure, two-client behavior, published
  place behavior, and child comprehension remain separately reported rather
  than inferred from static proof.

## Rejected scope

- No new Robux products, ads, premium currency, pay-to-win convenience, or
  external telemetry endpoint.
- No hidden admin backdoor, remote command console, or profile reset action.
- No claim that aggregate attributes are a substitute for Roblox Creator
  Dashboard analytics, cross-server observability, or production SLOs.
