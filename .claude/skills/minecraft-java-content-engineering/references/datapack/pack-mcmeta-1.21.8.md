# `pack.mcmeta` — Minecraft Java 1.21.8

The repository baseline is Minecraft Java Edition 1.21.8.

```json
{
  "pack": {
    "description": "My Datapack for 1.21.8",
    "pack_format": 81
  }
}
```

## Rules

1. Use `pack_format: 81` for this bundle baseline.
2. Do not copy `min_format` / `max_format` examples from later Minecraft releases.
3. Validate JSON, run `/reload`, and confirm the load function executes.
4. If the project intentionally changes Minecraft versions, update the repository support policy first instead of silently mixing formats.
