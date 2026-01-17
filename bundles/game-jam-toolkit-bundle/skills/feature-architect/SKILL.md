---
name: feature-architect
description: architecture design system planning structure pattern integration features
---

# Feature Architect Skill

Designs game feature architecture before coding begins.

## What This Does

Takes feature requirements and produces complete architectural plans:

- **System Design** - What classes/components are needed?
- **Architecture Diagram** - Visual structure showing relationships
- **Integration Points** - How does this plug into GameManager, InputManager, UIManager, etc.?
- **Modern Patterns** - Input System usage, async/await patterns, dependency injection approach
- **Data Flow** - How information moves through the system
- **Initialization Order** - When/how does the feature initialize?
- **Resource Management** - Pooling needs, object lifetime, cleanup strategy

## Activation Triggers

This skill activates when you:
- Ask to "design a feature" or "plan out"
- Request an "architecture" for something
- Ask "how should I structure" a new system
- Run `/design-feature` command
- Ask "what classes do I need?"

## Input Format

Describe your feature simply:
- "I need a boss enemy with different attack patterns"
- "Create a shop system where players buy upgrades"
- "Design a checkpoint/save system"

## Output Format

Complete architecture plan with:
1. **System Overview** - High-level description
2. **Class Structure** - Classes needed, inheritance/composition
3. **Dependency Map** - What connects to what
4. **Integration Strategy** - How it plugs into starters
5. **Modern Patterns Used** - Input System, async, DI approaches
6. **Code Skeleton** - Class signatures and method stubs
7. **Next Step** - Ready for `/generate-feature` command

## Jam-Time Workflow

1. Describe feature → get architecture
2. Review architecture with team
3. Use `/generate-feature` to write code
