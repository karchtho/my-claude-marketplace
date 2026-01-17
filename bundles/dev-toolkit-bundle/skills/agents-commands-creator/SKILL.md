---
name: agents-commands-creator
description: Create Claude Code agents and commands with proper markdown structure, YAML frontmatter, and plugin.json arrays. Use when creating commands, slash commands, agents, autonomous assistants, and command-line utilities for Claude Code plugins.
version: 1.0.0
---

# Agents & Commands Creator

Comprehensive guide for creating agents and commands in Claude Code plugins. Ensures proper YAML frontmatter, markdown structure, and plugin.json integration.

## Critical Difference from Inline Configuration

⚠️ **COMMON MISTAKE:** Trying to define agents/commands as JSON objects inside `plugin.json`

❌ **WRONG:**
```json
{
  "agents": [
    { "name": "my-agent", "description": "..." }
  ]
}
```

✅ **CORRECT:**
```json
{
  "agents": [
    "./agents/my-agent.md"
  ]
}
```

Each agent and command is a **separate markdown file**, not a JSON object. The `plugin.json` only lists the file paths in arrays.

---

## Part 1: Creating Commands

Commands are CLI-like utilities invoked with `/command-name`. Each command is a single `.md` file with YAML frontmatter.

### Command File Structure

**Location:** `commands/command-name.md`

**Basic Template:**
```yaml
---
name: kebab-case-name
description: Brief description of what the command does
---

# /command-name

One-sentence summary of purpose.

## Usage

```
/command-name [optional-args]
```

## What This Does

Paragraph explaining functionality.

## Output

What the command produces or returns.

## When to Use

When should a user invoke this command?

## Related Commands

Links to complementary commands.
```

### Required YAML Fields

| Field | Type | Required | Example |
|-------|------|----------|---------|
| `name` | string | ✓ | `"review-code"` |
| `description` | string | ✓ | `"Get instant feedback on code"` |

### Command Creation Best Practices

**1. Keep it focused**
- One command = one clear purpose
- Example: `/review-code` does code review, not code generation

**2. Use imperative language**
- ✅ "Review code for patterns"
- ❌ "This command reviews your code"

**3. Simple bash commands**
- Use only if absolutely necessary
- NO complex pipes or chains
- Single operations only

**4. Clear output format**
- Describe exactly what the command returns
- Include examples if helpful
- List any side effects (file creation, etc.)

### Example: /review-starters Command

**File: `commands/review-starters.md`**
```yaml
---
name: review-starters
description: Run full validation on your 20 starter scripts
---

# /review-starters

Comprehensive audit of your 20 starter scripts from your unity-starter repository.

## What This Does

Validates all starter scripts for:
- Code quality and consistency
- Best practices (Singleton patterns, error handling)
- Integration health between scripts
- Memory safety (pooling, cleanup, leaks)
- Modern pattern readiness

## Usage

```
/review-starters
```

## Output

Detailed report with:
1. Critical Issues
2. Best Practice Suggestions
3. Integration Warnings
4. Modern Pattern Gaps
5. Ready Status

## When to Use

**Pre-jam** (3-4 days before): Run to validate starter scripts before jam begins.

## Related Commands

- `/jam-status` - Quick project health check
- `/design-feature` - Plan a new feature
```

### Command Documentation Guidelines

- **Title** - Start with `/command-name` (matches command name)
- **One-liner** - First sentence explains purpose
- **What This Does** - 2-3 bullet points describing functionality
- **Usage** - Show command syntax with examples
- **Output** - Describe what command produces
- **When to Use** - Help users understand when to invoke
- **Related Commands** - Link to complementary commands

---

## Part 2: Creating Agents

Agents are autonomous assistants invoked with `@agent-name`. Each agent is a single `.md` file with YAML frontmatter followed by detailed instructions.

### Agent File Structure

**Location:** `agents/agent-name.md`

**Basic Template:**
```yaml
---
name: kebab-case-name
description: Brief description of agent purpose and capabilities
---

# @agent-name

One-sentence summary of role.

## What This Agent Does

The agent-name is your [role description]. Invoke with `@agent-name` to:

- **Capability 1** - Description
- **Capability 2** - Description
- **Capability 3** - Description

## Capabilities

✓ Specific capability 1
✓ Specific capability 2
✓ Specific capability 3

## Usage Examples

```
@agent-name: [example task 1]
→ Get: [example output 1]

