# EditSession and Region patterns

## Mental model

WorldEdit separates **where**, **what**, and **how the mutation is applied**.

- `Region`: where the operation is bounded.
- `Mask`: which positions inside that scope are eligible.
- `Pattern`: what result is placed.
- `EditSession`: mutation context, limits, buffering/reordering, history/change tracking.

## Fabric adaptation

The Fabric implementation exposes `FabricAdapter` so Minecraft/Fabric world/player/value types can cross into WorldEdit's platform-independent API.

Conceptual Java shape:

```java
World weWorld = FabricAdapter.adapt(serverWorld);

try (EditSession editSession =
         WorldEdit.getInstance().newEditSession(weWorld)) {
    // apply one bounded operation
}
```

Verify the exact 7.3.16 imports and mapped parameter types in the project's resolved Fabric artifact before coding.

## Region ownership

When the application already has coordinates, create the Region directly. Do not route through player selections or command parsing.

For cuboids:

```java
Region region = new CuboidRegion(
    weWorld,
    BlockVector3.at(minX, minY, minZ),
    BlockVector3.at(maxX, maxY, maxZ)
);
```

Before editing, calculate:

- min/max build-height validity;
- region volume;
- affected chunk range;
- expected match count if cheaply knowable;
- maximum allowed changes for the operation.

## Session lifetime

Use one EditSession for one logical operation.

Do not:

- store EditSession in a singleton;
- reuse a closed EditSession;
- leave a session unclosed;
- open unbounded sessions for user-controlled coordinates.

WorldEdit documents `newEditSession(World)` and the edit-session builder as the normal public entry points.

## API-first operation design

Prefer high-level WorldEdit operations over manually iterating every position when a Region/Mask/Pattern operation expresses the requirement.

Manual loops are still justified when domain-specific logic cannot be represented safely as a WorldEdit operation. In that case keep the EditSession as the mutation sink and keep the loop bounded.

## Verification

An API call returning successfully is not the final assertion.

After the operation:

- inspect representative changed positions;
- compare affected-count expectations;
- verify non-target positions remain unchanged;
- validate rollback/history if required.

## Sources

- https://worldedit.enginehub.org/en/7.3.19/api/concepts/edit-sessions/
- https://worldedit.enginehub.org/en/7.3.19/api/concepts/adapters/
