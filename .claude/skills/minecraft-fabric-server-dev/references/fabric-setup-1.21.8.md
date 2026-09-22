# Fabric 서버사이드 환경 설정 (Java 1.21.8)

- Minecraft: `1.21.8`
- Java: `21`
- Dedicated Server 우선

Generic Fabric scaffold는 Fabric Loader/API와 선택적 Mixin까지만 소유한다. Polymer dependency/module/projection은 `minecraft-polymer-server-content`가 소유한다.

권장 version keys:

```properties
minecraft_version=1.21.8
yarn_mappings=1.21.8+build.1
loader_version=<compatible>
fabric_api_version=<compatible>
```

Gradle에는 Fabric Loom, Minecraft, mappings, Loader, Fabric API, Java 21 toolchain을 둔다. Polymer가 필요하면 generic scaffold에 임의로 `polymer-core`를 추가하지 말고 specialist의 dependency guide와 verifier를 사용한다.

초기 검증:

1. `verify-mod-env.sh`
2. `./gradlew clean build`
3. dedicated server boot
4. Mixin/entrypoint logs
5. `fabric-server-validation` runtime evidence
