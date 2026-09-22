# Minecraft Java 1.21.8 Worldgen Data

Worldgen is a datapack data domain. This reference owns schemas, paths, and registry/reference graphs. Fabric Java registration and datagen wiring belong to `minecraft-fabric-server-dev`.

## Start from exact-version data

Use Minecraft 1.21.8 vanilla data or version-matched datagen output as the source of truth for field-level schema. Do not infer a schema from an earlier/later tutorial merely because the JSON parses.

## Common layout

```text
data/<namespace>/
├── dimension/
├── dimension_type/
├── structure/
├── tags/worldgen/
└── worldgen/
    ├── biome/
    ├── configured_feature/
    ├── placed_feature/
    ├── noise_settings/
    ├── processor_list/
    ├── structure/
    ├── structure_set/
    └── template_pool/
```

## Reference graph

Build from leaves upward:

1. configured feature → placed feature;
2. placed feature → biome/tag/other owning graph;
3. structure template + processor list + template pool → jigsaw structure;
4. structure → structure set;
5. biome/dimension/noise settings references → owning dimension graph.

Local references in the same namespace should resolve before runtime testing. External vanilla/dependency references may legitimately live outside the pack.

## Static validation

```bash
./scripts/datapack/worldgen/validate-worldgen-json.sh --root <pack-root>
```

Use `--strict` when warnings must fail CI. The validator checks JSON integrity, path conventions, and local cross-references including placed/configured features, dimensions, structures, template pools, processor lists, and structure templates.

## Fabric integration boundary

- JSON/data graph and pack assets: this skill.
- Fabric API registration, BiomeModification, Java datagen wiring, callbacks: `minecraft-fabric-server-dev`.
- Runtime behavior proof: use the relevant project validation path rather than treating static JSON validation as in-game proof.

## Failure modes

- registry path copied from another Minecraft version;
- missing local reference;
- jigsaw pool points to a missing structure `.nbt`;
- processor list/template pool/structure set chain incomplete;
- static JSON passes but the world load/generation contract was never exercised.
