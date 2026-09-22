# Safety, threading, and performance

## Server-thread ownership

Treat Minecraft world mutation as server-thread-affine unless the exact pinned API documents otherwise.

Do not move an EditSession call onto a worker thread simply because the region is large.

If expensive preparation can run asynchronously:

```text
server-thread snapshot / immutable job description
→ worker computes non-Minecraft data
→ server thread revalidates world + job preconditions
→ WorldEdit operation
```

Never retain mutable Minecraft world/entity objects in worker tasks.

## Bound the blast radius

Before editing calculate:

- world/dimension;
- min/max positions;
- block volume;
- chunk footprint;
- maximum allowed changed blocks;
- expected operation frequency;
- whether chunks should already be loaded;
- rollback/history owner.

Reject obviously invalid/unbounded user input before creating the EditSession.

## Avoid tick-hot-path editing

Do not run large scans or WorldEdit mutations every tick.

Prefer:

- explicit jobs;
- event-triggered operations;
- bounded queues;
- rate limiting;
- batching/cadence chosen from profiling and gameplay requirements.

## Chunk and neighbor effects

A block count is not the whole cost.

Consider:

- chunk loads/generation;
- lighting;
- neighbor updates;
- fluids;
- block entities;
- scheduled ticks;
- entity collisions;
- downstream mod listeners.

Test representative production-like regions, not only an empty flat world.

## Permissions and domain rules

WorldEdit's ability to change blocks is not application authorization.

Validate:

- caller permission;
- ownership/claim policy;
- allowed dimension/region;
- protected blocks/content;
- rate/cooldown;
- operation-size limits.

Then construct the WorldEdit operation.

## Rollback policy

Low-risk disposable edit:
- EditSession/history may be sufficient.

Player-attributed edit:
- LocalSession history when appropriate.

Large production edit:
- backup/snapshot + explicit rollback procedure + WorldEdit history as supporting tooling.

Automated recurring edit:
- idempotency/job-state strategy; do not grow unbounded retained histories.

## Verification

Measure before and after:

- operation duration;
- affected block count;
- MSPT around the edit;
- chunk-load side effects;
- memory pressure for clipboard/history-heavy jobs.

A faster API call that causes downstream tick spikes is not a successful optimization.
