# PR Framing Report Template

Use this template for a reviewer briefing. Trim sections that do not apply.

## Big Picture

Explain the broader engineering problem in 2-4 sentences. Name the abstraction level above the PR's stated task as a governing design question before describing the PR's answer.

First, choose the highest review-useful frame from an implicit ladder: system goal -> subsystem capability -> lifecycle/operating-model question -> design direction -> implementation mechanism. Prefer "how should the system manage X across its lifecycle?" over a frame that names a role, tool, command, file, API, or other implementation mechanism.

The first sentence should name the selected frame without mentioning implementation mechanisms. The second sentence can summarize the PR's answer. For migration work, prefer "where database schema evolution belongs in the application lifecycle" over "which database role runs migrations."

Fold the frame challenge into this section instead of creating a separate default heading. State whether the PR appears to be solving the right problem and name the main design question a reviewer should keep in mind. Mention alternatives only when they clarify the principles or would change the review outcome.

If this section names a specific database role, migration tool, command, file, route, or generated artifact as the frame, rewrite it one notch higher and move that detail to Approach, Tradeoffs, or What To Review.

## Key Assumptions

List 3-5 assumptions that drive the review. These should be the places where a human reviewer, author, or operator needs to confirm the context because the answer would change the recommendation.

Use a compact table:

| Assumption | Confidence | Why It Matters |
| --- | --- | --- |
| Assumption stated as a claim. | Confident / Plausible / Unsure | How this assumption affects the design or review route. |

Use **Confident** when the PR, repo context, or standard engineering practice strongly supports the assumption. Use **Plausible** when it seems likely but local context matters. Use **Unsure** when the assumption materially affects the review and evidence is missing.

## Governing Principles

List 3-7 principles. Start each item with the principle itself, phrased independently of the implementation. Add 1-2 concise sentences explaining what it means, why it matters, and how to apply it.

- **Principle**: Explanation of the invariant and why it matters. Briefly describe how reviewers should apply it.

Principles should describe lifecycle, reliability, safety, operability, and user/developer-experience invariants. Avoid principles that merely restate implementation steps.
Do not evaluate the PR here. Do not include filenames, command names, database roles, APIs, tests, or verdict words; those belong in Assessment.

## Approach Taken

Summarize the main implementation moves by subsystem. Focus on how the PR answers the principles above: lifecycle boundaries, responsibility boundaries, data flow, public contracts, operational behavior, and any role/tool/command choices.

## Assessment

Assess the PR against the principles above. Use one row per principle unless a principle cannot be evaluated from the diff.

| Principle | Evaluation | Description |
| --- | --- | --- |
| Principle name from above. | Strong / Good / Moderate / Poor / Unknown | Brief evidence, caveat, or missing confirmation. |

Use **Strong** when the PR convincingly satisfies the principle with implementation plus tests/docs/ops wiring; **Good** when it mostly satisfies it with minor caveats; **Moderate** when important behavior, tests, docs, or ownership remain unclear; **Poor** when the PR conflicts with the principle or leaves a high-risk gap; and **Unknown** when evidence is insufficient without author or operator input.

## Major Tradeoffs

Describe the largest tradeoffs as two short lists:

**What Improves**

- Concrete improvement.

**What We Give Up**

- Concrete cost, lost convenience, new obligation, or future risk.

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
