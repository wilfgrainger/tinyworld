# TinyWorld v0.2.0 portal worlds implementation plan

1. Extend the existing portal rule with a catalogued world definition and
   generic completion function; preserve `completeGiantKitchen` compatibility.
2. Add failing coverage for Moonlit Meadow’s reward and the second-portal goal.
3. Build Moonlit Meadow from bounded Roblox-native parts and three visible
   Moonlit Seed prompts; add a second village portal.
4. Refactor PortalService to connect worlds from one reusable start/collect/
   return pipeline and initialise the generic active-world attribute.
5. Update the HUD, source guard, README/progress, and Studio test route.
6. Run the full source gate, reconnect Rojo, play the second portal route,
   inspect Output, commit, and push the intentional release set.
