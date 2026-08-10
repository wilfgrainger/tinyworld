# UI and UX

## Normal play

The permanent in-play layer stays quiet:

- `CoinChip`: icon/current coins;
- `LevelChip`: compact level/progress;
- `QuestChip`: one current activity in player language;
- `JournalButton`: intentional access to deeper information;
- short-lived toast feedback;
- contextual physical `ProximityPrompt` interactions.

Do not turn profile/analytics/debug state into permanent HUD telemetry.

## Deep information architecture

The journal target sections are:

- **Today**: current useful goals/routines;
- **Bag**: resources/items;
- **Home**: ownership/placement/home expression;
- **Careers**: ordinary-life progression;
- **Collection**: keepsakes/discoveries;
- **Places**: village/impossible-world discovery.

Copy translates replicated/server state into player language. Raw field names/database status are Studio-debug material only.

## Home catalogue

Home Store/catalogue UX must show:

- recognisable item name/category;
- real server-owned price displayed from trusted definitions;
- owned quantity/state;
- clear buy vs place intent;
- unavailable/insufficient-currency feedback;
- physical placement after ownership.

The client never submits a price.

## Furniture placement UX

Required flow:

1. choose owned furniture;
2. enter placement mode;
3. show local preview/ghost;
4. move pointer/touch aim or controller aim;
5. rotate in 90-degree increments;
6. confirm once;
7. wait for authoritative server result;
8. show clear rejection if bounds/overlap/ownership/security fails;
9. allow later move/store/remove.

Preview movement is local-only; never fire gameplay remotes every render frame.

## Responsive breakpoints

TinyWorld-native breakpoints:

- phone: viewport width < 600;
- portrait: taller-than-wide after phone classification;
- tablet: landscape width < 1100;
- desktop: wider layout.

Use scale-based panel layouts plus pixel padding/minimum-size constraints. Avoid fixed desktop-sized black rectangles.

## Touch

- minimum effective target: 44x44;
- no hover-only critical action;
- use `Activated` or equivalent unified input;
- safe-area/inset aware;
- key controls remain reachable in portrait/landscape;
- placement has visible touch buttons for rotate/confirm/cancel.

## Controller

- explicit `Selectable` controls;
- deliberate focus order/grid neighbours;
- modal opening selects a useful first control;
- closing restores prior focus when possible;
- no focus trap in scroll panels;
- placement supports rotate/confirm/cancel controller bindings.

## Text/readability

- normal body text target >=14 px equivalent;
- primary button/title text larger;
- wrapped copy may not clip;
- avoid `TextScaled` as a blanket fix;
- important state is not conveyed by colour alone.

## Modal layering

Use one modal owner at a time. Normal HUD remains behind it. A new modal closes/replaces the previous modal rather than stacking opaque panels indefinitely.

## Required states

Every deep UI surface defines:

- loading/waiting;
- normal populated;
- empty;
- validation/error;
- unavailable/permission denied.

Raw Roblox/service exceptions are never player copy.

## Feedback and authority

The client may optimistically preview presentation, but it confirms economic/progression/ownership/placement success only after the server response/replicated state confirms it. Message nonces prevent old toast timers hiding newer feedback.

## Onboarding and appearance

Legacy Boy/Girl plus Meadow/Harbor/Sunset onboarding values remain supported for compatibility. Long-term character expression uses free hair/outfit presets and saved outfits. Production Roblox assets require manifest approval; identity is never paywalled by design.

## Debugging

Raw attributes may appear only in a separate Studio-only opt-in drawer. The debug control is absent from published normal play.

## Evidence

The active release acceptance route checks:

- smallest agreed phone viewport;
- portrait/landscape;
- tablet/desktop;
- controller focus/navigation;
- catalogue purchase;
- furniture placement/rejection;
- wardrobe;
- no clipped journal tabs/copy;
- no hover-only core feature.

Source structure cannot by itself mark device usability PASS.