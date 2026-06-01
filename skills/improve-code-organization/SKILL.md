---
name: improve-code-organization
description: Find folder-structure, naming, scoping, and organization-smell problems in a codebase, then propose behavior-preserving rename, move, split, merge, or alternative tree-shape candidates that make the file tree navigable on its own. Use when the user wants to restructure folders, rename files, tighten what lives in each file, investigate code organization smells, reduce organization friction, or make a codebase legible at a glance.
---

# Improve Code Organization

Surface organization friction and propose changes that make the **file tree itself documentation** — so a reader who has never seen the codebase can guess where a thing lives, open the file they expect, and find what its name promised. Three lenses, applied outer-to-inner: **folders**, then **naming**, then **scoping**.

## Operating bias

Use one primary decision pressure: **reduce reader complexity by increasing predictiveness**. The best change is not the largest cleanup; it is the smallest rename, move, split, or merge that lets a stranger predict the right file from the folder tree and predict the file's scope from its name.

Secondary guardrails:

- Ground each diagnosis in one rule lens from `ciembor/agent-rules-books`: **A Philosophy of Software Design** by default, **Refactoring** for safety, and **Clean Architecture** or **Domain-Driven Design Distilled** only when dependency direction or domain boundaries are the real issue.
- Treat organization work as **behavior-preserving refactoring** unless the user explicitly asks for behavior changes.
- Prefer project-specific concepts over type buckets, roles, or implementation mechanisms.
- Split or merge by total reader burden, not by file size, habit, or "one thing per file" slogans.
- Every new folder or file boundary must hide more complexity than it adds.
- Stop before speculative architecture. If the next change would not improve predictiveness, cohesion, or co-location for the current task, leave it as a note.

## Glossary

Use these terms exactly in every suggestion. Don't drift into "module," "component," "package," or "section." Full definitions in [references/LANGUAGE.md](references/LANGUAGE.md).

- **File** — the unit of code on disk; has a **name** and a **scope**.
- **Scope** — what's inside a file; **tight**, **mixed**, or **fragmented**.
- **Cohesion** — how well a file's contents belong together.
- **Folder** — a **claim** about what's inside; should predict its contents.
- **Co-location** — placing files that change together near each other.
- **Drift** — when a file's contents have outgrown its name.
- **Predictiveness** — the central property: can a stranger guess the path?

Key tests:

- **Predictiveness test** — predict scope from name; predict file from folder. If no, the name or folder is wrong.
- **Cohesion test** — would splitting this file produce two distinct concerns? If yes, scope is mixed.
- **Fragmentation test** — would merging these N files produce one coherent file? If yes, they were fragmented.
- **Boundary test** — does this new file or folder boundary remove more reader complexity than it introduces? If no, don't create it.
- **Behavior test** — can this organization change be reviewed without reasoning about changed behavior? If no, split the behavior change from the rename, move, split, or merge.
- **Smell triage** — record `Smell -> Rule lens -> Diagnosis -> Candidate -> Verification -> Escalate?`. See [references/SMELLS.md](references/SMELLS.md).
- **Vertical trace test** — follow one representative request from start to end, such as React form to handler to validation to persistence to migration. If the path tells an incoherent story, diagnose the folder and name claims that broke the trace. See [references/SMELLS.md](references/SMELLS.md).

## Process

### 1. Explore

