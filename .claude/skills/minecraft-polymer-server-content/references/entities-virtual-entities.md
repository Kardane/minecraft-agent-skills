# Polymer entities and virtual entities

Use a real custom entity plus Polymer projection when the server needs normal Entity lifecycle, persistence, AI/gameplay, collision/damage, equipment, or tracking.

Keep the projected vanilla entity type compatible with emitted tracked data. Verify exact 0.13.13 registration/helper signatures from the resolved artifact.

Use `polymer-virtual-entity` for display labels, decorations, packet-only composites, visual children, and other presentation that does not need full server Entity semantics.

Every virtual create/attach path needs a viewer/owner/chunk unload cleanup path. Bound element count, update frequency, and per-player fan-out.
