# Folders

How to evaluate and improve folder structure. Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **folder**, **co-location**, **predictiveness**.

A folder is a **claim** about what's inside. The claim is checkable: does the folder name predict the files inside? Do the files inside actually belong together? When the answer is no, the folder is misnamed, miscomposed, or both.

## Symptoms of a bad folder

A folder name is rarely bad in isolation — it's bad when it gives no useful prediction *in this project*. Several common patterns become smells when unbounded, inconsistent with the surrounding shape, or hiding unrelated concerns. See [Allowed exceptions](#allowed-exceptions) below for when these same names are fine.

- **Unbounded generic names** — `utils/`, `helpers/`, `lib/`, `common/`, `shared/`, `misc/`, `core/`. A smell when they grow without scope: anything can land there, and nothing can violate the name. A small, scoped `utils/` for genuinely cross-cutting helpers (e.g. string formatting) can be fine — the smell is gravity, not the letters.
- **Type-based folders without a reason** — `interfaces/`, `types/`, `classes/`, `constants/`, `enums/`. A smell when types are scattered into them away from the behaviour they describe. Legitimate when types are themselves the public surface (generated types, schema definitions, a published type package).
- **Tech-stack folders inconsistent with the project shape** — `controllers/`, `models/`, `views/` mixed into an otherwise feature-organized codebase. The smell is the inconsistency, not the names; an MVC app where `controllers/` is the dominant shape is fine.
- **Empty-ish folders** — three files in a folder named for what *might* go there someday. Speculative groupings.
- **One folder so large that scanning stops working** — a flat folder where you can no longer skim and find what you want. There's no universal file count; generated code, routes, fixtures, assets, and data folders can be large and still coherent. The signal is that *the reader's scan fails*, not the size on its own.
- **Folder name doesn't match its files' names.** A folder called `billing/` containing `invoice.ts`, `subscription.ts`, `payment.ts` is plausibly fine — though in some domains those are three distinct bounded contexts that shouldn't share a folder. A folder called `billing/` containing `email-sender.ts`, `csv-export.ts`, `feature-flags.ts` is a lie: the name predicts nothing about the contents.

For sibling abstraction mismatch, path friction, cousin folders that always change together, and other cross-cutting smells, use the catalog in [SMELLS.md](SMELLS.md#tree-smells).

## Allowed exceptions

Conventional folders — `routes/`, `migrations/`, `schemas/`, `fixtures/`, `controllers/` in an MVC app, `types/` for a generated or public type surface, `pages/` and `components/` in a framework that mandates them — are acceptable when the convention is **explicit and bounded**:

- **Explicit** — the project (or its framework) has an established convention that says what goes in the folder. A reader who knows the convention can predict the contents.
- **Bounded** — the folder holds only what the convention says it holds. The moment unrelated code starts landing there, the convention has eroded and the folder is back to being a junk drawer.

Common categories that legitimately keep role/type names:

- **Framework conventions** — `routes/`, `pages/`, `components/`, `middleware/`, `migrations/`, `controllers/`/`models/`/`views/` in MVC.
- **Generated or schema-only code** — `generated/`, `schemas/`, `proto/`, a `types/` folder that publishes a project's external type surface.
- **Test infrastructure** — `e2e/`, `integration/`, `fixtures/`, `test-utils/` when not co-located.
- **Build / ops artefacts** — `scripts/`, `infra/`, `deploy/`, `ci/`.

The rule isn't "never use these names." The rule is: the name must give a useful prediction *in this project*. `utils/` for cross-cutting string formatting in a small repo is fine. `utils/` as the default destination for anything that didn't fit elsewhere is the smell.

## Tests to apply

- **Predictiveness test.** From the folder name alone, what files would you expect to find? Open the folder. How wide is the gap?
- **Co-change test.** Look at `git log` — co-change is a *clue about cohesion*, not proof. Files in the same folder tending to change together is a positive signal; files across two folders always changing together is a hint they may belong together. Discount the signal for new modules (no history yet), broad refactors (noisy co-change across the tree), and intentionally stable abstractions (low change rate doesn't mean low cohesion).
- **Dependency-direction test.** Pick a folder. What does it import? What imports it? The question isn't "does it import a lot / get imported a lot" — it's *does the direction match the folder's intended role?* A composition root, CLI entrypoint, job runner, or adapter folder *should* import from everywhere and be imported by little. A domain-core folder should be the opposite. The smell is direction that contradicts the role the name implies.
- **Sibling strategy test.** What is the grouping strategy for this folder's immediate children: concept, use case, layer, adapter role, lifecycle phase, framework convention, or something else? Do the siblings follow that strategy consistently? `auth/`, `billing/`, `orders/`, `utils/` mixes three concept folders with one junk drawer; the set is incoherent.
- **Same-altitude test.** Scan one folder level. Are the sibling files and folders peers, or is one an orchestration layer sitting next to the implementation details it coordinates? If they are not peers, either the folder claim is too broad or a sub-folder is missing.
- **Depth test.** Are you four folders deep just to reach the file you want? Each level of nesting should add a meaningful distinction. If a sub-folder contains one file, the sub-folder isn't earning its place.
- **Boundary test.** Would this folder let a reader forget implementation detail, or does it merely add another hop? A folder boundary earns its place by hiding a real distinction and making the next search easier.

## Organizing principles

The right organization depends on the project, but the heuristics are stable:

- **Group by what changes together, not by what looks alike.** Files that ship in the same PR belong in the same folder. Files that share a type but no behaviour don't.
- **Name the sibling strategy before judging names.** Sibling files and folders do not need shared prefixes or suffixes. They need a coherent reason to sit together. If the strategy is concept-based, names should be peer concepts; if it is adapter-based, names should be peer adapters; if it is a framework convention, the convention must be explicit and bounded.
- **Keep contents at the same level of abstraction.** A folder should read as one layer — opening it shouldn't show an orchestrator sitting next to the low-level pieces it composes. When sibling abstractions exist (two implementations of one interface, three adapters for one port), give each its own folder at the same level, rather than nesting one inside another or scattering them among unrelated files. **Convention exceptions:** some languages mandate flat packages — Go is the canonical case, where one package equals one folder. There, differentiate concerns with `prefix_name.go` filenames within the package, but still prefer same-altitude contents where the language permits.
- **Prefer deep folder claims.** A folder with a narrow, meaningful public surface can hide internal mess while still being easy to search. A folder that only groups thin wrappers, pass-through files, or type buckets adds names without reducing reader burden.
- **Prefer concept names over role names.** `order-intake/` is more predictive than `services/`. `pricing-rules/` is more predictive than `domain/`.
- **One level of nesting per real distinction.** Don't nest just for cosmetics.
- **Match the project's existing shape.** If the rest of the codebase is grouped by feature, don't introduce a layer of `controllers/` underneath. Consistency of shape is part of predictiveness.
- **Tests live with their code by default**, unless the project's convention is otherwise. Co-locating unit tests next to source makes them discoverable from the file they cover. Common exceptions: **black-box integration tests**, **end-to-end tests**, **contract tests**, **fixtures**, and **shared test utilities** often deserve their own top-level folders because they aren't tied to a single source file and frequently have their own tooling, runners, or environments.

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
