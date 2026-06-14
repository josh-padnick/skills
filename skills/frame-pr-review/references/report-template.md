# PR Framing Report Template

Use this template for a reviewer briefing. Trim sections that do not apply.

## Big Picture

Explain the broader engineering problem in 2-4 sentences. Name the abstraction level above the PR's stated task as a governing design question before describing the PR's answer.

First, choose the highest review-useful frame from an implicit ladder: system goal -> subsystem capability -> lifecycle/operating-model question -> design direction -> implementation mechanism. Prefer "how should the system manage X across its lifecycle?" over a frame that names a role, tool, command, file, API, or other implementation mechanism.

## Frame Challenge

State whether the PR appears to be solving the right problem. Include:

- The stronger framing as a lifecycle, ownership, timing, or responsibility question.
- The design question a reviewer should keep asking while reading the diff.
- Any alternative approaches that deserve comparison.

If your frame names a specific database role, migration tool, command, file, route, or generated artifact, check whether that is really the frame or just evidence for a broader frame.

## Governing Principles

List 3-7 principles. For each, give a short verdict and evidence:

- **Principle**: upheld / partial / violated / unproven. Evidence or concern.

## Approach Taken

Summarize the main implementation moves by subsystem. Focus on responsibility boundaries, lifecycle changes, data flow, public contracts, and operational behavior.

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
