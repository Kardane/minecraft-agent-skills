---
name: minecraft-java-reference-hub
description: "Use Minecraft Java reference workflows for commands, NBT, item components, datapacks, resources, entities, and multiplayer operations. Use for version-sensitive questions; route Fabric code, mappings, Mixin targets, and runtime validation to specialist implementation and validation skills."
---

# Minecraft Java Reference Hub

## Routing Boundaries

- `Use when`: answering version-sensitive Minecraft Java domain, command, NBT, item-component, datapack, resource-pack, or multiplayer reference questions.
- `Do not use when`: modifying Fabric code, resolving mappings or Mixin targets, or running behavior validation.

이 스킬은 정보 나열 도구가 아니다. 버전-도메인-운영 리스크를 고정해서 바로 실행 가능한 답으로 내보내는 품질 게이트다.

## 언제 쓰는가

아래 중 하나라도 해당되면 이 스킬을 우선 적용한다.

1. 버전별 차이 때문에 답변 리스크가 있는 질문
2. 명령어/데이터팩/NBT/item component가 섞인 복합 질문
3. 멀티플레이어 서버 운영/성능/권한 이슈 질문
4. 단순 설명이 아니라 즉시 적용 가능한 절차가 필요한 질문

## Fabric 개발 작업과의 경계

이 스킬은 **Minecraft 도메인/버전 레퍼런스 허브**다. Fabric 저장소를 실제로 수정하거나 Minecraft 내부 구현을 추적하는 작업에서는 다음으로 넘긴다.

- 저장소 구현/리팩터링/배포: `minecraft-fabric-server-dev`
- 1.21.8 내부 클래스, 메서드, mapping, caller/callee, Mixin target: `minecraft-fabric-server-dev`의 mcdev-mcp 분석 절차
- 동작/회귀 검증 경로 선택: `fabric-server-validation`

즉 “명령/NBT/component 문법이 무엇인가?”는 이 스킬이 잘 맞고, “이 1.21.8 메서드에 어떤 Mixin을 걸고 어떻게 자동 검증할까?”는 Fabric 개발 스킬 체인으로 넘긴다.

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
