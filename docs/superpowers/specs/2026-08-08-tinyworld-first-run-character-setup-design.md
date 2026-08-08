# TinyWorld First-Run Character Setup Design

## Purpose

Add a short first-run setup before a player begins the village loop. New players choose an in-game display name, a Boy or Girl avatar presentation choice, and one free starter outfit. The setup must feel welcoming without introducing Robux, catalog assets, gameplay advantages, or destructive changes to existing saved progression.

## Scope

The v0.01 implementation includes:

- a client-side setup panel shown when the profile has not completed onboarding;
- a server-validated in-game display name;
- two presentation choices: `Boy` and `Girl`;
- three free built-in outfit palettes: `Meadow`, `Harbor`, and `Sunset`;
- persistence for the selected values;
- a visible avatar color treatment and display-name replication after submission;
- existing-profile migration that preserves all current coins, progression, inventory, house, garden, and mission data.

The setup does not change the Roblox account username, grant gameplay benefits, create Robux products, load catalog clothing, or add a full avatar editor.

## Player experience

When a player joins with `onboardingComplete == false`, a centered setup panel appears above the normal HUD:

1. Enter a TinyWorld display name.
2. Select `Boy` or `Girl`.
3. Select one of the three free outfit palettes.
4. Press `Begin TinyWorld`.

The submit control remains disabled until all three choices are present. The panel is modal for the setup moment: the client disables normal movement controls while it is visible, and the server does not treat the player as fully onboarded until the validated submission succeeds. A validation failure leaves the panel open with a clear message.

After success, the panel disappears, the HUD shows the chosen display name, the player’s plot sign uses the chosen display name, the avatar receives the selected built-in color palette, and the normal v0.01 loop begins. Rejoining skips the panel once the saved setup is complete.

## Data contract

`ProfileSchema.VERSION` becomes `3`. The profile adds:

```text
displayName: string
avatarStyle: "" | "Boy" | "Girl"
starterOutfit: "" | "Meadow" | "Harbor" | "Sunset"
onboardingComplete: boolean
```

New profiles default these fields to empty values and `false`. Existing schema-v2 profiles normalize safely to the same defaults while retaining every existing field. A profile is considered ready to skip onboarding only when `onboardingComplete` is true and all three selected values are present.

The server replicates the final values through attributes:

```text
TinyWorldDisplayName
TinyWorldAvatarStyle
TinyWorldStarterOutfit
TinyWorldOnboardingComplete
TinyWorldOnboardingRequired
```

## Validation and authority

The client sends a setup submission through a server-created `RemoteEvent`. The server owns the authoritative result.

- Display names are trimmed, limited to 3–16 characters, and restricted to letters, numbers, spaces, `_`, and `-` before filtering.
- The server filters the submitted name with Roblox text filtering before saving or displaying it. If filtering fails or produces no usable text, the submission is rejected and the player is asked to choose another name.
- `avatarStyle` must be exactly `Boy` or `Girl`.
- `starterOutfit` must be exactly `Meadow`, `Harbor`, or `Sunset`.
- A player cannot complete onboarding twice through the remote; subsequent submissions are ignored or answered with the already-complete state.
- The server saves the normalized profile only after all validation passes, then updates replicated state and applies the avatar palette. If saving fails, it restores the previous onboarding fields, keeps onboarding required, and returns a retryable error instead of presenting setup as complete.

The pure validation rules live in a Roblox-service-free shared module so they can be covered by Luau CLI tests. Roblox `TextService` access remains in the thin server adapter.

## Outfit presentation

Each starter outfit is a free built-in palette applied through the character’s `BodyColors` so no external asset IDs or catalog permissions are required:

| Outfit | Torso | Arms | Legs | Intended feel |
| --- | --- | --- | --- | --- |
| Meadow | warm green | cream | brown | garden and village |
| Harbor | blue | light grey | navy | courier and travel |
| Sunset | orange | warm yellow | dark brown | energetic and adventurous |

The Boy/Girl choice is stored as presentation metadata for this slice and has no effect on economy, progression, permissions, or access. The implementation must not infer personality, ability, or gameplay role from it.

## Architecture

### Shared

Add `src/shared/OnboardingRules.luau` with constants and pure functions for allowed styles, outfit names, display-name validation, and setup completeness. Extend `ProfileSchema.luau` with schema-v3 defaults and normalization.

### Server

Add `src/server/OnboardingService.luau`. It creates or reuses the setup `RemoteEvent`, listens for submissions, validates them through `OnboardingRules`, filters the display name with `TextService`, updates the profile, saves it, replicates attributes, applies the palette, and sends a status message.

`Main.server.luau` composes the service and marks each player’s onboarding-required attribute after profile load. `PlayerStateService.luau` syncs onboarding fields. `PlotService.luau` uses the saved display name for owner labels while retaining the Roblox username as the underlying player identity.

### Client

Add a focused `src/client/Onboarding.client.luau` that creates the setup panel, captures the three selections, sends one submission, displays server responses, and disables/restores normal movement while the panel is active. `Main.client.luau` displays the chosen display name in the HUD and listens for the onboarding attributes.

## Error handling

- Missing or malformed saved onboarding fields normalize to the setup-required state.
- Invalid submissions never mutate coins, XP, inventory, house, garden, portal, trade, or civic state.
- Text filtering failures are shown as a retryable setup message and are not saved.
- DataStore save failure follows the existing fail-closed persistence rules; the previous onboarding fields are restored and the player is not told onboarding is complete unless the new profile state is valid and saved.
- If the client loses the remote or receives an unexpected response, it keeps the setup panel visible and reports that the setup could not be completed.

## Testing

Automated tests cover:

- schema-v2 normalization into schema-v3 defaults;
- valid and invalid display names;
- valid and invalid Boy/Girl choices;
- valid and invalid outfit choices;
- setup completeness and duplicate completion behavior;
- preservation of existing profile progression during normalization.

Manual Roblox Studio testing covers:

1. A fresh or onboarding-incomplete profile sees the setup panel before gameplay.
2. The submit button stays unavailable until all choices are made.
3. Invalid names are rejected without changing profile data.
4. A valid setup closes the panel, updates the HUD and plot sign, and visibly applies the chosen palette.
5. Stop/rejoin skips setup and preserves the chosen values.
6. Existing v0.01 smoke-test interactions still work after onboarding completes.

## Acceptance criteria

This slice is ready when:

1. A new or onboarding-incomplete player is prompted for a name, Boy/Girl presentation choice, and free outfit.
2. The server validates and filters the name before saving or displaying it.
3. The three choices persist without resetting existing v0.01 progression.
4. The selected outfit visibly changes the player using only built-in, free presentation logic.
5. Rejoining skips setup after successful completion.
6. Invalid or duplicate submissions cannot mutate authoritative gameplay state.
7. Automated shared-rule tests pass and the existing Studio smoke test remains runnable.

## Deliberate limits

This is a first-run identity and presentation step, not a production avatar editor. It does not implement catalog browsing, arbitrary clothing uploads, gender-based gameplay, voice or chat identity, account-name changes, Robux purchases, or a reset/re-customize menu. Those can be designed later after this onboarding moment is proven in Studio.
