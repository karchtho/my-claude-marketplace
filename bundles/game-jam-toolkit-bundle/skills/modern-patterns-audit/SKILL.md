---
name: modern-patterns-audit
description: modern practices Input System async await dependency injection pooling optimization
---

# Modern Patterns Audit Skill

Analyzes your starter scripts against modern Unity development practices and identifies gaps.

## What This Does

Evaluates starter scripts for:

- **Input System** - Are scripts ready for modern Input System (not legacy Input)? Do they support rebindable controls?
- **Async/Await Patterns** - Are coroutines replaceable with modern async/await? Identifies patterns that should be async
- **Dependency Injection** - Are systems loosely coupled? Can they be injected rather than hardcoded?
- **Memory Optimization** - Are pooling patterns in place? Resource cleanup? Proper use of Addressables?
- **Architecture Modularity** - Can new features plug in cleanly without modifying existing code?

## Activation Triggers

This skill activates when you:
- Ask about "modern patterns" or "modern practices"
- Request an "Input System audit" or "async/await review"
- Ask if your code is "up to date" or "modern"
- Ask about "dependency injection" or "decoupling"

## Output Format

Returns analysis organized by pattern:
- **Input System Readiness** - How to adapt for modern Input System
- **Async/Await Opportunities** - Where to use async instead of coroutines
- **DI Improvements** - How to decouple systems
- **Memory Safety Enhancements** - Pooling and resource optimization suggestions
- **Action Items** - Prioritized changes to modernize the code

## During Development

Use this to guide your code generation during the jam - all generated features will follow these modern patterns.
