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

Core modal sizes use scale-based dimensions. Offsets are reserved for padding, pinned HUD controls and minimum-size constraints.

Required checks:

- smallest agreed phone viewport;
- common phone landscape/portrait;
- tablet;
- desktop;
- gamepad/controller focus.

## Text

- body text should normally be >= 14 px equivalent;
- primary buttons/title text should remain readable without `TextScaled` as a blanket solution;
- wrapped text must not clip;
- essential meaning is not conveyed by colour alone.

## Controller

- selectable controls have deliberate focus order;
- modal opening selects a sensible first action;
- modal closing restores previous focus when possible;
- placement: rotate, confirm and cancel have gamepad bindings;
- no controller trap inside scroll/modal surfaces.

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

## Visual accessibility

- interactive controls have sufficient contrast against their panel/background;
- state changes use shape/text as well as colour where practical;
- placement ghost uses valid/invalid feedback but the server remains the final authority;
- important 3D objects remain recognisable with labels hidden.

## Evidence

Device evidence records screenshots/video or observed pass/fail for clipped UI, touch reachability, focus order, readable text and placement ergonomics. Source code alone cannot mark these items PASS.