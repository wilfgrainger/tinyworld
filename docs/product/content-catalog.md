# TinyWorld content catalogue contract

**Authority:** durable product/data contract.

TinyWorld content is data-driven. A service may implement behaviour for a reusable category or interaction verb, but it must not become the only place that knows an item's identity, price, reward or acquisition rule.

## Canonical definition modules

- `ItemDefinitions.luau`: resources and keepsakes.
- `FurnitureDefinitions.luau`: useful/expressive home content.
- `ActivityDefinitions.luau`: careers and ordinary-life activities.
- `WorldDefinitions.luau`: impossible-world contracts and rewards.
- `ShopDefinitions.luau`: server-owned stock and prices.
- `AppearanceDefinitions.luau`: free character-expression presets.

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
- multiple free hair/outfit combinations.

v0.6.0 establishes those definitions and the reusable runtime foundations. Production art remains subject to the asset manifest and evidence gates.

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

## Originality

TinyWorld may borrow broad qualities such as warmth, tactile play, readability and adventurous contrast. It must not reproduce another game's identifiable characters, locations, props, logos, names, layouts or distinctive UI/art expression.

## Change control

Changing the fixed content floor or adding a new monetisation/trade class is a product decision, not opportunistic implementation scope. Record it in the target-state document and active release spec before code.