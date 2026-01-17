---
name: review-code
description: Get instant feedback on code
---

# /review-code

Submit code for fast, jam-time friendly feedback without blocking workflow.

## What This Does

Reviews code for:
- Starter pattern compliance - Does it match your style?
- Modern practices - Input System, async/await, DI, pooling
- Memory safety - Cleanup, pooling, resource management
- Integration issues - Will it work with existing systems?
- Performance - Obvious inefficiencies, unnecessary allocations
- Best practices - Error handling, null checks, logging
- Architectural consistency - Fits the system design?

## Usage

```
/review-code
```

Then paste your code (full class, method, or even pseudocode).

## Output

Quick feedback covering:
1. **Status** - ✓ Good / ⚠ Minor issues / ❌ Rework needed
2. **Pattern Match** - Does it fit your starters?
3. **Modern Practices** - Input System, async, DI usage?
4. **Memory Safety** - Any leaks, pooling issues?
5. **Integration** - Will it work with the rest?
6. **Issues Found** - Specific problems with line refs
7. **Quick Fixes** - Suggestions to improve in-place
8. **Ready** - Ready to ship or what to fix?

## When to Use

**During jam**: Team members submit code for instant feedback without waiting for formal code review.

**Fast iteration**: Quick validation before merging to main branch.

## Related Commands

- `/design-feature` - Plan before coding
- `/generate-feature` - Auto-generate if stuck
- `/jam-status` - Overall project health
