#!/bin/bash
# create-bundle.sh - Create a new bundle directory structure
# Usage: ./create-bundle.sh <bundle-name> [--with-all]

set -e

BUNDLE_NAME="$1"
WITH_ALL="$2"

if [ -z "$BUNDLE_NAME" ]; then
  echo "Error: Bundle name is required"
  echo "Usage: ./create-bundle.sh <bundle-name> [--with-all]"
  exit 1
fi

# Detect marketplace root
if [ -f ".claude-plugin/marketplace.json" ]; then
  MARKETPLACE_ROOT="."
elif [ -f "../.claude-plugin/marketplace.json" ]; then
  MARKETPLACE_ROOT=".."
else
  echo "Error: Could not find marketplace.json"
  echo "Please run this script from the marketplace root or bundles/ directory"
  exit 1
fi

BUNDLES_DIR="$MARKETPLACE_ROOT/bundles"
BUNDLE_PATH="$BUNDLES_DIR/$BUNDLE_NAME"

if [ -d "$BUNDLE_PATH" ]; then
  echo "Error: Bundle '$BUNDLE_NAME' already exists at $BUNDLE_PATH"
  exit 1
fi

echo "Creating bundle: $BUNDLE_NAME"
echo "Location: $BUNDLE_PATH"

# Create base structure
mkdir -p "$BUNDLE_PATH/.claude-plugin"

if [ "$WITH_ALL" == "--with-all" ]; then
  echo "Creating all component directories..."
  mkdir -p "$BUNDLE_PATH/skills"
  mkdir -p "$BUNDLE_PATH/commands"
  mkdir -p "$BUNDLE_PATH/agents"
  mkdir -p "$BUNDLE_PATH/hooks"
  mkdir -p "$BUNDLE_PATH/mcp"
else
  echo "Creating skills directory only (use --with-all for all components)..."
  mkdir -p "$BUNDLE_PATH/skills"
fi

# Create plugin.json template
cat > "$BUNDLE_PATH/.claude-plugin/plugin.json" << 'EOF'
{
  "name": "BUNDLE_NAME_PLACEHOLDER",
  "version": "1.0.0",
  "description": "TODO: Add bundle description",
  "author": {
    "name": "TODO: Add your name",
    "email": "TODO: Add your email"
  },
  "skills": []
}
EOF

# Replace placeholder with actual bundle name
sed -i "s/BUNDLE_NAME_PLACEHOLDER/$BUNDLE_NAME/g" "$BUNDLE_PATH/.claude-plugin/plugin.json"

echo ""
echo "✓ Bundle structure created successfully!"
echo ""
echo "Next steps:"
echo "1. Edit $BUNDLE_PATH/.claude-plugin/plugin.json"
echo "   - Update description"
echo "   - Update author information"
echo "2. Add skills to $BUNDLE_PATH/skills/"
echo "3. Register bundle in $MARKETPLACE_ROOT/.claude-plugin/marketplace.json"
echo ""
