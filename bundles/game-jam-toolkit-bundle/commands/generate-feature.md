---
name: generate-feature
description: Generate complete C# scripts for a feature
---

# /generate-feature

Write complete, production-ready C# scripts for a game feature.

## What This Does

Generates fully-functional code that:
- Matches your starter script patterns exactly
- Uses modern practices (Input System, async/await, DI, pooling)
- Integrates seamlessly with GameManager, managers, utilities
- Is production quality (error handling, null checks, logging)
- Is memory safe (pooling, cleanup, no leaks)
- Is well-documented and ready to test immediately

## Usage

```
/generate-feature
```

Then provide the architecture from `/design-feature`:
- "Generate the BossEnemy script based on this architecture..."
- "Write all three attack pattern scripts..."
- "Code the complete shop UI system..."

## Output

Complete C# scripts with:
- **Full Code** - Ready to copy/paste into Unity
- **Documentation** - What each class does
- **Public API** - Exposed methods and properties
- **Integration Notes** - How to wire up in Inspector
- **Modern Patterns** - Where Input System, async, DI, pooling used
- **Performance Notes** - Why certain decisions made

## Quality Guarantees

Generated code:
- ✓ Compiles without errors
- ✓ Follows your starter patterns
- ✓ Uses modern Unity practices
- ✓ Memory efficient
- ✓ Ready to test immediately

## Jam-Time Workflow

Design → Generate → Paste → Test → Next feature. No refactoring needed.

## Related Commands

- `/design-feature` - Plan the architecture first
- `/review-code` - Get feedback during development
