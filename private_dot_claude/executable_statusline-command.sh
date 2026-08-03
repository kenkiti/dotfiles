#!/bin/bash
input=$(cat)

extract() {
  # extract("key") -> value of the first top-level-ish "key":"value" or "key":number match
  echo "$input" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed -E 's/.*:[[:space:]]*"(.*)"/\1/'
}
extract_num() {
  echo "$input" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[0-9.]*" | head -1 | sed -E 's/.*:[[:space:]]*//'
}

project_dir=$(extract "project_dir")
project_name=$(basename "$project_dir")

model=$(extract "display_name")

used=$(extract_num "used_percentage")
if [ -n "$used" ]; then
  ctx=$(printf '%.0f%%' "$used")
else
  ctx="--"
fi

branch=$(git --no-optional-locks -C "$project_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -z "$branch" ]; then
  branch="no-git"
fi

printf '\033[1;97;46m %s \033[0m \033[2m|\033[0m \033[32mgit:%s\033[0m \033[2m|\033[0m \033[33m%s\033[0m \033[2m|\033[0m \033[35mctx:%s\033[0m\n' \
  "$project_name" "$branch" "$model" "$ctx"
