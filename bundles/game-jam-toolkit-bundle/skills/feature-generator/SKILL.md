---
name: feature-generator
description: code generation script writing implementation production-ready features
---

# Feature Generator Skill

Writes complete, production-ready C# scripts for game features.

## What This Does

Generates fully-functional feature code that:

- **Matches Your Patterns** - Follows your 20 starter scripts' style and organization
- **Uses Modern Practices** - Input System, async/await, dependency injection, pooling
- **Integrates Seamlessly** - Properly connects to GameManager, InputManager, UIManager, AudioManager
- **Production Quality** - Proper error handling, null checks, logging, optimization
- **Memory Safe** - Appropriate pooling, proper cleanup, no leaks
- **Well-Documented** - Clear comments explaining non-obvious logic

## Activation Triggers

This skill activates when you:
- Ask to "generate a script" or "write a script"
- Request "code" for a feature
- Run `/generate-feature` command
- Ask to "implement" something
- Say "write code for" a system

## Input Format

Provide the architecture from `/design-feature`:
- "Generate the BossEnemy script based on this architecture..."
- "Write all three attack pattern scripts..."
- "Code the shop UI system..."

## Output Format

Complete scripts with:
- **Full C# code** - Ready to copy/paste into Unity
- **Class Documentation** - What the class does
- **Public API** - Exposed methods/properties and their purpose
- **Integration Notes** - How to connect in editor (Inspector assignments)
- **Modern Pattern Usage** - Where Input System, async, DI, pooling are used
- **Performance Notes** - Why certain decisions were made

## Quality Guarantees

Generated code:
✓ Compiles without errors
✓ Follows your starter patterns
✓ Uses modern Unity practices
✓ Memory efficient
✓ Ready to test immediately

## Jam-Time Speed

Generate → Paste → Test → Next feature. No refactoring needed.
