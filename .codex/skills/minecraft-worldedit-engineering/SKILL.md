---
name: minecraft-worldedit-engineering
description: "Minecraft Java 1.21.8 Fabric 모드에서 WorldEdit 7.3.16 public API로 Region/Mask/Pattern/EditSession, clipboard/schematic, history/undo 기반 live-world 편집을 구현할 때 사용한다. 문자열 명령 실행보다 API 통합을 우선하며 offline NBT 편집과 일반 Fabric 로직은 specialist에 위임한다."
---

# Minecraft WorldEdit Engineering

## Routing Boundaries

- `Use when`: WorldEdit is the primary implementation dependency for live-world mutation, especially Region/Mask/Pattern/EditSession, clipboard/schematic, transform, or history/undo integration from Fabric Java.
- `Primary capabilities`: `worldedit-api-engineering`
- `Do not use when`: the task is general Fabric logic with no WorldEdit-specific API work (`minecraft-fabric-server-dev`), offline `.dat`/`.mca` mutation (`minecraft-java-world-nbt`), datapack/worldgen authoring (`minecraft-java-content-engineering`), raw vanilla command syntax (`minecraft-commands-scripting`), or merely installing/operating server mods (`minecraft-server-admin`).

This skill treats WorldEdit as a **programmatic world-mutation engine**, not primarily as a command collection.

## Baseline

- Minecraft Java Edition: `1.21.8`
- Java: `21`
- Fabric
- WorldEdit: `7.3.16`
- WorldEdit commands are a human/operator interface. Fabric integration should normally call the public WorldEdit API directly.

WorldEdit 7.3.16 is the pinned release for the repository baseline. Verify the exact Fabric dependency artifact exposed by EngineHub's Maven repository before editing Gradle; do not guess an artifact suffix from Minecraft patch numbering.

## Core architecture

Prefer:

```text
Fabric event / command / domain service
→ validate permission + bounds + intent
→ adapt Minecraft/Fabric types to WorldEdit types
→ Region + Mask + Pattern / Clipboard
→ EditSession
→ apply operation
→ close/flush session
→ remember history or persist rollback handle
→ verify authoritative world state
```

Avoid:

```text
Fabric Java
→ construct "//replace ..." string
→ execute WorldEdit command parser
```

Command execution is acceptable only when the feature explicitly wants command semantics or is an operator-only one-off. Library integration should use the public API.

## API ownership

### EditSession

Every world mutation should flow through an `EditSession`. Read [edit-session-region.md](references/edit-session-region.md).

- create one edit session per bounded operation;
- use try-with-resources so queues/buffers flush;
- set a maximum block-change budget when the caller or job has a meaningful bound;
- do not keep an EditSession as a long-lived singleton.

### Region

Let the mod calculate the target region directly. Do not require players to run `//pos1`/`//pos2` when the application already knows the coordinates.

Use explicit min/max bounds, dimensions, chunk footprint, and estimated block count before mutation.

### Mask and Pattern

Use WorldEdit's abstraction instead of hand-written nested block loops when the requirement is conditional bulk editing.

- Mask = where the edit may apply.
- Pattern = what is placed at each accepted position.

Read [masks-patterns.md](references/masks-patterns.md).

### Clipboard / schematic / transform

Use WorldEdit clipboard and operation APIs for reusable structures, copy/paste, transforms, and schematic workflows. Read [clipboard-history.md](references/clipboard-history.md).

### History / undo

Choose ownership explicitly:

- player-attributed edit → adapt the player to a WorldEdit Actor and remember the EditSession in that player's `LocalSession`;
- automated server job → do not fake a player session; retain an application-level rollback strategy or use the EditSession undo path where appropriate.

History is not a substitute for backups on high-impact production edits.

## Fabric integration rules

1. Keep gameplay/domain validation outside WorldEdit adapters.
2. Adapt at the boundary. Do not spread WorldEdit types through unrelated domain code.
3. `worldedit-core` gives platform-independent APIs; Fabric conversion needs the Fabric implementation/adapter.
4. Treat exact adapter signatures and mapped Minecraft types as version-sensitive. Inspect the pinned 7.3.16 artifact/Javadocs when imports or signatures are uncertain.
5. Keep live Minecraft mutation on the logical server thread unless the exact WorldEdit API explicitly documents a safe alternative.
6. Do not perform arbitrary filesystem/schematic I/O inside a tick hot path.
7. Bound edit size, chunk scope, frequency, and concurrency.
8. Do not bypass permission/business rules merely because WorldEdit can mutate the world.

## Safety workflow

For any non-trivial live edit:

```text
calculate target
→ validate world + coordinates
→ calculate volume/chunk footprint
→ apply permission/ownership/rate policy
→ choose rollback/history strategy
→ open EditSession with bounded change budget
→ execute operation
→ close EditSession
→ verify changed state/count
→ retain or discard rollback metadata intentionally
```

For production-scale operations, read [safety-threading-performance.md](references/safety-threading-performance.md).

## When WorldEdit is the wrong backend

Use vanilla/Fabric APIs instead when only a handful of blocks change and WorldEdit adds no meaningful selection/mask/pattern/history value.

Use `minecraft-java-world-nbt` when the server is intentionally offline and the requirement is direct region/NBT editing.

Use datapack/worldgen/Fabric generation APIs when the feature is persistent generation logic rather than an explicit live-world edit.

## Validation

After implementation:

1. build against the exact project dependencies;
2. validate a tiny disposable region first;
3. assert actual block/entity/biome state, not only the WorldEdit method return;
4. test boundary/empty/no-match cases;
5. test failure cleanup and history/rollback behavior;
6. use `fabric-server-validation` when gameplay behavior or client-visible effects need behavioral evidence.

## Reference loading guide

Load only what the task requires:

- dependency/version/Fabric adapter setup: [dependency-setup-1.21.8.md](references/dependency-setup-1.21.8.md)
- EditSession/Region/API-first mutation: [edit-session-region.md](references/edit-session-region.md)
- conditional bulk editing: [masks-patterns.md](references/masks-patterns.md)
- clipboard/schematic/transform/history: [clipboard-history.md](references/clipboard-history.md)
- production safety/threading/performance: [safety-threading-performance.md](references/safety-threading-performance.md)

## Sources

- https://worldedit.enginehub.org/en/7.3.19/api/
- https://worldedit.enginehub.org/en/7.3.19/api/concepts/edit-sessions/
- https://worldedit.enginehub.org/en/7.3.19/api/concepts/local-sessions/
- https://worldedit.enginehub.org/en/7.3.19/api/examples/local-sessions/
- https://modrinth.com/plugin/worldedit/version/7.3.16
