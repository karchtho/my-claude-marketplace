---
name: integration-validator
description: integration testing system compatibility dependencies validation coherence
---

# Integration Validator Skill

Ensures new code integrates properly with existing systems and starter scripts.

## What This Does

Validates integration between:

- **New Code ↔ Starter Scripts** - Does the new feature work with GameManager, managers, utilities?
- **Manager Dependencies** - InputManager → PlayerController, AudioManager → sound events, etc.
- **Initialization Order** - Do things initialize in the right sequence?
- **Circular Dependencies** - Are there any dependency cycles?
- **Reference Integrity** - Will all serialized fields and connections work?
- **Event/Callback Chains** - Will events fire in correct order?
- **Pooling Integration** - If new code spawns objects, are they pooled correctly?
- **Async Coordination** - Do async operations coordinate without race conditions?

## Activation Triggers

This skill activates when you:
- Ask "does this work with my starters?"
- Request an "integration check"
- Ask about "dependencies" or "how this connects"
- Say "will this work with the rest?"
- Ask about "initialization order"

## Input Format

Provide:
- New script(s) being added
- What they interact with from starters
- Any custom connections needed

Example:
```
New BossEnemy system needs to:
- Register with GameManager
- Receive input from InputManager
- Play sounds via AudioManager
- Use pooling via PoolingManager
```

## Output Format

Validation report:
1. **Integration Map** - How new code connects to starters
2. **Dependency Graph** - What depends on what
3. **Initialization Sequence** - Correct order to awaken/setup
4. **Compatibility** - Any version conflicts or pattern mismatches?
5. **Potential Issues** - Circular deps, missing references, race conditions
6. **Connection Checklist** - What to wire up in Inspector
7. **Ready Status** - Safe to integrate or needs fixes

## During Development

Run before merging new features to main development branch. Catches integration issues early.
