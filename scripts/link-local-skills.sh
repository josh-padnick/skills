#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_root="$repo_root/skills"
codex_skills_root="${CODEX_HOME:-$HOME/.codex}/skills"
claude_skills_root="${CLAUDE_SKILLS_HOME:-$HOME/.claude/skills}"

extract_frontmatter_field() {
  local file="$1"
  local field="$2"

  awk -v field="$field" '
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter {
      pattern = "^" field ":[[:space:]]*"
      if ($0 ~ pattern) {
        sub(pattern, "")
        gsub(/^["'\'']|["'\'']$/, "")
        print
        exit
      }
    }
  ' "$file"
}

link_skill() {
  local skill_dir="$1"
  local target_root="$2"
  local skill_name
  local link_path

  skill_name="$(basename "$skill_dir")"
  link_path="$target_root/$skill_name"

  mkdir -p "$target_root"

  if [ -L "$link_path" ]; then
    rm "$link_path"
  elif [ -e "$link_path" ]; then
    echo "Refusing to replace non-symlink: $link_path" >&2
    exit 1
  fi

  ln -s "$skill_dir" "$link_path"
  echo "Linked $link_path -> $skill_dir"
}

if [ ! -d "$skills_root" ]; then
  echo "No skills directory found: $skills_root" >&2
  exit 1
fi

found=0

for skill_dir in "$skills_root"/*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue

  found=1
  skill_name="$(basename "$skill_dir")"
  frontmatter_name="$(extract_frontmatter_field "$skill_dir/SKILL.md" "name")"

  if [ -z "$frontmatter_name" ]; then
    echo "Missing frontmatter name in $skill_dir/SKILL.md" >&2
    exit 1
  fi

  if [ "$frontmatter_name" != "$skill_name" ]; then
    echo "Skill folder '$skill_name' does not match frontmatter name '$frontmatter_name'" >&2
    exit 1
  fi

  link_skill "$skill_dir" "$codex_skills_root"
  link_skill "$skill_dir" "$claude_skills_root"
done

if [ "$found" -eq 0 ]; then
  echo "No skills with SKILL.md found under $skills_root" >&2
  exit 1
fi

echo "Restart Codex and Claude Code to refresh skill metadata."
