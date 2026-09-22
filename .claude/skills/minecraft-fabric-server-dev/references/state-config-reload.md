# Fabric 1.21.8 Saved Data, Serialization, and Config Reload

Use this reference when a mod must survive restart, migrate stored data, or support
operator configuration.

## Separate three lifetimes

Do not use one object as all three:

1. **Transient runtime state** — caches, derived indexes, cooldown bookkeeping.
2. **Persistent gameplay state** — data that must survive restart/world reload.
3. **Operator config** — desired policy/input that may be edited outside the game.

Each lifetime has different ownership, serialization, validation, and reload rules.

## Persistent state with Mojang mappings

This skill uses **official Mojang mappings**.

For Minecraft 1.21.8, the relevant Mojang-mapped storage concepts include:

- `net.minecraft.world.level.saveddata.SavedData`;
- `net.minecraft.world.level.saveddata.SavedDataType`;
- `net.minecraft.world.level.storage.DimensionDataStorage`;
- `ServerLevel#getDataStorage()`.

Do not copy Yarn names such as `PersistentState`, `PersistentStateManager`, or
`ServerWorld#getPersistentStateManager()` into code produced by this skill.

Exact constructors, codecs, factories, and generic types are version-sensitive.
Inspect the resolved 1.21.8 Mojang-mapped source before implementing a custom
`SavedData` type.

For custom durable state:

- choose a stable namespaced storage id;
- define serialization and default construction together;
- preserve unknown data when forward compatibility requires it;
- call the exact `SavedData#setDirty` contract after semantic mutations;
- keep a mod-owned schema version when migrations are required;
- do not repurpose Minecraft's `DataVersion` as the mod schema version.

Useful 1.21.8 mapping references:

- https://mappings.dev/1.21.8/net/minecraft/world/level/saveddata/index.html
- https://mappings.dev/1.21.8/net/minecraft/server/level/ServerLevel.html

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
