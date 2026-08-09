# TinyWorld performance budgets

These are initial release gates, not claims that current runtime evidence already passes them.

## Mobile

Agreed low/mid target device:

- minimum sustained FPS: 30;
- frame budget: 33.3 ms;
- target client memory: <= 500 MB;
- target join/spawn usability: <= 15 seconds on a normal connection;
- no repeated script spikes that make ordinary home/village interaction visibly hitch.

## Desktop

- target FPS: 60;
- target frame budget: 16.6 ms where practical.

## Network

- no gameplay RemoteEvent every render frame;
- target ceiling: < 50 gameplay remote calls/second/client;
- placement preview is client-local; only confirmed mutations use remotes;
- batch/coalesce state changes where a single intent is sufficient;
- record Developer Console send/receive behaviour during multiplayer evidence.

## World/content

Starting limits encoded in `PerformanceBudgets.luau`:

- 60 persistent furniture placements/home;
- <= 500 parts for a single complex model;
- <= 20 active particle emitters in view;
- <= 200 particles/second/emitter;
- Streaming target radius 256 studs, minimum 64 when world growth/device evidence justifies enabling/configuring it.

Static decor is anchored. Decorative parts disable touch/query unless interaction requires them.

## Evidence route

Capture MicroProfiler/Developer Console/device evidence for:

1. spawn/onboarding;
2. village centre;
3. all four neighbourhoods;
4. own home with representative furniture load;
5. another player's home;
6. vehicle traversal;
7. each portal world;
8. trade area;
9. long-session memory/connection behaviour.

Record device model, graphics setting, player count, timestamp/build SHA and observed metrics.

## Failure policy

If a target is missed:

- do not mark the evidence row PASS;
- identify the dominant CPU/GPU/network/memory cost;
- optimise measured hotspots rather than guessing;
- re-run the same route on the same target device.

Static source inspection cannot satisfy a performance evidence gate.