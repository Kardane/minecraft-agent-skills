# Fabric 1.21.8 Commands, Permissions, and Hot-Path Performance

Use this reference for Fabric-side Brigadier registration, authorization boundaries,
and server hot-path design.

## Command registration

Fabric API provides `CommandRegistrationCallback` for server command
registration. Verify the exact 1.21.8 callback types/mappings in the pinned project.

Primary references:

- https://maven.fabricmc.net/docs/fabric-api-0.136.0+1.21.8/
- https://docs.fabricmc.net/develop/commands/basics

Command **syntax/selector/scoreboard semantics** belong to
`minecraft-commands-scripting`. This reference owns Java registration and the
server-side execution boundary.

## Permission boundary

Apply authorization before expensive argument resolution or mutation.

Use the exact project's permission model:

- Brigadier/Fabric source requirement for vanilla permission levels;
- an existing permission API when the project already depends on one;
- explicit console/command-block/player distinctions when relevant.

Do not invent a new permission abstraction only to wrap one boolean check.

After authorization, still validate:

- target existence;
- dimension/world;
- range/count limits;
- current gameplay state;
- ownership;
- cooldown/rate boundary.

Tab visibility and execution authorization should not accidentally diverge.

## Shared domain operation

If both a command and C2S payload perform the same action:

```text
command/network adapter
→ authenticate + parse
→ shared validated server operation
→ persistent mutation
→ result/notification
```

Do not duplicate economic/inventory/state-transition logic in each adapter.

## Performance budget

At 20 TPS, a tick interval is 50 ms. That is a whole-server budget, not a budget
for one mod.

Watch these patterns first:

- global entity/player/chunk scans every tick;
- repeated registry lookups/string parsing in hot loops;
- per-tick JSON/NBT serialization;
- filesystem/database/network waits on the server thread;
- unbounded scheduled tasks or queues;
- broadcasting unchanged state every tick;
- allocation-heavy temporary collections in large loops.

Prefer:

- event-driven updates;
- dirty sets/indexes;
- bounded cadence;
- cached derived data with explicit invalidation;
- change-driven synchronization;
- batching with a documented maximum.

## Profiling rule

Do not optimize from intuition alone. Establish representative load, measure the
hot path, make one change, then re-measure.

Moving work to another thread is not automatically an optimization. It can add
contention, ordering bugs, stale-state races, and queue latency.

Runtime/performance evidence belongs to `fabric-server-validation`.
