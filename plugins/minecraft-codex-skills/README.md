# minecraft-codex-skills

This plugin packages the same 5 Minecraft skills for Codex and Claude Code.
`minecraft-imagegen` requires a host with image-generation support.

## Install

- Codex: preserve the repository layout: `.agents/plugins/marketplace.json`
  and `plugins/minecraft-codex-skills/` share the same project root. Install
  `minecraft-codex-skills` from the plugins surface.
- Claude Code:

  ```bash
  claude --plugin-dir ./plugins/minecraft-codex-skills
  ```

Use either the plugin or raw skill folders for a host to avoid duplicate skills.
Choose your model and tools in Codex or Claude Code.
See [usage examples](../../README.md#usage).

## Maintain

Edit `.agents/skills/` in the repository root, then run `npm run sync:skills`.
Do not edit this plugin's `skills/` directory directly.
