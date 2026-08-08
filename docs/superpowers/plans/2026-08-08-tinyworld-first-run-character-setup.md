# TinyWorld First-Run Character Setup Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` to implement this plan task-by-task. Keep the current checkout on `feat/v0.1-foundation` because it is the Rojo source used by the live Studio test session.

**Goal:** Add a safe, persistent first-run setup flow so a new TinyWorld player chooses an in-game display name, a Boy/Girl avatar label, and one of three free starter outfit palettes before entering the village.

**Architecture:** Keep the profile contract and validation rules in `src/shared`. Let the server own filtering, validation, persistence, replicated attributes, and `BodyColors` application. Let the client render a touch-friendly modal and send one submission through a server-created `RemoteEvent`. Existing v0.01 progression and Roblox usernames remain unchanged.

**Tech Stack:** Roblox Luau, Roblox `TextService`, `RemoteEvent`, `BodyColors`, Rojo 7.7.0, Luau CLI tests where available, PowerShell static checks, Roblox Studio manual testing.

## Global constraints

- Preserve every existing v0.01 profile field and progression rule.
- Normalize old profiles to schema version 3 without resetting coins, inventory, gardens, jobs, bike state, house state, portal progress, contribution, or privacy.
- Treat the chosen display name as an in-game label only; never rename or impersonate the Roblox account.
- Keep Boy/Girl as presentation metadata only. Neither choice changes stats, access, rewards, or gameplay.
- Keep Meadow, Harbor, and Sunset as built-in free palettes. Do not add catalog asset IDs, Robux purchases, external HTTP calls, or avatar-clothing dependencies.
- Filter the submitted display name on the server before saving it. Client-side checks are only for usability.
- A completed onboarding submission is idempotent. A failed save leaves the old profile values intact and keeps onboarding required.
- Do not make the experience public as part of this implementation. Remote playtest setup is documented separately for the owner to perform deliberately.

## Task 1: Add the schema and pure onboarding rules

**Files:**

- Modify `src/shared/ProfileSchema.luau`.
- Create `src/shared/OnboardingRules.luau`.
- Modify `tests/ProfileSchema.spec.luau`.
- Create `tests/OnboardingRules.spec.luau`.
- Modify `tests/run.luau` if the runner requires explicit registration.

**Steps:**

1. Extend `PlayerProfile` with `displayName: string`, `avatarStyle: string`, `starterOutfit: string`, and `onboardingComplete: boolean`.
2. Change `ProfileSchema.VERSION` and new normalized profiles to `3`.
3. Normalize the new fields to empty strings/`false` unless they have the exact allowed values. Preserve all existing normalization behaviour.
4. Add pure rules with these exact choices:
   - avatar styles: `Boy`, `Girl`;
   - starter outfits: `Meadow`, `Harbor`, `Sunset`.
5. Add pure display-name validation: trim leading/trailing whitespace, require 3–16 characters, and allow only ASCII letters, digits, spaces, `_`, and `-`.
6. Add `isComplete(profile)` that requires `onboardingComplete`, a valid display name, a valid avatar style, and a valid starter outfit.
7. Write failing tests first for schema migration, progression preservation, name boundaries/invalid characters, exact choice validation, and completeness. Run the tests and record the expected failure before implementation.
8. Implement the smallest code needed to make those tests pass, then run the complete shared-rule suite.

**Verification:** `luau tests/run.luau` when Luau CLI is installed; otherwise use the repository’s CI/Studio-compatible checks and report the local CLI limitation without claiming the suite ran.

**Commit:** `feat: add first-run profile contract and rules`

## Task 2: Add server-owned onboarding and starter palettes

**Files:**

- Create `src/server/OnboardingService.luau`.
- Modify `src/server/Main.server.luau`.
- Modify `src/server/PlayerStateService.luau`.
- Modify `src/server/PlotService.luau`.

**Steps:**

