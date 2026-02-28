---
name: session-manager
description: Activates when the user asks to "create session summary", "summarize this session", "end the session", "start a session", "load context", "what did we work on", "session notes", "document this session", or wants to track, document, and manage work sessions.
version: 2.0.0
---

# Session Manager Skill

Flexible session management for projects using the sessions-workflow-bundle. Use the slash commands for automated workflow, or ask this skill for interactive help.

## Session Lifecycle

```
/session-start          ← load context + memory
  ↓ work on tasks
/session-end            ← write memory + commit
```

Memory persists in `~/.claude/projects/<project-path>/memory/`:
- `sessions.md` — append-only log of past sessions
- `MEMORY.md` — stable patterns, gotchas, key decisions

## Commands

| Command | When to use |
|---------|-------------|
| `/init-project` | First time on a project — scaffolds CLAUDE.md with project conventions and session settings |
| `/session-start` | Beginning of every session — loads context and memory |
| `/session-end` | End of every session — writes memory entry and commits |

## Teacher Mode

Teacher mode is a **CLAUDE.md setting**, not a separate command.

In your project's `CLAUDE.md`, under `## Session Settings`:
```markdown
## Session Settings
- **Teacher Mode**: enabled
```

When enabled, `/session-start` responds with 400-600 words — narrating context, explaining patterns, and proposing 2-3 paths forward with trade-offs.

When disabled (default), `/session-start` responds in ≤200 words with a bullet summary.

To set up CLAUDE.md (including teacher mode): run `/init-project`.

## Use Cases

**Understand current state** — "What did we work on in the last session?"
→ This skill reads `memory/sessions.md` and surfaces recent entries.

**Track progress mid-session** — "How many files have we changed so far?"
→ Checks git status and summarizes staged/unstaged changes.

**Document insights** — "Note this for next session: null values break auth middleware"
→ Appends a note to the current session's memory entry.

**Review project constraints** — "What does CLAUDE.md say about architecture?"
→ Reads CLAUDE.md and extracts key patterns and rules.

## Best Practices

**Do:**
- Run `/session-start` at the start of every session
- Run `/session-end` at the end — it writes memory and commits
- Run `/init-project` once per project to scaffold CLAUDE.md

**Don't:**
- Write exhaustive summaries — 100 words per session entry is enough
- Skip `/session-start` — you'll miss memory from previous sessions
- Mix unrelated work in one session — hard to summarize accurately

## Integration

Works with any project and any other bundle. Sessions build project memory over time, so every `/session-start` gets better as the project evolves.
