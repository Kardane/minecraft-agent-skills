# Datapack Content Catalog — Minecraft Java 1.21.8

Use this as a conservative routing index, not as proof that every possible registry type has been enumerated.

## Core pack content

| Type | Typical path | Purpose |
|---|---|---|
| function | `data/<ns>/function/*.mcfunction` | executable pack logic |
| function tag | `data/<ns>/tags/function/*.json` | load/tick or custom function groups |
| advancement | `data/<ns>/advancement/*.json` | progression and criteria |
| recipe | `data/<ns>/recipe/*.json` | crafting recipes |
| loot table | `data/<ns>/loot_table/*.json` | drops and rewards |
| predicate | `data/<ns>/predicate/*.json` | reusable conditions |
| structure template | `data/<ns>/structure/*.nbt` | binary structure templates |

## Registry-backed content

For registry-backed types such as damage types, enchantments, variants, paintings, instruments, dimension types, and other data-driven registries, derive the exact file/schema from Minecraft 1.21.8 vanilla data or version-matched datagen output. Do not maintain a later-version superset here.

## Worldgen

Worldgen is now owned inside this content skill. Common registry paths include:

| Path | Purpose |
|---|---|
| `worldgen/biome` | biome definitions |
| `worldgen/configured_feature` | configured feature definitions |
| `worldgen/placed_feature` | placement graph |
| `worldgen/noise_settings` | noise settings |
| `worldgen/processor_list` | structure processors |
| `worldgen/structure` | structure generation definitions |
| `worldgen/structure_set` | structure placement sets |
| `worldgen/template_pool` | jigsaw pools |
| `dimension` | dimension definitions |
| `dimension_type` | dimension rules |

See `worldgen/guide.md` before hand-authoring cross-references.

## Ownership rule

- Data/schema/reference graph: this skill.
- Raw command syntax: `minecraft-commands-scripting`.
- Loader-specific Java registration/datagen wiring: `minecraft-fabric-server-dev`.
