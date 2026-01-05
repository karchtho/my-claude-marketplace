# MCP Integration Examples

This `complete-bundle` example demonstrates MCP (Model Context Protocol) server integration using a separate `.mcp.json` configuration file.

## Configured MCP Servers

### 1. Figma (HTTP Transport)

**Purpose:** Access Figma design files and components

**Configuration:**
```json
{
  "figma": {
    "type": "http",
    "url": "https://api.figma.com/v1/mcp/",
    "headers": {
      "Authorization": "Bearer ${FIGMA_ACCESS_TOKEN}"
    }
  }
}
```

**Authentication:** Bearer token via `FIGMA_ACCESS_TOKEN` environment variable

**Capabilities:**
- List design files
- Read components
- Access design assets
- Query design specifications

### 2. Database (Stdio Transport)

**Purpose:** Query production database with natural language

**Configuration:**
```json
{
  "database": {
    "type": "stdio",
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-mcp",
    "args": ["--database", "production"],
    "env": {
      "DB_HOST": "${DB_HOST}",
      "DB_USER": "${DB_USER}",
      "DB_PASSWORD": "${DB_PASSWORD}"
    }
  }
}
```

**Environment Variables:**
- `DB_HOST` - Database connection (host:port)
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password

**Capabilities:**
- Execute queries
- Explore schema
- Analyze data
- Get table descriptions

---

## Setup Instructions

### 1. Set Required Environment Variables

Create a `.env` file (don't commit to git):

```bash
# Figma integration
export FIGMA_ACCESS_TOKEN="your-figma-token-here"

# Database integration
export DB_HOST="prod.example.com:5432"
export DB_USER="analytics_user"
export DB_PASSWORD="your-secure-password"
```

**Or set directly:**

```bash
export FIGMA_ACCESS_TOKEN="your-figma-token-here"
export DB_HOST="prod.example.com:5432"
export DB_USER="analytics_user"
export DB_PASSWORD="your-secure-password"
```

### 2. Get Figma Token

1. Visit https://figma.com/files
2. Go to **Settings > Developer Settings**
3. Generate a **Personal access token**
4. Copy token and set `FIGMA_ACCESS_TOKEN`

### 3. Validate Bundle

```bash
./scripts/validate-bundle.sh examples/complete-bundle
```

Expected output:
```
✓ plugin.json is valid
✓ Skills are valid
✓ MCP server 'figma' (http) is valid
✓ MCP server 'database' (stdio) is valid
✓ Bundle is valid!
```

### 4. Install Bundle

```bash
/plugin install complete-bundle@my-marketplace
```

### 5. Test MCP Integration

**Test Figma:**
```
> List my Figma files
```

**Test Database:**
```
> Query the database to find users created in the last 7 days
```

---

## Configuration File Locations

### Separate `.mcp.json` (Current Example)

**Best for:** Multiple servers, complex configurations

**Location:**
```
complete-bundle/
├── .claude-plugin/
│   └── plugin.json          # References .mcp.json
├── .mcp.json                # MCP servers here
├── skills/
└── commands/
```

**Reference in plugin.json:**
```json
{
  "name": "complete-bundle",
  "mcpServers": "./.mcp.json"
}
```

**Advantages:**
- Cleaner separation
- Easier to maintain
- Supports unlimited servers

### Alternative: Inline in `plugin.json`

**Best for:** Single MCP server bundles

**Example:**
```json
{
  "name": "complete-bundle",
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://api.figma.com/v1/mcp/",
      "headers": {"Authorization": "Bearer ${FIGMA_ACCESS_TOKEN}"}
    }
  }
}
```

**Advantages:**
- Single file
- Simpler for prototyping
- All metadata together

---

## Using MCP Servers in Skills

Reference MCP capabilities in your skills:

**Example skill using Figma MCP:**

```markdown
---
name: design-system-integration
description: Extract design tokens from Figma design system. Use when asked to "get design tokens", "extract Figma colors", or "integrate design system"
---

# Design System Integration

Use the Figma MCP to:
1. Find the design system file with `list_figma_files`
2. Get components with `get_figma_components`
3. Extract design tokens
4. Export specifications

The Figma MCP provides tools for accessing your design files.
```

**Example skill using database MCP:**

```markdown
---
name: data-analysis
description: Analyze user data from the production database. Use when asked to "find users", "query the database", or "analyze user metrics"
---

# Data Analysis

Use the database MCP to:
1. Query user data with natural language
2. Explore database schema
3. Analyze trends
4. Generate reports

The database MCP provides SQL query execution.
```

---

## Environment Variable Reference

### `.env.example` (Template)

Check this file into git with placeholder values:

```bash
# Figma Integration
# Get token from: https://figma.com/files (Settings > Developer)
FIGMA_ACCESS_TOKEN=figma_token_here

# Database Integration
# Format: hostname:port
DB_HOST=prod.example.com:5432

# Database user with analytics permissions
DB_USER=analytics_user

# Database password (use secrets manager for production)
DB_PASSWORD=your_password_here
```

### Setup Command

```bash
# Load environment variables
source .env

# Verify they're set
echo $FIGMA_ACCESS_TOKEN
echo $DB_HOST
```

---

## Validation Checklist

Before deploying this bundle:

- [ ] `.mcp.json` is valid JSON (`jq empty .mcp.json`)
- [ ] `plugin.json` references `.mcp.json` correctly
- [ ] All environment variables documented
- [ ] `.env.example` provided (without real values)
- [ ] MCP servers tested with real credentials
- [ ] Skills reference MCP capabilities
- [ ] Error handling documented
- [ ] Validation passes: `./scripts/validate-bundle.sh examples/complete-bundle`

---

## Troubleshooting

### "Connection refused" (Stdio)

**Cause:** Database server not running

**Solution:**
- Verify server executable exists: `ls -la ${CLAUDE_PLUGIN_ROOT}/servers/db-mcp`
- Check permissions: `chmod +x ${CLAUDE_PLUGIN_ROOT}/servers/db-mcp`
- Test manually: `${CLAUDE_PLUGIN_ROOT}/servers/db-mcp --help`

### "Unauthorized" (HTTP/Figma)

**Cause:** Invalid or expired token

**Solution:**
```bash
# Verify token is set
echo $FIGMA_ACCESS_TOKEN

# Generate new token if needed
# Visit: https://figma.com/files (Settings > Developer)
```

### "Invalid JSON" in `.mcp.json`

**Cause:** Syntax error

**Solution:**
```bash
# Validate with jq
jq empty .mcp.json

# Fix common issues:
# - Missing comma between properties
# - Unquoted string values
# - Trailing comma
```

### MCP tools don't appear

**Cause:** Configuration not loaded

**Solution:**
1. Check configuration: `jq .mcpServers plugin.json`
2. Restart Claude Code
3. Verify environment variables: `echo $FIGMA_ACCESS_TOKEN`

---

## Next Steps

1. **Test with real tokens** - Set up actual Figma and database access
2. **Add more servers** - Integrate GitHub, Sentry, or other APIs
3. **Extend skills** - Build skills that use MCP capabilities
4. **Document usage** - Update README with MCP workflows
5. **Monitor access** - Track which MCP tools are being used

---

## Resources

- **MCP Integration Guide:** See `references/mcp-integration-guide.md` for complete documentation
- **Figma API:** https://www.figma.com/developers
- **Database MCP:** Look for @bytebase/dbhub or similar
- **Claude Code Docs:** Check official Claude Code plugin documentation
