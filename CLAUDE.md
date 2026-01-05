# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code Skills Marketplace** - a curated collection of plugin bundles that provide context-aware development expertise. Each bundle contains specialized skills that activate automatically based on conversation context.

## Repository Structure

```
my-claude-marketplace/
├── .claude-plugin/marketplace.json    # Registry of all bundles
├── bundles/
│   ├── react-frontend-bundle/         # React development expertise
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       ├── react-patterns/SKILL.md
│   │       └── ui-ux-design/SKILL.md
│   └── dev-toolkit-bundle/            # Bundle creation automation
│       └── skills/bundle-maker/
│           ├── SKILL.md
│           ├── references/skill-creation-guide.md
│           ├── scripts/               # Bash utilities
│           └── examples/              # Bundle templates
└── docs/
```

## Common Commands

### Bundle Management Scripts

```bash
# Navigate to scripts directory
cd bundles/dev-toolkit-bundle/skills/bundle-maker/scripts/

# Create new bundle structure
./create-bundle.sh my-bundle-name
./create-bundle.sh my-bundle-name --with-all  # Include all component dirs

# Add skill to existing bundle
./add-skill-to-bundle.sh /path/to/bundle skill-name

# Validate bundle structure and JSON
./validate-bundle.sh /path/to/bundle
```

### Validate All Bundles

```bash
for bundle in bundles/*/; do
  bundles/dev-toolkit-bundle/skills/bundle-maker/scripts/validate-bundle.sh "$bundle"
done
```

## Architecture

### Plugin Bundle Structure

Each bundle contains:
- **Manifest** (`plugin.json`) - Metadata and component registration
- **Skills** - Specialized knowledge modules with SKILL.md files
- **Commands** (optional) - CLI-like automation
- **Agents** (optional) - Autonomous task handlers
- **Hooks** (optional) - Event-driven automation
- **MCP Servers** (optional) - External tool integrations

### Skill File Format

SKILL.md files use YAML frontmatter:
```yaml
---
name: skill-name  # kebab-case identifier
description: Trigger phrases that activate this skill
---
```

The description field contains trigger words that determine when the skill activates.

### Plugin Manifest Format

```json
{
  "name": "bundle-name",
  "version": "1.0.0",
  "description": "Bundle purpose",
  "author": {
    "name": "Author Name",
    "email": "email@example.com"
  },
  "skills": ["./skills/skill-name"]
}
```

## Key Patterns

### No-Placeholder Strategy

The bundle-maker skill enforces gathering ALL required information upfront before creating any files. Generated bundles must have no TODO placeholders.

### Marketplace Registry

`.claude-plugin/marketplace.json` registers bundles:
- Local bundles via relative paths (`./bundles/...`)
- External bundles via Git URLs

### Script Requirements

- bash 4.0+
- jq (for JSON validation): `sudo apt-get install jq` or `brew install jq`

## Current Bundles

1. **react-frontend-bundle** - React patterns, hooks, state management (Zustand, Redux, Jotai), UI/UX design, accessibility
2. **dev-toolkit-bundle** - Bundle creation workflow with automation scripts and working examples
