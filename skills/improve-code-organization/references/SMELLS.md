# Organization Smells

Use smells as triage signals, not automatic fixes. A smell earns a candidate only when it points to failed **predictiveness**, weak **co-location**, mixed or fragmented **scope**, or a folder claim that does not match the files inside it.

Ground every diagnosis in one local rule lens from [agent-rules-books](agent-rules-books/ATTRIBUTION.md). Read only the relevant file:

- **[A Philosophy of Software Design](agent-rules-books/a-philosophy-of-software-design.mini.md)** — reduce reader complexity, reject shallow boundaries, hide knowledge where it belongs, and split or merge by total complexity.
- **[Refactoring](agent-rules-books/refactoring.mini.md)** — keep the candidate behavior-preserving, small, reversible, and aimed at the current blocking smell.
- **[Refactoring.Guru](agent-rules-books/refactoring-guru.mini.md)** — use when the main work is classifying a smell, choosing the smallest treatment, and knowing when to stop.
- **[The Pragmatic Programmer](agent-rules-books/the-pragmatic-programmer.mini.md)** — use when a trace exposes duplicated knowledge, non-orthogonal concerns, missing feedback, or a need for one authoritative owner.
- **[Clean Architecture](agent-rules-books/clean-architecture.mini.md)** — use only when source dependencies, framework details, persistence details, or delivery mechanisms are shaping the core file tree.
- **[Domain-Driven Design Distilled](agent-rules-books/domain-driven-design-distilled.mini.md)** — use only when domain language, bounded contexts, aggregates, or business capabilities are the reason the current folder or file names mislead.

## Smell triage

For each smell, record:

```text
Smell -> Rule lens -> Diagnosis -> Candidate -> Verification -> Architecture flag?
```

- **Smell** — the concrete observation in the tree, names, imports, or change history.
- **Rule lens** — which rule set makes this smell matter.
- **Diagnosis** — why the smell hurts predictiveness, cohesion, co-location, or reader complexity.
- **Candidate** — the smallest behavior-preserving rename, move, split, merge, or alternative organization to explore.
- **Verification** — import search, type check, tests, dependency rule, or manual tree inspection.
- **Architecture flag?** — yes when the fix implies new seams, dependency direction changes, domain modeling, or ADR-level architecture work; stop and ask the user rather than applying it as organization-only work.

## Vertical trace sanity check

Use one representative request to test whether the file tree tells a coherent start-to-end story. Good traces include:

- UI form -> client validation -> request action -> server validation -> use case -> persistence -> migration
- API route -> authorization -> domain rule -> external adapter -> stored state
- scheduled job -> query -> business decision -> write path -> emitted event

Trace only far enough to judge organization. The goal is not full behavior analysis; it is to see whether a reader can predict the next file from the current file and whether the concepts stay named consistently across the path.

Look for these trace smells:

- **Concept changes names mid-flight** — the same business thing is called `lead`, `contact`, `profile`, and `userInput` across the path. Candidate: rename around one concept or identify separate bounded contexts.
- **Layer jump surprise** — a UI file reaches directly into persistence, schema, or vendor details when an intermediate concept should own the knowledge. Candidate: flag as architecture work if dependency direction must change.
- **Policy hides in adapters** — business rules live in React forms, HTTP handlers, ORM mappers, or migration helpers. Candidate: flag the misplaced folder claim; mark as architecture work when moving rules changes seams.
- **Persistence leads the story** — migration/table names shape application names even though the user-facing concept differs. Candidate: rename application files by concept and keep storage translation at the edge.
- **End-to-end scatter** — one request crosses many folders whose names do not explain why each hop exists. Candidate: explore a use-case or business-capability tree shape.
- **Trace-only folder** — a folder exists because it is one step in a request sequence (`prepare/`, `process/`, `finalize/`) rather than a stable concept. Candidate: reorganize around the durable concept unless temporal order is the domain fact.

Record the trace as:

```text
Trace -> Breakpoint -> Rule lens -> Candidate -> Verification -> Architecture flag?
```

Use **A Philosophy of Software Design** when the trace exposes cognitive load, hidden dependencies, shallow pass-through files, or temporal coupling. Use **The Pragmatic Programmer** when the trace exposes duplicated knowledge, non-orthogonal concerns, missing feedback, or no authoritative owner. Use **Clean Architecture** when dependency direction is wrong. Use **Domain-Driven Design Distilled** when the trace exposes confused business language. Use **Refactoring** to keep any proposed change behavior-preserving and reviewable.

## Tree smells

