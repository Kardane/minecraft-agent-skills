# Polymer resource packs and AutoHost

Polymer Resource Pack owns generated-pack integration:

```text
assets → Polymer registration → pack build → delivery → projected visuals
```

Asset creation itself remains `minecraft-java-content-engineering`.

Decide whether missing/declined packs cause cosmetic degradation, a vanilla fallback, or a hard requirement. Do not claim "resource pack optional" when the selected textured-block/model strategy requires it.

Polymer AutoHost integration belongs here; DNS, reverse proxy, firewall, TLS, public ports, and service deployment belong to `minecraft-server-admin`.

Validate generated contents, version/hash changes, acceptance/fallback behavior, and actual vanilla-client results through `fabric-server-validation`.
