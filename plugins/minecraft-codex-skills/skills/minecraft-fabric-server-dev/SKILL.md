---
name: minecraft-fabric-server-dev
description: "Minecraft Java Edition 1.21.8 Fabric 서버사이드 Java 코드를 official Mojang mappings 기준으로 설계, 구현, 디버깅하고 로컬 artifact를 빌드할 때 사용한다. 서버 권한/상태, networking, lifecycle/threading, persistence/config, commands/permissions, performance를 우선하며 Mixin은 필요할 때만 사용한다."
---

# Minecraft Fabric Server Dev

## Routing Boundaries

- `Use when`: designing, implementing, debugging, or locally building Fabric server-side Java code, Fabric API integrations, Mixin, mappings, or Minecraft internals.
- `Primary capabilities`: `fabric-java-implementation`, `fabric-internals-mapping`, `fabric-local-build`
- `Do not use when`: behavior validation is the primary task (`fabric-server-validation`), the task is CI/tag/publishing/release automation (`minecraft-ci-release`), the task is worldgen data/schema work without Java integration (`minecraft-java-content-engineering`), WorldEdit API/Region/Mask/Pattern/EditSession integration is the primary problem (`minecraft-worldedit-engineering`), Polymer projection/server-content integration is the primary problem (`minecraft-polymer-server-content`), the work is client-rendering-only, or the project uses a non-Fabric loader.

이 스킬은 "돌아가기만 하는 모드"가 아니라, 운영 서버에서 장애 없이 굴러가는 서버사이드 Fabric 모드를 만드는 실무용 표준이다.

## 적용 범위

- Minecraft Java Edition `1.21.8`
- Fabric Loader + Fabric API
- 서버 권한 모델, lifecycle/events, tick/thread affinity
- custom payload networking과 C2S trust boundary
- persistent state, serialization, config/reload boundary
- Brigadier command registration과 permission gate
- tick hot-path / allocation / I/O 성능 설계
- 필요한 경우에만 Mixin 런타임 주입
- WSL/Linux 셸(`.sh`) 기준 자동화

## 빠른 시작

1. 새 프로젝트 생성
`./scripts/new-fabric-server-mod.sh -ProjectName <name> -PackageBase <pkg> -OutputDir <path>`

   기본 scaffold는 Fabric API만 사용한다. 실제 요구사항이 있을 때만 `--with-mixin`을 추가한다. Polymer가 필요하면 `minecraft-polymer-server-content`로 위임한다.

2. 생성 직후 정합성 검증
`./scripts/verify-mod-env.sh -ProjectDir <path>/<name>`

3. Minecraft 내부 구현, lifecycle, Mixin target이 불확실하면 **내장 mcdev-mcp 소스 분석 절차**를 먼저 수행한다. `references/mcdev-source-analysis.md`와 `references/mcdev-query-playbook.md`를 필요한 범위만 읽는다.

4. placeholder 버전을 치환한다. 이 scaffold는 Gradle wrapper 바이너리를 임의 생성하지 않는다. `gradlew`가 없으면 공식 Fabric 템플릿의 version-matched wrapper를 가져오거나 신뢰할 수 있는 로컬 Gradle로 wrapper를 먼저 생성한다. wrapper가 준비된 뒤 `./gradlew clean build`를 실행한다.

5. 런타임/행동 검증은 `fabric-server-validation`에 위임. 기본적으로 GUI/Computer Use보다 GameTest 또는 MCP Fabric + Carpet 상태 검증을 우선

## 실무 워크플로우

### 1) 요구사항과 데이터 경계 잠금

- authoritative state가 무엇인지 먼저 정한다: world/player/server/transient/config.
- 외부 입력 경계를 식별한다: command, C2S payload, config reload, filesystem, admin operation.
- 핵심 기능을 분류한다: lifecycle/event, networking, persistence, command/permission, worldgen integration, client projection.
- 위험도는 편의/진행/경제·전투처럼 상태 손실·권한 상승·악용 가능성 기준으로 분류한다.

### 2) 버전 잠금

- Java Toolchain: `21`
- Minecraft: `1.21.8`
- Fabric API/Loader: `1.21.8` 호환 안정 버전으로 고정
- Development mapping namespace: **official Mojang mappings** via `mappings loom.officialMojangMappings()`
- Yarn mapping dependency/property를 추가하지 않는다.
- 버전 변경은 한 축씩만 수행하고 매번 서버 기동 검증

