---
name: review-starters
description: Run full validation on your 20 starter scripts
---

# /review-starters

Comprehensive audit of your 20 starter scripts from your unity-starter repository.

## What This Does

Validates all starter scripts for:
- Code quality and consistency
- Best practices (Singleton patterns, error handling, null checks)
- Integration health between scripts
- Memory safety (pooling, cleanup, leaks)
- Modern pattern readiness (Input System, async/await, DI, pooling)

## Usage

```
/review-starters
```

## Output

Returns a detailed report with:
1. **Critical Issues** - Must fix before jam
2. **Best Practice Suggestions** - Code quality improvements
3. **Integration Warnings** - Script dependency issues
4. **Modern Pattern Gaps** - Missing Input System, async, DI patterns
5. **Ready Status** - "Ready to ship" or action items needed

## When to Use

**Pre-jam** (3-4 days before): Run this to validate your starter scripts before the jam begins. Review findings with your team and decide if improvements needed.

## Related Commands

- `/jam-status` - Quick project health check
- `/design-feature` - Plan a new feature
