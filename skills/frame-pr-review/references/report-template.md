# PR Framing Report Template

Use this template for a reviewer briefing. Trim sections that do not apply.

## Big Picture

Explain the broader engineering problem in 1-2 sentences. Name the abstraction level above the PR's stated task as a governing design question before describing the PR's answer.

First, use the Abstraction Chain to choose the best review-useful frame: system goal -> subsystem capability -> lifecycle/operating-model question -> design direction -> implementation mechanism. Prefer a frame that names the durable engineering problem over one that names a role, tool, command, file, API, or other implementation mechanism.

The first 1 - 2 sentences should name the selected frame without mentioning implementation mechanisms.

Then create a a second paragraph that summarizes the PR's answer. For migration work, prefer "how the system should maintainably manage database schema migrations" over "which database role runs migrations" or "which function runs the migration tool."

If this section names a specific database role, migration tool, command, file, route, or generated artifact as the frame, rewrite it one notch higher and move that detail to Approach, Tradeoffs, or What To Review.

## Abstraction Chain

Show the chain that led to the chosen frame. Start with what the PR is actually doing, climb upward with "Why is that important?" or "So we can do what?", then return to the starting point and descend with concise "How?" answers. Bold the level that is the best framing for the human reviewer.

Use a compact table or list:

| Step | Direction | Question | Chain Level |
| --- | --- | --- | --- |
| 1 | Start | What is the PR doing? | Concrete PR move. |
| 2 | Up | Why is that important? | Higher-level goal or capability. |
| 3 | Up | So we can do what? | Broader system goal. |
| 4 | Down | How? | Concise technical approach below the starting point. |

Do not put best practices or principles in the chain as "how" rows. If a how answer is really a desired property, move it to Governing Principles and either replace it with a concrete technical mechanism or stop descending.

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
