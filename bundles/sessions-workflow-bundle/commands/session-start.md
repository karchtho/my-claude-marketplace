---
description: Initialize session with project context loading
allowed-tools: Read(CLAUDE.md), Read(README.md), Read(docs/sessions/**), Glob(docs/sessions/), Bash(git branch), Bash(git status), Bash(git log)
model: haiku
---

# /session-start

Initialize a new Claude Code session with full context loading.

## Context

- Git status: !`git status --short 2>/dev/null || echo "Not in git repo"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "N/A"`
- Latest session: !`ls -t docs/sessions/*.md 2>/dev/null | head -1 || echo "None"`

## Your Task

Execute these steps **in order**:

1. **Load Latest Session Context** (if exists)
   - Check if `docs/sessions/` directory exists
   - Find the most recent session summary file
   - Read ONLY the key sections: objectives, work completed, next steps
   - Report what was accomplished and what's next

2. **Load Project Guidelines** (if exists)
   - Check if `CLAUDE.md` exists
   - Read only the first 50 lines (summary sections)
   - Note key architecture, commands, patterns, tools

3. **Load Project Overview** (if exists)
   - Check if `README.md` exists
   - Read ONLY the first 100 lines (overview section)
   - Get project purpose, key features, structure

4. **Detect Environment**
   - **Project type**: Check for `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, or `pom.xml`
   - **Available skills**: Parse installed plugins from context above (React, Angular, etc.)
   - **Git state**: From context above - current branch, unstaged changes, if repo exists

5. **Summarize Context** (max 300 words total)
   - Report what was loaded and what's available
   - Highlight critical constraints or decisions from previous sessions
   - List key next steps from previous session
   - Note any available expertise from installed plugins

6. **Ask what to work on**
   - Simple question: "What would you like to work on today?"

## Response Format

```
📚 Loading context...

✓ Latest session: [file name] - [1-2 key points]
✓ CLAUDE.md loaded - [1-2 key guidelines]
✓ README.md loaded - [1-2 key features]
✓ Project: [type detected]
✓ Git: [branch name, any uncommitted changes]
✓ Skills: [detected plugins]

Ready to work! What would you like to focus on?
```

## Context Loading Rules

- **Non-blocking**: Missing files should NOT prevent session start
- **Selective reading**: Use first N lines only, avoid loading full files
- **Compact git**: Use `--short`, `--oneline` for minimal tokens
- **No errors**: Handle all missing directories/files gracefully
- **Focus on key info**: Report only critical context, not exhaustive details

## Examples

### Example 1: Fresh Project (No Previous Sessions)

```
📚 Loading context...

✗ No previous sessions found
✓ CLAUDE.md loaded - Using strict TypeScript, conventional commits required
✓ README.md loaded - Build a Node.js API server
✓ Project: Node.js backend
✓ Git: main branch, 2 files unstaged
✓ Skills: None detected yet

Ready to work! What would you like to focus on?
```

### Example 2: Continuing Previous Work

```
📚 Loading context...

✓ Latest session: 2026-01-04_bundle-maker.md
  - Created dev-toolkit-bundle automation
  - Next: Test bundle creation workflow

✓ CLAUDE.md loaded - No placeholders policy, bundle structure documented
✓ README.md loaded - Skills marketplace with React and dev toolkit bundles
✓ Project: Claude Code plugins marketplace
✓ Git: main branch, 1 file staged (session summary)
✓ Skills: React patterns (UI/UX design), Bundle maker

Ready to work! What would you like to focus on?
```

### Example 3: Multi-Stack Project

```
📚 Loading context...

✓ Latest session: 2025-12-20_auth-implementation.md
  - Implemented JWT authentication
  - Need: Refresh token logic, tests

✓ CLAUDE.md loaded - TypeScript strict, Jest testing, Zustand state
✓ README.md loaded - Full-stack e-commerce platform (React + Node.js)
✓ Project: Full-stack (React frontend + Node.js backend)
✓ Git: feature/auth branch, 8 files modified
✓ Skills: React patterns, UI/UX design

Ready to work! What would you like to focus on?
```

## Error Handling

If a context source can't be loaded, report it but continue:

```
⚠️ Could not read CLAUDE.md - continuing without guidelines
```

Never block session start on missing files.

## Token Budget

This command uses **~1500-2000 tokens maximum**:
- Dynamic context injection: ~200-300 tokens (executed server-side)
- File reading (selective, first N lines): ~500-1000 tokens
- Analysis and summary: ~300-500 tokens
- Response formatting: ~200 tokens
