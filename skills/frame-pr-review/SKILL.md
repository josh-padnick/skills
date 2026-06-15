---
name: frame-pr-review
description: Analyze a GitHub pull request from the engineering-decision level before code review. Use when Codex is pointed at a PR URL, branch, diff, or local PR checkout and asked to explain the problem being solved, show the abstraction chain behind the PR, challenge the framing one abstraction level up, identify best practice principles, summarize the chosen approach and tradeoffs, call out what reviewers should inspect, or recommend a review strategy rather than immediately doing a line-by-line bug review.
---

# Frame PR Review

## Overview

Use this skill to turn a PR into a reviewer briefing: what engineering problem the PR is really trying to solve, whether that frame is right, what principles should govern the design, what tradeoffs the author chose, and how to review the code efficiently.

This is not a substitute for a detailed code review. It prepares the reviewer to do one with better taste and sharper priorities.

## Workflow

1. Gather context before judging.
2. Reconstruct the stated problem.
3. Build an abstraction chain from the PR's concrete move upward, then back down through concise how steps; show it from highest abstraction to lowest.
4. Choose and bold the best review-useful frame.
5. Extract the best practice principles.
6. Summarize this PR's approach.
7. Identify key assumptions that need human judgment.
8. Explain the implementation approach and tradeoffs.
9. Assess the PR against the principles as recommendation-oriented sections.
10. Recommend how to review the code.

When the user provides a PR URL, prefer the GitHub connector or `gh` for PR metadata, changed files, patch, review comments, CI status, and linked issues. If a local checkout is available, compare the PR branch against its base with Git commands and read touched docs/tests directly.

## Context To Gather

Collect enough evidence to avoid merely summarizing the PR description:

- PR title, body, linked issues, author intent, and reviewer comments.
- Changed file list grouped by subsystem.
- Diff or patch for architecture-bearing files, tests, docs, migrations, scripts, and public interfaces.
- Existing docs, ADRs, rules, or tests touched by the PR.
- The relevant current-state behavior on the base branch when the PR changes lifecycle, startup, security, data shape, API, or developer workflow.

Read the most decision-relevant files. Do not read every changed file when the PR shape is already clear; save detailed inspection for the recommended review pass.

## Abstraction Chain

Many PRs are presented as a crisp implementation question even though the real decision chain starts several levels higher. Before writing the Big Picture or Frame Challenge, build a visible abstraction chain.

Start with what the PR is actually doing, stated in one sentence from the PR title/body/diff. Then climb upward by repeatedly asking "Why is that important?" or "So we can do what?" Stop climbing when the answer becomes a broad product or system goal that is still meaningful for this PR.

After climbing, return to the starting point and go downward by asking "How?" Add only concise technical answers that name the chosen design direction, mechanism, workflow, API, data flow, or file-level move. If a "how" answer needs more than one sentence, stop descending; those implementation details belong in Implementation approach, Assessment, or What to review.

Avoid inserting best practices, virtues, or principles into the chain as "how" steps. A sentence such as "keep runtime store startup permission-scoped" is a principle or practice, not a technical how. A sentence such as "remove the in-process migration runner and run migrations through explicit ops scripts" is a technical how.

Show the chain in the report as a compact two-column Markdown table ordered from highest abstraction to lowest abstraction. Use one column for the step number and one column for the level description. Use blank header cells rather than named column headers, and do not use raw HTML because Codex may render it as escaped text. Label the top of the table `Business goals` and the bottom `Implementation details`.

1. Highest meaningful product or system goal.
2. Intermediate capability, operating-model, lifecycle, ownership, timing, or policy levels.
3. The detected starting level from the PR title/body/diff, marked with `*`.
4. Lower concise "how?" answers.

Add an italic note immediately below the chain: `* = Abstraction level first detected from the PR title/body/diff.`

Bold the level that is the best framing for the human reviewer to consider. The best frame is usually a lifecycle, operating-model, ownership, timing, or policy question, not the highest product goal and not the lowest mechanism.

For PR 143-style migration work, a good chain is:

**Business goals**

|  |  |
| ---: | --- |
| 1 | Enable Fabrica to evolve quickly without compromising safety, reliability, or end-user UX. |
| 2 | Have a safe, efficient approach to evolving the database over time. |
| 3 | **Set up a maintainable, robust approach to database schema migrations.** |
| 4 | * Move Postgres migrations to a Goose-managed setup. |
| 5 | Remove the in-process Go migration runner/embed and replace it with explicit operating scripts. |

**Implementation details**

Choose the sweet spot: the level that gives the reviewer the most useful judgment frame while staying specific enough to guide review of this PR. If the frame names a database role, migration tool, command, file, class, route, protocol, or generated artifact, it is usually still describing the implementation answer. Climb one notch unless that primitive is itself the architectural subject.

Use this acceptance test for the chosen frame:

- It explains why the PR matters to the system without assuming the implementation.
- It gives principles a place to attach before discussing files or commands.
- It makes the chosen approach feel like one possible answer, not the only thinkable answer.
- It is specific enough that a reviewer can decide which evidence in the diff matters.

