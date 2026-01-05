# Command Creation Guide

This guide provides best practices for creating Claude Code commands that work reliably and follow official Anthropic recommendations.

## What Are Commands?

Commands are CLI-like utilities that provide specialized workflows and context-aware assistance. They are declared in `.md` files within the `commands/` directory of a bundle.

**Examples:**
- `/session-start` - Initialize session with project context
- `/commit` - Create conventional commits with context
- `/test-debug` - Run and debug failing tests

## Anatomy of a Command File

Every command is a Markdown file with YAML frontmatter:

```markdown
---
name: command-name
description: Trigger phrase keywords that activate this command
allowed-tools: Bash(git:*), Read, Glob
model: haiku  # optional - override default model
---

# /command-name

Command description and workflow

## Context

Key information for the user

## Your Task

Instructions for Claude to follow
```

## Official Best Practices

### 1. Frontmatter Requirements

Every command **MUST** include:

```yaml
---
name: kebab-case-command-name
description: Clear description with trigger keywords that users would naturally say
allowed-tools: [explicit list of allowed tools]
---
```

**Name:** Use kebab-case (e.g., `session-start`, `test-debug`, `bundle-maker`)

**Description:** Include keywords users would search for. This is critical for command discovery.

**Allowed-Tools:** Always explicitly declare which tools are needed. Use glob patterns:
- `Bash(git:*)` - Allow all git commands
- `Bash(npm:*)` - Allow all npm commands
- `Bash(find:*)` - Allow find command
- `Read` - Allow reading files
- `Glob` - Allow file pattern matching

### 2. Bash Commands - Keep Them Simple

**Golden Rule: One bash command = One piece of information**

#### ✅ DO: Simple, Single-Purpose Commands

```markdown
Project directory: !`pwd`
Current branch: !`git branch --show-current`
Git status: !`git status --short`
Recent commits: !`git log --oneline -5`
```

Each command:
- Does ONE thing only
- Produces one piece of output
- Is self-contained (no pipes or complex logic)
- Is easy to understand and maintain

#### ❌ DON'T: Complex Piped Commands

