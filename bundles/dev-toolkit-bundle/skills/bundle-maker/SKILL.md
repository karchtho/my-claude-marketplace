---
name: bundle-maker
description: This skill should be used when the user asks to "create a bundle", "make a plugin", "build a Claude plugin", "create a skill bundle", "package skills", "add skills to a bundle", "create plugin.json", or wants to create comprehensive Claude Code plugins with skills, commands, agents, hooks, or MCP servers. Activates when creating plugin structures or bundling Claude capabilities.
version: 1.0.0
---

# Bundle Maker for Claude Code Plugins

This skill guides the creation of comprehensive Claude Code plugin bundles that can include skills, commands, agents, hooks, and MCP server integrations.

## What are Bundles?

**Bundles (Plugins)** are semantic packages of Claude capabilities organized by context or domain. A bundle can contain:

- **Skills** - Specialized knowledge and workflows (e.g., React patterns, API design)
- **Commands** - CLI-like commands for code generation (e.g., `/prefab`, `/commit`)
- **Agents** - Autonomous agents for complex tasks (e.g., code reviewer, test engineer)
- **Hooks** - Event-driven automation (e.g., pre-commit validation)
- **MCP Servers** - Model Context Protocol integrations (e.g., Figma, Linear)

Bundles enable context-switching between different development environments and expertise domains.

## Bundle Structure

Every bundle follows this structure:

```
bundle-name/
├── .claude-plugin/
│   └── plugin.json           # Bundle manifest (required)
├── skills/                   # Skill packages (optional)
│   └── skill-name/
│       ├── SKILL.md          # Required for each skill
│       ├── references/       # Detailed docs (optional)
│       ├── examples/         # Working examples (optional)
│       └── scripts/          # Utilities (optional)
├── commands/                 # Command implementations (optional)
│   └── command-name.md
├── agents/                   # Agent implementations (optional)
│   └── agent-name.md
├── hooks/                    # Hook scripts (optional)
│   └── hooks.json
└── mcp/                      # MCP server configs (optional)
    └── server-config.json
```

## Core Workflow: Creating a Bundle

### Step 0: Gather Bundle Information

**IMPORTANT: Gather ALL identifiers and metadata BEFORE creating any files or directories. NEVER use placeholders.**

Before creating a bundle, collect the following information from the user:

**Required Information:**
1. **Bundle name** - Kebab-case identifier (e.g., "react-frontend-bundle", "unity-game-dev-bundle")
2. **Bundle description** - Clear description of bundle capabilities (1-2 sentences)
3. **Author name** - Full name for plugin.json author field
4. **Author email** - Email address for plugin.json author field
5. **Marketplace location** - Path to the marketplace bundles directory (detect from current working directory or ask)
6. **Component types** - Which components to include: skills, commands, agents, hooks, MCP servers

**Optional Information:**
7. **Version number** - Semantic version (default: "1.0.0" if not specified)
8. **Tags** - Metadata tags for categorization (if using extended format)
9. **Category** - Bundle category (if using extended format)

**Detection Strategy for Marketplace Location:**

```bash
# Try to detect marketplace root from git repository
# Look for .claude-plugin/marketplace.json or bundles/ directory
# If not found, ask user for marketplace location
```

**Example information gathering:**

Ask the user:
- "What would you like to name this bundle? (use kebab-case, e.g., 'react-frontend-bundle')"
- "What is your name for the author field?"
- "What is your email for the author field?"
- "Please describe what this bundle will provide (1-2 sentences)"
- "Which components do you want to include? (skills, commands, agents, hooks, MCP servers)"

**Do NOT proceed to Step 1 until ALL required information is collected.**

### Step 1: Understand the Bundle Purpose

Based on the information gathered in Step 0, identify:

1. **Target context** - What development context does this bundle serve?
2. **Concrete examples** - How will users interact with this bundle?
3. **Initial skills/components** - What specific skills or components to create first?

Example clarifying questions:
- "What capabilities should this bundle provide?"
- "Can you give examples of how this bundle would be used?"
- "What skills would be most valuable to start with?"

### Step 2: Create Bundle Directory Structure

Using the ACTUAL bundle name and marketplace location from Step 0:

```bash
# Navigate to marketplace bundles directory (detected or provided by user)
cd <marketplace-path>/bundles/

# Create bundle structure using ACTUAL bundle name
mkdir -p <actual-bundle-name>/.claude-plugin
mkdir -p <actual-bundle-name>/skills    # If including skills
mkdir -p <actual-bundle-name>/commands  # If including commands
mkdir -p <actual-bundle-name>/agents    # If including agents
mkdir -p <actual-bundle-name>/hooks     # If including hooks
mkdir -p <actual-bundle-name>/mcp       # If including MCP servers
```

