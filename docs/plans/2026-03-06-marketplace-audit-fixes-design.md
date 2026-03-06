# Marketplace Audit Fixes — Design Doc

**Date:** 2026-03-06
**Status:** Approved
**Scope:** Fix all audit findings from the 2026-03-06 comprehensive marketplace review

---

## Goals

1. Replace aspirational broken references in `express-backend-bundle` with real reference files sourced from `projet-cda` and `eval-final-express` codebases
2. Clean up `api-design-bundle` broken links honestly
3. Fix all remaining audit issues (CLAUDE.md, game-jam triggers, command pipes, metadata)

---

## Section 1: Express Bundle — New Reference Files

Create 5 reference files inside `express-backend-bundle` skills, content sourced from real `projet-cda` code:

### 1a. `skills/express-fundamentals/references/app-setup-patterns.md`
- Express app initialization
- Middleware ordering (CORS -> body-parser -> logging -> routes -> 404 -> error handler)
- CORS configuration with allowed origins array
- Health check / root endpoint pattern
- 404 catch-all middleware using custom error classes
- Server listen with `0.0.0.0` for Docker compatibility

### 1b. `skills/express-fundamentals/references/env-config-patterns.md`
- Single `env` export object pattern
- `parseInt` for numeric vars, `.split(',')` for arrays
- Default values with `||`
- Required variable validation loop on module load (fail fast)
- Organize by feature group (Server, JWT, Database, CORS, Mail, etc.)

### 2a. `skills/middleware-patterns/references/async-handler.md`
- The 3-line HOF: `(fn) => (req, res, next) => Promise.resolve(fn(...)).catch(next)`
- Why it works: converts rejected promises to Express `next(err)` calls
- Comparison with try/catch approach (eval-final-express pattern)
- Usage in routes: `router.get('/:id', asyncHandler(getById))`

### 2b. `skills/middleware-patterns/references/error-class-hierarchy.md`
- `AppError` base class (message, statusCode, errorCode, captureStackTrace)
- Subclasses: NotFoundError (404), UnauthorizedError (401), ForbiddenError (403), ValidationError (400), ConflictError (409), UnprocessableEntityError (422)
- Default constructor parameters for one-argument usage
- JWT error conversion pattern in auth middleware
- Error handler middleware reading `err.statusCode` and `err.errorCode`

### 3a. `skills/database-integration/references/repository-patterns.md`
- Repository = pure Prisma queries only, no business logic
- Function naming: `find*`, `create*`, `update*`, `delete*`
- `include` for relations, `select` for field filtering
- Nested create pattern for many-to-many (recipe_tags, recipe_ingredients)
- Service layer owns: existence checks, conflict detection, data transformation (snake_case -> camelCase)
- Raw Prisma object returned from repo; service shapes the API response

---

## Section 2: API Design Bundle — Cleanup

Remove "Additional Resources" sections from 3 files; replace with planned note:

- `skills/rest-api-design/SKILL.md` — remove 3 broken links
- `skills/graphql-api-design/SKILL.md` — remove 3 broken links
- `skills/api-testing/SKILL.md` — remove 3 broken links

Replacement text:
```
> Reference files for this skill are planned for a future release.
```

---

## Section 3: Other Audit Fixes

| File | Change |
|---|---|
| `CLAUDE.md` | Update "Current Bundles" to list all 8 bundles |
| `bundles/game-jam-toolkit-bundle/skills/validate-starter-scripts/SKILL.md` | Rewrite description in "Use when..." sentence form |
| `bundles/game-jam-toolkit-bundle/skills/feature-architect/SKILL.md` | Rewrite description in "Use when..." sentence form |
| `bundles/game-jam-toolkit-bundle/skills/modern-patterns-audit/SKILL.md` | Rewrite description in "Use when..." sentence form |
| `bundles/sessions-workflow-bundle/commands/init-project.md` | Split piped inline commands into separate lines |
| `bundles/sessions-workflow-bundle/commands/session-end.md` | Remove pipe from git diff command |
| `bundles/jest-testing-bundle/.claude-plugin/plugin.json` | Add real email |
| `docs/NEXT_STEPS.md` | Archive with header noting it is outdated |
| `docs/INDEX.md` | Remove broken QUICK_START.md links |

---

## Out of Scope

- bundle-maker references marked `(future)` — already correctly labeled, leave as-is
- Author identity inconsistency across bundles — cosmetic, not blocking
- react-patterns / react-state-management overlap — separate concern
- infra-bundle version bump and missing README — separate concern