### 3) 아키텍처 잠금

우선순위는 다음과 같다.

1. **서버 권위**: gameplay truth는 logical server가 소유한다. 클라이언트 입력은 요청이지 사실이 아니다.
2. **Fabric event/callback**: lifecycle/event hook으로 해결할 수 있으면 먼저 사용한다.
3. **thread affinity**: Minecraft world/entity/registry 상태 변경은 서버 스레드 경계를 보존한다.
4. **명시적 persistence/config**: transient state, 저장 상태, 운영 config를 서로 다른 수명 주기로 관리한다.
5. **bounded hot path**: tick마다 전역 스캔, blocking I/O, 무제한 allocation/queue를 만들지 않는다.
6. **Mixin**: Fabric API/event/callback로 요구사항을 충족할 수 없을 때만 최소 범위로 추가한다.
7. **Polymer handoff**: 바닐라 클라이언트 projection이 핵심이면 `minecraft-polymer-server-content`에 위임한다.

책임이 생기기 전에는 빈 service/bridge 계층이나 확장 포인트를 미리 만들지 않는다.

### 4) 구현 루프

1. authoritative state와 외부 입력을 분리한다.
2. lifecycle/event/command/network entrypoint를 Fabric API로 연결한다.
3. C2S/command/config 입력을 서버에서 검증하고 permission/state/rate boundary를 건다.
4. 저장이 필요한 상태는 serializer와 schema/migration 정책을 먼저 정한 뒤 persistence에 연결한다.
5. blocking I/O나 비싼 계산은 tick hot path에서 분리하고, Minecraft 객체 접근은 서버 스레드로 되돌린다.
6. Minecraft 내부 메서드/호출 순서가 불확실할 때만 mcdev-mcp로 exact 1.21.8 class/method/caller/callee를 확인한다.
7. Fabric API로 부족할 때만 최소 Mixin을 추가한다. Polymer projection 구현은 `minecraft-polymer-server-content`에 위임한다.
8. `fabric-server-validation`로 가장 싼 충분한 행동 증거를 만든다.
9. representative load에서 로그/프로파일을 확인한 뒤 다음 기능으로 이동한다.

### 5) 검증 루프

- 구조 검증: `verify-mod-env.sh`
- 빌드 검증: `./gradlew clean build`
- 행동/런타임 검증: `fabric-server-validation`에 위임
- 기본 우선순위: Unit/JUnit → Server GameTest → MCP Fabric + Carpet runtime harness → 실제 network contract가 필요할 때 Mineflayer → 필요한 경우에만 client/vanilla gate
- 안정성 검증: 반복 틱/다중 플레이어/예외 흐름
- 컴파일/서버 기동 성공만으로 인게임 동작 PASS를 선언하지 않는다.

### 6) 로컬 아티팩트 handoff

- 로컬 production artifact의 이름/버전/의존성 메타가 맞는지 확인한다.
- 실제 CI workflow, tag 검증, GitHub Release, Modrinth/CurseForge publishing은 `minecraft-ci-release`에 위임한다.
- 행동 검증과 호환성 증거는 `fabric-server-validation`에 위임한다.

## 스크립트 계약 (WSL/Linux)

### `scripts/new-fabric-server-mod.sh`

- 목적: 1.21.8 서버사이드 모드 스캐폴드 생성
- 기본 계약:
  - `-ProjectName <name>` 또는 `--project-name <name>`
  - `-PackageBase <pkg>` 또는 `--package-base <pkg>`
  - `-OutputDir <path>` 또는 `--output-dir <path>`
- 확장 옵션:
  - `--mod-id <id>`
  - `--loader-version <ver>`
  - `--fabric-api-version <ver>`
  - `--with-mixin` — Mixin config를 opt-in으로 생성

생성 결과:
- 항상: `gradle.properties`, `build.gradle`, `settings.gradle`, `fabric.mod.json`, 최소 `MainMod`
- `--with-mixin`: 빈 Mixin config를 추가하고 실제 target mixin은 요구사항이 생겼을 때 작성
- Gradle wrapper는 생성하지 않는다. 공식 Fabric 템플릿의 1.21.8 wrapper를 사용하거나 로컬 Gradle로 생성한 뒤 커밋한다.