**Example with actual values:**
```bash
cd /path/to/my-marketplace/bundles/
mkdir -p react-frontend-bundle/{.claude-plugin,skills,commands}
```

Create only the directories needed for the bundle's components.

### Step 3: Create plugin.json Manifest

Create `.claude-plugin/plugin.json` using ACTUAL metadata from Step 0:

**Simple format (skills only):**
```json
{
  "name": "<actual-bundle-name>",
  "version": "<actual-version>",
  "description": "<actual-description>",
  "author": {
    "name": "<actual-author-name>",
    "email": "<actual-author-email>"
  },
  "skills": [
    "./skills/<actual-skill-name>"
  ]
}
```

**Example with actual values:**
```json
{
  "name": "react-frontend-bundle",
  "version": "1.0.0",
  "description": "Complete React development toolkit with UI/UX design principles",
  "author": {
    "name": "John Doe",
    "email": "john.doe@example.com"
  },
  "skills": [
    "./skills/react-patterns",
    "./skills/ui-ux-design"
  ]
}
```

**Extended format (all components):**
```json
{
  "name": "bundle-name",
  "version": "1.0.0",
  "description": "Comprehensive description",
  "author": {
    "name": "Your Name",
    "email": "your.email@example.com"
  },
  "components": {
    "skills": ["skills/skill-name"],
    "commands": ["commands/command-name"],
    "agents": ["agents/agent-name"],
    "hooks": ["hooks/hooks.json"],
    "mcp": ["mcp/server-config.json"]
  },
  "metadata": {
    "tags": ["tag1", "tag2"],
    "category": "development-category"
  }
}
```

### Step 4: Add Components to Bundle

Depending on the bundle's purpose, add the appropriate components:

#### Adding Skills

For each skill in the bundle, create the skill structure and SKILL.md. See **`references/skill-creation-guide.md`** for comprehensive skill development process.

**Quick skill creation (using actual values):**
```bash
cd <marketplace-path>/bundles/<actual-bundle-name>/skills
mkdir -p <actual-skill-name>/{references,examples,scripts}
touch <actual-skill-name>/SKILL.md
```

**Example with actual values:**
```bash
cd /path/to/my-marketplace/bundles/react-frontend-bundle/skills
mkdir -p react-patterns/{references,examples,scripts}
touch react-patterns/SKILL.md
```

Each SKILL.md must have:
- YAML frontmatter with `name` and `description` (with trigger phrases)
- Markdown body with imperative instructions
- References to any bundled resources

For detailed skill creation methodology, consult **`references/skill-creation-guide.md`** which includes the complete skill-creator workflow.

#### Adding Commands (Recommended)

Commands are CLI-like utilities for specialized workflows (e.g., `/session-start`, `/commit`, `/test-debug`).

**CRITICAL: Command Creation Requirements**

Follow **`references/commands-guide.md`** STRICTLY. Commands must:
- Use simple, single-purpose bash commands (NO piped commands like `ls -t | head`)
- Declare all `allowed-tools` in frontmatter explicitly
- Use `@` file references (e.g., `@CLAUDE.md`) instead of bash to locate files
- Keep instructions concise (5-10 lines max)
- Gracefully handle missing files/directories

**Command Structure:**
```bash
commands/
├── command-1.md        # One command per file
├── command-2.md
└── command-3.md
```

Each command file must have YAML frontmatter:
```yaml
---
name: kebab-case-name
description: Keywords and description users would search for
allowed-tools: Bash(git:*), Read, Glob  # Explicit declarations
---
```

See **`references/commands-guide.md`** for complete patterns, examples, and validation checklist.

#### Adding Agents (Future Extension)

Agents are autonomous assistants for complex tasks. See **`references/agents-guide.md`** for agent creation patterns.

#### Adding Hooks (Future Extension)

Hooks enable event-driven automation. See **`references/hooks-guide.md`** for hook implementation patterns.

#### Adding MCP Servers (Future Extension)

MCP servers integrate external tools (Figma, Linear, GitHub). See **`references/mcp-integration-guide.md`** for MCP configuration patterns.

### Step 5: Register Bundle in Marketplace

Add the bundle to the marketplace configuration file using ACTUAL values from Step 0.

