# Structure NBT and Datapack NBT Boundaries

## Ownership

- `data/<namespace>/structure/*.nbt` is a datapack asset and belongs here.
- Raw `/data` command syntax belongs to `minecraft-commands-scripting`.
- Offline world `.dat` / Anvil `.mca` editing belongs to `minecraft-java-world-nbt`.

## Structure-template workflow

1. Save the structure with a version-matched Minecraft 1.21.8 workflow.
2. Copy the resulting binary `.nbt` into `data/<namespace>/structure/`.
3. Keep an original backup; do not edit the binary as text.
4. Verify the identifier/path and place it in a test world before production use.
5. For jigsaw worldgen, verify template-pool and processor-list references with the worldgen validator.

## Failure patterns

- namespace/path mismatch;
- missing structure template referenced by a template pool;
- copying a structure from a different Minecraft line without validation;
- mass placement causing chunk/tick pressure;
- confusing a datapack structure asset with a live-world region/NBT edit.
