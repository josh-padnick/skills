---
name: frame-pr-review
description: Analyze a GitHub pull request from the engineering-decision level before code review. Use when Codex is pointed at a PR URL, branch, diff, or local PR checkout and asked to explain the problem being solved, challenge the framing one abstraction level up, identify governing principles, summarize the chosen approach and tradeoffs, call out what reviewers should inspect, or recommend a review strategy rather than immediately doing a line-by-line bug review.
---

# Frame PR Review

## Overview

Use this skill to turn a PR into a reviewer briefing: what engineering problem the PR is really trying to solve, whether that frame is right, what principles should govern the design, what tradeoffs the author chose, and how to review the code efficiently.

This is not a substitute for a detailed code review. It prepares the reviewer to do one with better taste and sharper priorities.

## Workflow

1. Gather context before judging.
2. Reconstruct the stated problem.
3. Build an abstraction ladder from high-level goal to concrete implementation.
4. Choose the highest review-useful frame.
5. Extract the governing principles.
6. Assess the PR against those principles.
7. Explain the implementation approach and tradeoffs.
8. Recommend how to review the code.

When the user provides a PR URL, prefer the GitHub connector or `gh` for PR metadata, changed files, patch, review comments, CI status, and linked issues. If a local checkout is available, compare the PR branch against its base with Git commands and read touched docs/tests directly.

## Context To Gather

Collect enough evidence to avoid merely summarizing the PR description:

- PR title, body, linked issues, author intent, and reviewer comments.
- Changed file list grouped by subsystem.
- Diff or patch for architecture-bearing files, tests, docs, migrations, scripts, and public interfaces.
- Existing docs, ADRs, rules, or tests touched by the PR.
- The relevant current-state behavior on the base branch when the PR changes lifecycle, startup, security, data shape, API, or developer workflow.

Read the most decision-relevant files. Do not read every changed file when the PR shape is already clear; save detailed inspection for the recommended review pass.

## Abstraction Ladder

Many PRs are presented as a crisp implementation question even though the real decision chain starts several levels higher. Before writing the Big Picture or Frame Challenge, sketch 4-6 abstraction levels:

1. Product or system goal.
2. Capability or subsystem responsibility that supports that goal.
3. Operating-model, lifecycle, ownership, timing, or policy question.
4. Design direction chosen by the PR.
5. Implementation mechanisms in the diff.

Choose the sweet spot: the highest level that is still specific enough to guide review of this PR. If the frame names a database role, migration tool, command, file, class, route, protocol, or generated artifact, it is usually still describing the implementation answer. Climb one notch unless that primitive is itself the architectural subject.

Use this acceptance test for the chosen frame:

- It explains why the PR matters to the system without assuming the implementation.
- It gives principles a place to attach before discussing files or commands.
- It makes the chosen approach feel like one possible answer, not the only thinkable answer.
- It is specific enough that a reviewer can decide which evidence in the diff matters.

For the Big Picture section, write the first sentence at the selected frame. The first sentence should usually not mention roles, tools, commands, files, functions, route names, or checks. Put those in the approach, evidence, tradeoffs, or review guidance.

For a database migration PR:

- Too high: "How should Fabrica persist data?"
- Sweet spot: "How should Fabrica manage database schema evolution across local development, CI, deployment, runtime startup, and maintenance?"
- Too low: "Under which database role should schema convergence happen?"
- Too low: "Should runtime startup only verify schema compatibility?"

Database roles, goose commands, startup checks, and privilege scripts are design constraints, evidence, or tradeoffs within the schema-evolution frame. Do not let them become the frame unless the PR is primarily about credential management.

For PR 143-style work, the Big Picture should start closer to: "This PR is about where database schema evolution belongs in Fabrica's application lifecycle." Then explain that the PR's answer is to make schema convergence an explicit setup/deploy/test concern while app startup verifies compatibility. Mention database roles only after that, as one reason this lifecycle split matters.

## Frame Challenge

Before accepting the PR's stated goal, explicitly ask:

- What broader system or operating model is this PR changing?
- What lifecycle, ownership, timing, or policy question sits above the proposed solution?
- Does the proposed frame name an implementation mechanism that should instead be evidence under a broader frame?
- What should be true in a well-designed version of that broader system?
- Is the PR solving the root design problem, or only moving complexity somewhere less visible?
- What alternatives would a strong reviewer expect the author to have considered?
- What would make the chosen direction wrong despite the code working?

State the frame as a question before stating the PR's answer. A question such as "how should the app manage schema evolution across its lifecycle?" is usually a better frame than "under which database role should migrations run?" or "should runtime only verify schema compatibility?" because the first names the design space while the others already sit inside a chosen design.

For example, if a PR says "move migrations to an external ops command," the broader frame is not only "remove startup migrations" or "which role runs goose." It is: "How should Fabrica manage database schema evolution across local development, CI, deployment, runtime startup, and maintenance?" Then evaluate whether the PR's answer, such as explicit migration/setup commands plus startup compatibility checks, follows from sound lifecycle, reliability, and operational principles.

## Principle Pass

Derive 3-7 principles that should govern the PR. Keep them concrete enough to evaluate.

Good principles are about invariants and responsibility boundaries, not preferences. Examples:

- Schema evolution should have an explicit lifecycle: local setup, CI, deployment, runtime startup, and maintenance should each have a known responsibility.
- Runtime startup should be predictable: it should either serve against a compatible schema or fail clearly before serving.
- Schema-changing operations should be explicit, auditable, and repeatable outside request-serving paths.
- Local development should stay easy without teaching habits that differ dangerously from production.
- CI should exercise the lifecycle and failure modes the deployed app relies on.
- Generated code, docs, and tests should move with the contract they describe.

For each principle, assess whether the PR upholds it, partially upholds it, violates it, or leaves it unproven. Name the evidence: files, tests, commands, docs, or missing checks.

## Analysis Shape

Use the report template in `references/report-template.md` unless the user asks for a different format.

Keep the output reviewer-oriented:

- Prefer "what matters for review" over exhaustive summary.
- State uncertainty and where to verify it.
- Separate "this is the intended design" from "this diff proves it."
- Present the report in this order: big-picture frame, governing principles, PR approach, tradeoffs and review route.
- Do not make "Frame Challenge" a default top-level output section. Use it as internal reasoning, then fold the conclusion into the Big Picture unless the user explicitly asks to see the challenge separately.
- Call out cross-cutting risks: lifecycle order, permissions, generated artifacts, backwards-incompatible behavior, data migration safety, local/CI/prod drift, test realism, and docs drift.
- Give the reviewer a rough route through the diff: first files to read, tests to scrutinize, commands to run, and questions to ask.

Before finalizing the report, run a quick frame audit:

- If the Big Picture's governing question mentions a database role, CLI, file, function, or command, rewrite it one notch higher.
- If the first paragraph could only apply to the chosen implementation, rewrite it so alternatives could be compared.
- If the principles mostly restate code changes, rewrite them as lifecycle, reliability, safety, operability, or user/developer-experience principles.
- If the visible report starts debating implementation details before naming principles, move that material into Approach, Tradeoffs, or Review Guidance.

## Review Recommendation

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