@agent-name: [example task 2]
→ Get: [example output 2]
```

## When to Invoke

- **Situation 1** - Use agent for...
- **Situation 2** - Use agent when...
- **Situation 3** - Use agent for...

## Works With

- `/command-name` command
- `@other-agent` agent
- Specific tools or workflows
```

### Required YAML Fields

| Field | Type | Required | Example |
|-------|------|----------|---------|
| `name` | string | ✓ | `"code-reviewer"` |
| `description` | string | ✓ | `"Code review focused on quality"` |

### Agent Creation Best Practices

**1. Clear role definition**
- What is this agent's specialty?
- What problems does it solve?
- Be very specific (not "general assistant")

**2. Concrete examples**
- Show exactly how to invoke the agent
- Provide 2-3 usage examples
- Include expected outputs

**3. Capability list**
- Use checkmarks (✓) for readable list
- Group related capabilities
- Be specific, not vague

**4. Context and timing**
- When should user invoke this agent?
- What prerequisites are needed?
- What's the expected workflow?

**5. Integration awareness**
- List related commands
- Link to complementary agents
- Show how agent fits in larger workflow

### Example: @code-quality Agent

**File: `agents/code-quality.md`**
```yaml
---
name: code-quality
description: Code review focused on jam-time quality. Catches memory leaks, pattern inconsistencies, async issues, pooling problems without blocking workflow.
---

# @code-quality

Code review specialist focused on jam-time quality. Catches memory leaks, pattern inconsistencies, async issues, pooling problems, and architectural conflicts without blocking workflow.

## What This Agent Does

The code-quality agent is your fast-feedback reviewer. Invoke with `@code-quality` to:

- **Review code quality** - Spot issues without slowing development
- **Memory safety** - Catch leaks, pooling problems, cleanup issues
- **Pattern consistency** - Does it match your codebase patterns?
- **Modern practices** - Input System, async/await, DI, pooling done right?
- **Integration validation** - Will it work with existing systems?
- **Performance checks** - Inefficiencies, unnecessary allocations
- **Quick fixes** - Get suggestions to improve in-place

## Capabilities

✓ C# code review
✓ Memory safety analysis
✓ Pattern consistency checking
✓ Performance analysis
✓ Integration validation
✓ Best practice validation
✓ Quick fix suggestions

## Usage Examples

```
@code-quality: Review this enemy spawner - is it efficient during high-spawn moments?
→ Get: Performance analysis, pooling assessment, suggestions

@code-quality: Check this UI code for memory leaks
→ Get: Memory analysis, Manager connection validation, quick fixes
```

## When to Invoke

- **During development** - Get quick feedback without formal review
- **Before merging** - Validate quality before integration
- **Complex code** - Need expert validation on tricky logic
- **Performance concern** - "Is this efficient?"

## Works With

- `/review-code` command - Quick status checks
- `@feature-developer` agent - Reviews generated code
- Your team - Fast feedback during crunch
```

### Agent Documentation Guidelines

- **Title** - `# @agent-name` (matches agent name)
- **Role Statement** - Describe the agent's role/specialty
- **What This Agent Does** - List key capabilities
- **Capabilities** - Checkmark list of specific abilities
- **Usage Examples** - 2-3 concrete examples with expected outputs
- **When to Invoke** - Situations where agent is useful
- **Works With** - Related commands, agents, tools

---

## Part 3: Updating plugin.json

### plugin.json Structure for Commands

```json
{
  "name": "your-bundle",
  "version": "1.0.0",
  "skills": ["./skills/skill-name"],
  "commands": [
    "./commands/review-starters.md",
    "./commands/design-feature.md",
    "./commands/generate-feature.md"
  ]
}
```

**Key Points:**
- `commands` is an **array** of file paths
- Each path points to a `.md` file in the `commands/` directory
- File names can be different from command names (use kebab-case for both)

### plugin.json Structure for Agents

```json
{
  "name": "your-bundle",
  "version": "1.0.0",
  "skills": ["./skills/skill-name"],
  "agents": [
    "./agents/code-quality.md",
    "./agents/feature-developer.md",
    "./agents/jam-architect.md"
  ]
}
```

**Key Points:**
- `agents` is an **array** of file paths
- Each path points to a `.md` file in the `agents/` directory
- File names should match agent names (use kebab-case)

### plugin.json with Both Commands and Agents

