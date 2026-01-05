#!/bin/bash
# add-mcp-to-bundle.sh - Add an MCP server to an existing bundle
# Usage: ./add-mcp-to-bundle.sh <bundle-path> <server-name> <transport-type>
# Example: ./add-mcp-to-bundle.sh ./bundles/angular-bundle figma http

set -e

BUNDLE_PATH="$1"
SERVER_NAME="$2"
TRANSPORT_TYPE="$3"

# Function to print usage
usage() {
  cat << 'EOF'
Usage: ./add-mcp-to-bundle.sh <bundle-path> <server-name> <transport-type>

Arguments:
  <bundle-path>      Path to the bundle directory
  <server-name>      Kebab-case name for the MCP server (e.g., figma, github)
  <transport-type>   Transport protocol: "stdio" or "http"

Examples:
  # Add HTTP MCP server (Figma)
  ./add-mcp-to-bundle.sh ./bundles/angular-bundle figma http

  # Add stdio MCP server (database)
  ./add-mcp-to-bundle.sh ./bundles/angular-bundle database stdio

This script gathers all required information interactively, then creates or updates
the MCP configuration with NO placeholder values.
EOF
  exit 1
}

# Validate parameters
if [ -z "$BUNDLE_PATH" ] || [ -z "$SERVER_NAME" ] || [ -z "$TRANSPORT_TYPE" ]; then
  echo "Error: Bundle path, server name, and transport type are required"
  usage
fi

# Validate bundle exists
if [ ! -d "$BUNDLE_PATH" ]; then
  echo "Error: Bundle path '$BUNDLE_PATH' does not exist"
  exit 1
fi

if [ ! -f "$BUNDLE_PATH/.claude-plugin/plugin.json" ]; then
  echo "Error: No plugin.json found at '$BUNDLE_PATH/.claude-plugin/plugin.json'"
  exit 1
fi

# Validate transport type
if [ "$TRANSPORT_TYPE" != "stdio" ] && [ "$TRANSPORT_TYPE" != "http" ]; then
  echo "Error: Transport type must be 'stdio' or 'http' (got: $TRANSPORT_TYPE)"
  exit 1
fi

echo "═════════════════════════════════════════════"
echo "Adding MCP Server to Bundle"
echo "═════════════════════════════════════════════"
echo "Bundle: $BUNDLE_PATH"
echo "Server name: $SERVER_NAME"
echo "Transport: $TRANSPORT_TYPE"
echo ""

# Gather information based on transport type
if [ "$TRANSPORT_TYPE" = "stdio" ]; then
  echo "Gathering stdio MCP configuration..."
  echo ""

  read -p "Command path (e.g., \${CLAUDE_PLUGIN_ROOT}/servers/db-mcp): " COMMAND
  if [ -z "$COMMAND" ]; then
    echo "Error: Command path is required"
    exit 1
  fi

  read -p "Arguments (optional, space-separated): " ARGS_INPUT

  echo "Environment variables (optional):"
  echo "  Enter VAR_NAME=\${ENV_VAR} (e.g., DB_PASSWORD=\${DB_PASSWORD})"
  echo "  Leave blank when done"

  ENV_VARS=()
  while true; do
    read -p "  Add env var? (enter VAR=\${VAR} or leave blank to finish): " ENV_VAR
    if [ -z "$ENV_VAR" ]; then
      break
    fi
    ENV_VARS+=("$ENV_VAR")
  done

elif [ "$TRANSPORT_TYPE" = "http" ]; then
  echo "Gathering HTTP MCP configuration..."
  echo ""

  read -p "URL (e.g., https://api.figma.com/v1/mcp/): " URL
  if [ -z "$URL" ]; then
    echo "Error: URL is required"
    exit 1
  fi

  read -p "Need authentication? (y/n) [n]: " NEED_AUTH
  NEED_AUTH="${NEED_AUTH:-n}"

  if [ "$NEED_AUTH" = "y" ] || [ "$NEED_AUTH" = "Y" ]; then
    read -p "Authentication token variable name (e.g., FIGMA_ACCESS_TOKEN): " TOKEN_VAR
    if [ -z "$TOKEN_VAR" ]; then
      echo "Error: Token variable name is required"
      exit 1
    fi
  fi
