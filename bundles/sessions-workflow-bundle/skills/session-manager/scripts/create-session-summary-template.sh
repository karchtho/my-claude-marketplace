#!/bin/bash
# create-session-summary-template.sh - Generate session summary template
#
# Usage: ./create-session-summary-template.sh [topic]
# Creates: docs/sessions/YYYY-MM-DD_topic.md
# Exit: 0 on success, 1 on error

set -e

# Get topic from argument or use "session"
TOPIC="${1:-session}"

# Sanitize topic (lowercase, replace spaces with hyphens)
TOPIC=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/-+/-/g' | sed 's/-$//')

# Create docs/sessions directory if missing
mkdir -p docs/sessions

# Generate filename
DATE=$(date +%Y-%m-%d)
FILENAME="docs/sessions/${DATE}_${TOPIC}.md"

# Avoid overwriting existing files on same day
COUNTER=1
BASE_FILENAME="$FILENAME"
while [ -f "$FILENAME" ]; do
  FILENAME="docs/sessions/${DATE}_${TOPIC}_${COUNTER}.md"
  COUNTER=$((COUNTER + 1))
done

# Get changed files from git (if in repo)
CHANGED_FILES=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CHANGED_FILES=$(git diff --name-status HEAD 2>/dev/null | head -10 | awk '{print "- " $2}' || echo "- [No git history]")
fi

# Create summary template
cat > "$FILENAME" << 'EOF'
# Session Summary - $(date +"%B %d, %Y")

## Session Objectives
[What were you trying to accomplish in this session? 1-2 sentences]

## Work Completed
- [Key accomplishment 1]
- [Key accomplishment 2]
- [Key accomplishment 3]

## Files Modified
EOF

# Add actual changed files if available
if [ -n "$CHANGED_FILES" ] && [ "$CHANGED_FILES" != "- [No git history]" ]; then
  echo "$CHANGED_FILES" >> "$FILENAME"
else
  echo "- [File list from git diff]" >> "$FILENAME"
fi

cat >> "$FILENAME" << 'EOF'

## Key Decisions
[If applicable: Important architectural or design decisions made in this session]

## Issues Encountered
[If applicable: Problems encountered and how they were solved]

## Next Steps
1. [Specific next action]
2. [Specific next action]
3. [Specific next action]
EOF

# Output the filename
echo "$FILENAME"
