---
name: minecraft-polymer-server-content
description: "Minecraft Java 1.21.8 Fabric에서 Polymer 0.13.13+1.21.8로 custom item/block/entity를 vanilla-client 표현으로 투영하고 generated resource pack, virtual entity, Polymer networking을 통합할 때 사용한다. 일반 Fabric 로직, asset 제작, 호환성 검증은 specialist에 위임한다."
---

# Minecraft Polymer Server Content

## Routing Boundaries

- `Use when`: Polymer is the primary mechanism for server-side custom item/block/entity projection, generated resource packs, textured blocks, virtual entities, or Polymer-specific networking.
- `Primary capabilities`: `polymer-server-content`
- `Do not use when`: ordinary Fabric gameplay/domain implementation has no Polymer projection (`minecraft-fabric-server-dev`), asset authoring itself (`minecraft-java-content-engineering`), behavior/vanilla-client proof (`fabric-server-validation`), or proxy/firewall/deployment work (`minecraft-server-admin`).

Polymer is a **projection layer over authoritative server content**. Keep gameplay truth on the server and derive the vanilla-client representation from it.

## Baseline

- Minecraft Java Edition: `1.21.8`
- Java: `21`
- Fabric
- Polymer: `0.13.13+1.21.8`

Use the exact resolved 0.13.13 artifacts/source for signatures. Polymer's online latest docs can be newer than this baseline.

## Architecture

```text
authoritative Fabric domain state
→ real custom registry object / server behavior
→ Polymer projection
   ├─ item
   ├─ block
   ├─ entity
   ├─ generated resource pack
   └─ virtual entity when presentation-only semantics fit
→ vanilla client
```

Rules:

1. Real server content/state remains authoritative.
2. Projection callbacks should be read-only/pure where practical.
3. Do not hide gameplay mutation, permission checks, persistence, or economy rules inside projection callbacks.
4. Treat projection code as thread-sensitive; do not assume every callback runs only on the main server thread.
5. Do not add Polymer interfaces to vanilla items/blocks through Mixins or use registry replacement as a shortcut.
6. Use the smallest Polymer module set required by the feature.

## Module selection

- `polymer-core`: item/block/entity projection.
- `polymer-resource-pack`: generated pack integration.
- `polymer-blocks`: textured custom blocks; use with Core + Resource Pack.
- `polymer-virtual-entity`: packet-only/display-oriented entities.
- `polymer-networking`: Polymer-specific capability/synchronization APIs.
- AutoHost: generated-pack delivery when Polymer-managed hosting is desired.

Read [dependency-setup-1.21.8.md](references/dependency-setup-1.21.8.md) before changing Gradle.

## Items and blocks

Read [items-blocks.md](references/items-blocks.md).

- Server `ItemStack` and client-projected stack are different concerns.
- Keep real item/block registration and server components authoritative.
- A Polymer block's real state and client-visible state may differ.
- Textured blocks are a resource-pack + carrier-state problem, not just a block registration problem.

## Entities and virtual entities

Read [entities-virtual-entities.md](references/entities-virtual-entities.md).

- real custom entity + Polymer representation: use when gameplay lifecycle/state is a real Entity;
- virtual entity: use for display/packet-only presentation that does not need full authoritative Entity semantics.

Do not use virtual entities to avoid modeling gameplay state the server actually needs.

## Resource packs

Read [resource-pack-autohost.md](references/resource-pack-autohost.md).

Polymer owns integration with generated packs. Asset creation remains in `minecraft-java-content-engineering`; raster creation may use `minecraft-imagegen`. Reverse proxy/firewall/public-port deployment belongs to `minecraft-server-admin`.

## Networking

Read [networking.md](references/networking.md).

- ordinary Fabric C2S/S2C application protocol → `minecraft-fabric-server-dev`;
- Polymer-specific capability/context/synchronization → this skill.

Client capability is never authority.

## Validation

A correct Polymer implementation does not prove vanilla-client compatibility.

```text
compile + dedicated-server boot
→ authoritative server-state checks
→ Polymer projection smoke check
→ fabric-server-validation
→ unmodified vanilla-client gate when promised
```

Run the static integration checker:

```bash
<skill-dir>/scripts/verify-polymer-integration.sh --project-dir .
```

## Reference loading guide

- setup/modules: [dependency-setup-1.21.8.md](references/dependency-setup-1.21.8.md)
- ownership/threading: [architecture-projection-contract.md](references/architecture-projection-contract.md)
- items/blocks: [items-blocks.md](references/items-blocks.md)
- entities/virtual entities: [entities-virtual-entities.md](references/entities-virtual-entities.md)
- resource packs/AutoHost: [resource-pack-autohost.md](references/resource-pack-autohost.md)
- networking: [networking.md](references/networking.md)
- safety/performance/compatibility: [safety-performance-compatibility.md](references/safety-performance-compatibility.md)

## Sources

- https://polymer.pb4.eu/latest/
- https://polymer.pb4.eu/latest/polymer-core/getting-started/
- https://modrinth.com/mod/polymer/version/0.13.13+1.21.8
