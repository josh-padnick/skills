# Language

Shared vocabulary for every suggestion this skill makes. Use these terms exactly — don't substitute "module," "component," "package," or "section." Consistent language is the whole point.

## Terms

**File**
The unit of code on disk. Has a **name** and a **scope**. Deliberately neutral about granularity (a file can hold one function or a whole subsystem) — the question is whether the scope inside matches the name on the outside.
_Avoid_: module, unit, source.

**Name**
What the file is called, including extension. A name is a **promise** about what's inside; a good name is also a **prediction tool** for readers searching the tree.
_Avoid_: label, title.

**Scope**
The set of concerns inside a file. Three failure modes:
- **Tight** (good) — one clear concern, cohesive.
- **Mixed** — two or more unrelated concerns sharing one file.
- **Fragmented** — one concern split across many files when one would suffice.

**Cohesion**
Degree to which the things inside a file belong together. High cohesion means a reader who understands one item in the file can guess why the others are there. Low cohesion is the symptom of **mixed scope**.

**Co-location**
Placing things that change together physically near each other on disk. A correct folder co-locates files that change together; an incorrect folder either separates them or bundles unrelated files.

**Folder**
A grouping that names a real architectural concept. A folder is a **claim** about what's inside. Broad shared names (`lib/`, `shared/`, `common/`) can be legitimate project conventions; generic names (`utils/`, `helpers/`, `misc/`) can also be fine when scoped. The smell is an unbounded folder that makes no checkable claim and tends to become a junk drawer.
_Avoid_: directory (mechanically correct but loses the "claim" connotation), package, namespace.

**Drift**
When a file's contents have grown beyond what its name suggests. The most common organization failure: nobody added a file with mismatched name, the file simply accumulated.

**Predictiveness**
The central property of good organization. A name is predictive if a reader can guess the scope from it; a folder is predictive if a reader can guess which file holds the thing they want. The whole skill aims at predictiveness.

## Relationships

- A **File** has exactly one **Name** and one **Scope**.
- A **Folder** contains **Files** (and possibly sub-folders), and its name should predict their **Scope**.
- **Cohesion** is a property of a **File** (how well its contents belong together).
- **Co-location** is a property of a **Folder** (how well it groups files that change together).
- **Predictiveness** is the cross-cutting test that applies to both **Names** and **Folders**.
