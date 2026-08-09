# Playtesting

## Principles

Test the ordinary player experience first. Observe whether a player can find, name, and use places without coaching or debug telemetry. Record confusion as a product problem, not a player failure.

## v0.5.2 observation route

1. Complete visual-card onboarding on a fresh profile.
2. Read the compact HUD and open each journal section.
3. Walk the village centre and identify civic destinations with labels hidden.
4. Visit Meadow Lane, Harbour Row, Woodland Rise, and Orchard End; describe what makes each distinct.
5. Enter the assigned home and use bed, kitchen, wardrobe, desk or storage, garden, and ambient interactions.
6. Cycle plot privacy and visit another available home.
7. Buy or activate the bike, use the boat route, complete a portal loop, and set up a trade.
8. Rejoin and verify authoritative state persists.
9. Review Roblox Output for errors and capture the exact build/commit tested.

## Sessions

- **One player:** onboarding, readability, home, navigation, progression, persistence, and labels-hidden visual review.
- **Two clients:** plot visiting/privacy, trade versioning and confirmation, replicated visual state, and player-specific prompts.
- **Published devices:** API services, touch targets, safe areas, performance, controller behavior, and real network behavior.

## Evidence record

For each check, record date, commit, environment, device, tester count, result, and evidence link. Mark checks `Pass`, `Fail`, `Blocked`, or `Not run`. Do not infer published or multi-client success from local source tests.
