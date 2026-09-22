# Fabric 1.21.8 Lifecycle, Threading, and Async I/O

Use this reference for startup/shutdown hooks, tick work, background computation,
reload boundaries, and thread-affinity decisions.

## Prefer lifecycle/events over polling

Use Fabric events/callbacks when they represent the state transition directly.
Examples in the 1.21.8 Fabric API include server lifecycle/world/tick event
families. Verify the exact event and signature against the project's pinned API.

Primary API index:

- https://maven.fabricmc.net/docs/fabric-api-0.136.0+1.21.8/

A tick callback is appropriate for genuinely time-based behavior. It is not a
default replacement for join/leave/load/save/command/network events.

## Server thread ownership

Treat mutable Minecraft world state as server-thread-owned unless the exact API
documents a different contract.

Do not read or mutate live entities, worlds, registries, inventories, chunks, or
server-owned collections from arbitrary worker threads.

For async work:

1. capture the smallest immutable input snapshot on the server thread;
2. run pure computation or blocking external I/O on a bounded worker;
3. return a result DTO;
4. schedule result application back onto the server thread;
5. re-check state that may have changed while the work was in flight.

Never assume a player/entity reference is still valid after an async gap.

## Blocking I/O

Do not synchronously wait for these in a tick, command, or network handler:

- filesystem scans/writes that can be large;
- database or HTTP calls;
- external process completion;
- long compression/serialization work.

Small bounded config reads at startup may be acceptable, but measure before making
that a general rule.

## Executors and queues

Prefer a bounded executor or an existing project executor with known lifecycle.

Define:

- maximum concurrency;
- queue bound or rejection policy;
- cancellation behavior on server stop;
- whether in-flight results may be dropped during reload/stop;
- failure logging and retry policy.

An unbounded executor/queue can convert a packet or command burst into memory
pressure.

## Tick work

For recurring work, document both cadence and cardinality:

- every tick for every player;
- every N ticks for dirty players only;
- event-driven index plus bounded maintenance pass.

Avoid nested global scans such as every-player × every-entity unless the measured
server size makes the bound explicit.

## Reload and shutdown

A reload must not leave duplicate listeners, stale snapshots, orphan workers, or
two config generations active simultaneously.

On shutdown:

- stop accepting new external work;
- cancel or drain workers according to the durability contract;
- flush durable state through the normal persistence mechanism;
- close owned resources.

Behavioral race/reload tests belong to `fabric-server-validation`.
