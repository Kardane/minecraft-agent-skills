# Carpet Fake-Player Command Vocabulary

Use this reference only after Tier B+ was selected by `fabric-server-validation`.

For the repository baseline, Carpet **1.4.177** is a known release compatible with Minecraft Java 1.21.8. Treat the actually installed Carpet build as authoritative for command syntax.

Upstream Carpet defines `commandPlayer` and `commandTick` as command rules with operator-oriented defaults. Do not weaken server permissions merely to run a test; use the existing development-server operator/test identity.

Primary references:

- https://modrinth.com/mod/carpet/version/1.4.177
- https://github.com/gnembon/fabric-carpet

## Preflight

1. Confirm Carpet is loaded on the isolated development server.
2. Check `/help player` and `/help tick` on the installed build.
3. Confirm the test command source has the required permission.
4. Choose a unique bot name and isolated fixture coordinates.
5. Record the initial authoritative state that will be asserted later.

If a command is rejected, inspect installed Carpet help/source. Do not retry guessed syntax from another release.

## Fake-player actions

Common `/player` actions include:

```text
/player <name> spawn
/player <name> kill
/player <name> stop
/player <name> attack once
/player <name> attack continuous
/player <name> attack interval <ticks>
/player <name> use once
/player <name> use continuous
/player <name> use interval <ticks>
/player <name> jump
/player <name> move forward|backward|left|right
/player <name> look north|south|east|west|up|down
/player <name> look at <x> <y> <z>
/player <name> sneak
/player <name> unsneak
/player <name> sprint
/player <name> unsprint
/player <name> hotbar <slot>
/player <name> mount
/player <name> dismount
/player <name> swapHands
```

Use vanilla server commands for fixture priming when clearer:

```text
/tp <name> <x> <y> <z>
/gamemode survival <name>
/give <name> <item> <count>
/clear <name>
```

## Tick control

When deterministic timing helps, use installed Carpet `/tick` support rather than wall-clock sleeps:

```text
/tick freeze
/tick step <ticks>
/tick warp <ticks>
```

Typical patterns:

- `freeze → arrange → action → step N → assert` for tick-exact state changes.
- `warp N → assert aggregate` for bounded long-running server simulations such as farm output or cooldown/state progression.

Do not use a warp when the contract depends on a real client's rendering, input cadence, network timing, or wall-clock behavior.

## Semantic scenario

```text
observe baseline
→ arrange isolated fixture
→ spawn unique fake player
→ tp / gamemode / inventory / hotbar / look
→ perform one player action
→ step ticks or poll a bounded server predicate
→ assert authoritative block/entity/player/mod state
→ player stop
→ player kill
→ cleanup fixture
→ verify cleanup
```

The assertion should use MCP Fabric structured reads when available, otherwise an existing deterministic server-side observer.

## Fidelity warning

Carpet fake players use Carpet's server-side action machinery. They are excellent for player-shaped **server interaction**, but they are not a socket-backed vanilla client.

Do not use fake-player evidence alone to prove:

- login/configuration/play protocol behavior;
- authentication or encryption;
- packet ordering across a real connection;
- client prediction, rendering, GUI, or resource-pack behavior;
- exact normal-client reach/hand-interaction semantics;
- unmodified vanilla-client compatibility.

If the bug itself is about one of those boundaries, escalate to the matching client/network tier instead of adding more `/player` commands.

Scarpet is intentionally outside the default v1 backend.
