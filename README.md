# Skills

Version-controlled AI skills for Codex and Claude Code.

## Layout

Each skill lives under `skills/<skill-name>/`:

```text
skills/
  improve-code-organization/
    SKILL.md
    references/
      LANGUAGE.md
      FOLDERS.md
      NAMING.md
      SCOPING.md
      SMELLS.md
      HTML-REPORT.md
```

`SKILL.md` is the entry point. Its YAML frontmatter must include `name` and `description`, and the `name` should match the folder name.

Keep detailed supporting material in `references/` and link to it from `SKILL.md`. That keeps the always-loaded skill metadata small while still making deeper instructions available when the skill is invoked.

## Local setup

Use symlinks so Codex and Claude Code both read the version-controlled files from this checkout:

```bash
./scripts/link-local-skills.sh
```

The script links every `skills/*/SKILL.md` folder into:

```text
~/.codex/skills/<skill-name>
~/.claude/skills/<skill-name>
```

It refuses to overwrite a non-symlink at either destination.

If your Codex home is somewhere other than `~/.codex`, set `CODEX_HOME`:

```bash
CODEX_HOME=/path/to/codex-home ./scripts/link-local-skills.sh
```

If your Claude Code skills directory is somewhere other than `~/.claude/skills`, set `CLAUDE_SKILLS_HOME`:

```bash
CLAUDE_SKILLS_HOME=/path/to/claude-skills ./scripts/link-local-skills.sh
```

Restart Codex and Claude Code after linking, adding a new skill, or changing a skill's `name` or `description`.

## Development workflow

1. Edit the skill files in this repo.
2. Run `./scripts/validate-skills.sh`.
3. Restart Codex or Claude Code if you changed skill metadata.
4. Commit the repo changes.

Because the installed skills are symlinks, body edits to `SKILL.md` and files under `references/` are available from the same checkout immediately. If an agent appears to use stale instructions, start a new session.

For Conductor workspaces, prefer linking from a stable checkout of this repo when you want skills to remain stable across workspaces. Link from a Conductor workspace branch only when you intentionally want that branch's skill edits to be the active local version.
