# Datapack Syntax and Integration — Minecraft Java 1.21.8

This document covers file-level datapack integration. It intentionally does not duplicate the full `execute`, selector, scoreboard, or command-NBT reference owned by `minecraft-commands-scripting`.

## Text and file rules

- UTF-8 text, preferably without BOM.
- One command per `.mcfunction` line; comments start with `#`.
- Keep namespaced paths lowercase and predictable.
- Split initialization, recurring work, and feature operations into separate functions.

## `pack.mcmeta`

Use the repository baseline only:

```json
{
  "pack": {
    "pack_format": 81,
    "description": "My Datapack (1.21.8)"
  }
}
```

## Function tags

`data/minecraft/tags/function/load.json`:

```json
{
  "replace": false,
  "values": ["mypack:init/load"]
}
```

`data/minecraft/tags/function/tick.json`:

```json
{
  "replace": false,
  "values": ["mypack:loop/tick"]
}
```

Keep high-frequency work bounded. The fact that a function is reachable from `tick` does not justify scanning all entities or players every tick.

## Function macros

- Macro lines start with `$`.
- Variables use `$(name)`.
- Validate required inputs before operational use.
- Read `function-macro-guide.md` for parameterized-function patterns.

## JSON/data files

- Prefer exact 1.21.8 vanilla data or version-matched datagen output as the schema source.
- Validate JSON syntax before runtime loading.
- Treat registry identifiers as references that must resolve in the pack, vanilla, or a declared dependency.

## NBT boundary

- Structure-template `.nbt` belongs to the datapack and is handled by `nbt-and-structure-nbt.md`.
- Raw `/data` command syntax belongs to `minecraft-commands-scripting`.
- Offline world `.dat` and `.mca` editing belongs to `minecraft-java-world-nbt`.

## Anti-patterns

1. Copying later-version `pack.mcmeta` or registry data into 1.21.8.
2. Re-implementing the command reference inside pack documentation.
3. Putting unrelated systems into one tick function.
4. Editing binary structure NBT as text.
5. Declaring success without `/reload` or load-boundary verification.
