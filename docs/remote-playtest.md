# TinyWorld remote family playtest

This is the handoff for testing the dedicated **TinyWorld Dev** experience from the children’s own Roblox devices. It does not publish the game, change access, or share credentials automatically; the owner performs each Roblox Dashboard action deliberately.

## Important distinction

Studio **Play**, **Server & Clients**, and the Device Emulator are local Studio simulations. They are useful for checking the village, touch layout, and multiplayer rules on one computer, but they do not put a real build onto another person’s phone, tablet, console, or PC. Roblox’s [Studio testing modes](https://create.roblox.com/docs/studio/testing-modes) describe those local simulations and device emulation.

For the kids to play from their own devices, publish the current Rojo-synced place to the already-created **TinyWorld Dev** experience and give only their Roblox accounts playtest access.

## Owner checklist

1. Stop the Studio Play session and make sure the latest Rojo changes are synced.
2. In Studio, publish the place to **TinyWorld Dev**. Do not publish this branch to a production experience.
3. In the [Creator Dashboard](https://create.roblox.com/dashboard/creations), open **TinyWorld Dev → Configure → Settings**.
4. Under **Audience**, choose **Limited → Playtesters** if that option is available for the account. This keeps the experience undiscoverable to the general public while allowing explicitly approved playtesters. Roblox documents the `Private`, `Limited`, and `Public` audience choices in [Create and publish games and places](https://create.roblox.com/docs/production/publishing/publish-games-and-places).
5. Add each child’s Roblox account to the experience’s playtest access list. If the dashboard presents this as a permission or access list rather than a button named “Playtesters,” use the play permission for the specific accounts. Do not give Edit/Studio access just to let them play.
6. Copy the experience landing-page URL from the dashboard and send that link to the children or their parent/guardian.

If Playtesters is not available, `Limited → Friends` is a narrower fallback for a user-owned experience when the children are Roblox friends of the owner. Do not choose `Public` for this family test unless you intentionally want anyone to discover and join it.

Roblox’s collaboration documentation says user-owned games can grant Play access to a user or group, while Edit access is a separate permission. Keep the children on Play access only; they should not need Studio or repository access.

## Tester checklist

Each tester should:

1. Use their own Roblox account on their own device. Do not send or request account passwords, cookies, API keys, or Studio credentials.
2. Open the experience link in the Roblox app or a browser signed into that account.
3. Press **Play** and complete the TinyWorld welcome screen: choose a 3–16 character display name, Boy or Girl avatar style, and Meadow, Harbor, or Sunset starter outfit.
4. Confirm the setup screen disappears, the chosen colors are visible, the HUD shows the chosen in-game name, and the plot label uses the chosen name. The Roblox username should remain unchanged.
5. Run the normal smoke test: fountain reward, carrot garden, Courier job, Tiny Bike, and one safe village interaction. Record anything where the E prompt completes but no action occurs.

The first completed setup is saved to the TinyWorld Dev profile. On a later join, the setup screen should be skipped and the chosen name/outfit should return. If a save fails, the screen should remain and the player should be able to retry.

## Getting everyone into one live server

With a limited playtest experience, Roblox places testers into available live servers; opening the link at the same time may put them together, but it is not a guarantee. If a guaranteed family-only room becomes necessary, consider a free private server only after checking the experience’s Roblox eligibility and your family’s privacy settings. Roblox notes that private servers require the game to be public and that availability can be affected by parental or under-13 restrictions; see [Private servers](https://create.roblox.com/docs/production/monetization/private-servers).

For the first test, the recommended order is:

1. Use **Limited → Playtesters** and test one child at a time.
2. Test two devices together and see whether Roblox puts them in the same server.
3. Only then decide whether a private server is worth enabling.

## Feedback card

For each problem, capture:

- tester account nickname (not a password or account identifier);
- device type and whether it was touch, keyboard/mouse, or controller;
- the exact step, for example “pressed E at Courier Depot”;
- expected result;
- actual result and any visible message;
- screenshot or the Roblox Studio Output text, when the owner is reproducing locally.

