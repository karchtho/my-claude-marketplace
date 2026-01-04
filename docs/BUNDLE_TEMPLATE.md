# Bundle Template Guide

Use this template when creating new bundles for your marketplace.

## Quick Copy-Paste Bundle Structure

### Directory Creation
```bash
# Replace <bundle-name> with your bundle name (e.g., angular-frontend-bundle)
mkdir -p ~/projects/my-claude-skills/bundles/<bundle-name>/{.claude-plugin,skills/<skill-name>,commands,hooks/pre-commit,mcp/<mcp-name>}
```

---

## Template Files

### 1. plugin.json Template

**Location:** `bundles/<bundle-name>/.claude-plugin/plugin.json`

```json
{
  "name": "<bundle-name>",
  "version": "1.0.0",
  "description": "<Short description of what this bundle provides>",
  "author": "karchto",
  "components": {
    "skills": [
      "skills/<skill-name>"
    ],
    "commands": [
      "commands/<command-name>"
    ],
    "hooks": [
      "hooks/pre-commit"
    ],
    "mcp": [
      "mcp/<mcp-server-name>"
    ]
  },
  "metadata": {
    "tags": ["tag1", "tag2", "tag3"],
    "category": "<category-name>"
  }
}
```

**Common Categories:**
- `frontend-development`
- `backend-development`
- `game-development`
- `mobile-development`
- `devops`
- `data-science`

---

### 2. SKILL.md Template

**Location:** `bundles/<bundle-name>/skills/<skill-name>/SKILL.md`

```markdown
---
name: <skill-name>
description: <When this skill activates - be specific with trigger words>. Activates when working with <technology>, <frameworks>, or <specific-tasks>.
---

# <Skill Display Name>

<Brief overview of what this skill provides>

## When to Apply This Skill

Use these patterns when:
- <Use case 1>
- <Use case 2>
- <Use case 3>

## Core Principles

### 1. <First Major Topic>

**<Subtopic>**
- Key point 1
- Key point 2
- Key point 3

**Example:**
```<language>
// Good example
<code>

// Avoid
<anti-pattern>
```

### 2. <Second Major Topic>

**<Subtopic>**
<Explanation>

```<language>
<code example>
```

### 3. <Third Major Topic>

<Continue pattern...>

## Common Patterns

### <Pattern Name>
```<language>
<pattern implementation>
```

**When to use:**
- <scenario 1>
- <scenario 2>

## Best Practices

1. **<Practice name>** - <Description>
2. **<Practice name>** - <Description>
3. **<Practice name>** - <Description>

## Code Review Checklist

When reviewing code, check for:
- [ ] <Check item 1>
- [ ] <Check item 2>
- [ ] <Check item 3>

## Anti-Patterns to Avoid

❌ **<Anti-pattern name>**
```<language>
// Wrong
<bad code>

// Correct
<good code>
```

## Resources

- <Resource name>: <URL>
- <Resource name>: <URL>
```

---

### 3. Command Template

**Location:** `bundles/<bundle-name>/commands/<command-name>.md`

```markdown
---
name: <command-name>
description: <What this command does>
---

# <Command Display Name>

<Overview of the command>

## Usage

```
/command-name <arg1> <arg2>
```

## What It Does

When user types `/command-name <args>`:

1. <Action 1>
2. <Action 2>
3. <Action 3>

## Examples

### Example 1: <Scenario>
```
User: /command-name example-arg
```

**Generated:**
```<language>
<generated code>
```

### Example 2: <Another Scenario>
```
User: /command-name --flag argument
```

**Generated:**
<What gets generated>

## Options

| Option | Description |
|--------|-------------|
| `--flag` | <What it does> |
| `--another` | <What it does> |
```

---

### 4. Hook Template

**Location:** `bundles/<bundle-name>/hooks/pre-commit/<hook-name>.sh`

```bash
#!/bin/bash
# <Hook name> - <What it does>

# Exit on error
set -e

echo "Running <hook-name>..."

# Your hook logic here
# Example: Run linter
if command -v eslint &> /dev/null; then
  eslint --fix .
fi

# Example: Run formatter
if command -v prettier &> /dev/null; then
  prettier --write .
fi

# Example: Run tests
# npm test

echo "✅ <Hook-name> complete"
```

**Don't forget:**
```bash
chmod +x bundles/<bundle-name>/hooks/pre-commit/<hook-name>.sh
```

---

### 5. MCP Config Template

**Location:** `bundles/<bundle-name>/mcp/<mcp-name>/config.json`

