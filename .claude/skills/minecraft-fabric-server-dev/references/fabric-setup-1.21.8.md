# Fabric 서버사이드 환경 설정 (Java 1.21.8)

## 고정 baseline

- Minecraft: `1.21.8`
- Java: `21`
- Dedicated Server 우선
- Development mapping namespace: **official Mojang mappings**
- Gradle mapping declaration: `mappings loom.officialMojangMappings()`

이 skill은 Yarn을 baseline으로 사용하지 않는다. 프로젝트에 `yarn_mappings` property나 `net.fabricmc:yarn` dependency를 추가하지 않는다.

## Gradle 기준

```groovy
dependencies {
    minecraft "com.mojang:minecraft:${project.minecraft_version}"
    mappings loom.officialMojangMappings()

    modImplementation "net.fabricmc:fabric-loader:${project.loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:${project.fabric_api_version}"
}
```

`gradle.properties`에는 mapping version key가 필요하지 않다.

```properties
minecraft_version=1.21.8
loader_version=<compatible>
fabric_api_version=<compatible>
```

Mojang mappings는 공식 이름을 제공하지만 Yarn Javadocs/이름과 동일하지 않다. 오래된 Fabric/Yarn 예제에서 `ServerPlayerEntity`, `Identifier` 같은 Yarn symbol을 그대로 복사하지 말고, 현재 1.21.8 Mojang-mapped source/IDE/mcdev evidence에서 해당 symbol을 다시 확인한다.

## Mixin 기준

Mixin target class/method/descriptor를 문서나 오래된 Yarn 이름으로 추측하지 않는다.

1. exact Minecraft 1.21.8 source를 찾는다.
2. repository namespace가 Mojang mappings임을 확인한다.
3. source-analysis 결과가 다른 namespace라면 Mojang 이름으로 변환한다.
4. target descriptor/injection point를 확인한다.
5. compile + relevant GameTest/runtime validation을 수행한다.

## Generic scaffold

Generic Fabric scaffold는 Fabric Loader/API와 선택적 Mixin까지만 소유한다. Polymer dependency/module/projection은 `minecraft-polymer-server-content`가 소유한다.

초기 검증:

1. `verify-mod-env.sh`
2. `./gradlew clean build`
3. dedicated server boot
4. Mixin/entrypoint logs
5. `fabric-server-validation` runtime evidence

## Mapping migration boundary

기존 Yarn 프로젝트를 이 baseline으로 옮기는 작업은 단순 import 검색/치환이 아니다. Loom mapping migration 또는 IDE-supported migration을 사용한 뒤 Mixins와 version-sensitive symbols를 수동 검토한다.

이 skill에서 새 프로젝트를 scaffold할 때는 처음부터 Mojang mappings를 사용한다.

## Sources

- https://wiki.fabricmc.net/tutorial:mappings
- https://docs.fabricmc.net/develop/loom/options
- https://docs.fabricmc.net/develop/porting/mappings/
