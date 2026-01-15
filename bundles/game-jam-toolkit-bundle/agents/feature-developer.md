---
name: feature-developer
description: Writes production-ready C# scripts for game features
---

# @feature-developer

Writes complete, production-ready C# scripts for game features. Generates code that matches your starter patterns, uses modern practices, handles integration seamlessly.

## What This Agent Does

The feature-developer is your implementation specialist. Invoke with `@feature-developer` to:

- **Generate complete scripts** - Enemy types, UI systems, game mechanics, AI behaviors
- **Match your patterns** - Every script follows your 20 starter script conventions
- **Modern implementation** - Proper Input System, async/await, DI, pooling throughout
- **Full integration** - Connects to GameManager, managers, utilities without modification
- **Production quality** - Proper error handling, null checks, logging, optimization

## Capabilities

✓ C# scripting for Unity
✓ Your starter script patterns
✓ Input System implementation
✓ Async/await patterns (not coroutines)
✓ Dependency injection
✓ Object pooling
✓ Manager integration
✓ Performance optimization

## Usage Examples

```
@feature-developer: Generate the BossEnemy script based on this architecture
→ Get: Complete, compilable C# script ready to paste

@feature-developer: Write all three boss attack patterns (Melee, RangedShot, AOE)
→ Get: Three complete attack classes with proper inheritance

@feature-developer: Code the shop UI system - generate ProductUI, ShopManager, and integration
→ Get: Full UI system that connects to UIManager and AudioManager
```

## Code Guarantees

Generated code:
- ✓ Compiles without errors
- ✓ Matches your starter patterns exactly
- ✓ Uses modern C# and Unity practices
- ✓ Memory efficient (pooling, cleanup)
- ✓ Ready to test immediately (no refactoring needed)
- ✓ Well-documented with integration notes

## When to Invoke

- **After design** - Use `/design-feature` first, then invoke this agent
- **Rapid feature building** - Generate while team continues other work
- **Stuck on implementation** - Can't figure out the code? Get expert help
- **Code templates** - Need similar patterns? Ask for variations

## Works With

- `/design-feature` command - Creates architecture first
- `/generate-feature` command - Also generates code (use either)
- `@jam-architect` agent - Gets design guidance
- `@code-quality` agent - Reviews generated code

## During Jam

Workflow: Design (5 min) → Generate (2 min) → Paste → Test (5 min) → Next feature

No manual coding needed for well-planned features.
