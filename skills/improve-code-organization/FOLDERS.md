# Folders

How to evaluate and improve folder structure. Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **folder**, **co-location**, **predictiveness**.

A folder is a **claim** about what's inside. The claim is checkable: does the folder name predict the files inside? Do the files inside actually belong together? When the answer is no, the folder is misnamed, miscomposed, or both.

## Symptoms of a bad folder

- **Generic names** — `utils/`, `helpers/`, `lib/`, `common/`, `shared/`, `misc/`, `core/`. These make no specific claim, so nothing can violate them. They become junk drawers by gravity.
- **Type-based folders** — `interfaces/`, `types/`, `classes/`, `constants/`, `enums/`. Groups files that never change together; separates files that always change together.
- **Tech-stack folders** at the top level of a feature-organized project — `controllers/`, `models/`, `views/` when the rest of the project is grouped by feature. Inconsistent shape.
- **Empty-ish folders** — three files in a folder named for what *might* go there someday. Speculative groupings.
- **Cousin folders that always change together** — `order/` and `pricing/` whose files appear in every commit together. They're one concept that's been split prematurely.
- **One huge folder** — 80 files all at the same level. No structure means no claim.
- **Folder name doesn't match its files' names.** A folder called `billing/` containing `invoice.ts`, `subscription.ts`, `payment.ts` — fine. A folder called `billing/` containing `email-sender.ts`, `csv-export.ts`, `feature-flags.ts` — the folder name is a lie.

## Tests to apply

- **Predictiveness test.** From the folder name alone, what files would you expect to find? Open the folder. How wide is the gap?
- **Co-change test.** Look at `git log`. Files in the same folder should change together more often than files in different folders. If a folder's files never co-change, the grouping is wrong. If files across two folders always co-change, those folders should probably merge.
- **Import-direction test.** Pick a folder. What does it import? What imports it? If a folder imports from everywhere and is imported by nothing, it's probably mis-scoped (often a `utils/`). If imports run cleanly in one direction, the folder names a real layer.
- **Sibling test.** Do the sibling folders make sense as a set? `auth/`, `billing/`, `orders/`, `utils/` — three feature names and one junk drawer. The set is incoherent.
- **Depth test.** Are you four folders deep just to reach the file you want? Each level of nesting should add a meaningful distinction. If a sub-folder contains one file, the sub-folder isn't earning its place.

## Organizing principles

The right organization depends on the project, but the heuristics are stable:

- **Group by what changes together, not by what looks alike.** Files that ship in the same PR belong in the same folder. Files that share a type but no behaviour don't.
- **Prefer concept names over role names.** `order-intake/` is more predictive than `services/`. `pricing-rules/` is more predictive than `domain/`.
- **One level of nesting per real distinction.** Don't nest just for cosmetics.
- **Match the project's existing shape.** If the rest of the codebase is grouped by feature, don't introduce a layer of `controllers/` underneath. Consistency of shape is part of predictiveness.
- **Tests live with their code, not in a parallel `tests/` tree** — unless the project's convention is otherwise. Co-location of test and source is a strong default; it makes the test discoverable from the source it covers.

## Fixing folders

### Killing a generic folder (`utils/`, `helpers/`, etc.)

1. **List the contents.** What's actually in there?
2. **Group by concept.** Most "utils" decompose into a handful of real concepts.
3. **Distribute or rename.** If a group of files belongs to an existing feature folder, move them there. If they form a new coherent concept, rename `utils/` to that concept (or extract a new folder).
4. **What's left?** A truly cross-cutting generic helper (a string utility used by ten unrelated places) can stay in a renamed folder — but call it what it is (`string-formatting/`), not `utils/`.

### Splitting a folder that grew too large

1. **Find natural seams in the file list.** Often you'll see two or three sub-concepts hiding in a flat folder.
2. **Confirm with the co-change test.** Files in each proposed sub-folder should change together more than across.
3. **Move, don't copy.** `git mv` so history follows.

### Merging cousin folders

1. **Confirm with the co-change test.** If `order/` and `pricing/` always change in the same commit, they're one concept.
2. **Pick the merged name carefully.** It should cover both without being so generic that it becomes a new junk drawer. `order-pricing/` is honest; `commerce/` is probably too vague.

## Blast radius

Folder moves usually touch many imports. Before recommending a folder change:

- **Count the import sites.** A `grep` over the codebase gives a rough number.
- **Check for absolute-import path config.** Some projects map `@app/foo` to `src/foo`; renaming `src/foo` to `src/bar` may need a config update.
- **If the count is large**, consider whether the move can be staged: rename in one commit, update imports in the next, so reverts are easier.
