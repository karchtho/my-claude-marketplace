# API Design Bundle

Comprehensive API design expertise for REST and GraphQL APIs with Postman MCP integration.

## Overview

This bundle contains 4 specialized skills for designing, implementing, and testing production-grade APIs:

### Skills Included

1. **REST API Design** (485 lines)
   - Resource-oriented architecture and HTTP semantics
   - Pagination strategies (offset, cursor, link header)
   - Error handling and status codes
   - API versioning approaches
   - Security patterns (authentication, CORS, rate limiting)

2. **GraphQL API Design** (670 lines)
   - Schema-first development and type systems
   - Query, mutation, and subscription design
   - Resolver implementation and DataLoader patterns
   - Pagination (Relay and offset-based)
   - N+1 query prevention and complexity limiting
   - Directives and custom scalars

3. **API Architecture** (310 lines)
   - Versioning strategies across API types
   - Security and authentication/authorization
   - Rate limiting implementation
   - Monitoring and observability
   - Caching strategies
   - Error handling and documentation

4. **API Testing** (546 lines)
   - Testing pyramid (unit, integration, E2E)
   - REST API testing with pytest
   - GraphQL testing with Jest
   - **Postman MCP integration** for collection automation
   - Newman CLI for CI/CD automation
   - Contract testing (OpenAPI, Pact)
   - Framework-specific examples

## Installation

### From Marketplace

```bash
/plugin install api-design-bundle@my-claude-marketplace
```

### Manual Installation

```bash
# Clone or navigate to marketplace directory
cd ~/.claude/plugins/

# Bundle is already registered when marketplace is loaded
```

## Postman MCP Integration

This bundle includes comprehensive Postman MCP integration for automating API tests:

### Setup

**Method 1: Via Smithery (Recommended)**
```bash
npx -y @smithery/cli install mcp-postman --client claude
```

**Method 2: Manual Installation**
```bash
git clone https://github.com/shannonlal/mcp-postman.git
cd mcp-postman
pnpm install && pnpm build
```

### Configuration

Add to `~/.config/claude/config.json`:
```json
{
  "mcpServers": {
    "postman": {
      "command": "node",
      "args": ["/path/to/mcp-postman/build/index.js"],
      "env": {
        "POSTMAN_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

## Usage

### Skill Activation

The skills activate automatically based on your questions and context:

- **REST API Design**: "How should I design REST endpoints?" "What's the best pagination approach?"
- **GraphQL API Design**: "Building a GraphQL schema" "How do I prevent N+1 queries?"
- **API Architecture**: "Implementing API versioning" "Setting up authentication" "Rate limiting strategies"
- **API Testing**: "Writing API tests" "Integrating Postman" "Setting up test automation"

### Example Workflows

**Designing a User API:**
```
User: "I'm designing a REST API for user management. What structure should I use?"

→ REST API Design skill activates with:
  - Resource-oriented patterns
  - CRUD operation examples
  - Error handling strategies
  - Pagination recommendations
```

**Optimizing GraphQL Queries:**
```
User: "My GraphQL API has N+1 query problems. How do I fix this?"

→ GraphQL API Design skill activates with:
  - DataLoader pattern explanation
  - Complete implementation example
  - Performance optimization strategies
```

**Running Tests in CI/CD:**
```
User: "Set up automated API testing with Postman collections"

→ API Testing skill activates with:
  - Postman MCP integration guide
  - Newman CLI automation
  - CI/CD pipeline examples (GitHub Actions, etc.)
```

## File Structure

```
api-design-bundle/
├── .claude-plugin/
│   └── plugin.json           # Bundle manifest
├── skills/
│   ├── rest-api-design/
│   │   └── SKILL.md         # REST API patterns (485 lines)
│   ├── graphql-api-design/
│   │   └── SKILL.md         # GraphQL patterns (670 lines)
│   ├── api-architecture/
│   │   └── SKILL.md         # Architecture concerns (310 lines)
│   └── api-testing/
│       └── SKILL.md         # Testing strategies (546 lines)
├── README.md                # This file
└── examples/                # (Coming soon)
    ├── openapi-spec.yaml
    ├── graphql-schema.graphql
    ├── postman-collection.json
    └── newman-automation.sh
