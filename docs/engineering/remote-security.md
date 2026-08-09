# TinyWorld remote security

All RemoteEvent input is untrusted.

## Required checks

A mutating remote must use the relevant combination of:

- payload type/shape validation;
- finite-number checks;
- integer/range checks;
- string length limits before expensive filtering/service calls;
- definition/enum allow-lists;
- per-player/per-action rate limits;
- distance/context checks;
- plot/home/item ownership checks;
- privacy/permission checks;
- server-side price and reward lookup.

`src/server/security/RemoteGuard.luau` is the common adapter. Pure validation/window behaviour lives in `src/shared/RemoteGuardRules.luau` for CLI tests.

## Never accept from a client

- coin or XP deltas;
- product/furniture prices;
- career/portal reward amounts;
- final inventory quantities;
- trade commit contents;
- ownership claims;
- unrestricted CFrames/physics state;
- unbounded strings.

## Placement

Client placement preview is presentation. On confirm, the server converts the requested world point to home-local space, snaps rotation, checks bounds, ownership, overlap and placement budget, then persists the canonical result.

## Onboarding

Display-name input is length checked before TextService. Final displayed/persisted player-authored names pass Roblox filtering and deterministic character/length rules. Submission attempts are rate-limited.

## Diagnostics

Security warnings may record:

- UserId;
- action name;
- rejection reason.

They must not copy free-form player text or secret/token values into logs.

## Cleanup

Per-player rate state is cleared when the player leaves. New services that retain RemoteEvent connections or per-player state must own corresponding cleanup.

## Review gate

Every PR adding a new client-to-server mutation must answer:

1. What does the client control?
2. What is re-derived by the server?
3. Which ownership/context rule applies?
4. What prevents spam?
5. What happens on malformed input?
6. What deterministic test proves the validator rejects hostile cases?

If any answer is unclear, the remote is not merge-ready.