---
name: minecraft-commands-scripting
description: "Write and debug Minecraft Java 1.21.8 command syntax and command-only logic: selectors, execute chains, scoreboards, NBT/components, and mcfunction snippets. Use content engineering for complete datapacks and server admin for RCON transport, backups, or live operations."
---

# Minecraft Commands & Scripting Skill

Before editing, inspect the exact Minecraft version and execution context
(chat, function, command block, or RCON). Keep the requested scope and use only
the relevant examples. Check current release notes for version-sensitive syntax.

## Command Syntax Conventions

- `<required>` — required argument
- `[optional]` — optional argument
- `(a|b|c)` — choose one
- `...` — repeating / multiple
- Coordinates: `~` = relative offset, `^` = local (look-direction)

### Routing Boundaries
- `Use when`: the task is raw command syntax, command chains, scoreboards, selector logic, or isolated mcfunction logic.
- `Primary capabilities`: `command-semantics`
- `Do not use when`: creating/editing a complete datapack (`minecraft-java-content-engineering`), implementing Brigadier/Fabric Java code (`minecraft-fabric-server-dev`), or automating RCON connections, backups, retries, credentials, or live operations (`minecraft-server-admin`).

## Bundled References And Examples

- Execute cheat sheet: `references/execute-cheat-sheet.md`
- Selector cheat sheet: `references/selector-cheat-sheet.md`
- Example scripts: `scripts/examples/arena-countdown.mcfunction`, `scripts/examples/stopwatch-podium.mcfunction`

Use the cheat sheets when you need fast command recall without scanning this whole
skill file. Copy and adapt the example scripts as needed.

---

## Command reference

Use [references/command-reference.md](references/command-reference.md) for the
relevant command family. It includes version boundaries for item components,
attributes, text events, gamerules, and 1.21.8 time/weather syntax. Do not run example
blocks as a batch; each demonstrates a separate operation.

## RCON as an execution context

When the user only needs the **Minecraft command string** that will be sent over RCON, this skill owns the command semantics. Connection setup, credential handling, retries, `save-off`/backup orchestration, transport security, and live-server automation belong to `minecraft-server-admin`.


---

## Common Scripting Patterns

### First-join setup (load and tick functions)
```mcfunction
# load.mcfunction: create the objective
scoreboard objectives add initialized dummy

# tick.mcfunction: detect players who have not been initialized
execute as @a unless score @s initialized matches 1 run function mypack:on_first_join

# on_first_join.mcfunction
scoreboard players set @s initialized 1
give @s minecraft:stone_sword
give @s minecraft:bread 16
tellraw @s {"text":"Welcome! Here's a starter kit.","color":"green"}
```

### Death counter + respawn
```mcfunction
# tick.mcfunction — check deaths
execute as @a[scores={deaths=1..}] run function mypack:on_death

# on_death.mcfunction (separate file)
scoreboard players reset @s deaths
scoreboard players add @s total_deaths 1
```

### Proximity detection
```mcfunction
# Check if any player is within 5 blocks of a location
execute if entity @a[x=10,y=64,z=10,distance=..5] run function mypack:player_nearby
```

### Math tricks (no fractions in scoreboards)
```mcfunction
# Multiply @s.value by 1.5 using integer math (×3 then /2)
scoreboard players operation @s result = @s value
scoreboard players operation @s result *= #three constants
scoreboard players operation @s result /= #two constants
# Set #two and #three on load:
# scoreboard players set #two constants 2
# scoreboard players set #three constants 3
```

---

## References

- Minecraft Wiki — Commands: https://minecraft.wiki/w/Commands
- Minecraft Wiki — Target selectors: https://minecraft.wiki/w/Target_selectors
- Minecraft Wiki — NBT format: https://minecraft.wiki/w/NBT_format
- Minecraft Wiki — Raw JSON text: https://minecraft.wiki/w/Raw_JSON_text_format
- Minecraft Wiki — Scoreboard: https://minecraft.wiki/w/Scoreboard
- Execute command wiki: https://minecraft.wiki/w/Commands/execute
