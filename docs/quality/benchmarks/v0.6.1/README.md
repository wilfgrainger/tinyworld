# v0.6.1 visual benchmark captures

This directory holds **observed screenshots from the exact v0.6.1 release candidate**. It is not a mood board and must not contain generated placeholders or screenshots from reference games.

## Required files

1. `01-character-front.png`
2. `02-normal-hud.png`
3. `03-village-centre-labels-off.png`
4. `04-town-hall.png`
5. `05-village-shop.png`
6. `06-home-store.png`
7. `07-courier-depot.png`
8. `08-daily-fountain.png`
9. `09-starter-home-exterior.png`
10. `10-starter-home-interior.png`
11. `11-giant-kitchen-entrance.png`
12. `12-moonlit-meadow-entrance.png`

## Capture metadata

For every committed image record in the v0.6.1 acceptance file:

- exact source commit SHA;
- artifact SHA if testing a built `.rbxlx`;
- Studio/published environment;
- viewport/device;
- graphics quality;
- whether explanatory labels/prompts were hidden;
- PASS/FAIL against the named visual check.

## Framing rules

- Capture at normal player camera height/zoom unless the check explicitly needs another view.
- Do not crop away HUD/geometry that causes a failure.
- Do not edit out unwanted labels, clipping, geometry or visual defects.
- Diagnostic annotations belong in a separate copy, not the benchmark evidence image.
- Proper-name signs may remain visible; the labels-off tests target explanatory system panels, not all language in the world.

## Quality rule

A screenshot does not pass because it is prettier than v0.6.0. It passes only when the corresponding row in `docs/releases/v0.6.1/acceptance.md` meets the defined visual contract.

See `docs/v0.6.1-visual-rescue-test.md` for the exact route.