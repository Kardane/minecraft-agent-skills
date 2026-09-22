# Masks and Patterns

Use Masks and Patterns when the task is a **conditional bulk edit**.

## Separation of responsibility

```text
Region = outer spatial boundary
Mask   = positions allowed to change
Pattern = replacement/result at each accepted position
```

Do not bury all three concerns in one nested loop if WorldEdit already models them explicitly.

## Mask design

Examples of requirements that naturally belong in a mask:

- only stone-like source blocks;
- only blocks exposed to air;
- only positions inside another geometric constraint;
- only blocks matching a state/property;
- only blocks accepted by a project-specific predicate adapter.

Keep business authorization outside the Mask. A Mask answers "may this position be edited by this operation?", not "is this caller allowed to run the feature?".

## Pattern design

Patterns are appropriate for:

- one fixed block/state;
- weighted or varying replacement;
- position-dependent replacement;
- clipboard-backed/repeating results where supported by the chosen API.

Do not use a Pattern to hide unrelated gameplay state mutations.

## Performance rule

A Mask can make an operation selective without making the outer Region cheap.

Always bound the Region first. A predicate that matches 1% of a billion-position region is still a potentially expensive scan.

## API construction vs command parser

Do not build strings like `"stone,20%andesite"` and feed WorldEdit's command parser from production Java merely because the same syntax exists in commands.

Construct API objects directly when the mod owns the data model. Use parser APIs only when the feature intentionally accepts WorldEdit expression syntax from a trusted/validated user input surface.

## Validation

Test:

- no matches;
- all matches;
- boundary matches;
- block-state-sensitive matches;
- deterministic/expected distribution where randomness is involved;
- region too large;
- cancelled/failed operation cleanup.

## Source

- https://worldedit.enginehub.org/en/7.3.19/usage/general/masks/
- https://worldedit.enginehub.org/en/7.3.19/usage/general/patterns/