For the Big Picture section, write the first sentence at the selected frame. The first sentence should usually not mention roles, tools, commands, files, functions, route names, or checks unless the selected frame itself legitimately names that primitive. Put those lower-level details in Abstraction Chain, This PR's Approach, Implementation Approach, Assessment, Tradeoffs, or Review Guidance.

Do not assert whether the frame is strong, good, correct, or successful in Big Picture. The introduction should name the frame and summarize the PR's answer; evaluation belongs in Assessment.

For a database migration PR:

- Too high: "How should Fabrica persist data?"
- Useful but often still high: "How should Fabrica safely evolve its database over time?"
- Sweet spot: "How should Fabrica set up a maintainable, robust approach to database schema migrations?"
- Lower implementation frame: "Where should schema convergence happen across local development, CI, deployment, runtime startup, and maintenance?"
- Too low: "Under which database role should schema convergence happen?"
- Too low: "Should runtime startup only verify schema compatibility?"

Database roles, goose commands, startup checks, and privilege scripts are design constraints, evidence, or tradeoffs within the schema-evolution frame. Do not let them become the frame unless the PR is primarily about credential management.

For PR 143-style work, the Big Picture should start closer to: "This PR is about setting up a maintainable approach to database schema migrations as Fabrica evolves." Then explain that the PR's answer is to make schema convergence an explicit setup/deploy/test concern while app startup verifies compatibility. Mention database roles only after that, as one reason this lifecycle split matters.

Use contrastive calibration when the PR is a well-framed implementation slice:

- Reject: "The governing question is which database role should run schema convergence." This is an implementation constraint pretending to be the frame.
- Reject: "The stronger frame is that runtime should only verify schema compatibility." This states the PR's chosen answer, not the broader question.
- Prefer: "The governing question is how Fabrica should maintainably manage database schema migrations as the product evolves." This leaves room to compare answers before explaining why the PR's lifecycle split is reasonable.

## Frame Challenge

Before accepting the PR's stated goal, explicitly ask:

- What broader system or operating model is this PR changing?
- What lifecycle, ownership, timing, or policy question sits above the proposed solution?
- Does the proposed frame name an implementation mechanism that should instead be evidence under a broader frame?
- What should be true in a well-designed version of that broader system?
- Is the PR solving the root design problem, or only moving complexity somewhere less visible?
- What alternatives would a strong reviewer expect the author to have considered?
- What would make the chosen direction wrong despite the code working?

State the frame as a question before stating the PR's answer. A question such as "how should the app maintainably manage database schema migrations as it evolves?" is usually a better frame than "under which database role should migrations run?" or "should runtime only verify schema compatibility?" because the first names the design problem while the others already sit inside a chosen design.

For example, if a PR says "move migrations to an external ops command," the broader frame is not only "remove startup migrations" or "which role runs goose." It is: "How should Fabrica maintainably manage database schema migrations as the product and deployment surfaces evolve?" Then evaluate whether the PR's answer, such as explicit migration/setup commands plus startup compatibility checks, follows from sound lifecycle, reliability, and operational principles.

## Best practice principles

Derive up to 5 principles that should govern the PR. If more than 5 are truly necessary, group them under short labels rather than listing a long flat set.

Good principles are about invariants, lifecycle expectations, and responsibility boundaries, not preferences or implementation steps. State each principle in implementation-independent language first. Do not evaluate the PR in the best-practice-principles list.

Phrase principles with active verbs in imperative form, using idiomatic engineering language. Prefer "Make the database schema evolution lifecycle explicit" over "Schema evolution should have an explicit lifecycle." Prefer "Separate migration permissions and application runtime permissions" over "Migration authority and application authority should be separated."

For each principle, add 1-2 concise sentences explaining what the principle means, why it matters, and how a reviewer should apply it. Avoid file references, command names, test names, database roles, APIs, or verdict words in this section; those belong in Assessment.

Examples:

- Make the database schema evolution lifecycle explicit: local setup, CI, deployment, runtime startup, and maintenance each need a known responsibility.
- Keep runtime startup predictable: serving processes should either start against a compatible schema or fail clearly before serving.
- Separate migration permissions and application runtime permissions: schema-changing work may need broader database permissions than request-serving code.
- Rehearse the production operating order in local and CI workflows: convenience paths should not teach behavior that production cannot rely on.
- Move docs, rules, and tests with the contract: lifecycle changes only stick when the repo's instructions and checks say the same thing.

## This PR's approach

Summarize the PR's design answer in 1-2 sentences. Stay above file-level details here; explain the operating-model choice, responsibility split, or contract change.

## Key assumptions

Identify 3-5 assumptions that drive the PR's direction or the review recommendation. These should be the places where human judgment, product context, or operational context matters most.

For each assumption, state a confidence level:

- **Confident**: the PR, repo context, or common engineering practice strongly supports it.
- **Plausible**: it seems likely, but a reviewer should verify the local or organizational context.
- **Unsure**: the assumption materially affects the review, and evidence is missing or ambiguous.

