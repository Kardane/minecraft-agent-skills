# September 2026 review notes

Reviewed September 5–6, 2026 for v2.5.3. Covers the 5 retained skills, references,
helper scripts, plugin packaging, and repository checks.

## Changes

| Skill | Changes | Sources |
| --- | --- | --- |
| `minecraft-commands-scripting` | Checked attribute modifiers, text components, enchantments, sound sources, version-specific commands, and RCON credential handling. Preserved version-specific examples and the command-only route. | [Mojang 1.21.5](https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21-5), [Mojang 26.1](https://www.minecraft.net/en-us/article/minecraft-java-edition-26-1) |
| `minecraft-world-generation` | Corrected `/place feature` to use a configured-feature ID. Narrowed legacy JSON examples to 1.21.5 and corrected the biome carver list. Preserved current random-patch migration guidance and distinction between local references and external registries. | [NeoForge 26.1 primer](https://docs.neoforged.net/primer/docs/26.1/), [NeoForge biome modifiers](https://docs.neoforged.net/docs/worldgen/biomemodifier/), [Mojang 1.21.5 client data](https://piston-data.mojang.com/v1/objects/b88808bbb3da8d9f453694b5d8f74a3396f1a533/client.jar) |
| `minecraft-ci-release` | Verified immutable action pins. Release selection requires both loader artifacts with distinct names. Publisher tasks depend on version verification; tag preflight checks worktree, branch, exact push URL, and remote lookup errors. Removed an incorrect cache path and false strict-mode warnings for secretless workflows. | [Gradle setup cache behavior](https://github.com/gradle/actions/blob/main/docs/setup-gradle.md), [GitHub release action](https://github.com/softprops/action-gh-release), [Minotaur](https://github.com/modrinth/minotaur), [CurseForgeGradle](https://github.com/Darkhax/CurseForgeGradle) |
| `minecraft-server-admin` | Clarified Java requirements, corrected spark monitoring, scoped backup examples, added modded-server recovery inventory, and corrected live-backup consistency requirements and Folia limitations. | [Paper setup](https://docs.papermc.io/paper/getting-started/), [Velocity setup](https://docs.papermc.io/velocity/getting-started/), [spark commands](https://spark.lucko.me/docs/Command-Usage), [backup lifecycle](https://github.com/itzg/docker-mc-backup), [Folia FAQ](https://docs.papermc.io/folia/faq/) |
| `minecraft-imagegen` | Removed repeated prompt/workflow material and mandatory extra concept rounds. Uses actual host capability, the requested output, and verified save paths. Supporting recipes are conditional. | [OpenAI image generation](https://developers.openai.com/api/docs/guides/image-generation), [Claude vision](https://platform.claude.com/docs/en/build-with-claude/vision) |

Examples for Minecraft 26.x use Java 25. Minecraft 1.21.x examples use Java 21.

## Checks

- Ran skill sync and repository checks for copied files, packaging, metadata,
  links, code examples, validators, workflow pins, and Markdown.
- Tested release scripts with missing and duplicate artifacts, existing tags,
  remote lookup failures, incorrect push URLs, and untracked files. Git responses
  were mocked; these tests did not publish anything.
- Tried command, image-tool availability, and version-selection tasks. These were limited spot checks.
- Checked the 1.21.5 biome example against Mojang's client JAR, SHA-1
  `b88808bbb3da8d9f453694b5d8f74a3396f1a533`.

No Minecraft, Paper, or Gradle runtime was launched. Builds, rendering, gameplay,
and server operations still need testing in the target project.
