---
name: session-start
description: Initialize and load session context including project information, CLAUDE.md memory, recent work, and git status. Use when starting a new session or needing full project context. Provides brief, efficient summaries.
allowed-tools: Bash(pwd), Bash(git branch), Bash(git status), Bash(git log), Bash(find), Read, Glob
model: haiku
---

# /session-start

Initialize a new Claude Code session with full context loading. Provides brief, efficient summaries focused on actionable information.

For educational mode with detailed explanations and learning context, use `/session-start-teach` instead.

---

## Context Loading

Load this context to understand the project:

### Project Information
- Working directory: !`pwd`
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

### Recent Work
- Last 5 commits: !`git log --oneline -5`
- Available session files: !`find docs/sessions -name "*.md" -type f 2>/dev/null`

### Project Guidelines
See @CLAUDE.md for complete project guidance, conventions, and instructions.

### Available Documentation
Documentation files: !`find docs -maxdepth 3 -type f \( -name "README.md" -o -name "INDEX.md" \) 2>/dev/null`

**Note**: Documentation is listed but not loaded to conserve tokens. Suggest specific files if relevant to the user's work.

---

## Instructions

### Your Task

1. **Load project guidelines** - Review @CLAUDE.md to understand project structure, conventions, and any special instructions
2. **Check recent work** - Look at the available session files and understand what was recently accomplished
3. **Assess current state** - Note the git branch, any uncommitted changes, and overall project health
4. **Review available docs** - Note if documentation is available (but don't load it)
5. **Summarize briefly** - Provide a concise summary (max 300 words) of key information
6. **Ask what's next** - Simple question: "What would you like to work on today?"

### Response Format

Provide a brief session summary:

```
📚 Session Context Loaded

✓ Current branch: [branch name]
✓ Git status: [uncommitted changes summary]
✓ Documentation: [number] files available in docs/
✓ Project guidelines: [key constraints from CLAUDE.md]
✓ Previous work: [summary from latest session file, if any]

What would you like to work on today?
```

### Guidelines
- Keep response under 300 words
- Be concise and actionable
- Focus on information that affects today's work
- Mention documentation availability but don't describe contents
- If documentation is relevant, suggest a specific file (e.g., "I found docs/technical/README.md which might be helpful")

---

## Notes

- Missing files (CLAUDE.md, session history, docs/) should not block session start - handle gracefully
- Always gracefully handle missing directories or files
- Keep summary brief (~300 words max) to save tokens
- Focus on critical information that affects today's work
- For educational mode with detailed explanations, use `/session-start-teach` instead