### `scripts/verify-mod-env.sh`

- 목적: 구조/메타/버전/서버 전용 규칙 검증
- 계약:
  - `-ProjectDir <path>` 또는 `--project-dir <path>`
- 주요 검사:
  - 필수 파일/디렉터리 존재
  - `minecraft_version=1.21.8`, Java 21, Fabric Loader/API 버전 키 존재
  - `build.gradle`이 `mappings loom.officialMojangMappings()`를 사용하고 Yarn dependency/property가 없음
  - `fabric.mod.json` JSON 파싱 + `environment=server`
  - Mixin이 선언된 경우에만 config 존재/JSON 구조 검증
  - Gradle wrapper: 전체가 없으면 bootstrap 필요 경고, 일부만 존재하면 실패
  - 클라이언트 전용 import 사용 탐지(경고)
  - placeholder 미치환 값 탐지(경고)

## 스킬 경계와 내부 백엔드

이 스킬은 **Fabric 구현 관제탑**이다. 별도의 source-analysis 스킬을 선택하게 하지 않고 mcdev-mcp 분석을 이 스킬 내부 절차로 수행한다. 행동 검증 정책만 `fabric-server-validation`에 위임한다.

| 상황 | 처리 위치 |
|---|---|
| Minecraft 1.21.8 클래스/메서드/field/call graph/Mixin target 분석 | 이 스킬 내부 mcdev-mcp 절차 |
| 변경 사항의 행동/런타임 검증 | `fabric-server-validation` |
| `.dat`/`.mca` 오프라인 월드 데이터 검사/수정 | `minecraft-java-world-nbt` |
| 데이터팩/리소스팩 제작 | `minecraft-java-content-engineering` |
| worldgen JSON/registry graph/schema 설계 | `minecraft-java-content-engineering` |
| WorldEdit API 기반 대규모/조건부 live-world 편집 | `minecraft-worldedit-engineering` |
| Polymer item/block/entity projection, generated resource pack, virtual entity | `minecraft-polymer-server-content` |
| CI/tag/release/publishing 자동화 | `minecraft-ci-release` |

일반적인 수정 루프:

```text
repo inspect
→ 필요 시 mcdev-mcp source/call-graph 분석
→ production code 최소 수정
→ fabric-server-validation
   ├─ Unit / Server GameTest
   ├─ MCP Fabric + Carpet fake player
   ├─ Mineflayer protocol E2E
   └─ higher-fidelity client/vanilla/packet gate when justified
→ broader regression/build
→ evidence report
```

테스트 정책의 단일 source of truth는 `fabric-server-validation`이다. GameTest, MCP Fabric, Carpet, Mineflayer를 별도 활성 Skill로 분리하지 않는다.

## 문제 대응 우선순위

1. 권한 상승/중복 지급/상태 손실이면 authoritative state와 입력 검증부터 확인한다.
2. 동기화 문제면 server state → tracking/send → client observation 순서로 좁힌다.
3. tick lag면 blocking I/O, 전역 스캔, allocation, queue growth, 반복 serialization부터 확인한다.
4. 재시작 후 손실/오염이면 persistence ownership, dirty marking, schema migration, config reload 경계를 확인한다.
5. 빌드/기동 실패면 버전 키, official Mojang mappings 설정, entrypoint, dependency, metadata를 확인한다.
6. 그 다음에만 Mixin target/충돌을 조사한다. Polymer projection 문제는 `minecraft-polymer-server-content`에 위임한다.

## Production engineering rules

### Server authority and trust

- client payload, command argument, config file 값은 모두 외부 입력으로 취급한다.
- player identity/permission은 payload가 주장한 값을 믿지 말고 server context에서 가져온다.
- 경제·전투·인벤토리 변경은 현재 server state를 다시 확인한 뒤 적용한다.
- 반복 요청이 가능한 경로에는 rate/duplicate/idempotency 전략을 둔다.

### Lifecycle and threading