**Locate marketplace config:**
```bash
# Marketplace config is typically at the root of your marketplace repository
# Look for: .claude-plugin/marketplace.json
# Or ask user for marketplace config location
```

**Add bundle entry using actual values:**

```json
{
  "plugins": [
    {
      "name": "<actual-bundle-name>",
      "source": "./bundles/<actual-bundle-name>",
      "description": "<actual-description>"
    }
  ]
}
```

**Example with actual values:**

```json
{
  "plugins": [
    {
      "name": "react-frontend-bundle",
      "source": "./bundles/react-frontend-bundle",
      "description": "Complete React development toolkit with UI/UX design principles"
    }
  ]
}
```

**Location detection strategy:**
```bash
# If in git repo with .claude-plugin/marketplace.json:
find . -name "marketplace.json" -path "*/.claude-plugin/*"

# If not found, ask user:
# "Where is your marketplace.json file located?"
```

### Step 6: Install and Test Bundle

Install the bundle locally using ACTUAL values:

```bash
/plugin install <actual-bundle-name>@<actual-marketplace-name>
```

**Example with actual values:**
```bash
/plugin install react-frontend-bundle@my-claude-marketplace
```

**If you don't know the marketplace name:**
```bash
# Check marketplace.json for the "name" field
grep '"name"' <marketplace-path>/.claude-plugin/marketplace.json
```

**Test that:**
1. Skills trigger on expected user queries
2. Commands execute correctly (if included)
3. Agents activate appropriately (if included)
4. Hooks run on events (if included)
5. MCP servers connect (if included)

### Step 7: Iterate Based on Usage

After testing, refine the bundle:

1. Use the bundle on real tasks
2. Notice gaps or inefficiencies
3. Update skills, add commands/agents/hooks as needed
4. Strengthen trigger phrases in skill descriptions
5. Move detailed content to references/ for progressive disclosure

## Bundle Quality Standards

### plugin.json Quality
- Clear, descriptive bundle name
- Accurate version number (semantic versioning)
- Comprehensive description
- Valid author information
- All component paths exist

### Skill Quality
- Strong trigger phrases in descriptions
- Third-person frontmatter format
- Imperative/infinitive writing style
- Progressive disclosure (lean SKILL.md, detailed references/)
- Working examples and tested scripts

### Component Organization
- Logical grouping of related capabilities
- Clear separation of concerns
- Reusable skills across bundles
- Coherent bundle theme/context

## Key Principles

### 1. Context-Based Organization

Group capabilities by development context, not by component type:

**Good:**
- `react-frontend-bundle` - React patterns + UI/UX design
- `unity-game-dev-bundle` - Unity scripting + performance + architecture
- `devops-toolkit-bundle` - Deployment + monitoring + infrastructure

**Bad:**
- `all-skills-bundle` - Random collection of unrelated skills
- `general-purpose-bundle` - No clear context or theme

### 2. Progressive Complexity

Start simple, add complexity as needed:

1. **Phase 1:** Create bundle with core skills only
2. **Phase 2:** Add commands for common code generation tasks
3. **Phase 3:** Add agents for complex workflows
4. **Phase 4:** Add hooks for automation
5. **Phase 5:** Add MCP servers for tool integrations

Not every bundle needs all components. Start with what provides immediate value.

### 3. Reusability

Design skills to be reusable across bundles:

- `ui-ux-design` skill can be used in React, Angular, Vue bundles
- `database-design` skill can be used in backend bundles
- `testing-patterns` skill can be used in any development bundle

Reference the same skill from multiple plugin.json files to avoid duplication.

### 4. Lean Core, Rich References

Keep SKILL.md lean (1,500-2,000 words), move details to references/:

```
skill-name/
├── SKILL.md                    # 1,800 words - core essentials
└── references/
    ├── patterns.md             # 2,500 words - detailed patterns
    ├── advanced.md             # 3,700 words - advanced techniques
    └── migration-guide.md      # 1,200 words - migration strategies
```

Claude loads references only when needed, minimizing context bloat.

## Command Creation Best Practices

If your bundle includes commands, follow these CRITICAL principles to ensure reliability:

### Key Rules

**1. Use Simple Bash Commands Only**
- ONE command per piece of information
- NO pipes, chains, or complex operators
- NO `find ... -exec`, `ls -t | head`, or similar patterns

✅ **Good:**
```markdown
Current branch: !`git branch --show-current`
Git status: !`git status --short`
```

