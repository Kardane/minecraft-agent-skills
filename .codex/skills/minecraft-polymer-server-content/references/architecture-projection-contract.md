# Projection architecture contract

Use `domain state → custom server object → Polymer projection → client representation`.

Projection is not gameplay truth. Avoid blocking I/O, unsafe world mutation, shared mutable "current player" state, and hidden permission/economy mutations inside representation callbacks.

Polymer's official guidance warns that interacting code may execute from server, connection, or client-rendering contexts. Prefer immutable/read-only projection inputs and thread-safe caches.

Do not implement Polymer interfaces on vanilla Items/Blocks through Mixins, add custom BlockStates to non-Polymer vanilla blocks, or use registry replacement as a shortcut.

If output depends on player/client/resource-pack context, include all relevant context in cache keys and invalidate when authoritative inputs change.
