# HTML Report Format

The organization review is rendered as a single self-contained HTML file in the OS temp directory. Tailwind and Mermaid both come from CDNs. The centrepiece of every candidate card is a **before/after file tree** — show the actual paths so the reader can see exactly what moves, splits, merges, or renames.

## Contents

- [Scaffold](#scaffold)
- [Header](#header)
- [Candidate card](#candidate-card)
- [Before / After tree patterns](#before--after-tree-patterns)
- [Style guidance](#style-guidance)
- [Top recommendation section](#top-recommendation-section)
- [Tone](#tone)

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Code organization review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly */
      .tree { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
      .rename { background: #fef3c7; }   /* amber-100 */
      .add    { background: #d1fae5; }   /* emerald-100 */
      .remove { background: #fee2e2; text-decoration: line-through; }  /* red-100 */
      .move   { background: #dbeafe; }   /* blue-100 */
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Repo name, date, and a compact legend: amber = rename, blue = move, emerald = new file, red strikethrough = removed file. Also include a blast-radius legend: `Small` = ≤5 affected references, `Medium` = 6–25, `Large` = 26+. No introduction paragraph — straight into the candidates.

## Candidate card

The file tree carries the weight. Prose is sparse, plain, and uses the glossary terms ([LANGUAGE.md](LANGUAGE.md)) without ceremony.

Each candidate is one `<article>`:

- **Title** — short, names the change (e.g. "Split `auth.ts` into session and permissions").
- **Badge row** — three badges:
  - **Lens**: `folders` (teal), `naming` (indigo), `scoping` (violet), `smell` (rose), or `trace` (cyan). Use `smell` when the candidate comes directly from smell triage and does not map cleanly to folders, naming, or scoping; use `trace` when the vertical trace is the main evidence.
  - **Recommendation strength**: `Strong` = emerald, `Worth exploring` = amber, `Speculative` = slate.
  - **Blast radius**: spell out `Small`, `Medium`, or `Large`; include the count when known, e.g. `Blast radius: Small (3 refs)`. Do not use unexplained `S`, `M`, or `L` letters.
- **Smell / lens** — one compact line when the candidate comes from [SMELLS.md](SMELLS.md), e.g. `suffix inconsistency · APoSD + Refactoring`.
- **Trace** — include only when a vertical trace exposed the candidate, e.g. `signup form -> server action -> user profile write -> migration`.
- **Before / After file tree** — the centrepiece. Two columns, side by side. See patterns below.
- **Problem** — one sentence. What hurts.
- **Change** — one sentence. What moves, splits, merges, or is renamed.
- **Wins** — bullets, ≤6 words each. e.g. "Predictive name", "Cohesion: one concern per file", "Co-locates files that co-change".
- **Verification** — one terse line naming the checks that keep the change structural.
- **Architecture flag** — include only when the candidate is architecture work rather than organization-only work.

No paragraphs of explanation. If the tree needs a paragraph, redraw the tree.

## Before / After tree patterns

Pick the pattern that fits the candidate.

### Indented file tree (the workhorse)

Render before and after as monospaced indented lists. Highlight changed rows with the colour classes above. Show only the relevant subtree, not the whole repo.

```html
<div class="grid grid-cols-2 gap-4">
  <div class="rounded-lg border border-slate-200 bg-white p-4 tree text-sm">
    <div class="text-xs uppercase tracking-wider text-slate-500 mb-2">Before</div>
    <pre>
src/
├── auth.ts          <span class="remove">(354 lines, mixed scope)</span>
├── utils.ts
└── order/
    └── handler.ts
    </pre>
  </div>
  <div class="rounded-lg border border-slate-200 bg-white p-4 tree text-sm">
    <div class="text-xs uppercase tracking-wider text-slate-500 mb-2">After</div>
    <pre>
src/
├── <span class="add">auth-session.ts</span>
├── <span class="add">auth-permissions.ts</span>
├── utils.ts
└── order/
    └── handler.ts
    </pre>
  </div>
</div>
```

### Rename arrow (for pure renames)

Two stacked rows with an arrow between, when the only change is a name. Keeps the card compact.

```
src/helpers.ts  →  src/order-pricing.ts
```

### Folder merge / split diagram (Mermaid)

When folders are merging or splitting, a Mermaid `flowchart` shows the relationship clearly:

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[utils/] --> B[order-pricing/]
      A --> C[csv-export/]
      A --> D[email-templates/]
  </pre>
</div>
```

### Co-change heat map (for the case where the diagnosis is "these files always change together")

A small grid of file × file cells, shaded by how often they appear in the same commit. Useful when explaining why two folders should merge or one folder should split. Hand-built with a Tailwind grid, not Mermaid.

## Style guidance

- Lean editorial, not corporate-dashboard. Generous whitespace.
- Colour sparingly: one accent (indigo) plus the diff colours (amber/emerald/red/blue) for tree changes.
- Keep trees compact — show only the changed subtree, not the whole repo. A reader scanning ten candidates doesn't want to re-read the whole tree each time.
- Use `text-xs uppercase tracking-wider text-slate-500` for the "Before" / "After" labels above each tree.
- The only scripts are the Tailwind CDN and the Mermaid ESM import.

## Top recommendation section

One larger card. Candidate name, one sentence on why, anchor link to its card, and the verification line. That's it.

## Tone

Plain English, concise — architectural nouns and verbs come straight from [LANGUAGE.md](LANGUAGE.md). Concision is not an excuse to drift.

**Use exactly:** file, name, scope, cohesion, co-location, folder, drift, predictiveness, tight / mixed / fragmented scope.

**Never substitute:** module, component, package, namespace (for file or folder) · label, title (for name) · directory (for folder, when you mean the architectural grouping) · helpers, utils (as descriptors of a real category — those are smells, not categories).

**Phrasings that fit the style:**

- "`auth.ts` is mixed: session handling and permission checks share a file."
- "`utils/` is unnamed — its contents are three real concepts in a junk drawer."
- "Co-change history says `order/` and `pricing/` are one concept."
- "Rename only — scope is already tight."

**Wins bullets** name the gain in glossary terms: *"predictive name"*, *"cohesion: one concern"*, *"co-locates files that change together"*. Don't write *"cleaner"* or *"easier to navigate"* — those don't earn their place.

No hedging, no throat-clearing. If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it. If a term isn't in [LANGUAGE.md](LANGUAGE.md), reach for one that is before inventing a new one.
