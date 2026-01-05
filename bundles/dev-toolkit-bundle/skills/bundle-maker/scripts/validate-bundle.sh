#!/bin/bash
# validate-bundle.sh - Validate bundle structure and plugin.json format
# Usage: ./validate-bundle.sh <bundle-path>

set -e

BUNDLE_PATH="$1"

if [ -z "$BUNDLE_PATH" ]; then
  echo "Error: Bundle path is required"
  echo "Usage: ./validate-bundle.sh <bundle-path>"
  echo "Example: ./validate-bundle.sh ./bundles/react-frontend-bundle"
  exit 1
fi

if [ ! -d "$BUNDLE_PATH" ]; then
  echo "Error: Bundle path '$BUNDLE_PATH' does not exist"
  exit 1
fi

echo "Validating bundle: $BUNDLE_PATH"
echo ""

ERRORS=0
WARNINGS=0

# Check for .claude-plugin directory
if [ ! -d "$BUNDLE_PATH/.claude-plugin" ]; then
  echo "✗ ERROR: Missing .claude-plugin/ directory"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ .claude-plugin/ directory exists"
fi

# Check for plugin.json
if [ ! -f "$BUNDLE_PATH/.claude-plugin/plugin.json" ]; then
  echo "✗ ERROR: Missing .claude-plugin/plugin.json file"
  ERRORS=$((ERRORS + 1))
else
  echo "✓ plugin.json exists"

  # Validate JSON format
  if ! jq empty "$BUNDLE_PATH/.claude-plugin/plugin.json" 2>/dev/null; then
    echo "✗ ERROR: plugin.json is not valid JSON"
    ERRORS=$((ERRORS + 1))
  else
    echo "✓ plugin.json is valid JSON"

    # Check required fields
    REQUIRED_FIELDS=("name" "version" "description" "author")
    for field in "${REQUIRED_FIELDS[@]}"; do
      if ! jq -e ".$field" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
        echo "✗ ERROR: Missing required field: $field"
        ERRORS=$((ERRORS + 1))
      else
        echo "✓ Required field exists: $field"
      fi
    done

    # Check author subfields
    AUTHOR_FIELDS=("name" "email")
    for field in "${AUTHOR_FIELDS[@]}"; do
      if ! jq -e ".author.$field" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
        echo "✗ ERROR: Missing author.$field field"
        ERRORS=$((ERRORS + 1))
      else
        VALUE=$(jq -r ".author.$field" "$BUNDLE_PATH/.claude-plugin/plugin.json")
        if [[ "$VALUE" == *"TODO"* ]]; then
          echo "⚠ WARNING: author.$field contains TODO placeholder: $VALUE"
          WARNINGS=$((WARNINGS + 1))
        else
          echo "✓ author.$field is set: $VALUE"
        fi
      fi
    done

    # Check description for TODO
    DESCRIPTION=$(jq -r ".description" "$BUNDLE_PATH/.claude-plugin/plugin.json")
    if [[ "$DESCRIPTION" == *"TODO"* ]]; then
      echo "⚠ WARNING: description contains TODO placeholder"
      WARNINGS=$((WARNINGS + 1))
    fi

    # Check if skills array or components exists
    if jq -e ".skills" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
      SKILL_COUNT=$(jq '.skills | length' "$BUNDLE_PATH/.claude-plugin/plugin.json")
      echo "✓ Skills array exists ($SKILL_COUNT skills listed)"

      # Validate each skill path
      jq -r '.skills[]' "$BUNDLE_PATH/.claude-plugin/plugin.json" | while read -r skill_path; do
        # Remove leading ./ if present
        skill_path="${skill_path#./}"
        FULL_SKILL_PATH="$BUNDLE_PATH/$skill_path"

        if [ ! -d "$FULL_SKILL_PATH" ]; then
          echo "✗ ERROR: Skill directory not found: $skill_path"
          ERRORS=$((ERRORS + 1))
        else
          if [ ! -f "$FULL_SKILL_PATH/SKILL.md" ]; then
            echo "✗ ERROR: Missing SKILL.md in $skill_path"
            ERRORS=$((ERRORS + 1))
          else
            echo "✓ Skill valid: $skill_path"

            # Check SKILL.md frontmatter
            if ! grep -q "^---$" "$FULL_SKILL_PATH/SKILL.md"; then
              echo "⚠ WARNING: SKILL.md in $skill_path may be missing YAML frontmatter"
              WARNINGS=$((WARNINGS + 1))
            fi
          fi
        fi
      done
    elif jq -e ".components" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
      echo "✓ Components object exists (extended format)"
    else
      echo "⚠ WARNING: No skills array or components object found"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
fi

# Validate MCP configurations
echo ""
echo "Checking MCP configurations..."

