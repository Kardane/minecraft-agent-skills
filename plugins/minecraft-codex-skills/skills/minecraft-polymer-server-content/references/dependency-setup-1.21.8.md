# Polymer dependency setup for Minecraft 1.21.8

Baseline: Minecraft 1.21.8, Java 21, Polymer `0.13.13+1.21.8`.

Use `https://maven.nucleoid.xyz/` and group `eu.pb4`. Select only needed modules: `polymer-core`, `polymer-resource-pack`, `polymer-blocks`, `polymer-virtual-entity`, `polymer-networking`.

Keep one `polymer_version` property for the Polymer modules. `polymer-blocks` requires Core and Resource Pack in the intended integration.

Online latest docs may be newer than 0.13.13. For exact imports/signatures, inspect the resolved 0.13.13 jar/source and compile against it.

Typical Gradle shape:

```groovy
repositories {
    maven { url = 'https://maven.nucleoid.xyz/' }
}
dependencies {
    modImplementation include("eu.pb4:polymer-core:${project.polymer_version}")
}
```

Follow the project's existing packaging policy instead of changing external-vs-included Polymer deployment silently.
