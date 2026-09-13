# September 2026 review notes

Reviewed September 5–6, 2026 for v2.5.3. Covers the 13 skills, references,
helper scripts, plugin packaging, and repository checks.

## Changes

| Skill | Changes | Sources |
| --- | --- | --- |
| `minecraft-commands-scripting` | Checked attribute modifiers, text components, enchantments, sound sources, version-specific commands, and RCON credential handling. Preserved version-specific examples and the command-only route. | [Mojang 1.21.5](https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21-5), [Mojang 26.1](https://www.minecraft.net/en-us/article/minecraft-java-edition-26-1) |
| `minecraft-datapack` | Corrected automatic load/tick tags to the `minecraft` namespace. Custom tags remain legal but receive an advisory when named load/tick. Added modern metadata bounds, short-array endpoint handling, range ordering, and legacy compatibility checks. | [Mojang load tag](https://www.minecraft.net/en-us/article/minecraft-snapshot-18w01a), [Mojang pack metadata](https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21-9) |
| `minecraft-resource-pack` | Corrected the 1.21.4 item-definition boundary, string custom-model selectors, modern texture objects, sound event references, and block inspection guidance. Extended metadata validation and corrected misleading valid fixtures. | [Mojang 1.21.4](https://feedback.minecraft.net/hc/en-us/articles/32385811139085-Minecraft-Java-Edition-1-21-4-The-Garden-Awakens), [Mojang 26.1](https://www.minecraft.net/en-us/article/minecraft-java-edition-26-1), [NeoForge sounds](https://docs.neoforged.net/docs/1.21.8/resources/client/sounds/) |
| `minecraft-world-generation` | Corrected `/place feature` to use a configured-feature ID. Narrowed legacy JSON examples to 1.21.5 and corrected the biome carver list. Preserved current random-patch migration guidance and distinction between local references and external registries. | [NeoForge 26.1 primer](https://docs.neoforged.net/primer/docs/26.1/), [NeoForge biome modifiers](https://docs.neoforged.net/docs/worldgen/biomemodifier/), [Mojang 1.21.5 client data](https://piston-data.mojang.com/v1/objects/b88808bbb3da8d9f453694b5d8f74a3396f1a533/client.jar) |
| `minecraft-modding` | Fixed specialized registry types, registry keys before object construction, current tool/armor/entity patterns, and recipe paths/schema. The build helper accurately describes incremental builds and candidate artifacts. | [NeoForge blocks](https://docs.neoforged.net/docs/blocks/), [tools](https://docs.neoforged.net/docs/items/tools/), [armor](https://docs.neoforged.net/docs/items/armor/), [entities](https://docs.neoforged.net/docs/entities/), [Fabric blocks](https://docs.fabricmc.net/develop/blocks/first-block) |
| `minecraft-multiloader` | Corrected shared keyed item registration, removed claims of an unavailable released template, and derives artifact names from the real build. The helper is explicitly a static properties/family check. | [Architectury 1.21.11 source](https://github.com/architectury/architectury-api/tree/1.21.11), [26.2 source](https://github.com/architectury/architectury-api/tree/26.2), [template releases](https://github.com/architectury/architectury-templates/releases), [Loom releases](https://github.com/architectury/architectury-loom/releases) |
| `minecraft-plugin-dev` | Separated Bukkit `plugin.yml` command lookup from a paired Paper-only descriptor/main class using Brigadier lifecycle registration. Reviewed Java, Paper API, PDC, and Folia scheduler boundaries. | [Paper plugins](https://docs.papermc.io/paper/dev/getting-started/paper-plugins/), [command registration](https://docs.papermc.io/paper/dev/command-api/basics/registration/), [Folia support](https://docs.papermc.io/paper/dev/folia-support/) |
| `minecraft-testing` | Fixed paired Fabric metadata, current death-event construction, Jupiter alignment, current NeoForge test-function registration, legacy template naming, and class-specific event registration checks. GameTest-only projects do not require an unrelated JUnit source tree. | [Fabric testing](https://docs.fabricmc.net/develop/automatic-testing), [current NeoForge tests](https://docs.neoforged.net/docs/misc/gametest/), [legacy NeoForge tests](https://docs.neoforged.net/docs/1.21.3/misc/gametest/), [Paper death event](https://jd.papermc.io/paper/26.2/org/bukkit/event/entity/EntityDeathEvent.html) |
| `minecraft-ci-release` | Verified immutable action pins. Release selection requires both loader artifacts with distinct names. Publisher tasks depend on version verification; tag preflight checks worktree, branch, exact push URL, and remote lookup errors. Removed an incorrect cache path and false strict-mode warnings for secretless workflows. | [Gradle setup cache behavior](https://github.com/gradle/actions/blob/main/docs/setup-gradle.md), [GitHub release action](https://github.com/softprops/action-gh-release), [Minotaur](https://github.com/modrinth/minotaur), [CurseForgeGradle](https://github.com/Darkhax/CurseForgeGradle) |
| `minecraft-server-admin` | Clarified Java requirements, corrected spark monitoring, scoped backup examples, added modded-server recovery inventory, and corrected live-backup consistency requirements and Folia limitations. | [Paper setup](https://docs.papermc.io/paper/getting-started/), [Velocity setup](https://docs.papermc.io/velocity/getting-started/), [spark commands](https://spark.lucko.me/docs/Command-Usage), [backup lifecycle](https://github.com/itzg/docker-mc-backup), [Folia FAQ](https://docs.papermc.io/folia/faq/) |
| `minecraft-worldedit-ops` | Paste checks now preview the destination with `//paste -n` and matching placement flags before inspecting its size. Arena reset examples retain air when needed to remove old blocks. | [WorldEdit clipboard](https://worldedit.enginehub.org/en/latest/usage/clipboard/) |
| `minecraft-essentials-ops` | Added the documented unsupported-platform boundary, corrected jail permissions, and separated core mute handling from optional chat formatting. Exact server/build compatibility remains a prerequisite. | [EssentialsX 2.22.0](https://github.com/EssentialsX/Essentials/discussions/6552), [EssentialsX modules](https://essentialsx.net/wiki/modules) |
| `minecraft-imagegen` | Removed repeated prompt/workflow material and mandatory extra concept rounds. Uses actual host capability, the requested output, and verified save paths. Supporting recipes are conditional. | [OpenAI image generation](https://developers.openai.com/api/docs/guides/image-generation), [Claude vision](https://platform.claude.com/docs/en/build-with-claude/vision) |

Examples for Minecraft 26.x use Java 25. Older projects keep their existing
versions: Java 21 for 1.21.x and Java 17 for Forge 1.20.1.

## Checks

- Ran skill sync and repository checks for copied files, packaging, metadata,
  links, code examples, validators, workflow pins, and Markdown.
- Tested release scripts with missing and duplicate artifacts, existing tags,
  remote lookup failures, incorrect push URLs, and untracked files. Git responses
  were mocked; these tests did not publish anything.
- Tried command, datapack, image-tool availability, and version-selection tasks.
  The generated datapack passed its validator. These were limited spot checks.
- Checked the 1.21.5 biome example against Mojang's client JAR, SHA-1
  `b88808bbb3da8d9f453694b5d8f74a3396f1a533`.

No Minecraft, Paper, or Gradle runtime was launched. Builds, rendering, gameplay,
and server operations still need testing in the target project.

## Review fixes

- Kept the malformed animation fixture limited to its intended JSON error.
- Checked legacy GameTest template names and registration of the specific class.
- Added cases for missing implicit templates and registration of the wrong class.
- Connected the valid event fixture's listener to the mod event bus.
- Renamed a unit-test example to match what it actually tests.
- Labelled older modding references and linked current examples to the matching
  loader documentation.