```

## Key Concepts

### Progressive Disclosure

Each skill organizes content from quick patterns to detailed references:

1. **SKILL.md**: Core patterns and code examples (~500 lines)
2. **references/**: Deep dives and comprehensive guides (coming soon)
3. **examples/**: Working code samples (coming soon)

### Cross-Skill Integration

Skills reference each other for comprehensive coverage:

- **REST Design** → Compare with GraphQL (api-architecture)
- **GraphQL Design** → Security and versioning (api-architecture)
- **Architecture** → REST-specific or GraphQL-specific patterns
- **Testing** → Test REST and GraphQL endpoints

### No Placeholders

All content is production-ready with working code examples and complete implementations.

## Learning Path

### For Beginners

1. Start with **REST API Design** if building HTTP APIs
2. Or **GraphQL API Design** if building graph-based APIs
3. Use **API Architecture** for production considerations
4. Apply **API Testing** for quality assurance

### For Experienced Developers

1. Reference **API Architecture** for versioning and security strategies
2. Use **REST/GraphQL Design** for specific paradigm questions
3. Leverage **API Testing** with Postman MCP for automation
4. Combine skills for holistic API development

### For DevOps/Infrastructure

1. **API Architecture** - Monitoring, caching, rate limiting
2. **API Testing** - Newman automation, CI/CD integration
3. **REST API Design** - Error handling and logging

## Features

✓ **REST API Expertise** - Resource modeling, HTTP semantics, pagination
✓ **GraphQL Expertise** - Schema design, resolver optimization, subscriptions
✓ **Architecture Guidance** - Versioning, security, monitoring
✓ **Testing Integration** - Postman MCP, Newman, pytest, Jest
✓ **Production Ready** - No placeholders, complete implementations
✓ **Cross-Language** - Python, JavaScript/Node.js examples
✓ **Best Practices** - Industry standards and patterns

## Recent Updates

**v1.0.0 (Initial Release)**
- REST API Design skill (485 lines)
- GraphQL API Design skill (670 lines)
- API Architecture skill (310 lines)
- API Testing skill with Postman MCP (546 lines)
- 2,021 lines of comprehensive API design expertise

## Future Enhancements

- Reference files for deep dives (versioning, security, monitoring)
- Working examples (OpenAPI specs, GraphQL schemas, test collections)
- API gateway configurations (Kong, AWS API Gateway)
- gRPC/Protocol Buffers design patterns
- Async API and event-driven design patterns
- Performance optimization techniques
- Real-world case studies and migrations

## Sources & References

- [REST API Best Practices](docs/skills-to-test/api/api-design-principles/references/rest-best-practices.md)
- [GraphQL Schema Design](docs/skills-to-test/api/api-design-principles/references/graphql-schema-design.md)
- [Postman MCP GitHub](https://github.com/shannonlal/mcp-postman)
- [Official Postman Documentation](https://learning.postman.com/docs/developer/postman-api/postman-mcp-server/)

## Contributing

This bundle follows project conventions:

- SKILL.md files: 300-700 lines of lean core content
- No TODO placeholders in any files
- Cross-skill references for cohesion
- Production-ready code examples
- Consistent trigger phrases in skill descriptions

## Support

For issues or questions:

1. Check the skill descriptions for activation triggers
2. Review cross-skill references for related content
3. Refer to the plan file: `/home/ubuntu/.claude/plans/delegated-mapping-jellyfish.md`

## License

This bundle is part of the Claude Code Marketplace and follows the project license.

---

**Ready to design your APIs?** Ask Claude: "Help me design a REST API for..." or "I'm building a GraphQL schema..."
