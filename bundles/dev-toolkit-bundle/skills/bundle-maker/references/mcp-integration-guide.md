# MCP Integration Guide for Claude Code Plugins

## Table of Contents

1. [MCP Fundamentals](#mcp-fundamentals)
2. [Transport Types](#transport-types)
3. [Configuration Options](#configuration-options)
4. [Authentication Patterns](#authentication-patterns)
5. [Common MCP Servers](#common-mcp-servers)
6. [Adding MCP to Your Bundle](#adding-mcp-to-your-bundle)
7. [Complete Examples](#complete-examples)
8. [Validation Checklist](#validation-checklist)
9. [Troubleshooting](#troubleshooting)

---

## MCP Fundamentals

### What is MCP?

The Model Context Protocol (MCP) is an open-source standard that enables Claude Code to connect with external tools and data sources. MCP servers expose capabilities (tools, resources, prompts) that extend Claude's abilities.

### Why Add MCP to Bundles?

Bundling MCP servers with plugins provides:

- **Automatic distribution** - Tools included with the plugin
- **Team consistency** - Everyone gets the same integrations
- **Simplified setup** - No manual configuration required
- **Scoped credentials** - Per-project environment variables
- **Version control** - MCP configs checked into git

### When to Use MCP

Add MCP servers to your bundle when users need:

- **Design tool integration** - Figma API access for design systems
- **GitHub integration** - PR reviews, issue management, repository operations
- **Database access** - Query production/staging databases
- **Error monitoring** - Sentry, LogRocket, or similar services
- **External APIs** - Any REST API you want Claude to access

---

## Transport Types

### 1. Stdio (Local Processes)

For local executables that run on the user's machine.

**Best for:** Database clients, custom scripts, private services

**Required fields:**
```json
{
  "type": "stdio",
  "command": "path/to/executable",
  "args": ["arg1", "arg2"],
  "env": {"KEY": "value"}
}
```

**Example: Database Server**
```json
{
  "database": {
    "type": "stdio",
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-mcp",
    "args": ["--database", "production"],
    "env": {
      "DB_HOST": "${DB_HOST}",
      "DB_PASSWORD": "${DB_PASSWORD}"
    }
  }
}
```

### 2. HTTP (Cloud Services)

For remote APIs and cloud services.

**Best for:** GitHub, Figma, Sentry, Stripe, external APIs

**Required fields:**
```json
{
  "type": "http",
  "url": "https://api.service.com/mcp",
  "headers": {"Authorization": "Bearer ${TOKEN}"}
}
```

**Example: GitHub Integration**
```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp/",
    "headers": {
      "Authorization": "Bearer ${GITHUB_TOKEN}"
    }
  }
}
```

### 3. SSE (Deprecated)

Server-Sent Events. Avoid for new implementations—use HTTP instead.

---

## Configuration Options

### Option A: Separate `.mcp.json` File (Recommended)

For bundles with multiple MCP servers or complex configurations.

**File location:**
```
my-bundle/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json           ← MCP servers here
├── skills/
└── servers/
```

**Reference in `plugin.json`:**
```json
{
  "name": "my-bundle",
  "mcpServers": "./.mcp.json"
}
```

**`.mcp.json` format:**
```json
{
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://api.figma.com/v1/mcp/",
      "headers": {"Authorization": "Bearer ${FIGMA_TOKEN}"}
    },
    "database": {
      "type": "stdio",
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-mcp",
      "env": {"DB_PASSWORD": "${DB_PASSWORD}"}
    }
  }
}
```

### Option B: Inline in `plugin.json` (For Simple Setups)

For single MCP server bundles.

**Format:**
```json
{
  "name": "my-bundle",
  "version": "1.0.0",
  "description": "Bundle with MCP",
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {"Authorization": "Bearer ${GITHUB_TOKEN}"}
    }
  }
}
```

---

## Authentication Patterns

### Environment Variables

Store secrets in environment variables, not in configuration files.

**Variable expansion syntax:**
- `${VAR}` - Required variable
- `${VAR:-default}` - Optional with fallback

**Example:**
```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp/",
    "headers": {
      "Authorization": "Bearer ${GITHUB_TOKEN}"
    }
  }
}
```

**User setup:**
```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

### Bearer Tokens (HTTP Only)

Most cloud APIs use Bearer token authentication.

```json
{
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

### Custom Headers

Support any authentication header pattern:

```json
{
  "headers": {
    "Authorization": "Bearer ${TOKEN}",
    "X-API-Key": "${API_KEY}",
    "X-Client-ID": "${CLIENT_ID}"
  }
}
```

### Documenting Required Variables

Create an example environment file in your bundle:

**`.env.example`:**
```bash
# Required for Figma integration
FIGMA_ACCESS_TOKEN=figma_token_here

# Required for database server
DB_HOST=localhost:5432
DB_PASSWORD=your_password
```

---

## Common MCP Servers

### Figma (Design System Integration)

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

**Use cases:** Access design files, components, assets; integrate with design systems

### GitHub (Code Repository Integration)

```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp/",
    "headers": {
      "Authorization": "Bearer ${GITHUB_TOKEN}"
    }
  }
}
```

**Use cases:** PR reviews, repository management, issue creation, code search

### Sentry (Error Monitoring)

```json
{
  "sentry": {
    "type": "http",
    "url": "https://mcp.sentry.dev/mcp",
    "headers": {
      "Authorization": "Bearer ${SENTRY_TOKEN}"
    }
  }
}
```

**Use cases:** Query errors, analyze issues, manage releases

### Database (PostgreSQL/MySQL/SQLite)

For local database access via stdio:

```json
{
  "database": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@bytebase/dbhub"],
    "env": {
      "DATABASE_URL": "${DB_CONNECTION_STRING}"
    }
  }
}
```

**Use cases:** Query production data, analyze database schema

---

## Adding MCP to Your Bundle

### Step 1: Gather Information

Determine what you're adding:

- **MCP server name** - Kebab-case identifier (e.g., "figma", "github")
- **Transport type** - "stdio" or "http"
- **Configuration details:**
  - **For HTTP:** URL, authentication token name
  - **For stdio:** Command path, arguments, environment variables
- **Configuration approach** - Separate `.mcp.json` or inline

### Step 2: Use the Automation Script

```bash
scripts/add-mcp-to-bundle.sh <bundle-path> <server-name> <transport-type>
```

**Example:**
```bash
scripts/add-mcp-to-bundle.sh bundles/angular-bundle figma http
```

The script will interactively prompt for required information and generate the configuration.

### Step 3: Document Environment Variables

Update your bundle's README with required variables:

```markdown
## Setup

Set these environment variables before using the bundle:

\`\`\`bash
export FIGMA_ACCESS_TOKEN="your-figma-token"
export DATABASE_URL="postgresql://localhost:5432/mydb"
\`\`\`
```

### Step 4: Validate

```bash
scripts/validate-bundle.sh bundles/your-bundle
```

---

## Complete Examples

### Example 1: Figma Integration (HTTP)

**Scenario:** Angular bundle needs Figma access for design system

**`.mcp.json`:**
```json
{
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://api.figma.com/v1/mcp/",
      "headers": {
        "Authorization": "Bearer ${FIGMA_ACCESS_TOKEN}"
      }
    }
  }
}
```

**Setup instructions:**
1. Get Figma token from figma.com/profile/settings
2. Set environment variable: `export FIGMA_ACCESS_TOKEN="..."`
3. Reinstall bundle
4. Ask Claude: "Show me my Figma files"

### Example 2: Database Integration (Stdio)

**Scenario:** Bundle needs production database access

**`.mcp.json`:**
```json
{
  "mcpServers": {
    "database": {
      "type": "stdio",
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-mcp",
      "args": ["--host", "${DB_HOST}"],
      "env": {
        "DB_PASSWORD": "${DB_PASSWORD}",
        "DB_USER": "${DB_USER}"
      }
    }
  }
}
```

**Setup instructions:**
```bash
export DB_HOST="prod.example.com:5432"
export DB_USER="analytics_user"
export DB_PASSWORD="secure_password"
```

### Example 3: Multiple Servers

**Scenario:** Bundle integrates both Figma and GitHub

**`.mcp.json`:**
```json
{
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://api.figma.com/v1/mcp/",
      "headers": {
        "Authorization": "Bearer ${FIGMA_ACCESS_TOKEN}"
      }
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    }
  }
}
```

---

## Validation Checklist

Before deploying a bundle with MCP servers:

### Configuration Validation

- [ ] MCP configuration is valid JSON
- [ ] For separate `.mcp.json`: `mcpServers` object exists
- [ ] Each server has required fields:
  - Stdio: `type`, `command`
  - HTTP: `type`, `url`
- [ ] Transport type is valid (`stdio`, `http`, or `sse`)
- [ ] Environment variables use correct syntax (`${VAR}`)

### Filesystem Validation

- [ ] Stdio servers: command exists and is executable
- [ ] Plugin.json references MCP config correctly
- [ ] No both `.mcp.json` AND inline mcpServers (choose one)

### Documentation

- [ ] README documents required environment variables
- [ ] `.env.example` provided (don't include real values)
- [ ] Setup instructions are clear
- [ ] Example commands show how to test

### Testing

- [ ] MCP tools appear when using Claude Code
- [ ] Authentication works (real token set)
- [ ] Error handling when server unavailable
- [ ] Graceful degradation if MCP server fails

---

## Troubleshooting

### "Command not found" (Stdio)

**Cause:** Server executable doesn't exist

**Solution:**
```bash
# Verify command exists
which your-server
# or for local paths
ls -la ${CLAUDE_PLUGIN_ROOT}/servers/your-server
```

### "Invalid JSON" in `.mcp.json`

**Cause:** JSON syntax error

**Solution:**
```bash
# Validate with jq
jq empty .mcp.json

# Common mistakes:
# - Missing comma between properties
# - Unquoted keys
# - Trailing comma in last property
```

### "Unauthorized" or "Invalid credentials"

**Cause:** Authentication token invalid or wrong format

**Solution:**
```bash
# Verify token is set
echo $FIGMA_ACCESS_TOKEN

# Check token format (usually long string)
echo $FIGMA_ACCESS_TOKEN | wc -c

# Verify header format
# Should be: "Authorization": "Bearer ${TOKEN}"
```

### MCP tools don't appear

**Cause:** Server not running or not configured

**Solution:**
1. Check MCP configuration is loaded: `jq .mcpServers plugin.json`
2. Restart Claude Code
3. Check for errors in server startup
4. Verify environment variables are set

---

## Security Best Practices

### Credentials Management

**DO:**
- Store tokens in environment variables
- Use `.env.example` without real values
- Rotate tokens regularly
- Use least-privilege tokens

**DON'T:**
- Hardcode tokens in configuration
- Commit `.env` files to git
- Share tokens in documentation
- Use overly broad token permissions

### Server Selection

**DO:**
- Use official MCP servers when available
- Review server code if possible
- Test with limited permissions first
- Monitor server usage

**DON'T:**
- Use untrusted or unmaintained servers
- Give unnecessary permissions
- Skip validation before deployment

---

## Advanced Configuration

### Conditional Environment Variables

Use fallback syntax for optional credentials:

```json
{
  "database": {
    "type": "http",
    "url": "${DATABASE_URL:-http://localhost:5432}"
  }
}
```

### Plugin-Relative Paths

Use `${CLAUDE_PLUGIN_ROOT}` for stdio servers in bundles:

```json
{
  "type": "stdio",
  "command": "${CLAUDE_PLUGIN_ROOT}/servers/my-server"
}
```

### Working Directory

Set working directory for stdio servers:

```json
{
  "type": "stdio",
  "command": "node",
  "args": ["index.js"],
  "cwd": "${CLAUDE_PLUGIN_ROOT}/servers/my-server"
}
```

---

## Summary

Successfully integrate MCP servers by:

1. **Choose transport type** - Stdio for local, HTTP for cloud
2. **Gather configuration** - All required fields upfront
3. **Pick configuration approach** - Separate `.mcp.json` or inline
4. **Document variables** - Make setup clear
5. **Validate thoroughly** - Catch errors early
6. **Test before deploying** - Verify connectivity

Use the `add-mcp-to-bundle.sh` script to automate MCP setup with the no-placeholders strategy.
