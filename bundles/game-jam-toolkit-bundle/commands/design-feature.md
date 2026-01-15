---
name: design-feature
description: Design a new game feature before coding
---

# /design-feature

Design a game feature with complete architecture before writing code.

## What This Does

Takes your feature description and produces:
- System overview and high-level design
- Class structure and relationships
- Dependency map (what connects to what)
- Integration strategy (connects to GameManager, managers, etc.)
- Modern patterns used (Input System, async/await, DI, pooling)
- Code skeleton with class signatures
- Ready for `/generate-feature` to write actual code

## Usage

```
/design-feature
```

Then describe your feature:
- "I need a boss enemy with 3 different attack patterns"
- "Create a shop UI system where players buy upgrades"
- "Design a checkpoint/save system for progression"

## Output

Complete architecture plan with:
- **System Overview** - What is this and why?
- **Class Structure** - Classes, methods, properties
- **Integration Points** - How it connects to existing systems
- **Modern Patterns** - Input System, async, DI approach
- **Code Skeleton** - Method signatures ready for implementation
- **Next Steps** - "Ready for /generate-feature"

## Workflow

1. Describe feature → get architecture
2. Review with team
3. Use `/generate-feature` to write the code
4. Paste into project and test

## Related Commands

- `/generate-feature` - Write the actual code
- `/review-code` - Get feedback on code
