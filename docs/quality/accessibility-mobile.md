# TinyWorld mobile and accessibility contract

Mobile/touch is a primary input path, not a later port.

## Touch

- critical touch targets have at least 44x44 effective pixels;
- no critical action is hover-only;
- buttons use `Activated` or an equivalent touch/mouse/gamepad route;
- home placement supports touch preview, rotate, confirm and cancel;
- controls do not sit beneath device/system safe areas.

## Responsive layouts

TinyWorld-native breakpoints:

- `phone`: viewport width < 600;
- `portrait`: taller than wide after phone handling;
- `tablet`: width < 1100 in landscape;
- `desktop`: wider layout.

Core modal sizes use scale-based dimensions. Offsets are reserved for padding, pinned compact HUD controls and minimum-size constraints.

Required checks:

- smallest agreed phone viewport;
- common phone landscape/portrait;
- tablet;
- desktop;
- gamepad/controller focus.

## World-first screen budget

Accessibility does not mean covering the world with permanent explanatory UI.

For normal play:

- compact HUD surfaces should occupy only the space needed for status/current action;
- a full-width website-style navigation header is not acceptable;
- a permanent right-side system/dashboard panel is not acceptable;
- Home/Wardrobe/Journal navigation should be one coherent compact surface;
- contextual prompts appear near the relevant interaction rather than keeping instructions visible everywhere.

Reducing clutter improves both comprehension and mobile visibility.

## Text

- body text should normally be >= 14 px equivalent;
- primary buttons/title text should remain readable without `TextScaled` as a blanket solution;
- wrapped text must not clip;
- essential meaning is not conveyed by colour alone;
- paragraph-length system copy belongs in intentional panels, not BillboardGui world labels.

## Controller

- selectable controls have deliberate focus order;
- modal opening selects a sensible first action;
- modal closing restores previous focus when possible;
- placement: rotate, confirm and cancel have gamepad bindings;
- no controller trap inside scroll/modal surfaces;
- compact navigation provides an obvious route to Home/Wardrobe/Journal without depending on pointer-only placement.

## UI states

Every deep UI surface defines:

- loading/waiting;
- normal populated state;
- empty state;
- validation/error state;
- unavailable/permission state.

Errors use player-language messages, not raw service exceptions.

## Cognitive load

The permanent HUD remains compact. Deep information belongs in the journal/home/wardrobe surfaces. Do not add counters simply because a value exists in the profile.

Target journal sections:

- Today;
- Bag;
- Home;
- Careers;
- Collection;
- Places.

## Character accessibility/identity

When no approved TinyWorld character asset exists, preserve the player's normal Roblox avatar rather than replacing it with visibly inferior primitive add-ons.

Character identity is not improved by forcing every player into low-quality hair/shoe geometry. Saved TinyWorld style preferences may remain available without destroying the player's existing avatar presentation.

## Visual accessibility

- interactive controls have sufficient contrast against their panel/background;
- ordinary information panels prefer warm/light surfaces with dark readable text;
- state changes use shape/text as well as colour where practical;
- placement ghost uses valid/invalid feedback but the server remains the final authority;
- important 3D objects remain recognisable with explanatory labels hidden;
- large always-on-top world information walls are not an accessibility substitute for clear objects/landmarks;
- gold/orange accents do not become large low-hierarchy colour fields that compete with content.

## Evidence

Device evidence records screenshots/video or observed pass/fail for clipped UI, touch reachability, focus order, readable text, visual occlusion and placement ergonomics.

For v0.6.1 player-facing visual work, required phone/controller rows block merge-ready status until observed. Source code alone cannot mark these items PASS.