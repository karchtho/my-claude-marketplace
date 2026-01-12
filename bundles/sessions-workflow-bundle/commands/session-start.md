---
name: session-start
description: Initialize and load session context including project information, CLAUDE.md memory, recent work, and git status. Use when starting a new session or needing full project context. Supports --teacher flag for educational mode.
allowed-tools: Bash(pwd), Bash(git branch), Bash(git status), Bash(git log), Read, Glob
model: haiku
---

# /session-start

Initialize a new Claude Code session with full context loading.

## Arguments

- `--teacher` (optional): Enable teacher mode with educational explanations, learning context, and interactive guidance

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

### Teacher Mode Behavior

**If the `--teacher` flag is provided**, enhance your response with educational content:

1. **Explain every action**
   - Narrate what you're doing: "I'm reading CLAUDE.md to understand project conventions..."
   - Explain why: "Checking git status helps identify uncommitted work that might affect today's tasks"
   - Show your reasoning: "Based on the previous session, I notice you were working on X, so I'll focus on related patterns"

2. **Provide learning context**
   - Add educational notes: "This project uses conventional commits, which help generate changelogs automatically"
   - Explain best practices: "Session summaries create project memory, making it easier to resume work after breaks"
   - Share pattern insights: "I notice this codebase follows [specific pattern], which is useful because..."

3. **Ask follow-up questions**
   - After summarizing previous work: "Do you understand why the previous session chose approach X over Y?"
   - About current state: "Would you like me to explain any unfamiliar patterns in the codebase?"
   - For next steps: "Would you prefer to continue the previous work or start something new? Let me explain the trade-offs..."

4. **Show alternative approaches**
   - Present multiple paths: "We could approach today's work by: A) continuing feature X, B) addressing technical debt, or C) adding tests"
   - Explain trade-offs: "Approach A is faster but approach B reduces future maintenance burden"
   - Encourage critical thinking: "What factors are most important for your decision?"

## Expected Response

### Standard Mode

You should provide a brief session summary in this format:

```
📚 Session Context Loaded

✓ Current branch: [branch name]
✓ Git status: [uncommitted changes summary]
✓ Project guidelines: [key constraints from CLAUDE.md]
✓ Previous work: [summary from latest session file, if any]

What would you like to work on today?
```

### Teacher Mode (with --teacher flag)

Provide an expanded educational response with:

```
📚 Session Context Loaded (Teacher Mode)

🔍 Context Discovery Process:
[Narrate what you did and why - explain each step taken to load context]

✓ Current branch: [branch name]
  → [Explain what this branch represents and why it matters]

✓ Git status: [uncommitted changes summary]
  → [Explain implications of uncommitted changes]

✓ Project guidelines: [key constraints from CLAUDE.md]
  → [Provide learning context about these patterns/conventions]
  → [Explain why these guidelines exist]

✓ Previous work: [summary from latest session file]
  → [Explain the decisions made in previous session]
  → [Highlight key patterns or techniques used]

💡 Learning Points:
- [Educational insight 1]
- [Educational insight 2]
- [Best practice observation]

🤔 Discussion Questions:
- [Follow-up question about previous work]
- [Question about understanding project patterns]
- [Question about user's preferences for today's work]

🛤️ Possible Paths Forward:
A) [Option 1] - [Trade-offs and reasoning]
B) [Option 2] - [Trade-offs and reasoning]
C) [Option 3] - [Trade-offs and reasoning]

What would you like to explore today?
```

## Notes

- Missing files (CLAUDE.md, session history) should not block session start
- Always gracefully handle missing directories or files
- Keep the summary brief (~300 words max) to save tokens in standard mode
- Teacher mode responses will be longer (up to 500-700 words) to include educational content
- Focus on critical information that affects today's work
- In teacher mode, prioritize learning and understanding over brevity
