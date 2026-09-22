# Fabric 1.21.8 Server Networking and Trust Boundaries

Use this reference when a Fabric server mod receives client payloads, sends custom
payloads, or exposes an action that can be triggered repeatedly over the network.

## Version rule

Treat the target project's pinned Fabric API as authoritative. Fabric networking
names have changed across Minecraft lines. For the 1.21.8 line, verify the exact
project API/Javadocs before copying a signature.

Useful primary references:

- https://maven.fabricmc.net/docs/fabric-api-0.136.0+1.21.8/
- https://docs.fabricmc.net/develop/networking

## Server-authoritative contract

A C2S payload is a request. It must not be the source of truth for:

- player identity or permission;
- inventory ownership or balances;
- world position when the server can derive it;
- cooldown completion;
- target existence/visibility;
- progression or combat eligibility.

Read identity and authoritative state from the server networking context and current
world state.

## C2S validation order

For each serverbound action:

1. Decode only the bounded fields required by the operation.
2. Resolve the player from the server context.
3. Check permission/role.
4. Validate numeric/string/list bounds.
5. Resolve ids to current server objects.
6. Validate proximity, ownership, dimension, lifecycle, cooldown, or other state
   preconditions.
7. Apply one server-side domain operation.
8. Persist/mark dirty if the operation changes durable state.
9. Send only the resulting state needed by clients.

Do not scatter the same checks across command, packet, and GUI paths. Put the
domain mutation behind one server-side operation and make every entrypoint call it.

## Abuse and replay

Add a rate boundary when the action is cheap to send but expensive to process.

Choose the simplest control that fits the contract:

- per-player cooldown for interactive actions;
- bounded token/window rate limit for bursty requests;
- request id / idempotency key when retries can duplicate economic mutations;
- bounded collection sizes and maximum encoded string lengths.

A rate limiter is not a substitute for permission or state validation.

## S2C design

Prefer sending compact semantic state over internal object dumps. Avoid sending
secrets, operator-only config, filesystem paths, or implementation details that are
not part of the client contract.

Before sending an optional custom payload, verify that the target connection can
receive it when the chosen Fabric API exposes a capability check.

## Threading

Use the exact Fabric API documentation for the selected networking handler. The
packet-object server handler in the 1.21-era API is designed for server-side
handling, but do not generalize a thread guarantee from an unrelated API or older
example.

Even when the callback is on the logical server thread:

- do not block on filesystem/database/HTTP operations;
- do not perform unbounded scans from a client-triggered callback;
- hand expensive pure computation to a bounded worker only when worthwhile;
- apply Minecraft state changes back on the server thread.

## Failure policy

Reject malformed or unauthorized requests without partially mutating state. Log
enough structured context to diagnose abuse, but do not log authentication/session
material or arbitrary payload bytes.

Validation evidence belongs to `fabric-server-validation`.
