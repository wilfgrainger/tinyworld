# UI and UX

## Normal play

The permanent in-play layer stays quiet enough that the 3D world remains the primary information surface.

Normal play may show:

- compact coins;
- compact level/progress;
- one current useful task when needed;
- one compact navigation/journal surface;
- short-lived toast feedback;
- contextual physical `ProximityPrompt` interactions.

Do not turn profile/analytics/debug state into permanent HUD telemetry.

Do not use a full-width website-style navigation/header across normal gameplay. Home, Wardrobe, Journal and other deep surfaces belong behind one coherent compact navigation cluster and one modal owner.

## Visual language

Ordinary information panels use warm/light surfaces by default:

- `Paper` / `PaperSoft` body surfaces;
- `Ink` / `InkSoft` text;
- one restrained accent at a time;
- clear spacing and rounded containers;
- icons or simple thumbnail silhouettes where they reduce text dependence.

Dark surfaces remain available for contrast, overlays, fantasy moments or brief feedback. They are not the default body of every ordinary panel.

Gold/orange is an accent, not a full-screen UI field.

## World versus UI responsibility

The world should communicate:

- where the home is;
- what kind of building a destination is;
- whether an object looks interactable;
- what a fountain, parcel, bike, bed, cooker or jobs board physically is.

UI should communicate:

- precise counts/prices/progress;
- choices that require multiple options;
- inventory/collection detail;
- confirmation/error/recovery;
- deeper information intentionally opened by the player.

A floating information rectangle is not a valid substitute for unclear world art.

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

## Character and wardrobe UX

The player's Roblox avatar is the safe visual baseline when no approved TinyWorld character asset exists.

- do not show a wardrobe option as a rendered hair/shoe choice when normal runtime can only simulate it with primitive blocks;
- preserve saved appearance preference data for future approved assets;
- copy must be honest about what is visibly applied now;
- do not destroy existing Roblox clothing/accessories as a side effect of TinyWorld styling;
- identity remains meaningful and free, but visual-quality regression is not accepted merely to demonstrate variety.

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
- important state is not conveyed by colour alone;
- world text is short and local; paragraphs belong in intentional panels, not above landmarks.

## Modal layering

Use one modal owner at a time. Normal HUD remains behind it. A new modal closes/replaces the previous modal rather than stacking opaque panels indefinitely.

Home, Wardrobe and Journal launch controls may be owned by separate feature modules internally, but their normal-play presentation should form one coherent navigation cluster rather than three competing large buttons.

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

## Debugging

Raw attributes may appear only in a separate Studio-only opt-in drawer. The debug control is absent from published normal play.

## Evidence

The current release acceptance route must check:

- normal HUD leaves the world visually dominant;
- no permanent system-dashboard/website-header treatment;
- smallest agreed phone viewport;
- portrait/landscape;
- tablet/desktop;
- controller focus/navigation;
- catalogue purchase;
- furniture placement/rejection;
- wardrobe honesty/preservation of normal avatar;
- no clipped journal tabs/copy;
- no hover-only core feature.

For player-facing UI work, source structure cannot mark device/visual usability PASS. Required observed rows in the active release acceptance record remain authoritative.