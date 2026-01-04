# Detailed Patterns

This file demonstrates how detailed documentation lives in references/ instead of SKILL.md.

## Pattern 1: Domain-Specific Organization

When a skill covers multiple domains or frameworks, organize references by domain:

```
skill-name/
└── references/
    ├── domain-a.md
    ├── domain-b.md
    └── domain-c.md
```

Claude loads only the relevant reference file when needed.

## Pattern 2: Feature-Based Organization

For skills with many features, organize by feature:

```
skill-name/
└── references/
    ├── feature-1.md
    ├── feature-2.md
    └── advanced-features.md
```

## Pattern 3: Progressive Complexity

Organize content from simple to advanced:

```
skill-name/
└── references/
    ├── getting-started.md
    ├── intermediate.md
    └── advanced.md
```

## Additional Patterns

This file could contain 2,000+ words of detailed patterns without bloating SKILL.md context.