Use a dedicated exploration pass to walk the codebase **top-down**: folder structure first, then per-file naming, then file-internal scope. If the agent supports exploration subagents, use one; otherwise inspect the tree directly. Outer decisions frame inner ones — a file named `rules.ts` is fine inside `pricing/` and useless inside `utils/`, so settle the folder before re-judging the name. Expect to iterate: a folder problem often surfaces *through* naming friction (a folder full of files that can't be coherently named is the diagnostic for a bad folder), in which case go back up a level.

Ask these questions, in order, of every folder and the files inside it. Each lens's symptoms, tests, and mechanics live in its own file:

1. **Does the folder predict its contents, and are its files at the same level of abstraction?** Folders should make a checkable claim; sibling abstractions belong as sibling folders. Look for generic folders without a bounded convention, type-based folders without reason, mismatched contents, oversized folders, and path friction (`../../../` import chains often signal a folder that's wrong, not a path that's wrong). See [references/FOLDERS.md](references/FOLDERS.md).
2. **Does each file's name fit its contents?** The name should predict what's inside; the contents should deliver what the name promises. Look for **drifted** names (file grew past its name), **generic** names (could hold anything), and over- or under-promising names — see [references/NAMING.md](references/NAMING.md).
3. **Should this file be split, or should these files be combined?** A file holding two unrelated concerns has **mixed scope** and should split. A single concern spread thin across many tiny files is **fragmented** and should combine. See [references/SCOPING.md](references/SCOPING.md).
4. **Is there a repeated smell that points beyond a local rename, move, split, or merge?** Check sibling abstraction mismatch, suffix inconsistency, shotgun organization, pass-through files, fragmented pipelines, and domain or dependency smells. See [references/SMELLS.md](references/SMELLS.md).
5. **Does one vertical trace make sense from start to end?** Pick a representative user request or job and trace it across the tree. Use the trace to find misplaced concepts, misleading folder claims, hidden policy in adapters, and persistence details leaking into places they do not belong.

When smells suggest a new way of organizing the codebase, present it as an **alternative tree-shape candidate**, not as a silent expansion of scope. Escalate to an architecture-focused skill when the candidate requires new seams, changed dependency direction, domain modeling, or ADR-level decisions.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/code-organization-review-<timestamp>.html`. Open it for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

Each candidate is rendered as a card with a **before/after file tree** as the centrepiece. End with a **Top recommendation** section.

See [references/HTML-REPORT.md](references/HTML-REPORT.md) for the full scaffold, card structure, badge taxonomy, and styling guidance.

Each candidate must include:

- The specific friction: failed predictiveness, mixed scope, fragmented scope, weak co-location, or incoherent folder claim.
- The smell and rule lens, when a smell is the reason the candidate matters.
- The smallest behavior-preserving change that addresses it.
- Whether the candidate is local organization work or an alternative tree-shape exploration.
- Whether to escalate because the candidate is really architecture work.
- Blast radius: affected imports, tests, build config, generated files, or public paths.
- Verification: which tests, type checks, search checks, or manual inspections would prove the change stayed structural.

Do NOT start renaming or moving files yet. After the file is written, ask the user: "Which of these would you like to apply?"

### 3. Apply changes

Once the user picks a candidate, walk the change with them before touching the disk:

- **Confirm the new names and paths** out loud. Iterate if a name still feels off.
- **List the call sites** that will need updating. A surprising count can be a signal the rename was wrong.
- **Plan rename, split, merge, and move as distinct steps**, even if they happen in one commit — each is reversible if separated.
- **Use the version-control rename** (`git mv` or the language-server rename) so history follows. See the Mechanics section of [references/NAMING.md](references/NAMING.md) and the Fixing folders section of [references/FOLDERS.md](references/FOLDERS.md) for per-pillar detail.
- **Apply the predictiveness test again** after the change. If the new tree still doesn't reveal the architecture, the change wasn't enough.
- **Run the smallest relevant verification** after each applied step: import search for moves, type check for path updates, tests for touched behavior contracts, and project validation scripts if present.
- **Keep structural and behavior edits separate** in the diff where practical. If behavior must change, say so and stop treating it as organization-only work.

If during the conversation a new grouping concept emerges that doesn't exist anywhere yet, name it — and use that name consistently across files, folders, and any prose. **The naming we land on is itself an artifact** worth preserving in a code comment, ADR, or CONTEXT.md if the project has one.

## Final checklist

- Did the proposal reduce the facts a reader must hold to find and understand the file?
- Does every recommended folder, file, and name make a checkable claim?
- Did each split or merge improve cohesion, co-location, or predictiveness?
- Did every smell-based suggestion name the rule lens and avoid treating the smell as proof by itself?
- Are sibling files and folders at the same abstraction level, with suffixes and naming patterns used consistently?
- Did at least one representative vertical trace support the diagnosis when the issue spans UI, application logic, persistence, or schema files?
- Are behavior changes absent, explicitly separated, or called out as out of scope?
- Is the blast radius counted and the verification path concrete?
- Did the recommendation stop before speculative cleanup?