1. Create or reuse `ReplicatedStorage.TinyWorld.OnboardingRemote` as a `RemoteEvent` from the server; never trust a client-created remote.
2. Add `OnboardingService.new(ProfileStore, PlayerStateService)` and connect the remote’s server event once. The service must fetch the loaded profile from `ProfileStore`, reject malformed payloads, reject duplicate completed submissions, validate all three choices with `OnboardingRules`, and filter the name with `TextService:FilterStringAsync` plus `GetNonChatStringForBroadcastAsync` inside protected calls.
3. Make submission transactional: snapshot the four onboarding fields, assign the filtered values, set completion, call the existing profile save path, and restore the snapshot if saving or filtering fails. Send a short status response and keep `TinyWorldOnboardingRequired` true on failure.
4. Replicate `TinyWorldDisplayName`, `TinyWorldAvatarStyle`, `TinyWorldStarterOutfit`, `TinyWorldOnboardingComplete`, and `TinyWorldOnboardingRequired` from `PlayerStateService.sync`.
5. Make the suggested goal say `Complete your TinyWorld setup.` until onboarding is complete.
6. Apply the selected palette through a server-owned `BodyColors` instance on the current character and on later `CharacterAdded` events. Use only built-in color values for Meadow (green/cream/brown), Harbor (blue/light grey/navy), and Sunset (orange/warm yellow/dark brown); leave head/skin appearance alone.
7. Compose the service in `Main.server.luau` after profile loading and state setup, and clean up its player connection on removal. Existing services must continue to start even when onboarding is required.
8. Use the display name in plot labels and home welcome text, while retaining the Roblox username for ownership, permissions, and friend checks.

**Verification:** Add focused pure tests for the service-independent rules; run static Luau/material checks and Rojo build. Manually inspect Studio Output for errors during first join and submission.

**Commit:** `feat: add server-owned onboarding service`

## Task 3: Add the touch-friendly first-run client flow

**Files:**

- Create `src/client/Onboarding.client.luau`.
- Modify `src/client/Main.client.luau`.

**Steps:**

1. Create a `ResetOnSpawn = false` modal `ScreenGui` with a centered panel, name `TextBox`, Boy/Girl buttons, Meadow/Harbor/Sunset buttons, validation/status text, and a `Begin TinyWorld` button.
2. Use `Activated` handlers and sufficiently large buttons so the same flow works with mouse, touch, and controller activation.
3. Show the modal whenever `TinyWorldOnboardingRequired` is true or completion is false; hide it only after the server confirms success.
4. Disable local movement while the modal is active and restore the player’s movement settings after confirmation. Do not change the server’s bike movement rules.
5. Send only the selected values to `OnboardingRemote`. Display server error text without locally pretending the profile was saved.
6. Add the in-game display name to the HUD and observe the new attributes. Keep the existing v0.01 HUD content and status messages intact.
7. Ensure the client tolerates the remote appearing after the scripts start by waiting for the server-created object rather than assuming it already exists.

**Verification:** In Studio, test keyboard/mouse and touch emulation; confirm the modal blocks entry until success, invalid names are rejected, the modal disappears after success, and a rejoin skips it for the saved profile.

**Commit:** `feat: add first-run character setup UI`

## Task 4: Add remote family playtest instructions

**Files:**

- Create `docs/remote-playtest.md`.
- Modify `README.md` to link to the document and add the first-run setup to the smoke test.
- Modify `docs/progress.md` with the dated implementation/testing status only after verification.

**Steps:**

1. Explain that Studio Play and Server & Clients are local Studio simulations; children on their own devices must use the published Roblox dev experience.
2. Document the owner flow: stop Studio play, publish the current place to the dedicated TinyWorld Dev experience, open Creator Dashboard access settings, keep the experience closed to the public, select the narrowest available playtest access (prefer Playtesters; Friends is an explicit fallback), add the children’s Roblox accounts, and copy the experience landing-page link.
3. Document the tester flow: use each child’s own Roblox account, open the link in the Roblox app, press Play, and test the same onboarding/progression loop. State that account passwords, cookies, API keys, and Studio access must never be shared.
4. Explain server grouping honestly: testers can be placed in available live servers; for a guaranteed shared room, consider a free private server only after the experience meets Roblox’s eligibility/access requirements and after checking family/under-13 restrictions.
5. Add a concise feedback checklist covering account/device, onboarding choice, interaction prompt behaviour, expected result, actual result, and screenshot/output evidence.

**Commit:** `docs: add remote TinyWorld playtest guide`

## Task 5: Verify and hand off

1. Run `git diff --check`, the complete available test suite, the Roblox material guard, and `rojo build default.project.json`.
2. Inspect the final diff for accidental changes to v0.01 design/test instructions and confirm the remote guide does not grant access or publish anything automatically.
3. In Roblox Studio, run the manual acceptance checklist: new profile setup, invalid name, each gender/style combination, each palette, successful save/rejoin, existing profile migration, plot label, HUD name, and normal v0.01 activities after onboarding.
4. Check the branch, commit list, and draft status of PR #1. Do not change the PR from draft.
5. Report exactly which checks ran locally and which require the user’s Studio/device action.

