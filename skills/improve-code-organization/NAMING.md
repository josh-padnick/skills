# Naming

How to evaluate and improve file names. Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **name**, **scope**, **predictiveness**, **drift**.

A name is a **promise**. The whole file should be derivable from its name; the file's path should be guessable from a description of what it does. When that fails, the name is wrong — or the scope is.

## Symptoms of a bad name

- **Generic** — `utils.ts`, `helpers.py`, `common.go`, `misc.js`. Holds anything, predicts nothing.
- **Drifted** — name describes 30% of what's inside. The file was once correct; it grew.
- **Under-promising** — `parser.ts` when the file is specifically `csv-row-parser.ts`. Forces the reader to open the file to learn what it parses.
- **Over-promising** — `auth.ts` when the file is specifically `session-cookie-validator.ts`. The next person adds JWT logic and now `auth.ts` lives up to its name in a chaotic way.
- **Implementation-leaking** — `redis-cache.ts` when the consumers don't care it's Redis. The name should describe the role, not the technology, unless the technology is the point.
- **Abbreviation-y** — `usr_mgr.ts`. Save a few characters, lose tab-completion and grepability.
- **Plural without reason** — `users.ts` for a single function `getUser`. Plural suggests a collection; use it when there is one.
- **Suffix soup** — `userServiceHelperFactoryImpl.ts`. Each suffix was added to disambiguate from the last layer of suffixes. The pattern is the problem, not the latest suffix.

## Tests to apply

- **Stranger test.** If a developer who has never seen the codebase reads only the file name, what do they expect to find inside? Open the file. How wide is the gap?
- **Search test.** If you wanted to add a new function to do X, would you search for the file by guessing a name? Try it. Did you land where it actually lives?
- **Inverse test.** Pick a function inside the file. From the function alone, would you guess this file name? If no, either the function is in the wrong file or the file is named wrong.
- **Drift test.** Compare the name against the current contents — not what the file held when it was created. Drift is the most common naming failure and the hardest to see from inside.

## What good names do

- **Predict scope.** `order-pricing.ts` predicts code about pricing orders. Open it, you find pricing for orders. Done.
- **Match the domain language.** If `CONTEXT.md` (or the team's conversation) calls the concept "intake," name the file `order-intake.ts`, not `order-receiver.ts` or `order-handler.ts`.
- **Match the right level of specificity.** `auth.ts` for a small project's whole auth surface is fine; `auth.ts` for a 500-line file in a system with 12 auth concerns is too generic.
- **Read as a noun phrase or a clear verb.** `csv-row-parser`, `cancel-subscription`, `pricing-rules` — each is a phrase a reader can hold in their head.

## When to fix the name vs. fix the scope

When name and scope mismatch, decide which is wrong:

- **If the scope is right but mixed across one file**: split the file, give each part its own correct name.
- **If the scope is right and tight, but the name is generic or misleading**: rename only.
- **If the scope is fragmented across many files with similar-but-different names**: probably one well-named file would do; merge.
- **If the name promises something that lives in another file**: the name is a lie — rename, then check whether anything elsewhere is depending on the misleading name.

## Mechanics

- Use the version-control rename (`git mv`) so history follows the file. Copy-paste rename loses blame.
- Use the language-server rename for symbols inside the file at the same time, when the file's exported symbol shares a name with the file.
- Update imports atomically. A renamed file with stale imports is worse than no rename.
- If the rename is large, do one rename per commit. Easier to revert.
