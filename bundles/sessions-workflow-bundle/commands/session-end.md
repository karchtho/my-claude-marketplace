---
name: session-end
description: End session - create summary, commit changes with conventional commits
allowed-tools: Read(.), Write(docs/sessions/**), Bash(git:*), TodoWrite, Glob(docs/), Grep
model: haiku
---

# /session-end

Generate a comprehensive session summary and commit all changes using conventional commits.

## Context

- Changed files: !`git diff --name-status HEAD 2>/dev/null | head -10`
- Staged files: !`git diff --cached --name-status 2>/dev/null`
- Recent commits: !`git log --format='%s' -3 2>/dev/null || echo "No git history"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "main"`

## Your Task

Execute these steps **in order**:

### Step 1: Create Session Summary Document

1. Determine session topic from changed files:
   - Look at first 3 changed files
   - Infer the main work area (e.g., "bundle-maker", "session-commands", "bug-fixes")
   - Topic format: `YYYY-MM-DD_topic` (e.g., `2026-01-05_session-bundle`)

2. Create file: `docs/sessions/YYYY-MM-DD_topic.md`
   - Create `docs/sessions/` directory if missing: `mkdir -p docs/sessions`
   - Write summary with these sections (500 words max):

```markdown
# Session Summary - [Date]

## Session Objectives
[1-2 sentences about what you were trying to accomplish]

## Work Completed
- [Key change 1]
- [Key change 2]
- [Key change 3]
[List 3-5 items, not exhaustive]

## Files Modified
[List files that were changed, from git diff output]

## Key Decisions
[If applicable: 1-2 architectural or design decisions made]

## Issues Encountered
[If applicable: Problems encountered and how they were solved]

## Next Steps
[2-3 specific next actions for next session]
```

3. Save the summary file

### Step 2: Analyze Commit Style

1. From context above, check recent commits
2. Determine if repository uses:
   - **Conventional commits** (feat:, fix:, docs:, chore:, refactor:, test:, style:, perf:)
   - **Informal commits** (natural language, no prefix)
3. Decide commit style based on what's already in the repo

### Step 3: Stage and Commit

1. **Stage changes**
   ```bash
   git add .
   ```

2. **Create commit message** following detected style:

**If conventional commits detected:**
```
type(scope): subject

- [key change 1]
- [key change 2]
- [key change 3]

Session summary: docs/sessions/YYYY-MM-DD_topic.md
```

Examples:
- `feat(sessions): create session workflow bundle`
- `fix(bundle-maker): improve placeholder detection`
- `docs(marketplace): update installation guide`

**Types:** feat, fix, docs, style, refactor, test, chore, perf

**If informal commits detected:**
- Match the existing style from repo history
- Capitalize first letter, natural language
- Example: `Add session workflow commands and documentation`

3. **Commit with message**
   ```bash
   git commit -m "[message]"
   ```

4. **Verify commit created**
   ```bash
   git log --oneline -1
   ```

### Step 4: Report Results

Report:
- ✅ Session summary created at: `docs/sessions/YYYY-MM-DD_topic.md`
- ✅ Commit hash and message
- 📋 Summary highlights (2-3 key accomplishments)

## Rules

- **Summary non-blocking**: If summary creation fails, still create commit
- **Commit required**: Always attempt to commit (unless no changes exist)
- **Conventional detection**: Check last 5 commits to determine style
- **Empty commits**: If no changes exist, only commit summary file
- **Token efficiency**: Use compact git commands (`--oneline`, `--short`)

## Error Handling

### No changes to commit:
```
✅ Session summary created: docs/sessions/YYYY-MM-DD_session.md
ℹ️ No code changes - only summary committed
Commit: 2k3f4j5 chore(session): session summary
```

### Not in git repo:
```
✅ Session summary created: docs/sessions/YYYY-MM-DD_session.md
⚠️ Not in git repository - summary saved but not committed
Next: Initialize git and manually commit
```

### docs/sessions/ not writable:
```
❌ Could not write summary to docs/sessions/
Please ensure directory exists and is writable: mkdir -p docs/sessions
```

## Examples

### Example 1: Feature Implementation Session

```
Session Summary - January 5, 2026
## Session Objectives
Implement the sessions workflow bundle for token-efficient project context loading.

## Work Completed
- Created sessions-workflow-bundle structure
- Implemented /session-start command with context loading
- Implemented /session-end command with automatic commits
- Added session manager skill for non-command workflows

## Files Modified
- bundles/sessions-workflow-bundle/.claude-plugin/plugin.json
- bundles/sessions-workflow-bundle/commands/session-start.md
- bundles/sessions-workflow-bundle/commands/session-end.md
- bundles/sessions-workflow-bundle/skills/session-manager/SKILL.md

## Next Steps
- Create helper scripts for commit style detection
- Add comprehensive documentation and examples
- Test workflow with edge cases (no git, missing docs/)
```

**Commit:**
```
feat(sessions): create session workflow bundle

- Implemented /session-start command with context loading
- Implemented /session-end command with conventional commits
- Added session manager skill
- Token-efficient design with ~1500-2000 token budget per session

Session summary: docs/sessions/2026-01-05_sessions-workflow.md
```

### Example 2: Bug Fix Session

```
Session Summary - January 5, 2026
## Session Objectives
Fix placeholder leakage in bundle-maker skill and update validation.

## Work Completed
- Analyzed bundle-maker placeholder detection
- Updated validation script to catch TODO markers
- Fixed 3 existing template files with placeholders

## Files Modified
- bundles/dev-toolkit-bundle/skills/bundle-maker/SKILL.md
- bundles/dev-toolkit-bundle/skills/bundle-maker/scripts/validate-bundle.sh

## Issues Encountered
- Initial validation regex was too strict - refined to match real patterns
- Solution: Updated grep pattern in validation script

## Next Steps
- Test validation against all bundles
- Document new validation rules
- Create example of bad bundle structure for testing
```

**Commit:**
```
fix(bundle-maker): improve placeholder detection in validation

- Enhanced validate-bundle.sh to catch TODO markers
- Updated SKILL.md documentation of no-placeholder policy
- Test coverage for template validation

Session summary: docs/sessions/2026-01-05_bundle-validation.md
```

## Token Budget

This command uses **~2000-2500 tokens maximum**:
- Dynamic context injection: ~300-400 tokens (executed server-side)
- Session summary creation: ~500-800 tokens
- Commit style analysis: ~200-300 tokens
- File operations and verification: ~300-400 tokens
- Response formatting: ~200 tokens

## Token Optimization Techniques

1. **File list instead of diffs**: Use `git diff --name-status` not `git diff`
2. **Compact git output**: Use `--oneline`, `--short`, `--format='%s'`
3. **Summary templates**: Use standard format to avoid re-explaining
4. **One commit**: Combine all session work into single atomic commit
