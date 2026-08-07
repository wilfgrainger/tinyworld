# TinyWorld

TinyWorld is a persistent Roblox life sandbox where players build a home, grow a virtual life, travel to other villages, and enter increasingly strange portal worlds for missions, resources, stories, and shared challenges.

## Design principle

**Build your life. Explore impossible worlds. Discover the secrets of TinyWorld.**

The project is being developed in small playable slices. See `docs/superpowers/specs/` for design work and `docs/superpowers/plans/` for implementation plans.

## v0.1 foundation

The first slice establishes:

- a versioned player profile;
- coins and universal level/XP progression;
- five house tiers from Starter Nook to Grand Villa;
- server-authoritative upgrade rules;
- DataStore persistence for the core profile;
- Studio-only demo prompts for earning test rewards and upgrading the house tier;
- Luau CLI unit tests.

The demo prompts deliberately exist only while running in Roblox Studio, so they cannot become a free-currency exploit in a published experience.

## What you need

- A Roblox account.
- Roblox Studio. There is no separate paid developer licence required to start building.
- Rojo CLI plus the Rojo Studio plugin if you want to sync this Git repository into Studio.
- Git for local source control.

## Local workflow

1. Clone this repository.
2. Install Rojo and its Roblox Studio plugin.
3. From the repository root, run:

   ```sh
   rojo serve
   ```

4. Open a blank Roblox place in Studio.
5. Connect the Rojo plugin to the running project and sync.
6. For persistence testing, enable **Game Settings → Security → Enable Studio Access to API Services** on a test place. Do not enable this casually against live production data.
7. Press **Play**.

When a profile loads, the player receives `Coins` and `Level` leaderstats plus attributes for XP and house tier. In Studio, two temporary floor pads appear:

- **Complete Demo Mission** grants 250 test coins and 100 XP.
- **Upgrade House** attempts the next house tier using the real server-side requirements.

## House tiers in v0.1

| Tier | Name | Required level | Upgrade price |
| --- | --- | ---: | ---: |
| 1 | Starter Nook | 1 | Free |
| 2 | Cosy Cottage | 2 | 250 coins |
| 3 | Family Home | 4 | 750 coins |
| 4 | Garden House | 7 | 1,500 coins |
| 5 | Grand Villa | 10 | 3,000 coins |

These are progression states only in v0.1. Actual house models, rooms, gardens, plots, decorating, vehicles, portals, professions, trading, businesses, elections, and persistent village simulation come in later vertical slices.

## Test command

With a Luau CLI on your PATH:

```sh
luau tests/run.luau
```

The repository also contains a GitHub Actions workflow intended to run this suite on pushes and pull requests.

## Data-safety note

The v0.1 DataStore adapter is a foundation, not the final production persistence layer. Before a public alpha we should add session locking, retry/backoff policy, migration tests, telemetry, and recovery tooling so overlapping servers and transient Roblox failures cannot corrupt or lose recent progress.
