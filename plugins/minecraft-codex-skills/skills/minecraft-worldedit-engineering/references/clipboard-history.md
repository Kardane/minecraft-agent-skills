# Clipboard, schematic, transforms, and history

## Clipboard workflow

Use WorldEdit's clipboard/operation model for reusable structures.

```text
source Region or schematic
→ Clipboard
→ optional transform
→ destination
→ paste operation
→ EditSession
→ verify
```

Keep file I/O and world mutation as separate phases when practical.

Do not deserialize arbitrary user-controlled schematic paths from a tick callback.

## Transform rule

Apply rotation/flip/other transforms to the clipboard holder/operation model instead of manually rewriting every block coordinate unless the domain logic requires custom semantics.

Verify orientation-sensitive blocks after transformed pastes.

## Player-attributed history

When a WorldEdit API operation is performed on behalf of a player:

1. adapt the Fabric player to a WorldEdit Actor;
2. get the actor's `LocalSession` from the WorldEdit `SessionManager`;
3. perform the bounded edit through one EditSession;
4. remember that EditSession in the LocalSession when the change should be exposed to the player's WorldEdit history;
5. close/flush the EditSession according to the operation lifecycle rather than retaining it for reuse.

EngineHub documents:

```java
localSession.remember(editSession);
```

as the route that allows a later `//undo`.

Do not assume a selection or clipboard exists in LocalSession; official docs note that getters may throw when these values are absent.

## Automated server jobs

Do not invent a fake player merely to obtain LocalSession history.

For edits not directly attributed to a player:

- keep an explicit application-level job id;
- record enough metadata to explain what was changed;
- use an EditSession undo path when it fits the lifecycle;
- use backups/snapshots for operations whose failure domain exceeds in-memory history.

## History is not a transaction log

WorldEdit history is useful rollback machinery, but external side effects and downstream Minecraft behavior can escape a simple block-history model.

For high-impact production changes, combine WorldEdit history with an operational backup/rollback plan.

## Sources

- https://worldedit.enginehub.org/en/7.3.19/api/concepts/local-sessions/
- https://worldedit.enginehub.org/en/7.3.19/api/examples/local-sessions/
