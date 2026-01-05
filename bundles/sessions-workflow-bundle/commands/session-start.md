---
name: session-start
description: Initialize and load session context including project information, CLAUDE.md memory, recent work, and git status. Use when starting a new session or needing full project context.
allowed-tools: Bash(pwd), Bash(git branch), Bash(git status), Bash(git log), Read, Glob
model: haiku
---

# /session-start

Initialize a new Claude Code session with full context loading.

## Current Session Information

Project directory: !`pwd`
Current git branch: !`git branch --show-current`
Repository status: !`git status --short`

## Recent Commits

!`git log --oneline -5`

## Project Memory

See @CLAUDE.md for complete project guidance and instructions.

## Available Session History

Available session files: !`find docs/sessions -name "*.md" -type f 2>/dev/null`

## Your Task

Using the context loaded above:

1. **Load project guidelines** - Review @CLAUDE.md to understand project structure, conventions, and any special instructions
2. **Check recent work** - Look at the available session files and understand what was recently accomplished
3. **Assess current state** - Note the git branch, any uncommitted changes, and overall project health
4. **Summarize for the user** - Provide a brief summary (max 300 words) of:
   - Key project guidelines and constraints
   - What was done in the previous session
   - Current git state and any pending work
5. **Ask what's next** - Simple question: "What would you like to work on today?"

## Expected Response

You should provide a brief session summary in this format:

```
📚 Session Context Loaded

✓ Current branch: [branch name]
✓ Git status: [uncommitted changes summary]
✓ Project guidelines: [key constraints from CLAUDE.md]
✓ Previous work: [summary from latest session file, if any]

What would you like to work on today?
```

## Notes

- Missing files (CLAUDE.md, session history) should not block session start
- Always gracefully handle missing directories or files
- Keep the summary brief (~300 words max) to save tokens
- Focus on critical information that affects today's work
