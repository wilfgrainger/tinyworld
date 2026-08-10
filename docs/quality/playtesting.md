# Playtesting

## Principles

Test the ordinary player experience first. Observe whether a player can find, name and use places without coaching or debug telemetry. Record confusion as a product problem, not a player failure.

A visual release cannot be accepted from source inspection. Screenshots and observed routes must come from the exact candidate being evaluated.

## v0.6.1 Visual Rescue route

The active player-facing route is:

1. Spawn on a fresh/known DEV profile and review Output for immediate critical errors.
2. Capture the player character front/side. Confirm TinyWorld has not attached primitive block hair/shoes or destroyed the normal Roblox avatar presentation.
3. Review normal HUD. Confirm the world remains visually dominant and no website-header/telemetry-dashboard treatment occupies normal play.
4. Hide explanatory labels where practical and walk the village centre.
5. Identify Town Hall, Village Shop, Home Store, Courier Depot, daily fountain and profession/jobs board from physical form/context.
6. Enter the assigned starter home and identify/use representative bed, wardrobe, sofa, cooker/sink, bath/shower, storage, lamp and garden object.
7. Follow the golden route: home interaction -> Courier Depot -> visible parcel delivery -> reward -> Home Store -> buy/place item -> rejoin -> confirm continuity.
8. Observe Tiny Bike / primary travel object and portal entrances for labels-off silhouette/material quality.
9. Open Home, Wardrobe and Journal surfaces. Confirm one modal owner, readable light/warm surfaces, reachable close/save/place actions and no clipped short-screen layout.
10. Capture the required benchmark screenshots named in `docs/releases/v0.6.1/acceptance.md`.
11. Review Output again and record exact commit/build/artifact tested.

## Labels-off recognition

A destination/object fails if the tester can only identify its category because of a floating system label.

Small diegetic proper-name signs are allowed, but the tester should still be able to say things like "shop", "fountain", "jobs board", "home", "bike" or "courier place" from the scene itself.

## Sessions

- **One player:** character presentation, HUD, onboarding/readability, home, navigation, golden route, progression, persistence and labels-hidden visual review.
- **Two clients:** plot visiting/privacy, trade versioning/confirmation, replicated visual state and player-specific prompts where the release changes/depends on them.
- **Published devices:** API services, touch targets, safe areas, performance, controller behaviour and real network behaviour.

## Device route

At least one agreed phone run must record:

- portrait HUD/panel screenshot;
- landscape HUD/panel screenshot;
- touch reachability;
- golden-route FPS;
- memory;
- load/useful-spawn time;
- any clipping/occlusion caused by system safe areas.

Controller evidence covers Home/Wardrobe/Journal focus and placement controls where used by the golden route.

## Benchmark evidence

v0.6.1 uses `docs/quality/benchmarks/v0.6.1/` for exact-candidate screenshots. Do not populate that directory with generated mockups or unrelated reference-game screenshots.

External/reference screenshots can inform design discussion but are not release evidence.

## Evidence record

For each check, record date, commit, environment, device, tester count, result and evidence path/link. Mark checks `PASS`, `FAIL`, `BLOCKED` or `NOT RUN`.

For v0.6.1 player-facing visual rows, `NOT RUN` is acceptable only while the PR remains draft. Those rows block merge-ready status.