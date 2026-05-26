---
name: improve-code-organization
description: Find naming, scoping, and folder-structure problems in a codebase, and propose changes that make the file tree navigable on its own. Use when the user wants to rename files, tighten what lives in each file, restructure folders, or make a codebase legible at a glance.
---

# Improve Code Organization

Surface organization friction and propose changes that make the **directory listing itself documentation** — so a reader who has never seen the codebase can guess where a thing lives, open the file they expect, and find what its name promised. Three pillars: **naming**, **scoping**, **folders**.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "module," "component," "package," "section." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **File** — the unit of code on disk. Has a **name** and a **scope**.
- **Name** — what the file is called. A name **predicts** scope; a good name makes the file findable by guessing.
- **Scope** — the set of concerns inside a file. **Tight** = one clear concern. **Mixed** = unrelated concerns sharing a file. **Fragmented** = one concern split across many files.
- **Cohesion** — degree to which the things inside a file belong together. High cohesion is the goal of scoping.
- **Co-location** — placing things that change together near each other on disk. A folder either co-locates correctly or it doesn't.
- **Folder** — a grouping that should name a real architectural concept (not "utils," "helpers," "misc"). A folder is a **claim** about what's inside.
- **Drift** — when a file's contents have grown beyond what its name suggests.
- **Predictiveness** — the central test: would a stranger find this file by guessing the path?

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Predictiveness test**: from the name alone, can you predict the scope? From the folder alone, can you predict the file? If no, the name or folder is wrong.
- **Cohesion test**: would splitting this file produce two logically distinct concerns? If yes, the scope is mixed.
- **The file tree is documentation.** Browsing the tree should teach the architecture.
- **"utils," "helpers," "misc," "common," "shared"** are smells, not categories. They mean the real grouping has not been named yet.

## Process

### 1. Explore

Use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction:

- **Names that lie or under-promise** — files whose contents don't match what the name suggests (drift), or whose names are so generic they could hold anything (`helpers.ts`, `utils.py`, `common.go`).
- **Mixed scope** — files holding two or more unrelated concerns. Apply the **cohesion test**: would a split produce two coherent halves?
- **Fragmented scope** — one concept spread across many tiny files when one file would tell the story better.
- **Folders that don't predict their contents** — a `services/` folder containing mixed business logic, transport, and data access; a `lib/` folder that's a junk drawer.
- **Co-location violations** — files that always change together but live far apart, or files that never change together but share a folder.
- **Path friction** — `import` lines with awkward `../../../` chains often signal a folder that's wrong, not a path that's wrong.

Apply the **predictiveness test** to anything suspect: could a new reader guess this file's path from a description of what it does? A "no" is the signal.

See [NAMING.md](NAMING.md), [SCOPING.md](SCOPING.md), and [FOLDERS.md](FOLDERS.md) for the deeper criteria on each pillar.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/code-organization-review-<timestamp>.html` so each run gets a fresh file. Open it for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

The report uses **Tailwind via CDN** for layout and **Mermaid via CDN** for diagrams where a tree/graph reliably communicates the change. The centrepiece of each card is a **before/after file tree** — show the actual paths, with renames, splits, merges, and moves rendered visually. Be visual.

For each candidate, render as a card:

- **Pillar** — `naming`, `scoping`, or `folders` (a candidate can touch more than one; pick the dominant one)
- **Paths** — the file paths involved, monospaced
- **Problem** — why the current organization causes friction (one sentence)
- **Change** — what would move, split, merge, or be renamed (one sentence)
- **Before / After file tree** — side-by-side, showing the actual paths
- **Wins** — bullets in glossary terms (predictiveness, cohesion, co-location)
- **Recommendation strength** — one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge
- **Blast radius** — rough count of import sites / references touched, so the user can weigh effort

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, tree-diff patterns, and styling guidance.

Do NOT start renaming or moving files yet. After the file is written, ask the user: "Which of these would you like to apply?"

### 3. Apply changes

Once the user picks a candidate, walk the change with them before touching the disk:

- **Confirm the new names and paths** — read them out loud as a sanity check. If a name still feels off, iterate before moving.
- **List the call sites / imports** — count what will need updating. If the count is surprising, flag it; sometimes the surprise is the signal that the rename was wrong.
- **Plan rename vs. split vs. merge vs. move** as distinct steps, even if they happen in one commit. Each is reversible if separated.
- **Use the version-control rename, not delete-and-create.** `git mv` (or the language-server rename) preserves history; copy-paste loses it.
- **Update imports atomically.** Don't leave the tree in a broken state between rename and import update.
- **Apply the predictiveness test once more after the change.** If the new tree still doesn't reveal the architecture, the change wasn't enough.

If during the conversation a new grouping concept emerges that doesn't exist anywhere yet, name it — and use that name consistently across files, folders, and any prose. **The naming we land on is itself an artifact** worth preserving in a code comment, ADR, or CONTEXT.md if the project has one.
