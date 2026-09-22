---
name: minecraft-java-content-engineering
description: "Minecraft Java Edition 1.21.8 datapack/resource-pack authoring과 worldgen data/schema/registry graph를 설계·검증할 때 사용한다. pack 구조, data-driven content, worldgen JSON validation, asset integration을 소유하며 raw command semantics와 Fabric Java registration은 specialist에 위임한다."
---

# Minecraft Java Content Engineering

## Routing Boundaries

- `Use when`: authoring or validating a Minecraft Java 1.21.8 datapack/resource-pack deliverable, worldgen data/schema/registry graph, pack structure, registry data, or cross-file asset integration.
- `Primary capabilities`: `pack-authoring`, `worldgen-data-semantics`
- `Do not use when`: the task is command syntax/selector/scoreboard logic only (`minecraft-commands-scripting`), Fabric Java registration/datagen/Mixin/Polymer (`minecraft-fabric-server-dev`), offline world `.dat`/`.mca` editing (`minecraft-java-world-nbt`), or live server operations (`minecraft-server-admin`).

이 스킬은 datapack, resource pack, worldgen data를 하나의 content boundary 안에서 라우팅한다. Java loader integration은 여기서 소유하지 않는다.

## Internal routing

| Request | Internal material |
|---|---|
| datapack structure, functions, predicates, loot, recipes, advancements, tags, structure NBT | `references/datapack/` |
| biome, dimension, configured/placed feature, structure set, template pool, worldgen registry graph | `references/datapack/worldgen/` |
| textures, models, blockstates, item models, shaders, atlases, fonts, sounds | `references/resourcepack/` |
| datapack + resource pack feature | load only the relevant material from both sides |
| Fabric Java worldgen registration/datagen wiring | `minecraft-fabric-server-dev` |
| raw `execute` / selector / scoreboard / command-NBT semantics | `minecraft-commands-scripting` |

## Context budget

1. General datapack work starts with [the datapack guide](references/datapack/guide.md).
2. Worldgen work starts with [the worldgen guide](references/datapack/worldgen/guide.md) and does not load unrelated resource-pack references.
3. Resource-pack work starts with [the resource-pack guide](references/resourcepack/guide.md).
4. Command syntax is not duplicated here; use the command specialist when the difficult part is the command itself.
5. The repository baseline is Minecraft Java Edition 1.21.8. Do not import later-version pack formats or registry types by assumption.

## Datapack workflow

```text
1.21.8 lock
→ pack.mcmeta / namespace / folder layout
→ functions and data definitions
→ deterministic layout/schema validation
→ /reload or server load boundary
→ observable behavior check
```

Helpers:

```bash
./scripts/datapack/create_datapack_scaffold.sh --pack-name my_pack --namespace mypack --output-dir /tmp/datapacks
./scripts/datapack/validate_datapack_layout.sh --pack-dir /tmp/datapacks/my_pack
```

## Worldgen workflow

Worldgen is a datapack data domain. Own the JSON/schema/reference graph here; hand loader-specific Java registration to the Fabric development skill.

```text
vanilla 1.21.8 data/datagen reference
→ registry graph
→ JSON / structure template placement
→ local cross-reference validation
→ world load / generation validation
```

Static validator:

```bash
./scripts/datapack/worldgen/validate-worldgen-json.sh --root <pack-root>
```

The validator catches structural and local-reference errors. It does not prove that every schema field is semantically valid in Minecraft 1.21.8; compare risky fields with exact-version vanilla data or version-matched datagen output.

## Resource-pack workflow

```text
1.21.8 lock
→ pack.mcmeta / asset namespace
→ textures/models/items/etc.
→ static validation
→ client resource reload/test
```

## Cross-domain design

- Datapack owns server/data-driven rules.
- Resource pack owns client-presented texture/model/font/sound assets.
- Worldgen owns data-driven generation schema and registry references.
- Fabric Java owns loader callbacks, code registration, datagen wiring, Mixin, and Polymer integration.
- Shared identifiers must be documented once and reused consistently.
- For quest/economy/RP combinations inside data-driven content, read `references/datapack/domain-integration-playbooks.md` only when needed.

## Completion criteria

- Pack layout and JSON parse successfully.
- Relevant local references resolve.
- Worldgen changes pass the worldgen validator when applicable.
- The exact 1.21.8 load/reload boundary is exercised.
- Observable behavior is checked instead of declaring success from parsing alone.
