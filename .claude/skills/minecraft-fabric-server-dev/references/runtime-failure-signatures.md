# 런타임 장애 시그니처 대응표

## NoSuchMethodError / ClassNotFoundException

먼저 resolved Minecraft/mappings/Loader/Fabric API와 실제 runtime jars를 비교한다. Polymer API에서 난 오류라면 `minecraft-polymer-server-content`로 넘겨 모든 Polymer module이 같은 pinned release인지 확인한다.

## InvalidInjectionException

Exact 1.21.8 target signature, injection point, require/priority/conflict를 확인한다.

## 기능 일부만 실패

Event/callback 등록, logical/physical side, permission/state precondition, Mixin apply, persistence/config state 순으로 좁힌다. Client projection만 깨졌고 Polymer를 사용한다면 Polymer specialist가 소유한다.

## 틱 지연

Blocking I/O, global scan, hot-path allocation/serialization, repetitive logging, unbounded queue/task, high-frequency Mixin/callback부터 profile한다.

## 15분 트리아지

1. 최근 code/dependency 변경
2. version keys
3. fabric.mod.json / mixin config
4. Mixin apply errors
5. server-thread/lifecycle/permission preconditions
6. narrow runtime smoke test
