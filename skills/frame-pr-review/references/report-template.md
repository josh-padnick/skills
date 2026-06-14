# PR Framing Report Template

Use this template for a reviewer briefing. Trim sections that do not apply.

## Big Picture

Explain the broader engineering problem in 2-4 sentences. Name the abstraction level above the PR's stated task.

## Frame Challenge

State whether the PR appears to be solving the right problem. Include:

- The stronger framing.
- The design question a reviewer should keep asking.
- Any alternative approaches that deserve comparison.

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
