#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_root="$repo_root/skills"
names_file="$(mktemp)"

trap 'rm -f "$names_file"' EXIT

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

status=0
found=0

for skill_dir in "$skills_root"/*; do
  [ -d "$skill_dir" ] || continue

  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [ ! -f "$skill_file" ]; then
    echo "Missing SKILL.md: $skill_dir" >&2
    status=1
    continue
  fi

  found=1
  frontmatter_name="$(extract_frontmatter_field "$skill_file" "name")"
  description="$(extract_frontmatter_field "$skill_file" "description")"

  if [ -z "$frontmatter_name" ]; then
    echo "Missing frontmatter name: $skill_file" >&2
    status=1
  elif [ "$frontmatter_name" != "$skill_name" ]; then
    echo "Folder '$skill_name' does not match frontmatter name '$frontmatter_name'" >&2
    status=1
  else
    printf '%s\n' "$frontmatter_name" >> "$names_file"
  fi

  if [ -z "$description" ]; then
    echo "Missing frontmatter description: $skill_file" >&2
    status=1
  fi
done

if [ "$found" -eq 0 ]; then
  echo "No skills found under $skills_root" >&2
  exit 1
fi

duplicates="$(sort "$names_file" | uniq -d)"
if [ -n "$duplicates" ]; then
  echo "Duplicate skill names:" >&2
  echo "$duplicates" >&2
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "Skills validated."
fi

exit "$status"
