---
name: code-reviewer
description: code review feedback quality analysis best practices consistency checking
---

# Code Reviewer Skill

Provides instant feedback on code during development without blocking workflow.

## What This Does

Reviews submitted code for:

- **Starter Pattern Compliance** - Does it match your 20 starter scripts' style?
- **Modern Practices** - Input System usage, async/await patterns, DI, pooling
- **Memory Safety** - Object cleanup, pooling, resource management
- **Integration Issues** - Does it connect properly to GameManager, managers, other systems?
- **Performance** - Obvious inefficiencies, unnecessary allocations
- **Best Practices** - Error handling, null checks, logging, edge cases
- **Architectural Consistency** - Does it fit the system design?

## Activation Triggers

This skill activates when you:
- Ask for "feedback" on code
- Request a "code review"
- Run `/review-code` command
- Say "check this code" or "is this good?"
- Ask "does this follow the pattern?"

## Input Format

Paste code directly:
- Full class or script
- Methods from a larger class
- Even pseudocode/pseudoimplementation

## Output Format

Quick feedback covering:
1. **Status** - ✓ Good to use / ⚠ Minor issues / ❌ Needs rework
2. **Pattern Match** - Does it fit your starter patterns?
3. **Modern Practices** - How well does it use Input System, async, etc.?
4. **Memory Safety** - Any leaks, pooling issues, cleanup problems?
5. **Integration** - Will it work with the rest of the system?
6. **Issues Found** - Specific problems with line references
7. **Quick Fixes** - Suggestions to improve in-place
8. **Next Steps** - Ready to ship or what to fix

## Jam-Time Usage

Fast, non-blocking review during active development. Catch issues before they cascade.

## Team Code

Team members can submit their code for instant feedback without waiting for code review.
