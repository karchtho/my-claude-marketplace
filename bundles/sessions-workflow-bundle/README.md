# Sessions Workflow Bundle

Session management for Claude Code — load project context at the start of every session and automatically document your work at the end. Session history is stored in Claude's auto-memory directory, not in your project repo.

## Commands

| Command | Purpose |
|---------|---------|
| `/init-project` | Scaffold a CLAUDE.md for the current project (run once) |
| `/session-start` | Load context + memory at the start of a session |
| `/session-end` | Write memory entry + commit at the end of a session |

## Quick Start

```bash
# 1. First time on a project — scaffold CLAUDE.md
/init-project

# 2. Start every session
/session-start

# ... do your work ...

# 3. End every session
/session-end
```

## How It Works

### Memory-Based History

Session history lives in Claude's auto-memory directory — not in your project:

```
~/.claude/projects/<project-path>/memory/
├── sessions.md   ← append-only session log
└── MEMORY.md     ← stable patterns, gotchas, key decisions
```

`/session-start` reads this memory to surface relevant history. `/session-end` appends a new entry (≤100 words). Your project repo stays clean.

### Teacher Mode

Teacher mode is a **CLAUDE.md setting**, not a separate command.

In your CLAUDE.md under `## Session Settings`:
```markdown
## Session Settings
- **Teacher Mode**: enabled
```

- **Disabled (default)**: `/session-start` responds in ≤200 words — branch, status, recent work, key constraints
- **Enabled**: `/session-start` responds in 400-600 words — narrates context, explains patterns, proposes 2-3 paths with trade-offs

Run `/init-project` to create a CLAUDE.md with this section pre-filled.

### `/init-project` Flow

1. Analyzes your project: stack, package manager, key dirs, commit style, branch patterns
2. Drafts a CLAUDE.md (~300 lines, no filler)
3. Asks: enable teacher mode? Any constraints missed? Anything to add?
4. Writes CLAUDE.md incorporating your answers

### `/session-start` Flow

1. Checks for CLAUDE.md — warns + suggests `/init-project` if missing
2. Reads `Teacher Mode` setting from CLAUDE.md
3. Loads memory: last 5-10 session entries from `sessions.md`, stable patterns from `MEMORY.md`
4. Responds in the correct mode (brief or educational)

### `/session-end` Flow

1. Appends session entry to `~/.claude/projects/.../memory/sessions.md`
2. Updates `MEMORY.md` if stable new insights were gained
3. Detects commit style (conventional vs informal) from git log
4. Stages and commits all changes

## File Structure

```
sessions-workflow-bundle/
├── commands/
│   ├── init-project.md    # CLAUDE.md scaffolding
│   ├── session-start.md   # Load context + memory
│   └── session-end.md     # Write memory + commit
├── skills/
│   └── session-manager/   # Flexible session workflows (skill-based)
│       ├── SKILL.md
│       └── scripts/
└── .claude-plugin/
    └── plugin.json
```

## Integration with Other Bundles

Works with any project and any other bundle. Memory accumulates over time, so every `/session-start` gets better context as the project evolves.

---

MIT License