Focus on assumptions that would change the review outcome if false. Avoid minor uncertainties and facts that the diff already proves.

## Assessment

After Tradeoffs, assess the PR against the best practice principles as one short subsection per recommendation, not as a table. Put each recommendation under a `##` heading inside the top-level `# Assessment` section.

Each subsection should have a recommendation-oriented heading, then these fields:

- **Principle**: name the matching best practice principle.
- **Evaluation**: Strong / Good / Moderate / Poor / Unknown.
- **Description**: explain the evidence, caveat, or missing confirmation.
- **Recommendation**: say what the reviewer should accept, ask, fix, or verify.
- **Confidence**: High / Medium / Low, based on how directly the diff supports the assessment.

Use this evaluation scale:

- **Strong**: convincingly satisfies the principle, with direct implementation support and meaningful tests, docs, or operational wiring.
- **Good**: satisfies the principle with minor caveats or follow-up questions.
- **Moderate**: directionally aligned, but important behavior, docs, tests, or operational ownership remains unclear.
- **Poor**: conflicts with the principle or leaves a high-risk gap.
- **Unknown**: evidence is insufficient without author or operator input.

Use evidence sparingly in the Description field: name representative files, tests, commands, docs, or missing checks only after the principle is clear.

## Analysis Shape

Use the report template in `references/report-template.md` unless the user asks for a different format.

Keep the output reviewer-oriented:

- Prefer "what matters for review" over exhaustive summary.
- State uncertainty and where to verify it.
- Separate "this is the intended design" from "this diff proves it."
- Present the report with this heading hierarchy and order:
  - `# Big picture`
  - `## Abstraction chain`
  - `## Best practice principles`
  - `# This PR's approach`
  - `## Key assumptions`
  - `## Implementation approach`
  - `## Tradeoffs`
  - `# Assessment`
  - `## <Each principle or recommendation>`
  - `# Review`
  - `## What to review`
  - `## My recommendation`
- Do not make "Frame Challenge" a default top-level output section. Use it as internal reasoning, then fold the conclusion into the Big Picture unless the user explicitly asks to see the challenge separately.
- Call out cross-cutting risks: lifecycle order, permissions, generated artifacts, backwards-incompatible behavior, data migration safety, local/CI/prod drift, test realism, and docs drift.
- Give the reviewer a rough route through the diff: first files to read, tests to scrutinize, commands to run, and questions to ask.

Before finalizing the report, run a quick frame audit:

- If the Big Picture's governing question mentions a database role, CLI, file, function, or command, rewrite it one notch higher.
- If the first paragraph could only apply to the chosen implementation, rewrite it so alternatives could be compared.
- If Big Picture evaluates the frame or says it is strong/good/correct, remove that sentence or move the judgment to Assessment.
- If the Abstraction Chain does not start with what the PR actually does, rebuild it from the PR title/body/diff before climbing upward.
- If the visible Abstraction Chain is not ordered from highest abstraction to lowest, reorder it before finalizing.
- If the visible Abstraction Chain is not a two-column Markdown table with numbers and descriptions, blank header cells, `Business goals` at the top, and `Implementation details` at the bottom, rewrite it.
- If the first-detected abstraction level is not marked with `*` and the note is missing, add both.
- If a "how" row is really a best practice, principle, or desired property, move it to Best practice principles and replace it with a concrete technical approach or stop descending.
- If the best practice principles mostly restate code changes, rewrite them as lifecycle, reliability, safety, operability, or user/developer-experience principles with 1-2 explanatory sentences.
- If the best practice principles are phrased as "X should Y," rewrite them with active imperative verbs.
- If there are more than 5 ungrouped principles, keep the most important 5 or group them.
- If principle bullets include verdicts, filenames, commands, APIs, or test names, move that material to Assessment.
- If Assessment is a table, rewrite it as recommendation-oriented subsections with principle, evaluation, description, recommendation, and confidence.
- If the visible report starts debating implementation details before naming principles, move that material into This PR's approach, Implementation approach, Tradeoffs, or Review Guidance.

## My recommendation

End with a concrete recommendation:

- **Review depth**: skim, focused review, deep review, or split review.
- **Primary lens**: architecture, security/permissions, data correctness, API contract, UI behavior, migration/ops, test strategy, or docs.
- **Suggested order**: the sequence of files or subsystems to inspect.
- **Blockers vs follow-ups**: what must be resolved before merge versus what can become a separate issue.

If the PR is too broad, recommend splitting only when there is a coherent safer boundary. Do not reflexively ask for smaller PRs when the cross-cutting change needs atomicity.

## Failure Modes

Avoid these common mistakes:

- Do not just restate the PR body.
- Do not start with line-level nits.
- Do not assume the user's framing is correct.
- Do not over-index on the biggest file by line count.
- Do not invent intent when evidence is missing; ask or mark it as an assumption.
- Do not recommend generic best practices without tying them to the repo's actual constraints.
