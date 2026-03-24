---
name: session-end
description: End session - create summary, commit changes with conventional commits
allowed-tools: Bash(git:*), Bash(pwd), Bash(mkdir), Bash(ls), Read, Write
model: haiku
---

# /session-end

Save session to memory, then commit all changes.

## Context

- Working directory: !`pwd`
- Changed files: !`git diff --name-status HEAD`
- Current branch: !`git branch --show-current 2>/dev/null || echo "main"`
- Recent commits: !`git log --format='%s' -5 2>/dev/null || echo "No git history"`

---

## Your Task

Execute these steps **in order**:

### Step 1: Write Session Entry to Memory

Compute memory dir:
```bash
~/.claude/projects/$(pwd | sed 's|/|-|g')/memory/
```

1. Create the directory if it doesn't exist:
   ```bash
   mkdir -p ~/.claude/projects/$(pwd | sed 's|/|-|g')/memory/
   ```

2. Infer session topic from the changed files (look at first 3 changed files, infer the main work area).

3. Append to `sessions.md` in the memory dir (create if missing):
   ```markdown
   ## [DATE] - [topic]
   **Accomplished**: [2-3 bullets of what was done]
   **Decisions**: [key decisions made, or "none"]
   **Next**: [1-3 specific next steps]
   **Files**: [main files changed]
   ```
   Keep each entry ≤100 words.

4. If stable new insights were gained (new patterns, gotchas, architectural decisions): update `MEMORY.md` in the memory dir. Keep MEMORY.md under 200 lines total.

### Step 2: Detect Commit Style

From the recent commits context:
- **Conventional commits**: starts with `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `style:`, `perf:`
- **Informal commits**: natural language, no prefix

Use what the repo already uses.

### Step 3: Stage and Commit

**⚠️ IMPORTANT — Atomic Commits**

Each commit should represent **one logical unit of work**. Do NOT commit all changes together if they touch unrelated features or concerns.

**Before staging:**
- Review changed files: `git status`
- Group related changes: one commit per feature, fix, or refactor
- Use `git add [file]` to stage specific files, not `git add .` if changes are mixed

**Conventional commits are required:**
- Format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`
- Examples:
  - `fix(auth): resolve session timeout race condition`
  - `feat(api): add user pagination to endpoints`
  - `docs: update README with setup instructions`

This repo uses conventional commits — follow the pattern from recent commits above.

---

1. Stage related changes (atomically):
   ```bash
   # Option A: Stage specific files for one logical commit
   git add [file1] [file2] ...

   # Option B: Only use if all changes are one logical unit
   git add .
   ```

2. Create commit message in the detected style:

**Conventional:**
```
type(scope): subject

- key change 1
- key change 2
- key change 3
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`

**Informal:**
- Match existing repo style, capitalize first letter
- Example: `Add session workflow redesign`

3. Commit and verify:
   ```bash
   git commit -m "[message]"
   git log --oneline -1
   ```

### Step 4: Report

```
✅ Memory updated: ~/.claude/.../memory/sessions.md
✅ Committed: [hash] [message]

Next session: [next steps from the entry written above]
```

---

## Rules

- **Memory write is non-blocking**: if it fails, still commit
- **Commit required**: always attempt to commit (unless no changes exist)
- **No docs/sessions/ files**: memory lives in `~/.claude/projects/.../memory/` only
- **Empty state**: if no changes exist, write memory entry and skip commit

## Error Handling

### No changes to commit:
```
✅ Memory updated: ~/.claude/.../memory/sessions.md
ℹ️ No code changes to commit
Next session: [next steps]
```

### Not in git repo:
```
✅ Memory updated: ~/.claude/.../memory/sessions.md
⚠️ Not in git repository — memory saved but not committed
```

### Memory directory not writable:
```
⚠️ Could not write to memory dir — check permissions
✅ Committed: [hash] [message]
```
