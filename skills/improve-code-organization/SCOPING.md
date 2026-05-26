# Scoping

How to evaluate and improve what lives inside a file. Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **scope**, **cohesion**, **drift**, **predictiveness**.

A file's **scope** is the set of concerns it contains. Three failure modes:

- **Mixed** — two or more unrelated concerns share one file.
- **Fragmented** — one concern split across many files when one would suffice.
- **Drifted** — the scope quietly grew until the name no longer fits.

The goal is **tight, cohesive** scope: a reader who understands one item in the file can predict why the others are there.

## Symptoms of mixed scope

- **The "and" smell.** "This file handles X *and* Y." If you need "and" to describe it, you have two scopes.
- **Two unrelated test files for one source file.** If the same file needs tests in two different suites that share no setup, it's two scopes.
- **Imports cluster into two non-overlapping sets.** Half the imports serve concern A, the other half serve concern B, with nothing shared between them.
- **Sections separated by `// ---` comments.** The comments are a tacit admission the file has been split mentally but not physically.
- **Diff history splits cleanly.** Looking at `git log`, half the commits touch lines 1-200, the other half touch lines 201-400. Cohesion would mix them.

## Symptoms of fragmented scope

- **The "always together" smell.** Two files always change in the same commit. Probably one file.
- **One-function files everywhere.** A folder of 12 files each containing one ten-line function. Almost always over-fragmented.
- **The reader bounces.** To understand one behaviour, you have to read four files in a chain. The chain isn't adding modularity; it's adding hops.
- **Naming gymnastics to keep them distinct.** `parseOrderInput.ts`, `validateOrderInput.ts`, `normalizeOrderInput.ts` — each a five-line function. Probably one `order-input.ts`.

## Symptoms of drift

- **Name describes a subset.** The file was once `csv-parser.ts` and now also exports JSON parsing helpers because "they fit."
- **Comments apologize.** "This is a bit of a grab-bag, sorry."
- **The file is much longer than its siblings in the same folder.** Not always a problem — but worth checking whether it absorbed work that should have lived elsewhere.

## Tests to apply

- **Cohesion test.** If you split this file into two, would the two halves be logically distinct concerns? If yes, the scope is mixed; split. If no, leave it.
- **Fragmentation test.** If you merged these N files into one, would the result still be coherent and easy to scan? If yes, they were fragmented; merge.
- **Co-change test.** Look at `git log` over the last 6–12 months. Files that always change together are candidates for merging. Lines that always change separately within one file are candidates for splitting.
- **Mental model test.** Describe the file in one sentence without using "and" or "various." If you can't, the scope is too wide.

## Splitting a mixed file

1. **Identify the cleavage.** Often there are two import clusters, two diff clusters, or two narrative halves.
2. **Name each new file from the cleaved concerns**, not from the parent file's old name. `auth.ts` becoming `auth-session.ts` and `auth-permissions.ts` is fine; becoming `auth-1.ts` and `auth-2.ts` is a failure.
3. **Move tests with their code.** If tests were also mixed, split the test file along the same cleavage.
4. **Check imports.** Some callers will import from both halves; that's expected. If most callers only import one half, the split was real.

## Merging fragmented files

1. **Confirm the files share a concern**, not just a vague theme.
2. **Pick the merged file's name first.** If you can't agree on a single name that covers all the contents, they don't actually belong together.
3. **Preserve internal structure.** Section headers, ordering, exported-symbol grouping inside the merged file. Don't just concatenate.
4. **Delete the originals via `git mv` into one of them**, then concatenate the rest, so history follows at least the largest piece.

## When scope is right but feels wrong

Sometimes a file is correctly scoped and cohesive, but the **name** is wrong (see [NAMING.md](NAMING.md)) or the **folder** is wrong (see [FOLDERS.md](FOLDERS.md)). Don't split a tight file just because its location is awkward — move or rename it instead.
