---
name: improve-code-organization
description: Find folder-structure, naming, and scoping problems in a codebase, and propose changes that make the file tree navigable on its own. Use when the user wants to restructure folders, rename files, tighten what lives in each file, or make a codebase legible at a glance.
---

# Improve Code Organization

Surface organization friction and propose changes that make the **directory listing itself documentation** — so a reader who has never seen the codebase can guess where a thing lives, open the file they expect, and find what its name promised. Three lenses, applied outer-to-inner: **folders**, then **naming**, then **scoping**.

## Glossary

Use these terms exactly in every suggestion. Don't drift into "module," "component," "package," or "section." Full definitions in [LANGUAGE.md](LANGUAGE.md).

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

## Process

### 1. Explore

Use the Agent tool with `subagent_type=Explore` to walk the codebase **top-down**: folder structure first, then per-file naming, then file-internal scope. Outer decisions frame inner ones — a file named `rules.ts` is fine inside `pricing/` and useless inside `utils/`, so settle the folder before re-judging the name. Expect to iterate: a folder problem often surfaces *through* naming friction (a folder full of files that can't be coherently named is the diagnostic for a bad folder), in which case go back up a level.

Ask these three questions, in order, of every folder and the files inside it. Each lens's symptoms, tests, and mechanics live in its own file:

1. **Does the folder predict its contents, and are its files at the same level of abstraction?** Folders should make a checkable claim; sibling abstractions belong as sibling folders. Look for generic folders without a bounded convention, type-based folders without reason, mismatched contents, oversized folders, and path friction (`../../../` import chains often signal a folder that's wrong, not a path that's wrong). See [FOLDERS.md](FOLDERS.md).
2. **Does each file's name fit its contents?** The name should predict what's inside; the contents should deliver what the name promises. Look for **drifted** names (file grew past its name), **generic** names (could hold anything), and over- or under-promising names — see [NAMING.md](NAMING.md).
3. **Should this file be split, or should these files be combined?** A file holding two unrelated concerns has **mixed scope** and should split. A single concern spread thin across many tiny files is **fragmented** and should combine. See [SCOPING.md](SCOPING.md).

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/code-organization-review-<timestamp>.html`. Open it for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

Each candidate is rendered as a card with a **before/after file tree** as the centrepiece. End with a **Top recommendation** section.

See [HTML-REPORT.md](HTML-REPORT.md) for the full scaffold, card structure, badge taxonomy, and styling guidance.

Do NOT start renaming or moving files yet. After the file is written, ask the user: "Which of these would you like to apply?"

### 3. Apply changes

Once the user picks a candidate, walk the change with them before touching the disk:

- **Confirm the new names and paths** out loud. Iterate if a name still feels off.
- **List the call sites** that will need updating. A surprising count can be a signal the rename was wrong.
- **Plan rename, split, merge, and move as distinct steps**, even if they happen in one commit — each is reversible if separated.
- **Use the version-control rename** (`git mv` or the language-server rename) so history follows. See the Mechanics section of [NAMING.md](NAMING.md) and the Fixing folders section of [FOLDERS.md](FOLDERS.md) for per-pillar detail.
- **Apply the predictiveness test again** after the change. If the new tree still doesn't reveal the architecture, the change wasn't enough.

If during the conversation a new grouping concept emerges that doesn't exist anywhere yet, name it — and use that name consistently across files, folders, and any prose. **The naming we land on is itself an artifact** worth preserving in a code comment, ADR, or CONTEXT.md if the project has one.