fi

# Detect configuration approach
echo ""
echo "Detecting configuration approach..."

MCP_CONFIG_PATH=""
INLINE_CONFIG=false

if [ -f "$BUNDLE_PATH/.mcp.json" ]; then
  echo "✓ Found existing .mcp.json file"
  MCP_CONFIG_PATH="$BUNDLE_PATH/.mcp.json"
elif jq -e ".mcpServers" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
  echo "✓ Found inline mcpServers in plugin.json"
  INLINE_CONFIG=true
else
  echo "No existing MCP configuration found"
  read -p "Use separate .mcp.json file? (recommended) (y/n) [y]: " USE_SEPARATE
  USE_SEPARATE="${USE_SEPARATE:-y}"

  if [ "$USE_SEPARATE" = "y" ] || [ "$USE_SEPARATE" = "Y" ]; then
    MCP_CONFIG_PATH="$BUNDLE_PATH/.mcp.json"
    echo "✓ Will create .mcp.json"
  else
    INLINE_CONFIG=true
    echo "✓ Will add to inline mcpServers in plugin.json"
  fi
fi

# Build MCP server JSON based on transport type
echo ""
echo "Building MCP server configuration..."

if [ "$TRANSPORT_TYPE" = "stdio" ]; then
  # Build stdio configuration
  MCP_SERVER_JSON="{\"type\": \"stdio\", \"command\": \"$COMMAND\""

  if [ -n "$ARGS_INPUT" ]; then
    # Convert space-separated args to JSON array
    ARGS_JSON=$(echo "$ARGS_INPUT" | jq -R 'split(" ") | map(select(length > 0))')
    MCP_SERVER_JSON="$MCP_SERVER_JSON, \"args\": $ARGS_JSON"
  fi

  if [ ${#ENV_VARS[@]} -gt 0 ]; then
    # Build env object from array
    ENV_JSON="{"
    for i in "${!ENV_VARS[@]}"; do
      IFS='=' read -r VAR_NAME VAR_VALUE <<< "${ENV_VARS[$i]}"
      ENV_JSON="$ENV_JSON\"$VAR_NAME\": \"$VAR_VALUE\""
      if [ $((i + 1)) -lt ${#ENV_VARS[@]} ]; then
        ENV_JSON="$ENV_JSON, "
      fi
    done
    ENV_JSON="$ENV_JSON}"
    MCP_SERVER_JSON="$MCP_SERVER_JSON, \"env\": $ENV_JSON"
  fi

  MCP_SERVER_JSON="$MCP_SERVER_JSON}"

elif [ "$TRANSPORT_TYPE" = "http" ]; then
  # Build HTTP configuration
  MCP_SERVER_JSON="{\"type\": \"http\", \"url\": \"$URL\""

  if [ -n "$TOKEN_VAR" ]; then
    MCP_SERVER_JSON="$MCP_SERVER_JSON, \"headers\": {\"Authorization\": \"Bearer \${$TOKEN_VAR}\"}"
  fi

  MCP_SERVER_JSON="$MCP_SERVER_JSON}"
fi

# Validate JSON
if ! echo "$MCP_SERVER_JSON" | jq empty 2>/dev/null; then
  echo "Error: Generated invalid JSON"
  echo "JSON: $MCP_SERVER_JSON"
  exit 1
fi

# Apply configuration
if [ "$INLINE_CONFIG" = true ]; then
  echo "Adding to inline mcpServers in plugin.json..."

  # Use jq to safely add to plugin.json
  TEMP_FILE=$(mktemp)

  if jq -e ".mcpServers" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
    # mcpServers already exists, merge into it
    jq ".mcpServers[\"$SERVER_NAME\"] = $MCP_SERVER_JSON" "$BUNDLE_PATH/.claude-plugin/plugin.json" > "$TEMP_FILE"
  else
    # Create mcpServers object
    jq ".mcpServers = {\"$SERVER_NAME\": $MCP_SERVER_JSON}" "$BUNDLE_PATH/.claude-plugin/plugin.json" > "$TEMP_FILE"
  fi

  mv "$TEMP_FILE" "$BUNDLE_PATH/.claude-plugin/plugin.json"
  echo "✓ Updated plugin.json"
else
  echo "Adding to .mcp.json..."

  # Use jq to safely add to or create .mcp.json
  TEMP_FILE=$(mktemp)

  if [ -f "$MCP_CONFIG_PATH" ]; then
    # File exists, merge into it
    jq ".mcpServers[\"$SERVER_NAME\"] = $MCP_SERVER_JSON" "$MCP_CONFIG_PATH" > "$TEMP_FILE"
  else
    # Create new file
    echo "{\"mcpServers\": {\"$SERVER_NAME\": $MCP_SERVER_JSON}}" | jq . > "$TEMP_FILE"
  fi

  mv "$TEMP_FILE" "$MCP_CONFIG_PATH"
  echo "✓ Updated .mcp.json"
fi

# If using separate .mcp.json, ensure plugin.json references it
if [ "$INLINE_CONFIG" = false ] && [ -f "$MCP_CONFIG_PATH" ]; then
  if ! jq -e ".mcpServers == \"./.mcp.json\"" "$BUNDLE_PATH/.claude-plugin/plugin.json" > /dev/null 2>&1; then
    # Add reference if not already there
    jq ".mcpServers = \"./.mcp.json\"" "$BUNDLE_PATH/.claude-plugin/plugin.json" > "$BUNDLE_PATH/.claude-plugin/plugin.json.tmp"
    mv "$BUNDLE_PATH/.claude-plugin/plugin.json.tmp" "$BUNDLE_PATH/.claude-plugin/plugin.json"
    echo "✓ Updated plugin.json to reference .mcp.json"
  fi
fi

# Validation
echo ""
echo "Validating configuration..."

if [ "$INLINE_CONFIG" = false ]; then
  if ! jq empty "$MCP_CONFIG_PATH" 2>/dev/null; then
    echo "Error: Generated .mcp.json is not valid JSON"
    exit 1
  fi
  echo "✓ .mcp.json is valid JSON"
fi

echo "✓ Configuration is valid"

# Print success and next steps
echo ""
echo "═════════════════════════════════════════════"
echo "✓ MCP Server Added Successfully!"
echo "═════════════════════════════════════════════"
echo ""

if [ "$TRANSPORT_TYPE" = "stdio" ]; then
  echo "Next steps:"
  echo "1. Set environment variables (if needed):"
  for env_var in "${ENV_VARS[@]}"; do
    IFS='=' read -r VAR_NAME VAR_VALUE <<< "$env_var"
    echo "   export $VAR_NAME=\"value\""
  done
  echo ""
elif [ "$TRANSPORT_TYPE" = "http" ]; then
  echo "Next steps:"
  if [ -n "$TOKEN_VAR" ]; then
    echo "1. Set the authentication token:"
    echo "   export $TOKEN_VAR=\"your-token-here\""
    echo ""
  fi
fi

echo "2. Validate the bundle:"
echo "   ./scripts/validate-bundle.sh $BUNDLE_PATH"
echo ""
echo "3. Reinstall the bundle to pick up changes:"
echo "   /plugin install <bundle-name>@<marketplace>"
echo ""
echo "4. Test the MCP server:"
if [ "$SERVER_NAME" = "figma" ]; then
  echo "   Ask Claude: 'List my Figma files'"
elif [ "$SERVER_NAME" = "github" ]; then
  echo "   Ask Claude: 'Show my recent GitHub repos'"
elif [ "$SERVER_NAME" = "database" ]; then
  echo "   Ask Claude: 'Query the database for...'"
else
  echo "   Ask Claude to use the $SERVER_NAME MCP server"
fi
echo ""

echo "MCP Configuration Reference:"
if [ "$INLINE_CONFIG" = false ]; then
  echo "  Config file: $MCP_CONFIG_PATH"
else
  echo "  Config location: plugin.json (mcpServers field)"
fi
echo "  Server name: $SERVER_NAME"
echo "  Transport: $TRANSPORT_TYPE"
echo ""
