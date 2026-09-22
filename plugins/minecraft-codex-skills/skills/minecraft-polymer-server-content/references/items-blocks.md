# Polymer items and blocks

## Items

Keep authoritative server `ItemStack` separate from client projection. Register the real item normally, implement the 0.13.13-compatible Polymer item contract, choose a safe vanilla representation, and add generated-pack model data only when needed.

Do not mutate the authoritative stack merely to prepare outbound representation.

## Blocks

Register the real custom block, then map relevant authoritative BlockStates to client-safe states. Treat block-entity visibility, collision/interaction, light behavior, and client-side state recalculation as separate compatibility concerns.

## Textured blocks

Use `polymer-blocks` with `polymer-core` and `polymer-resource-pack`. Carrier-state space is finite; do not assume unlimited distinct textured states.

Asset authoring belongs to `minecraft-java-content-engineering`; Polymer binding/projection belongs here.
