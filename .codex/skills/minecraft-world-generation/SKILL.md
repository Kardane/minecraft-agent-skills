---
name: minecraft-world-generation
description: "Create and debug Minecraft Java 1.21.8 world generation for datapacks, NeoForge, or Fabric, including biomes, dimensions, features, structures, and biome modifiers. Use for worldgen data or registration, not general gameplay systems."
---

# Minecraft World Generation

Use this skill for biome, dimension, feature, or structure data and their
registration. Use `minecraft-java-content-engineering` for non-worldgen data and
`minecraft-fabric-server-dev` for non-worldgen gameplay code.

## Routing Boundaries

- `Use when`: the task changes worldgen data, registration, or injection.
- `Do not use when`: the task is non-worldgen datapack work (`minecraft-java-content-engineering`).
- `Do not use when`: the task is non-worldgen Fabric mod systems (`minecraft-fabric-server-dev`).

## Choose the delivery path

| Approach | Best When | Platform |
|----------|-----------|----------|
| Datapack JSON | Change data supplied by a pack | Vanilla, any server |
| **Mod + Datagen** | Registering new biomes/dimensions, code-driven | NeoForge / Fabric |
| **Biome Modifier (NeoForge)** | Adding features/spawns to existing biomes | NeoForge |
| **BiomeModification API (Fabric)** | Adding features/spawns to existing biomes | Fabric |