```markdown
# AVOID THIS - Causes permission check failures
Latest session: !`ls -t docs/sessions/*.md 2>/dev/null | head -1 || echo "None"`
Found plugins: !`find ~/.claude/plugins -maxdepth 2 -name "plugin.json" -exec jq '.name' {} \;`
```

**Why this fails:**
- Multiple operations trigger permission checks
- Pipes (`|`) combine multiple tools together
- `-exec` with `jq` is especially problematic
- Complex error handling (`|| echo`) is hard to debug

### 3. File References - Use `@` Prefix

For stable documents that guide behavior, use file references instead of trying to locate them with bash:

#### ✅ DO: Use File References

```markdown
## Project Guidelines

See @CLAUDE.md for complete project guidance.
See @README.md for project overview.

[Rest of command]
```

#### ❌ DON'T: Use Bash to Find or Locate Files

```markdown
# AVOID THIS - Tries to search for files
Project guidelines: !`cat CLAUDE.md | head -50`
Readme: !`find . -name "README.md" -type f`
```

**Why use file references:**
- Cleaner, more reliable syntax
- No permission checks
- Claude loads them automatically
- Simpler to read and maintain

### 4. Command Structure

Keep commands focused and concise:

```markdown
---
name: command-name
description: Keywords describing what this command does
allowed-tools: [relevant tools]
---

# /command-name

One-line description of command purpose.

## Context

Dynamic information gathered with simple bash commands:

Project: !`pwd`
Branch: !`git branch --show-current`
Status: !`git status --short`

## Project Information

See @CLAUDE.md for project guidelines.

## Your Task

Clear, numbered steps for Claude to follow:

1. First thing to do
2. Second thing to do
3. Report back with results

## Expected Output

Brief description of what Claude should produce.
```

### 5. Error Handling

**Always degrade gracefully** when files or directories are missing:

```markdown
## Session History

Available sessions (if any): !`find docs/sessions -name "*.md" -type f 2>/dev/null`

Note: Missing session history is not an error - this may be a fresh project.
```

### 6. Token Efficiency

Keep commands concise to minimize token usage:

- **Use `--short` flag:** `git status --short` instead of `git status`
- **Use `--oneline` flag:** `git log --oneline -5` instead of full logs
- **Limit output:** `head -10` or similar, but do so SIMPLY (not piped)
- **Reference files:** Use `@` for guides, not full file reads
- **Brief instructions:** 5-10 lines max, not exhaustive

### 7. Model Selection

Only override the default model if necessary:

```yaml
model: haiku  # Small, fast model for simple context loading
```

**Use cases:**
- `haiku` - Simple context loading, straightforward tasks
- `sonnet` - Complex analysis, code generation
- `opus` - Very complex multi-step workflows

Don't override unless there's a specific reason.

## Complete Example: Proper Command

Here's a complete example following all best practices:

```markdown
---
name: debug-test
description: Run failing tests and help debug with immediate context. Use when a test is broken or needs investigation.
allowed-tools: Bash(npm:*), Bash(yarn:*), Bash(python:*), Bash(pytest:*), Read, Glob
model: haiku
---

# /debug-test

Debug failing tests by running them and providing immediate context.

## Current Project State

Working directory: !`pwd`
Git branch: !`git branch --show-current`

## Project Configuration

See @CLAUDE.md for test framework and debugging guidelines.

## Your Task

1. Ask which test file to run (or let me specify)
2. Run the test in the appropriate test framework
3. Analyze the failure output
4. Suggest fixes or debugging steps
5. Report what you find

## Notes

- Keep output focused on the actual error
- Don't run the entire test suite, just the failing test
- Provide actionable debugging steps
```

## Common Mistakes to Avoid

### ❌ Mistake 1: Complex Bash Chains

```markdown
# Wrong - Multiple operations will fail
Latest: !`ls -t docs/*.md | head -1`
Project: !`find . -name "*.json" -exec jq '.name' {} \;`
```

**Fix:** Use simple commands and file references.

### ❌ Mistake 2: Missing Allowed-Tools

```markdown
---
description: Initialize session
---
# WRONG - No allowed-tools declared!
```

**Fix:** Always declare `allowed-tools` in frontmatter.

### ❌ Mistake 3: Overly Prescriptive Instructions

```markdown
# Wrong - Too many steps, hard to follow
1. Read CLAUDE.md
2. Parse the first 50 lines
3. Extract the "Key Patterns" section
4. Find the "No-Placeholder Strategy" subsection
...
```

**Fix:** Let Claude handle analysis. Give high-level goals only.

### ❌ Mistake 4: Trying to Detect Everything

```markdown
# Wrong - Too ambitious
Detect project type: !`[complex detection logic]`
Find all dependencies: !`[searches everywhere]`
Locate test files: !`[complex find patterns]`
```

**Fix:** Focus on what's essential. Let Claude ask for clarification.

### ❌ Mistake 5: Using Bash for Navigation

```markdown
# Wrong - Bash shouldn't navigate
Latest session: !`ls -t docs/sessions/ | head -1`
Current file: !`pwd`/src/main.ts
```

**Fix:** Use file references and simple `pwd` only.

## Command Naming Conventions

Use kebab-case for command names:

- ✅ `/session-start`
- ✅ `/test-debug`
- ✅ `/bundle-maker`
- ✅ `/code-review`

NOT CamelCase or snake_case.

## Validation Checklist

Before creating a command file, verify:

- [ ] Command has YAML frontmatter with `name`, `description`, `allowed-tools`
- [ ] All bash commands are simple and single-purpose
- [ ] No pipes or complex operators in bash commands
- [ ] File references use `@` prefix (e.g., `@CLAUDE.md`)
- [ ] Instructions are clear and concise (5-10 lines max)
- [ ] Missing files/directories don't block execution
- [ ] Error handling is graceful
- [ ] Token count is reasonable (~1000-2000 max)

## Quick Reference

### Simple Bash Commands Only

```markdown
!`pwd`
!`git branch --show-current`
!`git status --short`
!`git log --oneline -5`
!`find . -name "*.md" -type f`  # Simple find, no pipes
```

### File References

```markdown
See @CLAUDE.md for guidelines
See @README.md for overview
See @package.json for dependencies
```

### Command Template

```markdown
---
name: your-command-name
description: Keywords and description of what this does
allowed-tools: Bash(git:*), Read, Glob
---

# /your-command-name

Brief description.

## Context

!`pwd`
!`git branch --show-current`

See @CLAUDE.md for guidelines.

## Your Task

1. Do this
2. Then this
3. Report results
```

## Integration with Bundle Structure

Commands belong in the `commands/` directory:

```
bundle-name/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── command-1.md
│   ├── command-2.md
│   └── command-3.md
└── skills/
    └── skill-name/
```

Register commands in `plugin.json`:

```json
{
  "name": "bundle-name",
  "components": {
    "commands": ["commands/command-1", "commands/command-2"]
  }
}
```

## Testing Your Command

After creating a command:

1. Install the bundle locally
2. Invoke the command: `/your-command-name`
3. Verify all bash commands execute successfully
4. Check that file references are loaded
5. Ensure instructions are clear and executable
6. Test with missing files (graceful degradation)

## Further Reading

- [Claude Code Official Documentation](https://claude.ai/code)
- [Skill Creation Guide](./skill-creation-guide.md)
- [Bundle Maker Guide](../SKILL.md)
