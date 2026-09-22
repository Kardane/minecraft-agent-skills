# Fabric 1.21.8 Persistent State, Serialization, and Config Reload

Use this reference when a mod must survive restart, migrate stored data, or support
operator configuration.

## Separate three lifetimes

Do not use one object as all three:

1. **Transient runtime state** — caches, derived indexes, cooldown bookkeeping.
2. **Persistent gameplay state** — data that must survive restart/world reload.
3. **Operator config** — desired policy/input that may be edited outside the game.

Each lifetime has different ownership, serialization, validation, and reload rules.

## Persistent state

Minecraft 1.21.8 Yarn exposes `PersistentState` /
`PersistentStateManager`-style storage. Exact constructors and type wrappers are
version-sensitive; inspect the 1.21.8 mappings before implementing.

Primary mapping references:

- https://maven.fabricmc.net/docs/yarn-1.21.8+build.1/
- https://maven.fabricmc.net/docs/yarn-1.21.8+build.1/net/minecraft/command/DataCommandStorage.PersistentState.html

For custom durable state:

- choose a stable namespaced storage id;
- define serialization and default construction together;
- preserve unknown data when forward compatibility requires it;
- mark state dirty after semantic mutations according to the exact API contract;
- keep a mod-owned schema version when migrations are required;
- do not repurpose Minecraft's `DataVersion` as the mod schema version.

## Migration

Treat migration as a deterministic function from old schema to new schema.

Prefer:

```text
decode old
→ validate invariants
→ migrate one schema step
→ validate new invariants
→ publish new state
```

Do not silently reset economically important or progression state because decode
failed. Fail closed, preserve the original file/backing state, and surface a
diagnostic.

## Config loading

A safe runtime config flow is:

```text
read
→ parse
→ validate ranges/enums/references
→ build immutable snapshot
→ atomically replace active snapshot
```

Do not mutate the currently active config object field-by-field while gameplay
threads can observe it.

## What not to hot reload

Restart instead of hot reload when a setting changes startup-time contracts such
as:

- registry shape;
- packet codec/registration;
- Mixin application;
- entrypoints;
- fundamental persistent-state schema.

A reload command should state which fields are reloadable and which require restart.

## I/O boundary

Large config/state I/O should not block a hot tick or client-triggered network
handler. Parse expensive external data off-thread when needed, then apply the
validated immutable result on the server thread.

Persistence and restart behavior should be covered with deterministic validation in
`fabric-server-validation`.