```json
{
  "name": "<mcp-server-name>",
  "command": "npx",
  "args": ["-y", "<package-name>"],
  "env": {
    "API_KEY": "${ENV_VAR_NAME}",
    "CONFIG_OPTION": "value"
  }
}
```

**Common MCP Servers:**
- Figma: `@figma/mcp-server`
- Linear: `@linear/mcp-server`
- GitHub: `@github/mcp-server`
- Storybook: `@storybook/mcp-server`

---

### 6. Bundle README Template

**Location:** `bundles/<bundle-name>/README.md`

```markdown
# <Bundle Display Name>

<Short description of what this bundle provides>

## 📦 What's Included

### Skills

#### 1. <Skill Name> (`skills/<skill-name>/`)
**Activates when:** <Trigger description>

**Covers:**
- ✅ <Topic 1>
- ✅ <Topic 2>
- ✅ <Topic 3>

#### 2. <Another Skill> (`skills/<another-skill>/`)
**Activates when:** <Trigger description>

**Covers:**
- ✅ <Topic 1>
- ✅ <Topic 2>

### Commands

#### /<command-name>
<What the command does>

### Hooks

#### pre-commit/<hook-name>
<What the hook does>

### MCP Servers

#### <MCP Name>
<What the MCP provides>

## 🚀 Installation

```bash
/plugin install <bundle-name>@my-claude-skills
```

## 💡 Usage Examples

### Example 1: <Use Case>
```
User: "<Example query>"
```

**Expected:** <What Claude will do>

### Example 2: <Another Use Case>
```
User: "<Another query>"
```

**Expected:** <What Claude will do>

## 🎯 When This Bundle Is Active

The skills in this bundle automatically activate when you:
- <Trigger scenario 1>
- <Trigger scenario 2>
- <Trigger scenario 3>

## 🔧 Customization

### Add Your Patterns

Edit `skills/<skill-name>/SKILL.md` to include:
- <Customization option 1>
- <Customization option 2>

## 📁 Structure

```
<bundle-name>/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── <skill-name>/
│       └── SKILL.md
├── commands/
│   └── <command-name>.md
├── hooks/
│   └── pre-commit/
│       └── <hook-name>.sh
├── mcp/
│   └── <mcp-name>/
│       └── config.json
└── README.md
```

## 🔄 Deactivation

```bash
/plugin uninstall <bundle-name>
```

---

**Ready to use!** 🎉
```

---

## Adding Bundle to Marketplace

After creating all files, add to `marketplace.json`:

```json
{
  "plugins": [
    // ... existing bundles ...
    {
      "name": "<bundle-name>",
      "source": "./bundles/<bundle-name>",
      "description": "<Bundle description that appears in marketplace>"
    }
  ]
}
```

---

## Checklist for New Bundle

- [ ] Create directory structure
- [ ] Create `plugin.json` with metadata
- [ ] Create at least one skill with comprehensive SKILL.md
- [ ] (Optional) Create commands if applicable
- [ ] (Optional) Add hooks if applicable
- [ ] (Optional) Configure MCP servers if applicable
- [ ] Create bundle README.md
- [ ] Add to marketplace.json
- [ ] Test installation: `/plugin install <bundle-name>@my-claude-skills`
- [ ] Verify skills activate with relevant queries
- [ ] Document in main marketplace README.md

---

## Example: Creating Angular Bundle

```bash
# 1. Create structure
mkdir -p ~/projects/my-claude-skills/bundles/angular-frontend-bundle/{.claude-plugin,skills/{angular-patterns,ui-ux-design}}

# 2. Copy this template for plugin.json, edit with angular details
cat > ~/projects/my-claude-skills/bundles/angular-frontend-bundle/.claude-plugin/plugin.json <<EOF
{
  "name": "angular-frontend-bundle",
  "version": "1.0.0",
  "description": "Complete Angular development toolkit",
  "author": "karchto",
  "components": {
    "skills": ["skills/angular-patterns", "skills/ui-ux-design"]
  },
  "metadata": {
    "tags": ["angular", "frontend", "rxjs", "ui-ux"],
    "category": "frontend-development"
  }
}
EOF

# 3. Create angular-patterns/SKILL.md using the skill template above

# 4. Copy UI/UX skill from React bundle
cp ~/projects/my-claude-skills/bundles/react-frontend-bundle/skills/ui-ux-design/SKILL.md \
   ~/projects/my-claude-skills/bundles/angular-frontend-bundle/skills/ui-ux-design/SKILL.md

# 5. Add to marketplace.json

# 6. Test
/plugin install angular-frontend-bundle@my-claude-skills
```

---

**Use this template every time you create a new bundle to maintain consistency!** 🎯
