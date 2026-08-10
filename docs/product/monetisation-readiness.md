# TinyWorld monetisation readiness

TinyWorld does not need monetisation code to be a complete game foundation. The product must first prove that players want to live in TinyWorld.

## Non-negotiable rule

**No pay-to-win.**

Free players retain equivalent gameplay power, ordinary-life loops, portal access and meaningful character/home expression.

## Not present through v0.6.1

The current game intentionally contains no:

- fake Game Pass IDs;
- fake developer product IDs;
- receipt handler for products that do not exist;
- paid currency multiplier;
- paid career/progression power;
- paid identity requirement;
- coercive countdown/purchase pressure.

v0.6.1 Visual Rescue does not introduce monetisation. Its character correction specifically avoids turning the absence of approved TinyWorld character assets into a reason to degrade free/default avatar identity.

## Future acceptable categories

Subject to a separate approved product/safety design, monetisation may focus on:

- cosmetic character expression;
- optional authored home sets;
- expressive vehicle variants;
- bounded convenience that does not create superior gameplay power.

## Required design before implementation

Any monetisation branch must define and receive approval for:

- real Roblox experience product identifiers;
- child/family appropriateness;
- clear pricing/value communication;
- receipt idempotency;
- retries and duplicate receipt handling;
- refund/revocation implications where relevant;
- save/persistence failure behaviour;
- analytics taxonomy that distinguishes purchase success from attempts;
- free-player equivalent gameplay power;
- security review of every purchase-granted entitlement.

## Server authority

Clients may request a purchase prompt, but they never grant themselves an entitlement. Receipt/product validation and profile mutation remain server/platform-authoritative.

## Product test

A monetisation feature fails the TinyWorld target state if removing payment makes the ordinary game feel deliberately broken, humiliating, unreasonably slow or visually identity-less.

A free/default Roblox avatar must remain coherent even when optional TinyWorld cosmetic assets are unavailable.