Worldgen registries are datapack registries: their files load at world load and
their registry path determines the data path. Read the [NeoForge registry
guide](https://docs.neoforged.net/docs/concepts/registries/) before choosing a
mod-specific registry path.

## Version boundary

Target Minecraft Java Edition **1.21.8** with Java **21**. Start each JSON schema from 1.21.8 vanilla data or version-matched datagen output; do not copy shapes from later releases merely because they parse as JSON.

Use [the bundled 1.21 worldgen patterns](references/legacy-1.21-worldgen-json.md) as a structural aid, then verify registry paths and fields against the exact 1.21.8 target.

---

## Data layout and reference graph

```
data/<namespace>/
├── worldgen/
│   ├── biome/
│   │   └── my_biome.json
│   ├── configured_feature/
│   │   └── my_ore.json
│   ├── placed_feature/
│   │   └── my_ore_placed.json
│   ├── noise_settings/
│   │   └── my_dimension_noise.json
│   ├── structure/
│   │   └── my_structure.json
│   ├── structure_set/
│   │   └── my_structures.json
│   ├── processor_list/
│   │   └── my_processors.json
│   ├── template_pool/
│   │   └── my_pool.json
│   └── carver/
│       └── my_carver.json
├── dimension/
│   └── my_dimension.json
├── dimension_type/
│   └── my_type.json
├── tags/
│   └── worldgen/
│       └── biome/
│           └── is_forest.json
└── neoforge/
    └── biome_modifier/      (NeoForge mod only)
        └── add_ores.json
```

Build and review the graph from its leaves upward:

1. Define a configured feature, then its placed feature.
2. Reference placed features from a biome or biome modifier at the intended
   decoration step.
3. Define a structure, then its structure set; a jigsaw structure also needs a
   template pool, processor list, and structure template.
4. Define a dimension type and noise settings before a dimension that references
   them.

Use fully qualified identifiers across namespaces. An external `minecraft:` or
dependency reference is valid when that dependency supplies the registry entry;
do not create a local copy merely to satisfy static checking. If the same pack
contains that external namespace and registry directory, treat it as local and
verify the target exists.

---

## Biomes and dimensions

For Minecraft 1.21.8 biome and dimension data, use the exact target's vanilla data or datagen output as the schema source. The 11 decoration steps organize placed features; choose the semantically appropriate step and keep ore placement in `underground_ores`.

The bundled [1.21 worldgen patterns](references/legacy-1.21-worldgen-json.md) are a starting point only; confirm any version-labeled example against 1.21.8 before shipping.

---

## NeoForge biome modifiers

Biome modifiers load from
`data/<modid>/neoforge/biome_modifier/<path>.json`. They can target a biome id
or tag and add or remove placed features, among other changes. The current
[Biome Modifiers guide](https://docs.neoforged.net/docs/worldgen/biomemodifier/)
documents their schemas, decoration steps, and datagen.

For `neoforge:add_features`, `features` accepts a placed-feature id, list, or
tag. Vanilla placed features may be referenced in biome JSON or added with a
modifier, but NeoForge cautions against doing both because feature-order cycles
can crash world loading. Prefer a copy under the mod namespace when an injected
vanilla feature would create that risk.

When targeting a biome from an optional dependency, put the target in a biome
tag entry with `required: false`, then use that tag in the modifier. This lets
the pack load when the dependency is absent.

---

## Structures and dimensions

For Minecraft 1.21.8, derive structure, template-pool, dimension, and
dimension-type JSON from that release's vanilla data or datagen output. Confirm
the reference graph before launching a test world:

- `structure_set` references `structure`.
- Jigsaw `start_pool` references `template_pool`; each single-pool element
  references its structure template and processor list.
- `dimension.type` references `dimension_type`; a noise generator's string
  `settings` references `worldgen/noise_settings`.

For Fabric registration or mod datagen, use the exact 1.21.8-compatible loader and API documentation rather than copying examples from another Minecraft line.

The detailed 1.21 structure and dimension examples are in
[legacy 1.21 JSON patterns](references/legacy-1.21-worldgen-json.md).

---

## Development Workflow

1. Create or edit worldgen JSON files in `data/<namespace>/worldgen/` (or equivalent mod resources path).
2. Run the bundled validator to catch JSON and cross-reference errors before loading:
   ```bash
   ./scripts/validate-worldgen-json.sh --root /path/to/datapack-or-mod-resources
   # Strict mode treats warnings as failures:
   ./scripts/validate-worldgen-json.sh --root /path/to/datapack-or-mod-resources --strict
   ```
3. Fix any reported errors and re-validate until clean. The validator checks:
   - JSON validity for `worldgen/**` and `neoforge/biome_modifier/**`
   - Cross-reference integrity for `placed_feature -> configured_feature`
   - Cross-reference integrity for `structure_set -> structure` and biome/biome_modifier feature targets
   - Cross-reference integrity for `jigsaw structure -> start_pool` and `template_pool -> structure template / processor_list`
4. Compare biome and dimension-type JSON against the exact target's vanilla
   registry shape before in-game testing. The helper does not run Mojang codecs:
   valid JSON and local references do not prove that fields such as `carvers`,
   `effects`, or dimension settings match that release's schema.
5. In-game biome and structure testing:
   ```mcfunction
   /locate structure <namespace>:my_structure
   /locate biome <namespace>:my_biome
   /place feature <namespace>:my_ore
   ```
   `place feature` takes a configured-feature ID, not its placed-feature wrapper.
   See Mojang's [place command reference in the 1.19 release notes](https://www.minecraft.net/en-us/article/the-wild-update-out-today-java).
6. For dimension testing, use `/execute in` (dimension must exist at world load, not added via `/reload`):
   ```mcfunction
   execute in <namespace>:my_dimension run tp @s 0 100 0
   ```
7. Check `latest.log` for worldgen errors (missing biome references, malformed noise settings).
8. Note: `/reload` refreshes datapack JSON but does **not** re-generate already-generated chunks. Test new worldgen in a fresh world or newly generated chunks. For existing test worlds, use a disposable copy and a purpose-built chunk reset/regeneration workflow; `/fill` only replaces blocks and is not a substitute for world generation.

---

## References

- Minecraft Wiki — World generation: https://minecraft.wiki/w/Custom_world_generation
- Minecraft Wiki — Biome: https://minecraft.wiki/w/Biome/JSON_format
- Minecraft Wiki — Features: https://minecraft.wiki/w/World_generation/Configured_feature
- NeoForge Biome Modifiers: https://docs.neoforged.net/docs/worldgen/biomemodifier/
- Fabric BiomeModifications: https://wiki.fabricmc.net/tutorial:biomemodification
- misode's data pack generator (worldgen UI): https://misode.github.io/worldgen/
