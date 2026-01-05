#!/bin/bash
# detect-commit-style.sh - Determine if repository uses conventional commits
#
# Output: "conventional" or "informal"
# Exit: 0 on success, 1 if not in git repo

set -e

# Check if in git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "informal"
  exit 0
fi

# Get last 10 commit messages
COMMITS=$(git log --format='%s' -10 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
  # No commits yet, default to informal
  echo "informal"
  exit 0
fi

# Count conventional commits
# Pattern: type(scope): subject or type: subject
CONVENTIONAL=$(echo "$COMMITS" | grep -c -E '^(feat|fix|docs|style|refactor|test|chore|perf)(\(.+\))?:' || true)

# Total commits to analyze
TOTAL=$(echo "$COMMITS" | wc -l)

# If more than 50% of commits are conventional, use that style
if [ "$TOTAL" -gt 0 ]; then
  PERCENTAGE=$((CONVENTIONAL * 100 / TOTAL))
  if [ "$PERCENTAGE" -ge 50 ]; then
    echo "conventional"
  else
    echo "informal"
  fi
else
  echo "informal"
fi
