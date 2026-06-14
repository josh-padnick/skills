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
3. Step one abstraction level up and challenge the frame.
4. Extract the governing principles.
5. Assess the PR against those principles.
6. Explain the implementation approach and tradeoffs.
7. Recommend how to review the code.

When the user provides a PR URL, prefer the GitHub connector or `gh` for PR metadata, changed files, patch, review comments, CI status, and linked issues. If a local checkout is available, compare the PR branch against its base with Git commands and read touched docs/tests directly.

## Context To Gather

Collect enough evidence to avoid merely summarizing the PR description:

- PR title, body, linked issues, author intent, and reviewer comments.
- Changed file list grouped by subsystem.
- Diff or patch for architecture-bearing files, tests, docs, migrations, scripts, and public interfaces.
- Existing docs, ADRs, rules, or tests touched by the PR.
- The relevant current-state behavior on the base branch when the PR changes lifecycle, startup, security, data shape, API, or developer workflow.

Read the most decision-relevant files. Do not read every changed file when the PR shape is already clear; save detailed inspection for the recommended review pass.

## Frame Challenge

Before accepting the PR's stated goal, explicitly ask:

- What broader system or operating model is this PR changing?
- What problem class does this belong to one level up?
- What should be true in a well-designed version of that broader system?
- Is the PR solving the root design problem, or only moving complexity somewhere less visible?
- What alternatives would a strong reviewer expect the author to have considered?
- What would make the chosen direction wrong despite the code working?

For example, if a PR says "move migrations to an external ops command," the broader frame is not only "remove startup migrations." It is the app's database schema management model: who owns schema convergence, which roles have privilege, when local dev and CI apply migrations, how runtime verifies compatibility, and how operational mistakes fail safely.

## Principle Pass

Derive 3-7 principles that should govern the PR. Keep them concrete enough to evaluate.

Good principles are about invariants and responsibility boundaries, not preferences. Examples:

- Runtime startup should not require privileges it does not need to serve requests.
- Schema-changing operations should be explicit, auditable, and owned by setup/deploy flows.
- Local development should stay easy without teaching habits that differ dangerously from production.
- CI should exercise the same privilege boundaries the deployed app relies on.
- Generated code, docs, and tests should move with the contract they describe.

For each principle, assess whether the PR upholds it, partially upholds it, violates it, or leaves it unproven. Name the evidence: files, tests, commands, docs, or missing checks.

## Analysis Shape

Use the report template in `references/report-template.md` unless the user asks for a different format.

Keep the output reviewer-oriented:

- Prefer "what matters for review" over exhaustive summary.
- State uncertainty and where to verify it.
- Separate "this is the intended design" from "this diff proves it."
- Call out cross-cutting risks: lifecycle order, permissions, generated artifacts, backwards-incompatible behavior, data migration safety, local/CI/prod drift, test realism, and docs drift.
- Give the reviewer a rough route through the diff: first files to read, tests to scrutinize, commands to run, and questions to ask.

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
