---
name: carpet-player-harness
description: "Drive Carpet fake players as repeatable player-shaped actors for Minecraft Java 1.21.8 Fabric server validation. Pair /player and optional /tick control with authoritative server-state assertions; do not treat fake players as real-client or vanilla-client evidence."
---

# Carpet Fake-Player Validation Backend

This is an internal backend of `fabric-server-validation`, not a separate routing skill. Its job is to make server-side player interaction cheap to reproduce.

For Minecraft Java 1.21.8, Carpet 1.4.177 is a known compatible release. The project's installed Carpet version remains the source of truth.

## Use this backend when

Choose Carpet B+ when all of these are true:

- the behavior needs a player-shaped actor;
- the important assertion is server-authoritative state;
- a socket-backed client is not part of the requirement;
- running a live isolated development server is acceptable;
- the scenario is faster to reproduce here than to author as a GameTest.

Strong examples:

- pressure plate, button, door, portal, pickup, trigger, or proximity behavior;
- inventory/server-state mutations initiated by a player action;
- multi-player-shaped concurrency where actual network timing is not the contract;
- farm or mechanic simulations where `/tick warp` can advance a bounded number of server ticks;
- reproducing a bug before encoding a durable GameTest regression.

## Do not use this backend as final proof when

- login/reconnect/disconnect packet lifecycle matters;
- encryption/authentication/socket timing matters;
- client prediction, GUI, rendering, resource packs, or visual state matter;
- the requirement says "unmodified vanilla client";
- exact normal-client interaction reach/hand behavior is the bug under test.

Known Carpet fake-player action behavior can differ from actual clients at some interaction edges. When the disputed behavior is the actuator itself, escalate rather than treating the fake player as an oracle.

## Required scenario contract

### 1. Arrange

- choose isolated coordinates;
- record the baseline state;
- create only required blocks/entities/items;
- choose a unique bot name such as `Test_<feature>_<short-id>`.

### 2. Spawn and prime

- spawn the fake player;
- explicitly set position and gamemode;
- clear/set inventory and hotbar state;
- explicitly set look direction/target;
- stop inherited or previous continuous actions.

Never depend on an operator's position, facing, inventory, or game mode.

### 3. Act

Issue the smallest player action that represents the behavior: use, attack, move, jump, sneak/sprint, hotbar selection, or mount/dismount.

Avoid continuous actions unless continuity is part of the requirement. If used, always stop them during cleanup.

### 4. Advance or await

Prefer server ticks and semantic predicates over wall-clock sleeps.

For tick-exact scenarios:

```text
/tick freeze
→ action
→ /tick step <N>
→ observe
```

For bounded simulations:

```text
baseline aggregate
→ /tick warp <N>
→ observe aggregate
→ compare delta
```

For event/state transitions, bounded polling is often clearer than either mode.

### 5. Assert

The assertion must be independent from command success.

Prefer, in order:

1. MCP Fabric structured server state/event reads;
2. an existing mod diagnostic/test hook;
3. a narrow deterministic vanilla/server command query.

Assert the semantic outcome: inventory, scoreboard/state, block/entity state, dimension, cooldown, counter, mod-owned persistent state, or a specific event.

### 6. Cleanup

Always:

1. `/player <name> stop`;
2. remove/kill the fake player;
3. remove test blocks/entities/items/state;
4. restore tick state if it was changed;
5. verify cleanup.

A failed assertion does not skip cleanup.

## Multi-actor scenarios

Use multiple fake players only when concurrency itself matters.

- assign one role per bot;
- use unique names;
- place each bot explicitly;
- phase actions with known ticks or a server predicate;
- assert one shared authoritative outcome;
- clean every actor even when one phase fails.

Do not interpret this as real multi-client network concurrency.

## Promotion rule

B+ is excellent for reproduction. A stable, deterministic regression should be promoted to Unit/Server GameTest when that preserves the actual behavior boundary.

```text
Carpet B+ reproduction
→ isolate server-side invariant
→ add Unit/GameTest regression
→ implement fix
→ rerun regression
→ use Carpet B+ again only when player-shaped integration adds evidence
```

## Scarpet policy

Scarpet is **not** required for the default fake-player backend.

Do not add a Scarpet app merely to sequence a handful of `/player` and `/tick` commands. Consider Scarpet later only when the project already uses it or repeated multi-actor orchestration becomes materially simpler than the existing test transport.

Read [carpet-player-commands.md](carpet-player-commands.md) for the bounded command vocabulary.
