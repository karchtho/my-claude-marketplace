---
name: jam-status
description: Quick project health check
---

# /jam-status

Quick health check of your entire game jam project.

## What This Does

Scans your project for:
- Code quality metrics
- Integration issues surfacing
- Best practice compliance
- Memory leaks or pooling problems
- Team collaboration health
- Performance baseline changes
- Overall readiness status

## Usage

```
/jam-status
```

## Output

Quick report with:
- ✓ Green indicators - All good
- ⚠ Yellow warnings - Minor issues to address
- ❌ Red blockers - Need attention soon
- **Overall Status** - Green/Yellow/Red readiness

## When to Use

**Pre-jam**: Day before jam - confirms everything is ready

**Daily standup**: Morning check to see if overnight work introduced issues

**Before merges**: Validate new features don't break the health

**End of day**: Confirm team's daily progress doesn't have blockers

## Example Output

```
✓ Code quality: Good
⚠ Memory usage: Rising (check for pooling)
✓ Integration: No conflicts
✓ Team patterns: Consistent
```

## Related Commands

- `/review-starters` - Detailed starter script audit
- `/review-code` - Deep dive on specific code
- `/design-feature` - Plan next feature
