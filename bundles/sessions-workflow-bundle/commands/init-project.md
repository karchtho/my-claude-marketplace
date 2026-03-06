---
name: init-project
description: Scaffold a CLAUDE.md for the current project by analyzing its stack, conventions, and structure. Run once per project. Writes a CLAUDE.md with session settings including teacher mode.
allowed-tools: Bash(pwd), Bash(ls), Bash(git log), Bash(git branch), Read, Write, Glob
model: haiku
---

# /init-project

Scaffold a CLAUDE.md for the current project. Run this once — it analyzes your project and writes a CLAUDE.md you can maintain going forward.

---

## Context Loading

- Working directory: !`pwd`
- Root files: !`ls -1`
- Git log (commit style): !`git log --oneline -10`
- Git branches: !`git branch -a`
- README: Read `README.md` if it exists
- package.json: Read `package.json` if it exists
- pyproject.toml: Read `pyproject.toml` if it exists
- Cargo.toml: Read `Cargo.toml` if it exists

---

## Instructions

### Step 1: Analyze the Project

From the context above, detect:
- **Stack & runtime**: language, framework, key libraries
- **Package manager**: npm/yarn/pnpm/bun/pip/cargo/etc. (check lockfiles in root)
- **Key directories**: src/, lib/, apps/, packages/, etc.
- **Commit style**: conventional (`feat(scope): msg`) or informal (`Fix the bug`)
- **Branch naming pattern**: feature/*, fix/*, or free-form
- **Key constraints**: e.g., pnpm lockfile = must use pnpm, not npm

### Step 2: Draft CLAUDE.md

Write a draft (~300 lines max, no filler) using this structure:

```markdown
# [Project Name]

> [One-sentence purpose]

## Project Overview
[2-3 sentences]

## Stack & Structure
- **Runtime/Framework**: [detected]
- **Package manager**: [detected]
- **Key directories**: [detected]

## Conventions
- **Commits**: [conventional | informal] — example: `feat(auth): add login`
- **Branching**: [pattern if detectable, or "free-form"]

## Key Constraints
- [e.g., "use pnpm not npm"]
- [e.g., "run tests with `cargo test`"]

## Session Settings
- **Teacher Mode**: disabled
  When enabled, Claude will: propose step-by-step plans before editing,
  explain reasoning, offer hints/snippets rather than auto-applying changes,
  wait for confirmation before writing files.
  → Change to `enabled` to activate.
```

### Step 3: Present and Ask

Show the draft to the user, then ask:
1. Should teacher mode be enabled? (default: no)
2. Any constraints I missed or should highlight?
3. Anything else to add?

Wait for answers before writing.

### Step 4: Write CLAUDE.md

Incorporate the user's answers, then write `CLAUDE.md` to the project root.

### Step 5: Confirm

```
✅ CLAUDE.md created.

Key settings:
- Teacher Mode: [enabled/disabled]
- Package manager: [detected]
- Commit style: [conventional/informal]

Run /session-start to begin your first session.
```

---

## Notes

- If CLAUDE.md already exists, warn the user and ask before overwriting
- Keep the file practical — no filler, no sections the project doesn't need
- The Session Settings section is required (it's what /session-start reads)
- Leave room at the bottom for the user to add project-specific notes
