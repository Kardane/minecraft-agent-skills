# Gradle Publishing Reference

Use these snippets only for a project that has chosen the relevant publisher. Keep
its existing project IDs, artifact tasks, loader metadata, and release approval flow.
The examples target Minecraft Java 1.21.8 on Java 21.

## Release Version and Changelog

Keep the mod version distinct from the computed project/artifact version. This makes
`v1.2.3` a reliable tag for an artifact such as `1.2.3+1.21.8`.

```kotlin
val modVersion = providers.gradleProperty("mod_version").orNull
    ?: throw GradleException("mod_version is required")
val minecraftVersion = providers.gradleProperty("minecraft_version").orNull
    ?: throw GradleException("minecraft_version is required")

version = "${modVersion}+${minecraftVersion}"

fun changelogFor(releaseVersion: String): String {
    val changelog = rootProject.file("CHANGELOG.md").readText()
    val heading = "## [$releaseVersion]"
    val start = changelog.indexOf(heading)
    check(start >= 0) { "CHANGELOG.md is missing heading: $heading" }

    return changelog.substring(start + heading.length)
        .substringBefore("\n## [")
        .trim()
        .also { check(it.isNotBlank()) { "CHANGELOG.md section is empty: $heading" } }
}

tasks.register("verifyReleaseVersion") {
    group = "verification"
    doLast {
        val tagVersion = providers.gradleProperty("releaseModVersion").orNull
            ?: error("Pass -PreleaseModVersion=<version from v<version> tag>")
        check(tagVersion == modVersion) {
            "Tag version $tagVersion does not match mod_version=$modVersion"
        }
        changelogFor(tagVersion)
    }
}
```

Use a changelog heading such as `## [1.2.3] — 2026-09-04`. Do not look up a heading
from `project.version`, because it includes `+1.21.8`; `substringAfter` also must not
be used without an explicit missing-heading check because it can return the entire
file.

## Modrinth with Minotaur

The current Gradle Plugin Portal release is `com.modrinth.minotaur` `2.9.0`. For a Minecraft 1.21.8 Fabric Loom project, publish the remapped production artifact (`remapJar`) rather than the development `jar`. Confirm the task exists in the target project before wiring the publisher.

```kotlin
import net.fabricmc.loom.task.RemapJarTask

plugins {
    id("com.modrinth.minotaur") version "2.9.0"
}

val productionJar = tasks.named<RemapJarTask>("remapJar")

modrinth {
    token.set(providers.environmentVariable("MODRINTH_TOKEN"))
    projectId.set(providers.gradleProperty("modrinth_project_id"))
    versionNumber.set(version.toString())
    versionType.set("release")
    uploadFile.set(productionJar)
    gameVersions.add(minecraftVersion)
    loaders.add("fabric")
    changelog.set(changelogFor(modVersion))
}

tasks.named("modrinth") {
    dependsOn(tasks.named("verifyReleaseVersion"))
    dependsOn(productionJar)
}
```

Confirm that `remapJar` is the distributable artifact in the exact Fabric Loom project before changing publisher wiring.

## CurseForge with CurseForgeGradle

The current Gradle Plugin Portal release is
`net.darkhax.curseforgegradle` `1.3.33`. Only add this task for a project that
publishes to CurseForge.

```kotlin
import net.fabricmc.loom.task.RemapJarTask

plugins {
    id("net.darkhax.curseforgegradle") version "1.3.33"
}

val productionJar = tasks.named<RemapJarTask>("remapJar")

tasks.register<net.darkhax.curseforgegradle.TaskPublishCurseForge>("curseforge") {
    apiToken = providers.environmentVariable("CURSEFORGE_TOKEN").orNull ?: ""

    val mainFile = upload(
        providers.gradleProperty("curseforge_project_id").get(),
        productionJar
    )
    mainFile.changelogType = "markdown"
    mainFile.changelog = changelogFor(modVersion)
    mainFile.releaseType = "release"
    mainFile.addGameVersion(minecraftVersion)
    mainFile.addModLoader("Fabric")
    mainFile.addJavaVersion("Java 21")
    mainFile.addEnvironment("Client", "Server")
}

tasks.named("curseforge") {
    dependsOn(tasks.named("verifyReleaseVersion"))
    dependsOn(productionJar)
}
```

Set the actual loader and supported environments for the artifact. CurseForgeGradle
can infer loader, game, and Java metadata when the relevant project configuration is
present; explicit metadata is useful only when it matches the released JAR.

## Optional Combined Task

Only create a combined task when both publishers and all named platform tasks are
already configured in the project:

```kotlin
tasks.register("publishSelectedDestinations") {
    group = "publishing"
    dependsOn("modrinth", "curseforge")
}
```

Do not add missing publisher plugins, task dependencies, project IDs, or secrets just
to make this aggregation example apply. Invoke any publisher task with
`-PreleaseModVersion=<tag version>`: each configured publish task depends on
`verifyReleaseVersion`, so a missing tag version or mismatched changelog blocks the
upload before it reaches a publisher.
