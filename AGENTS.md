# minecraft-agent-skills

This repository contains 10 Minecraft skills and a plugin for Codex and Claude Code.

## Editing

- Treat `.agents/skills/` as canonical.
- After canonical changes, run `npm run sync:skills` to refresh `.codex/skills/`,
  `.claude/skills/`, and `plugins/minecraft-codex-skills/skills/`.
- Do not hand-edit mirrored skill trees.
- Run `npm run check` before publishing changes.

## Skill standards

- Keep skill instructions focused on when to use them and which versions they
  support. Put longer examples in reference files.
- Preserve the user's project, version pins, and authorized scope. A sample
  workflow is not a requirement to migrate, publish, or add extra deliverables.
- Verify changing APIs against primary documentation for the exact version.
  Distinguish static helper checks from compilation and in-game validation.

- Target Minecraft Java Edition 1.21.8 with Java 21. Do not introduce guidance for other Minecraft or Java lines unless the repository baseline is intentionally changed.
- Keep platform-specific patterns clear and examples runnable.
- Keep JSON valid and formatted with 2-space indentation.
- Do not create filesystem or runtime dependencies between skills. Routing and handoff references between skills are allowed.

## Repository boundaries

- Do not run Minecraft, Gradle, or Paper server commands here.
- Keep helper scripts self-contained inside the skill that uses them.
- Do not add unstable Minecraft features or version guidance.
