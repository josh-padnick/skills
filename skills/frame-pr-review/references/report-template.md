# PR Framing Report Template

Use this template for a reviewer briefing. Trim sections that do not apply.

## Big Picture

Explain the broader engineering problem in 2-4 sentences. Name the abstraction level above the PR's stated task as a governing design question before describing the PR's answer.

First, choose the highest review-useful frame from an implicit ladder: system goal -> subsystem capability -> lifecycle/operating-model question -> design direction -> implementation mechanism. Prefer "how should the system manage X across its lifecycle?" over a frame that names a role, tool, command, file, API, or other implementation mechanism.

The first sentence should name the selected frame without mentioning implementation mechanisms. The second sentence can summarize the PR's answer. For migration work, prefer "where database schema evolution belongs in the application lifecycle" over "which database role runs migrations."

Fold the frame challenge into this section instead of creating a separate default heading. State whether the PR appears to be solving the right problem and name the main design question a reviewer should keep in mind. Mention alternatives only when they clarify the principles or would change the review outcome.

If this section names a specific database role, migration tool, command, file, route, or generated artifact as the frame, rewrite it one notch higher and move that detail to Approach, Tradeoffs, or What To Review.

## Governing Principles

List 3-7 principles. Start each item with the principle itself, phrased independently of the implementation. Then add a short verdict and only the most representative evidence.

- **Principle**: upheld / partial / violated / unproven. Brief evidence or concern.

Principles should describe lifecycle, reliability, safety, operability, and user/developer-experience invariants. Avoid principles that merely restate implementation steps.
Do not lead principle bullets with filenames, command names, database roles, APIs, or tests; those belong after the principle as evidence.

## Approach Taken

Summarize the main implementation moves by subsystem. Focus on how the PR answers the principles above: lifecycle boundaries, responsibility boundaries, data flow, public contracts, operational behavior, and any role/tool/command choices.

## Major Tradeoffs

Describe the largest tradeoffs, including what the PR gains, what it gives up, and what future work it makes easier or harder.

## What To Review

Give a prioritized review route:

1. Highest-risk files or subsystems.
2. Tests and checks that prove the intended invariant.
3. Docs, scripts, generated artifacts, or CI changes that must stay aligned.

## Review Recommendation

Give a rough recommendation:

- **Depth**: skim / focused / deep / split.
- **Lens**: architecture / security / data / API / UI / ops / tests / docs.
- **Merge posture**: ready if checks pass / needs targeted fixes / needs design discussion.
- **Questions for author**: only the questions that would change the review outcome.
