# PR Framing Report Template

Use this template for a reviewer briefing. Trim sections that do not apply.

## Big Picture

Explain the broader engineering problem in 1-2 sentences. Name the abstraction level above the PR's stated task as a governing design question before describing the PR's answer.

First, use the Abstraction Chain to choose the best review-useful frame: system goal -> subsystem capability -> lifecycle/operating-model question -> design direction -> implementation mechanism. Prefer a frame that names the durable engineering problem over one that names a role, tool, command, file, API, or other implementation mechanism.

The first 1 - 2 sentences should name the selected frame without mentioning implementation mechanisms.

Then create a second paragraph that summarizes the PR's answer. For migration work, prefer "how the system should maintainably manage database schema migrations" over "which database role runs migrations" or "which function runs the migration tool."

Do not assert whether the frame or PR is strong, good, correct, or successful here. Save evaluation for Assessment.

If this section names a specific database role, migration tool, command, file, route, or generated artifact as the frame, rewrite it one notch higher and move that detail to Implementation Approach, Major Tradeoffs, or What To Review.

## Abstraction Chain

Show the chain that led to the chosen frame. Build it by starting with what the PR is actually doing, climbing upward with "Why is that important?" or "So we can do what?", then returning to the starting point and descending with concise "How?" answers. Display the final chain from highest abstraction to lowest abstraction. Bold the level that is the best framing for the human reviewer. Mark the level first detected from the PR with `*`.

Use a compact table or list:

| Step | Direction | Question | Chain Level |
| --- | --- | --- | --- |
| 1 | Up | So we can do what? | Highest meaningful system or product goal. |
| 2 | Up | Why is that important? | Intermediate goal or capability. |
| 3 | Frame | Why is this the useful review frame? | **Best human-review frame.** |
| 4 | * Start | What is the PR doing? | * Concrete PR move first detected from the PR. |
| 5 | Down | How? | Concise technical approach below the starting point. |

_`*` = Abstraction level first detected from the PR title/body/diff._

Do not put best practices or principles in the chain as "how" rows. If a how answer is really a desired property, move it to Best Practice Principles and either replace it with a concrete technical mechanism or stop descending.

## Best Practice Principles

List up to 5 principles. Use more only when grouped under short labels. Start each item with an active imperative verb and idiomatic engineering language.

- **Principle**: Explanation of the invariant and why it matters. Briefly describe how reviewers should apply it.

Principles should describe lifecycle, reliability, safety, operability, and user/developer-experience invariants. Avoid principles that merely restate implementation steps. Do not evaluate the PR here. Do not include filenames, command names, database roles, APIs, tests, or verdict words; those belong in Assessment.

## This PR's Approach

Summarize the PR's design answer in 1-2 sentences. Stay above file-level details here; explain the operating-model choice, responsibility split, or contract change.

## Key Assumptions

List 3-5 assumptions that drive the review. These should be the places where a human reviewer, author, or operator needs to confirm the context because the answer would change the recommendation.

Use a compact table:

| Assumption | Confidence | Why It Matters |
| --- | --- | --- |
| Assumption stated as a claim. | Confident / Plausible / Unsure | How this assumption affects the design or review route. |

Use **Confident** when the PR, repo context, or standard engineering practice strongly supports the assumption. Use **Plausible** when it seems likely but local context matters. Use **Unsure** when the assumption materially affects the review and evidence is missing.

## Implementation Approach

Summarize the main implementation moves by subsystem. Focus on how the PR answers the principles above: lifecycle boundaries, responsibility boundaries, data flow, public contracts, operational behavior, and any role/tool/command choices.

## Assessment

Assess the PR against the principles above as one short subsection per recommendation, not as a table.

For each subsection, include:

- **Principle**: the matching best practice principle.
- **Evaluation**: Strong / Good / Moderate / Poor / Unknown.
- **Description**: evidence, caveat, or missing confirmation.
- **Recommendation**: what the reviewer should accept, ask, fix, or verify.
- **Confidence**: High / Medium / Low.

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