❌ **Bad:**
```markdown
Latest: !`ls -t docs/*.md | head -1`  # This breaks!
```

**2. Always Declare allowed-tools**
```yaml
---
name: my-command
allowed-tools: Bash(git:*), Bash(npm:*), Read, Glob
---
```

**3. Use File References Instead of Bash**
- Reference stable documents with `@` prefix
- Don't use bash to locate or read files

✅ **Good:**
```markdown
See @CLAUDE.md for project guidelines.
```

❌ **Bad:**
```markdown
Guidelines: !`cat CLAUDE.md | head -50`
```

**4. Keep Instructions Concise**
- 5-10 lines maximum
- Let Claude handle analysis
- Focus on high-level goals only

### Why This Matters

Complex bash commands (with pipes, find -exec, etc.) trigger Claude Code permission checks and cause runtime failures. Simple, focused commands execute reliably and load context effectively.

**See `references/commands-guide.md` for complete patterns, examples, and a validation checklist.**

## Relationship to Skill-Making Skills

This bundle-maker skill complements existing skill-creation guidance:

### Anthropic's skill-creator
Located at: `~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/skill-creator`

**Provides:**
- `scripts/init_skill.py` - Initialize standalone skill structure
- `scripts/package_skill.py` - Package skills into .skill ZIP files
- Generic skill creation methodology
- Standalone skill distribution format

**Use when:** Creating standalone skills for distribution outside of plugin bundles

### Claude Code's skill-development
Located at: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/plugin-dev/skills/skill-development`

**Provides:**
- Plugin-specific skill creation guidance
- Progressive disclosure patterns
- Trigger phrase best practices
- Plugin integration methodology

**Use when:** Creating skills within Claude Code plugin bundles

### bundle-maker (this skill)
**Provides:**
- Complete bundle/plugin creation workflow
- Multi-component bundle architecture (skills + commands + agents + hooks + MCP)
- Marketplace integration guidance
- Bundle quality standards

**Use when:** Creating comprehensive Claude Code plugin bundles with multiple components

## Utility Scripts

The bundle-maker skill includes utility scripts for common operations:

### `scripts/create-bundle.sh`
Creates a new bundle directory structure with plugin.json template

```bash
scripts/create-bundle.sh <bundle-name> [--with-all]
```

### `scripts/add-skill-to-bundle.sh`
Adds a skill structure to an existing bundle

```bash
scripts/add-skill-to-bundle.sh <bundle-path> <skill-name>
```

### `scripts/validate-bundle.sh`
Validates bundle structure and plugin.json format

```bash
scripts/validate-bundle.sh <bundle-path>
```

See **`scripts/README.md`** for complete script documentation.

## Additional Resources

### Reference Files

For detailed guidance on each component type:
- **`references/skill-creation-guide.md`** - Complete skill creation workflow (based on skill-creator)
- **`references/commands-guide.md`** - Command development patterns (future)
- **`references/agents-guide.md`** - Agent implementation patterns (future)
- **`references/hooks-guide.md`** - Hook automation patterns (future)
- **`references/mcp-integration-guide.md`** - MCP server integration (future)
- **`references/bundle-templates.md`** - Ready-to-use bundle templates

### Example Files

Working bundle examples in `examples/`:
- **`examples/minimal-bundle/`** - Simplest bundle structure (skills only)
- **`examples/complete-bundle/`** - Full bundle with all component types
- **`examples/react-frontend-bundle/`** - Real-world React development bundle

## Quick Reference

### Minimal Bundle (Skills Only)
```bash
bundle-name/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── skill-name/
        └── SKILL.md
```

### Standard Bundle (Recommended)
```bash
bundle-name/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── skill-1/
│   └── skill-2/
└── README.md
```

### Complete Bundle (All Components)
```bash
bundle-name/
├── .claude-plugin/
│   └── plugin.json
├── skills/
├── commands/
├── agents/
├── hooks/
└── mcp/
```

## Bundle Creation Checklist

- [ ] Bundle purpose and context clearly defined
- [ ] Directory structure created
- [ ] plugin.json created with valid metadata
- [ ] Skills added with proper SKILL.md frontmatter
- [ ] Skills use imperative writing style
- [ ] Skills have strong trigger phrases
- [ ] Detailed content moved to references/
- [ ] Bundle registered in marketplace.json
- [ ] Bundle installed and tested locally
- [ ] All components work as expected
- [ ] Documentation is clear and complete

Create bundles that provide focused, context-specific capabilities that truly enhance Claude's effectiveness in specific development domains.
