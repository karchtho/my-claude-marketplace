#!/bin/bash
# add-skill-to-bundle.sh - Add a skill to an existing bundle
# Usage: ./add-skill-to-bundle.sh <bundle-path> <skill-name>

set -e

BUNDLE_PATH="$1"
SKILL_NAME="$2"

if [ -z "$BUNDLE_PATH" ] || [ -z "$SKILL_NAME" ]; then
  echo "Error: Bundle path and skill name are required"
  echo "Usage: ./add-skill-to-bundle.sh <bundle-path> <skill-name>"
  echo "Example: ./add-skill-to-bundle.sh ./bundles/react-frontend-bundle react-patterns"
  exit 1
fi

if [ ! -d "$BUNDLE_PATH" ]; then
  echo "Error: Bundle path '$BUNDLE_PATH' does not exist"
  exit 1
fi

if [ ! -f "$BUNDLE_PATH/.claude-plugin/plugin.json" ]; then
  echo "Error: No plugin.json found at '$BUNDLE_PATH/.claude-plugin/plugin.json'"
  exit 1
fi

SKILL_PATH="$BUNDLE_PATH/skills/$SKILL_NAME"

if [ -d "$SKILL_PATH" ]; then
  echo "Error: Skill '$SKILL_NAME' already exists at $SKILL_PATH"
  exit 1
fi

echo "Adding skill: $SKILL_NAME"
echo "To bundle: $BUNDLE_PATH"
echo "Skill path: $SKILL_PATH"

# Create skill directory structure
mkdir -p "$SKILL_PATH/references"
mkdir -p "$SKILL_PATH/examples"
mkdir -p "$SKILL_PATH/scripts"

# Create SKILL.md template
cat > "$SKILL_PATH/SKILL.md" << 'EOF'
---
name: SKILL_NAME_PLACEHOLDER
description: This skill should be used when the user asks to "TODO: add trigger phrases". TODO: Add comprehensive description with specific trigger phrases and use cases.
version: 1.0.0
---

# SKILL_NAME_DISPLAY_PLACEHOLDER

TODO: Add skill description and purpose

## Core Workflows

TODO: Add core workflows and procedures

## Additional Resources

### Reference Files

For detailed guidance:
- **`references/patterns.md`** - TODO: Add reference files as needed

### Example Files

Working examples in `examples/`:
- **`examples/basic-usage.sh`** - TODO: Add examples as needed

### Utility Scripts

Helper scripts in `scripts/`:
- **`scripts/helper.sh`** - TODO: Add utility scripts as needed
EOF

# Replace placeholders
SKILL_NAME_DISPLAY=$(echo "$SKILL_NAME" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_PATH/SKILL.md"
sed -i "s/SKILL_NAME_DISPLAY_PLACEHOLDER/$SKILL_NAME_DISPLAY/g" "$SKILL_PATH/SKILL.md"

echo ""
echo "✓ Skill structure created successfully!"
echo ""
echo "Next steps:"
echo "1. Edit $SKILL_PATH/SKILL.md"
echo "   - Update description with specific trigger phrases"
echo "   - Add core workflows and procedures"
echo "   - Remove TODO placeholders"
echo "2. Add reference files to $SKILL_PATH/references/"
echo "3. Add example files to $SKILL_PATH/examples/"
echo "4. Add utility scripts to $SKILL_PATH/scripts/"
echo "5. Update $BUNDLE_PATH/.claude-plugin/plugin.json to include:"
echo "   \"./skills/$SKILL_NAME\""
echo ""