- event/callback이 있으면 polling tick보다 먼저 사용한다.
- world/entity/registry mutation은 logical server thread affinity를 유지한다.
- filesystem/database/HTTP 같은 blocking I/O를 tick callback이나 packet handler에서 직접 기다리지 않는다.
- worker thread에는 immutable snapshot 또는 primitive DTO만 넘기고 결과 적용은 server thread로 복귀한다.
- shutdown/reload 시 executor, queue, listener, cached state의 종료/교체 경계를 명시한다.

### Persistence and config

- transient cache, persistent gameplay state, operator config를 같은 객체 수명으로 섞지 않는다.
- persistent state는 serializer와 schema version/migration 정책을 함께 정의한다.
- 상태 변경 뒤 저장 dirty contract를 빠뜨리지 않는다.
- config reload는 parse → validate → immutable snapshot 교체 순서로 처리한다.
- registry/mapping/packet codec처럼 startup-time contract를 바꾸는 옵션은 무리하게 hot reload하지 않는다.

### Commands and permissions

- command 등록은 Fabric command callback을 우선한다.
- Brigadier `requires` 또는 프로젝트의 permission integration으로 실행 권한과 tab exposure를 같이 제한한다.
- command argument는 permission을 통과한 뒤에도 range, target existence, current state를 검증한다.
- 동일한 domain operation을 command와 network handler가 각각 재구현하지 말고 검증된 server-side operation으로 모은다.

### Performance

- 20 TPS의 정상 tick budget은 50 ms이므로 hot path에서 무제한 작업을 만들지 않는다.
- 매 tick 모든 player/entity/chunk를 훑기보다 event-driven index, dirty set, bounded cadence를 우선한다.
- packet fan-out과 serialization 빈도를 state change 기준으로 제한한다.
- 최적화는 profile/representative load evidence 뒤에 한다. 단순히 async로 옮겼다는 이유로 빨라졌다고 간주하지 않는다.

### Mixin and specialist boundaries

- Mixin은 public/event API로 해결되지 않는 정확한 gap을 설명할 수 있을 때만 사용한다.
- Polymer projection은 `minecraft-polymer-server-content`에 위임한다.
- Mixin은 core server rule의 기본 저장소나 permission boundary가 되어서는 안 된다.

### Simplicity gate

- 로직/검증/변환/ownership을 추가하지 않는 pass-through wrapper는 만들지 않는다.
- 확장 요구가 없는 interface/strategy/factory를 선제적으로 추가하지 않는다.
- 구조 변경 뒤에는 구 참조를 검색하고 최소 test/build를 실행한다.

## 참조 문서 인덱스

핵심 server engineering reference를 먼저 고르고, Mixin 문서는 실제 필요가 있을 때만 연다.

- Networking/C2S trust/rate boundary: [references/server-networking-security.md](references/server-networking-security.md)
- Lifecycle/thread affinity/async I/O: [references/server-lifecycle-threading.md](references/server-lifecycle-threading.md)
- Persistent state/config/reload: [references/state-config-reload.md](references/state-config-reload.md)
- Commands/permissions/hot-path performance: [references/commands-permissions-performance.md](references/commands-permissions-performance.md)
- Minecraft 1.21.8 소스/call graph + Mojang namespace 분석: [references/mcdev-source-analysis.md](references/mcdev-source-analysis.md)
- mcdev-mcp 질의 패턴: [references/mcdev-query-playbook.md](references/mcdev-query-playbook.md)
- Fabric 설정/버전 전략: [references/fabric-setup-1.21.8.md](references/fabric-setup-1.21.8.md)
- Mixin 패턴/충돌 해소: [references/mixin-patterns.md](references/mixin-patterns.md)
- Polymer server-content/projection: `minecraft-polymer-server-content`
- 검증 체크리스트: [references/verification-release-checklist.md](references/verification-release-checklist.md)
- 운영 장애 시그니처: [references/runtime-failure-signatures.md](references/runtime-failure-signatures.md)

## 출력 템플릿

```markdown
기준 버전: Java 1.21.8 / JDK 21

요약
- 목표: ...
- 범위: lifecycle | networking | state | config | command | permission | performance | mixin

구현 단계
1. ...
2. ...
3. ...

검증
- 구조 검증: PASS|FAIL
- 빌드 검증: PASS|FAIL
- 런타임 검증: PASS|FAIL

리스크
- 낮음|중간|높음: ...
```