```json
{
  "name": "game-jam-toolkit-bundle",
  "version": "1.0.0",
  "description": "Complete game jam development partner",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "skills": [
    "./skills/validate-starters",
    "./skills/feature-architect"
  ],
  "commands": [
    "./commands/review-starters.md",
    "./commands/design-feature.md",
    "./commands/generate-feature.md"
  ],
  "agents": [
    "./agents/jam-architect.md",
    "./agents/feature-developer.md",
    "./agents/code-quality.md"
  ]
}
```

---

## Common Mistakes & Fixes

### Mistake 1: Inline JSON Objects

❌ **WRONG - Inline agent definition in plugin.json:**
```json
{
  "agents": [
    {
      "name": "my-agent",
      "description": "Does something"
    }
  ]
}
```

✅ **CORRECT - Reference markdown file:**
```json
{
  "agents": [
    "./agents/my-agent.md"
  ]
}
```

### Mistake 2: Directory References Instead of Files

❌ **WRONG - Reference to directory:**
```json
{
  "commands": "./commands",
  "agents": "./agents"
}
```

✅ **CORRECT - Reference individual files:**
```json
{
  "commands": [
    "./commands/command1.md",
    "./commands/command2.md"
  ],
  "agents": [
    "./agents/agent1.md",
    "./agents/agent2.md"
  ]
}
```

### Mistake 3: Missing YAML Frontmatter

❌ **WRONG - No frontmatter:**
```markdown
# /my-command

This is my command...
```

✅ **CORRECT - YAML frontmatter required:**
```markdown
---
name: my-command
description: This is my command's purpose
---

# /my-command

This is my command...
```

### Mistake 4: Wrong File Extensions

❌ **WRONG - Wrong extensions:**
```
commands/
├── review.json    # Should be .md
└── validate.txt   # Should be .md
```

✅ **CORRECT - All .md files:**
```
commands/
├── review.md
└── validate.md
```

### Mistake 5: Incorrect File Paths in plugin.json

❌ **WRONG - Wrong paths:**
```json
{
  "commands": ["review-starters", "design-feature"]
}
```

✅ **CORRECT - Full relative paths:**
```json
{
  "commands": [
    "./commands/review-starters.md",
    "./commands/design-feature.md"
  ]
}
```

---

## Directory Structure

### Typical Bundle with Commands and Agents

```
bundle-name/
├── .claude-plugin/
│   └── plugin.json                    # References all components
├── README.md
├── skills/
│   ├── skill-1/
│   │   └── SKILL.md
│   └── skill-2/
│       └── SKILL.md
├── commands/                          # CLI-like utilities
│   ├── review-starters.md            # YAML frontmatter + docs
│   ├── design-feature.md
│   └── generate-feature.md
└── agents/                            # Autonomous assistants
    ├── code-quality.md               # YAML frontmatter + instructions
    ├── feature-developer.md
    └── jam-architect.md
```

---

## Validation Checklist

### Before Committing Commands/Agents

- [ ] All `.md` files are in correct directories (`commands/` or `agents/`)
- [ ] All files have `.md` extension
- [ ] All files have YAML frontmatter with `name` and `description`
- [ ] `name` field is kebab-case and matches file name
- [ ] `description` field is present and descriptive
- [ ] No JSON objects inside `plugin.json` for agents/commands
- [ ] `plugin.json` has arrays for `commands` and `agents`
- [ ] All paths in arrays are relative paths with `./` prefix
- [ ] All paths point to actual files that exist
- [ ] No typos in file paths
- [ ] Markdown content is well-formatted and clear

### Testing After Creation

```bash
# Validate bundle structure
bundles/dev-toolkit-bundle/skills/bundle-maker/scripts/validate-bundle.sh <bundle-path>

# Check that plugin.json is valid JSON
cat <bundle-path>/.claude-plugin/plugin.json | jq .

# Verify all referenced files exist
for file in $(jq -r '.commands[]? // .agents[]? | ltrimstr("./")' <bundle-path>/.claude-plugin/plugin.json); do
  if [ ! -f "<bundle-path>/$file" ]; then
    echo "Missing file: $file"
  fi
done
```

---

## When This Skill Applies

Use this skill when:
- Creating new commands for a Claude Code plugin bundle
- Creating new agents for a Claude Code plugin bundle
- Fixing command/agent configuration errors in existing bundles
- Learning proper YAML frontmatter format
- Understanding how to structure agent/command markdown
- Updating plugin.json to reference new commands/agents
- Troubleshooting "Invalid manifest" or similar errors

Complements the `bundle-maker` skill for complete plugin development workflow.