- **Unclear sibling strategy** — a folder's immediate children do not reveal whether they are grouped by concept, use case, layer, adapter role, lifecycle phase, framework convention, or another explicit strategy. Candidate: choose the strategy that best matches co-change and predictiveness, then rename or regroup the children to make it visible.
- **Sibling abstraction mismatch** — files or folders at one level are not peers: high-level orchestration, low-level primitives, adapters, schemas, generated code, and tests sit side by side without a shared folder claim. Candidate: split by concept, layer, or role only when the new folders make checkable claims. Mark as architecture work if this exposes dependency-direction problems.
- **Incoherent sibling set** — most sibling folders are business concepts but one is `utils/`, `common/`, `services/`, or another catch-all with no bounded contract. This is not a smell merely because a cross-cutting folder exists; `money/`, `time/`, `observability/`, `db/`, `schemas/`, or `contracts/` may be legitimate when the name predicts its contents and dependency direction. Candidate: first name the shared folder's actual contract, then either keep it, rename it to the contract, decompose it by real concepts, or move files to the concept that owns the knowledge.
- **Type bucket gravity** — `types/`, `interfaces/`, `constants/`, `classes/`, or `models/` keeps accumulating unrelated definitions and forces readers to jump away from the behavior, schema, or public surface that explains them. This is not a smell when the bucket is generated code, schema-only code, a published/public contract, a framework convention, or a small local bucket with a clear import contract. Candidate: first name the bucket's contract; only move definitions next to behavior when co-location improves predictiveness without breaking a legitimate surface.
- **Path friction** — many files reach across the tree with long relative imports. Candidate: check whether the folder claim is wrong before adding aliases.
- **Tree reveals framework before domain** — a business-heavy area is organized first by `controllers/`, `services/`, `repositories/`, or framework folders. Candidate: explore use-case, capability, or bounded-context folders. Mark as architecture work if dependency direction or domain ownership would change.

## Naming smells

- **Suffix inconsistency** — sibling files share a suffix but do different work, e.g. `*-handler` means HTTP endpoint in one file, event consumer in another, and business operation in a third. Candidate: rename by actual scope or split roles into separate folders.
- **Suffix collision** — sibling files use different suffixes for the same role, e.g. `*-handler`, `*-controller`, and `*-processor` all mean delivery adapter. Candidate: standardize the name pattern if the scopes are truly equivalent.
- **Mechanism-first names** — names expose storage, transport, framework, or vendor details when callers need the concept instead. Candidate: rename by role or concept; mark as architecture work only if the mechanism has leaked into core policy.
- **Near-duplicate names** — files differ only by weak adjectives like `new`, `old`, `shared`, `base`, `common`, `helper`, or `manager`. Candidate: identify the real distinction or merge fragmented scope.
- **Domain concept hiding behind role name** — a file named `service`, `handler`, `processor`, or `manager` owns business language. Candidate: rename to the domain concept or use case; mark as architecture work when the domain model is fuzzy.

## Change-history smells

- **Shotgun organization** — one conceptual change touches many unrelated folders. Candidate: co-locate the files that change together or introduce a concept folder that owns the knowledge.
- **Divergent folder** — one folder changes for several unrelated reasons. Candidate: split by the reasons to change, but only when each new folder has a predictive name.
- **Always-together files** — files in separate folders repeatedly change in the same commits. Candidate: merge or co-locate if they form one concern. Treat broad refactors and mechanical formatting commits as noise.
- **Always-separate halves** — one file's top and bottom halves change independently. Candidate: split mixed scope along the real concerns.
- **Duplicated system fact** — the same business rule, mapping, status meaning, schema fact, or validation rule appears in several files. Candidate: find the authoritative owner and make the rest derive, validate against it, or translate at the edge.

## Boundary smells

- **Pass-through file** — a file exists mostly to forward calls, re-export names, or wrap another file without hiding knowledge. Candidate: inline, rename, or move the boundary to where it hides real complexity.
- **Fragmented pipeline** — `parse-*`, `validate-*`, `normalize-*`, and `save-*` files force a reader through several tiny files for one concern. Candidate: merge when the stages are not stable concepts on their own.
- **Exposed ordering** — file names or folder layout encode `prepare/process/finalize` when the stable concept is something else. Candidate: reorganize around the concept unless temporal ordering is the real domain fact.
- **Core imports details** — concept folders import framework requests, ORM rows, vendor SDKs, transport types, or persistence details. Candidate: flag as architecture work; use organization only to reveal the dependency problem.

## Alternative organization candidates

Consider a new tree shape only when local rename, move, split, or merge candidates cannot explain the smell.

- **By business capability** — when changes cluster around durable capabilities such as billing, intake, pricing, or fulfillment.
- **By use case** — when application actions are the stable unit and framework folders hide intent.
- **By bounded context** — when the same word means different things in different areas, or domain concepts should not share one folder.
- **By edge adapter around a core** — when delivery, persistence, or vendor details surround business rules and dependency direction matters.
- **By generated/public surface** — when schema, proto, generated, or published type folders are legitimate external surfaces.

Do not recommend a new tree shape because it looks cleaner. Recommend it only when it lowers cognitive load, improves co-location, restores a checkable folder claim, or makes an existing architecture decision visible in the file tree.
