# WorldEdit 7.3.16 + Fabric 1.21.8 dependency setup

## Pinned baseline

- Minecraft Java Edition: 1.21.8
- Java: 21
- Fabric
- WorldEdit: 7.3.16

WorldEdit 7.3.16 explicitly supports the Fabric/NeoForge 1.21.8 line.

## Maven/API rule

EngineHub documents its Maven repository at:

`https://maven.enginehub.org/repo/`

The group is `com.sk89q.worldedit`.

The documented modules are:

- `worldedit-core` for platform-independent API types;
- `worldedit-fabric-mcXYZ` for the Fabric implementation and `FabricAdapter`.

Do **not** synthesize the exact Fabric artifact name from the Minecraft patch version. Before adding a Gradle dependency, inspect EngineHub Maven/release metadata for WorldEdit 7.3.16 and use the artifact that actually contains the 1.21.8 Fabric adapter/runtime.

The release/download compatibility and the Maven module suffix are separate facts.

## Runtime dependency

If the mod requires WorldEdit at runtime, make that dependency explicit in the project's dependency policy/metadata rather than catching `ClassNotFoundException` after startup.

If WorldEdit support is optional:

- isolate WorldEdit references behind an integration boundary;
- do not load WorldEdit classes before presence is established;
- keep the fallback behavior explicit.

## Core vs Fabric module

`worldedit-core` alone is not enough when code must convert Fabric/Minecraft objects to WorldEdit objects.

The Fabric implementation supplies `FabricAdapter`. Adapt at the integration boundary and keep the rest of the operation in WorldEdit's platform-independent types where practical.

## Verification

After dependency changes:

1. resolve dependencies without version substitution;
2. inspect the resolved WorldEdit artifacts;
3. compile imports against the pinned artifact;
4. start the 1.21.8 dedicated server;
5. confirm the WorldEdit mod and the integrating mod both initialize;
6. run one tiny disposable EditSession mutation.

## Sources

- https://worldedit.enginehub.org/en/7.3.19/api/
- https://modrinth.com/plugin/worldedit/version/7.3.16
