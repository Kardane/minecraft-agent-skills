---
name: minecraft-java-reference-hub
description: "Answer read-only Minecraft Java 1.21.8 reference questions that genuinely span multiple domains or do not have a narrower specialist owner. Command-only, worldgen-only, pack-authoring, server-ops, Fabric-code, validation, offline-world-data, and image tasks route to their specialist skills."
---

# Minecraft Java Reference Hub

## Routing Boundaries

- `Use when`: answering a read-only Minecraft Java 1.21.8 reference question that spans multiple domains, or synthesizing relationships between domains when no narrower specialist owns the whole question.
- `Primary capabilities`: `cross-domain-reference`
- `Do not use when`: the question is command-only (`minecraft-commands-scripting`), worldgen-only (`minecraft-world-generation`), complete datapack/resource-pack authoring (`minecraft-java-content-engineering`), Fabric code/internals (`minecraft-fabric-server-dev`), Fabric behavior validation, live server operations, offline world NBT editing, or raster image generation.

이 스킬은 정보 나열 도구가 아니다. 버전-도메인-운영 리스크를 고정해서 바로 실행 가능한 답으로 내보내는 품질 게이트다.

## 언제 쓰는가

이 스킬은 **fallback reference synthesizer**다. 다음 경우에만 primary로 선택한다.

1. 1.21.8의 여러 도메인(예: item component + advancement + resource-pack 표현)을 함께 설명해야 하지만 실제 파일/코드 구현은 요청되지 않은 경우.
2. 단일 specialist의 경계를 넘어서는 읽기 전용 개념/호환성 설명이 필요한 경우.

질문이 한 도메인으로 좁혀지면 commands, worldgen, content, server-admin, world-nbt 등 더 좁은 specialist를 먼저 사용한다.

## Fabric 개발 작업과의 경계

이 스킬은 **Minecraft 도메인/버전 레퍼런스 허브**다. Fabric 저장소를 실제로 수정하거나 Minecraft 내부 구현을 추적하는 작업에서는 다음으로 넘긴다.

- Fabric 저장소 구현/리팩터링/로컬 빌드: `minecraft-fabric-server-dev`
- 1.21.8 내부 클래스, 메서드, mapping, caller/callee, Mixin target: `minecraft-fabric-server-dev`
- 동작/회귀 검증 경로 선택: `fabric-server-validation`
- 명령 문법/selector/scoreboard: `minecraft-commands-scripting`
- worldgen data/schema/registry graph: `minecraft-world-generation`
- 완성형 datapack/resource-pack 제작: `minecraft-java-content-engineering`
- RCON/백업/배포/운영: `minecraft-server-admin`
- CI/tag/publishing: `minecraft-ci-release`
- offline `.dat`/`.mca`: `minecraft-java-world-nbt`

즉 단일 도메인 질문은 해당 specialist가 primary이고, 이 허브는 여러 도메인을 가로지르는 읽기 전용 synthesis에만 primary가 된다.

## 입력 잠금 규칙 (필수)

1. 기준 버전은 `1.21.8`로 고정한다. 다른 버전 문법을 혼합하지 않는다.
2. 질문을 2개 이하 도메인으로 분해한다.
3. 운영 영향이 있으면 위험도(낮음/중간/높음)를 먼저 적는다.
4. 모호하면 추측하지 말고 검증 절차를 같이 준다.

## 처리 파이프라인

### 1) 버전 잠금

- 기준은 `1.21.8`: [references/minecraft-je-1.21.8.md](references/minecraft-je-1.21.8.md)
- 다른 Minecraft 버전의 예시나 문법은 이 번들의 기준 답변에 혼합하지 않는다.

### 2) 도메인 분해

도메인 묶음:
- 데이터 정의: 블록, 아이템, 엔티티, NBT, item component, 마법부여, 상태 효과, 피해 종류, 생물군계, 구조물, 차원
- 시스템 설계: 발전과제, 스코어보드, 명령어, 게임 규칙, 게임 모드, 플레이어, 조작법
- 콘텐츠/배포: 루트 테이블, 다이얼로그, 데이터팩, 리소스팩, 멀티플레이어 서버

복합 설계가 필요하면: [references/domain-integration-playbooks.md](references/domain-integration-playbooks.md)

### 3) 운영 출력 계약

출력 모드는 3개로 고정한다.

1. 빠른 답변 모드
- 기준 버전
- 핵심 답
- 최소 실행 예시 1개
- 검증 포인트

1. 구현 레시피 모드
- 목표/제약
- 단계별 구현
- 실패 패턴
- 테스트 체크리스트

1. 운영 대응 모드
- 증상 분류
- 원인 가설(우선순위)
- 진단 순서
- 즉시 완화 + 근본 개선 + 롤백

운영/장애 플레이북은 [references/multiplayer-ops-troubleshooting.md](references/multiplayer-ops-troubleshooting.md) 사용.

## 품질 게이트

답변 제출 전 아래를 모두 통과시킨다.

1. 첫 줄에 기준 버전이 있는가
2. 도메인 경계가 명확한가
3. 실행 예시가 있는가
4. 검증 포인트가 있는가
5. 리스크가 있는 경우 완화책이 있는가
6. 운영 질문이면 롤백이 있는가

자동 점검 도구:
- `scripts/validate-reference-answer.sh --file <markdown>`

## WSL 스크립트

### `scripts/classify-mc-query.sh`

질문 텍스트를 `모드 + 도메인 태그`로 1차 분류한다.

```bash
./scripts/classify-mc-query.sh --query "1.21.8 서버에서 스코어보드랑 advancement 연동해줘"
```

### `scripts/validate-reference-answer.sh`

작성한 답변 초안이 기본 출력 계약을 만족하는지 검사한다.

```bash
./scripts/validate-reference-answer.sh --file /tmp/answer.md
```

## 금지사항

1. 버전 미확정 상태에서 문법을 단정하지 않는다.
2. 데이터팩 로직과 리소스팩 시각 변경을 한 단위로 섞지 않는다.
3. 전역 대상 명령(`@a`, `@e`)을 안전장치 없이 권장하지 않는다.
4. 멀티 서버 질문에서 권한/백업/롤백을 누락하지 않는다.

## 표준 출력 템플릿

```markdown
기준 버전: Java Edition <version>

요약
- 목표: ...
- 범위: ...

구현/설정
1. ...
2. ...
3. ...

검증
- 명령: ...
- 파일: ...
- 로그: ...

리스크
- 낮음|중간|높음: ...
```
