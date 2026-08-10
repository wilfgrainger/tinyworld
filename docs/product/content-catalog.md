# TinyWorld content catalogue contract

**Authority:** durable product/data contract.

TinyWorld content is data-driven. A service may implement behaviour for a reusable category or interaction verb, but it must not become the only place that knows an item's identity, price, reward or acquisition rule.

## Canonical definition modules

- `ItemDefinitions.luau`: resources and keepsakes.
- `FurnitureDefinitions.luau`: useful/expressive home content.
- `ActivityDefinitions.luau`: careers and ordinary-life activities.
- `WorldDefinitions.luau`: impossible-world contracts and rewards.
- `ShopDefinitions.luau`: server-owned stock and prices.
- `AppearanceDefinitions.luau`: free character/style preferences and future approved presentation choices.

## Metadata versus presentation

Definitions own stable metadata. They do not prove that a visual implementation is production quality.

In particular:

- an appearance definition may remain a persisted style preference while v0.6.1 preserves the player's Roblox avatar instead of rendering an inferior primitive fallback;
- a `prefabRole` identifies the intended art role but does not make anonymous geometry visually acceptable;
- player-facing hero content must satisfy the active visual tier/evidence contract in addition to having complete definition metadata.

## Metadata required for item/content definitions

Where relevant, every definition must provide:

- stable machine ID;
- display name;
- category;
- acquisition source;
- prefab/art role;
- interaction verb;
- stackability/identity policy;
- price or server-owned reward;
- trade policy;
- unlock condition;
- analytics category/event family;
- mobile interaction expectation;
- safety/age note if the content creates social or purchase implications.

Static display metadata is never duplicated into every player's profile.

## Launch content floor

The v1 target state fixes the minimum product promise at:

- at least 80 home/furnishing items;
- all eight home categories: bedroom, kitchen, bathroom, living, storage, garden, decoration and lighting;
- at least 20 items with meaningful interactions rather than display-only placement;
- at least four ordinary-life/career activities;
- exactly four launch-target impossible worlds until an explicit product decision expands scope;
- at least 30 keepsakes/discoverables;
- multiple meaningful free character/style choices over the product lifetime.

v0.6.0 established those definitions and reusable runtime foundations. v0.6.1 does not increase counts; it corrects how the most important existing content is presented and how visual quality is evidenced.

## Visual tiers

Content definitions should identify/route art roles consistently with the durable art pipeline:

- **Hero:** character presentation, homes, civic destinations, primary vehicles, portal entrances, signature keepsakes.
- **Interactive supporting:** furniture, activity equipment, parcels, gardening tools and traversal props.
- **Background:** scenery/ambient dressing.

The definition layer does not replace observed visual evidence for hero content.

## Interaction verbs

Reusable verbs are preferred over item-specific service branches:

- sit;
- rest/sleep;
- open/close;
- switch on/off;
- store/retrieve;
- cook;
- wash;
- bathe/shower;
- plant;
- water;
- harvest;
- read/play;
- dress/change;
- display/collect;
- place/decorate;
- craft/create.

A new verb needs a server authority/security review and a mobile/controller route.

## Inventory identity policy

Use stack quantities for ordinary resources and common keepsakes.

Use unique instances only when identity is needed for one of:

- placement provenance;
- customisation/metadata;
- durability/state;
- rare/high-value trade;
- ownership history.

Do not create UUIDs for ordinary carrots/resources.

## Pricing and rewards

Clients send IDs/intents only.

The server looks up:

- price;
- reward;
- unlock condition;
- ownership policy;
- trade policy.

A RemoteEvent payload containing a client-authored price, coin delta, XP reward or final inventory quantity is a release blocker.

## Physicality

If content is sold as a physical home/village object, owning it must result in a physical world object or an intentional inventory representation that can become one. Essential life-sandbox features may not exist only as menu text.

A physical object must also be recognisable enough for its visual tier. A coloured block plus a label is not sufficient physicality.

## Originality

TinyWorld may borrow broad qualities such as Roblox life-sandbox readability, tactile warmth and adventurous contrast. Team shorthand may reference Brookhaven, Toca-style play and Ready Player One-style wonder at the level of principles only. TinyWorld must not reproduce another game's identifiable characters, locations, props, buildings, logos, names, layouts or distinctive UI/art expression.

## Change control

Changing the fixed content floor or adding a new monetisation/trade class is a product decision, not opportunistic implementation scope. Record it in the target-state document and active release spec before code.

Improving visual presentation behind an existing semantic definition does not require a profile-schema change when gameplay identity/authority stays intact.