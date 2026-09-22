# Minecraft Java 1.21.8 Datapack Engineering

This reference owns pack structure and integration. Detailed command semantics belong to `minecraft-commands-scripting`.

## Quick start

1. Lock the target to Minecraft Java 1.21.8.
2. Use [pack.mcmeta for 1.21.8](pack-mcmeta-1.21.8.md).
3. Establish the folder layout from [the folder guide](datapack-folder-structure.md).
4. Select only the required content types from [the content catalog](datapack-content-catalog.md).
5. Use [the syntax guide](datapack-syntax-guide.md) for pack/file integration rules.
6. Use [the function macro guide](function-macro-guide.md) only when parameterized functions reduce duplication.
7. For worldgen, switch to [the worldgen guide](worldgen/guide.md).
8. Run the layout validator before loading the pack.

## Boundaries

- Pack/file ownership: this skill.
- `execute`, selectors, scoreboards, raw command NBT/components: `minecraft-commands-scripting`.
- Fabric registration/datagen Java code: `minecraft-fabric-server-dev`.
- Offline world `.dat`/`.mca`: `minecraft-java-world-nbt`.

## Architecture

- Separate `load` initialization from recurring `tick` work.
- Keep namespace and identifiers stable across functions, tags, loot, advancements, recipes, and resource-pack references.
- Avoid global per-tick scans when an event/state-driven design can narrow the set.
- Treat economic/PvP/progression mutations as rollback-sensitive.

## Validation

- structure: expected files, namespaces, tag entrypoints;
- syntax: JSON parsing and command execution paths;
- worldgen: local registry/reference graph validator;
- runtime: `/reload`, load function, representative tick behavior;
- operations: backup/rollback for high-impact changes.

## Scripts

```bash
./scripts/datapack/create_datapack_scaffold.sh --pack-name my_pack --namespace mypack --output-dir /tmp/datapacks
./scripts/datapack/validate_datapack_layout.sh --pack-dir /tmp/datapacks/my_pack
./scripts/datapack/worldgen/validate-worldgen-json.sh --root /tmp/datapacks/my_pack
```

## File index

- [pack.mcmeta 1.21.8](pack-mcmeta-1.21.8.md)
- [folder structure](datapack-folder-structure.md)
- [content catalog](datapack-content-catalog.md)
- [pack syntax/integration](datapack-syntax-guide.md)
- [function macros](function-macro-guide.md)
- [structure NBT boundary](nbt-and-structure-nbt.md)
- [worldgen](worldgen/guide.md)
- [domain integration playbooks](domain-integration-playbooks.md)