# Check for separate .mcp.json
if [ -f "$BUNDLE_PATH/.mcp.json" ]; then
  echo "✓ Found .mcp.json file"

  if ! jq empty "$BUNDLE_PATH/.mcp.json" 2>/dev/null; then
    echo "✗ ERROR: .mcp.json is not valid JSON"
    ERRORS=$((ERRORS + 1))
  else
    echo "✓ .mcp.json is valid JSON"

    if ! jq -e ".mcpServers" "$BUNDLE_PATH/.mcp.json" > /dev/null 2>&1; then
      echo "✗ ERROR: .mcp.json missing 'mcpServers' object"
      ERRORS=$((ERRORS + 1))
    else
      # Validate each server configuration
      SERVER_COUNT=$(jq '.mcpServers | keys | length' "$BUNDLE_PATH/.mcp.json")
      echo "  Validating $SERVER_COUNT MCP servers..."

      jq -r '.mcpServers | keys[]' "$BUNDLE_PATH/.mcp.json" | while read -r server_name; do
        TRANSPORT_TYPE=$(jq -r ".mcpServers[\"$server_name\"].type" "$BUNDLE_PATH/.mcp.json")

        if [ "$TRANSPORT_TYPE" = "stdio" ]; then
          if jq -e ".mcpServers[\"$server_name\"].command" "$BUNDLE_PATH/.mcp.json" > /dev/null 2>&1; then
            echo "  ✓ MCP server '$server_name' (stdio) is valid"
          else
            echo "  ✗ ERROR: MCP server '$server_name' (stdio) missing 'command' field"
            ERRORS=$((ERRORS + 1))
          fi
        elif [ "$TRANSPORT_TYPE" = "http" ]; then
          if jq -e ".mcpServers[\"$server_name\"].url" "$BUNDLE_PATH/.mcp.json" > /dev/null 2>&1; then
            echo "  ✓ MCP server '$server_name' (http) is valid"
          else
            echo "  ✗ ERROR: MCP server '$server_name' (http) missing 'url' field"
            ERRORS=$((ERRORS + 1))
          fi
        else
          echo "  ⚠ WARNING: MCP server '$server_name' has unknown transport type: $TRANSPORT_TYPE"
          WARNINGS=$((WARNINGS + 1))
        fi
      done
    fi
  fi
fi

# Check for inline mcpServers in plugin.json
if jq -e ".mcpServers" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
  MCP_VALUE=$(jq -r '.mcpServers | type' "$BUNDLE_PATH/.claude-plugin/plugin.json")

  if [ "$MCP_VALUE" = "string" ]; then
    # Reference to .mcp.json file
    echo "✓ plugin.json references external MCP configuration"
  else
    # Inline configuration
    echo "✓ plugin.json has inline mcpServers configuration"

    if [ -f "$BUNDLE_PATH/.mcp.json" ]; then
      echo "⚠ WARNING: Both .mcp.json and inline mcpServers exist - inline takes precedence"
      WARNINGS=$((WARNINGS + 1))
    fi

    # Validate inline servers
    SERVER_COUNT=$(jq '.mcpServers | keys | length' "$BUNDLE_PATH/.claude-plugin/plugin.json")
    echo "  Validating $SERVER_COUNT inline MCP servers..."

    jq -r '.mcpServers | keys[]' "$BUNDLE_PATH/.claude-plugin/plugin.json" | while read -r server_name; do
      TRANSPORT_TYPE=$(jq -r ".mcpServers[\"$server_name\"].type" "$BUNDLE_PATH/.claude-plugin/plugin.json")

      if [ "$TRANSPORT_TYPE" = "stdio" ]; then
        if jq -e ".mcpServers[\"$server_name\"].command" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
          echo "  ✓ MCP server '$server_name' (stdio) is valid"
        else
          echo "  ✗ ERROR: MCP server '$server_name' (stdio) missing 'command' field"
          ERRORS=$((ERRORS + 1))
        fi
      elif [ "$TRANSPORT_TYPE" = "http" ]; then
        if jq -e ".mcpServers[\"$server_name\"].url" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
          echo "  ✓ MCP server '$server_name' (http) is valid"
        else
          echo "  ✗ ERROR: MCP server '$server_name' (http) missing 'url' field"
          ERRORS=$((ERRORS + 1))
        fi
      else
        echo "  ⚠ WARNING: MCP server '$server_name' has unknown transport type: $TRANSPORT_TYPE"
        WARNINGS=$((WARNINGS + 1))
      fi
    done
  fi
fi

echo ""
echo "════════════════════════════════════════════"
echo "Validation Results"
echo "════════════════════════════════════════════"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
  if [ $WARNINGS -eq 0 ]; then
    echo "✓ Bundle is valid!"
    exit 0
  else
    echo "⚠ Bundle is valid but has warnings"
    exit 0
  fi
else
  echo "✗ Bundle validation failed"
  exit 1
fi
