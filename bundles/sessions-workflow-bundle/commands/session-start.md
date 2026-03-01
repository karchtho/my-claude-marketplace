---
name: session-start
description: Initialize and load session context including project information, CLAUDE.md memory, recent work, and git status. Use when starting a new session or needing full project context. Provides brief, efficient summaries.
allowed-tools: Bash(pwd), Bash(git branch), Bash(git status), Bash(git log), Bash(ls), Read, Glob
model: haiku
---

# /session-start

Initialize a new Claude Code session with full context loading.

---

## Context Loading

### Project Information
- Working directory: !`pwd`
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Recent commits: !`git log --oneline -5`

### Project Guidelines
See @CLAUDE.md if it exists.

---

## Instructions

### Step 1: CLAUDE.md Check

**If CLAUDE.md exists:**
- Read it to understand project structure, conventions, constraints
- Look for a `## Session Settings` section
- Check if `Teacher Mode` is set to `enabled` or `disabled`
- Extract any key constraints (e.g., package manager, commit style)

**If CLAUDE.md is missing:**
- Warn: "No CLAUDE.md found. Run `/init-project` to scaffold one with project conventions and session settings."
- Continue with defaults: teacher mode off, no project-specific constraints

### Step 2: Load Memory

Compute memory dir: `~/.claude/projects/$(pwd | sed 's|/|-|g')/memory/`

If the memory directory exists:
- Read `sessions.md` → surface the last 5-10 session entries
- Read `MEMORY.md` → stable patterns and constraints
- Pull what's relevant to the current branch/git state

If the memory directory doesn't exist: note that this is the first session.

### Step 3: Respond in the correct mode

**Teacher Mode DISABLED (default):**

Respond ≤200 words in this format:
```
📚 Session Context Loaded

✓ Branch: [branch name]
✓ Status: [uncommitted changes, or "clean"]
✓ Recent work: [1-2 sentence summary from memory, or "first session"]
✓ Key constraints: [from CLAUDE.md, or "none detected — run /init-project"]

What would you like to work on today?
```

**Teacher Mode ENABLED** (only when CLAUDE.md has `Teacher Mode: enabled`):

Respond 400-600 words:
- Narrate context loading: explain what each piece of information means
- Summarize previous work with explanation of decisions made
- Propose 2-3 paths forward with trade-offs
- Invite the user to choose: "What would you like to explore today?"

---

## Notes

- CLAUDE.md absence is a warning, not an error — always continue
- Memory absence is normal on first session — say so and move on
- Never fail silently: if something is missing, name it
- Keep standard mode brief — the user wants to get to work
