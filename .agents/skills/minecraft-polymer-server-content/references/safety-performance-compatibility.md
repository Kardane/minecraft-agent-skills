# Polymer safety, performance, and compatibility

Keep `domain state → projection`, never the reverse.

Projection code should avoid blocking I/O, unsafe world mutation, shared mutable scratch state, and unnecessary allocation. Measure per-player fan-out, item/block conversion counts, entity metadata transforms, resource-pack generation, and virtual-entity update rate.

When server state is correct but representation is wrong, check: vanilla fallback representation, player/context branch, resource-pack acceptance, generated assets, stale caches, and exact 0.13.13 behavior.

When `NoSuchMethodError`/`ClassNotFoundException` appears, verify all Polymer modules resolve to the same pinned release.

A server-only PASS is not a vanilla-client compatibility PASS. Use `fabric-server-validation` for unmodified-client behavior and resource-pack/client-visible contracts.
