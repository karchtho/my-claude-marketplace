---
name: session-start
description: Initialize and load session context including project information, CLAUDE.md memory, recent work, and git status. Use when starting a new session or needing full project context. Supports --teacher flag for educational mode.
allowed-tools: Bash(pwd), Bash(git branch), Bash(git status), Bash(git log), Bash(find), Bash(head), Read, Glob, Grep
model: haiku
---

# /session-start

Initialize a new Claude Code session with full context loading.

## Arguments

- `--teacher` (optional): Enable teacher mode with educational explanations, learning context, and interactive guidance

---

## ⚠️ MODE DETECTION - READ THIS FIRST

**CRITICAL**: Check if the `--teacher` flag was provided when this command was invoked.

### If `--teacher` flag IS PRESENT:
→ **ACTIVATE TEACHER MODE** (skip to "🎓 TEACHER MODE INSTRUCTIONS" section below)
→ Follow teacher mode instructions exclusively
→ Do NOT follow standard mode instructions

### If `--teacher` flag IS NOT PRESENT:
→ **ACTIVATE STANDARD MODE** (skip to "📋 STANDARD MODE INSTRUCTIONS" section below)
→ Follow standard mode instructions exclusively
→ Do NOT follow teacher mode instructions

**You MUST choose ONE mode. Do NOT blend instructions from both modes.**

---

## Context Loading (Applies to ALL Modes)

Load this context regardless of which mode is active:

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

## 📋 STANDARD MODE INSTRUCTIONS

**Use this section ONLY if `--teacher` flag is NOT present.**

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

## 🎓 TEACHER MODE INSTRUCTIONS

**Use this section ONLY if `--teacher` flag IS present.**

### Your Task

1. **Explain your process** - Narrate each step as you load context and explain why it matters
2. **Provide learning context** - Explain patterns, conventions, and best practices
3. **Share insights** - Connect observations to industry standards and project decisions
4. **Ask follow-up questions** - Encourage deeper understanding and critical thinking
5. **Present alternatives** - Show multiple approaches with trade-offs explained
6. **Invite exploration** - Suggest areas to learn more about

### Teacher Mode Behavior

Enhance your response with educational content:

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

### Response Format

Provide an expanded educational response:

```
📚 Session Context Loaded (Teacher Mode)

🔍 Context Discovery Process:
[Narrate what you did and why - explain each step taken to load context]

✓ Current branch: [branch name]
  → [Explain what this branch represents and why it matters]

✓ Git status: [uncommitted changes summary]
  → [Explain implications of uncommitted changes]

✓ Documentation: [count] files found
  → [Explain what documentation exists]
  → [Offer to review specific docs if relevant]
  → [Educational insight about documentation structure]

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

### Guidelines
- Responses can be 500-700 words (educational priority, not brevity)
- Explain the "why" behind everything
- Ask questions that encourage critical thinking
- Present multiple approaches with trade-offs
- Suggest documentation reviews when relevant to the work
- Focus on helping the user understand project patterns and practices

---

## Notes

- Missing files (CLAUDE.md, session history, docs/) should not block session start - handle gracefully
- Always gracefully handle missing directories or files
- Standard mode: Keep summary brief (~300 words max) to save tokens
- Teacher mode: Responses will be longer (500-700 words) to include educational content
- Focus on critical information that affects today's work
- In teacher mode, prioritize learning and understanding over brevity
