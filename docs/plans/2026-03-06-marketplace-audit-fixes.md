# Marketplace Audit Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix all audit findings from the 2026-03-06 marketplace review — real reference files for express-backend-bundle, cleanup of api-design-bundle broken links, and misc fixes across CLAUDE.md, game-jam triggers, command pipes, and metadata.

**Architecture:** Three parallel tracks — (1) create real reference files grounded in actual projet-cda code, (2) honest cleanup of aspirational links in api-design-bundle, (3) sweep of smaller issues. All changes are markdown/JSON edits; validation uses the existing validate-bundle.sh script.

**Tech Stack:** Markdown, JSON, bash (validate-bundle.sh)

---

## Track 1: Express Bundle Reference Files

### Task 1: Create `express-fundamentals/references/app-setup-patterns.md`

**Files:**
- Create: `bundles/express-backend-bundle/skills/express-fundamentals/references/app-setup-patterns.md`

**Step 1: Create the file**

```markdown
# Express App Setup Patterns

Reference for structuring your main `app.js` / `app.ts` entry point.

## Middleware Ordering (Order Matters)

```javascript
import express from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import apiRouter from './routes/index.js';
import { requestLogger } from './middleware/requestLogger.js';
import { errorHandler } from './middleware/errorHandler.js';
import { NotFoundError } from './utils/errors.js';

const app = express();

// 1. CORS — must come first so preflight OPTIONS requests are handled before anything else
app.use(cors({
  origin: env.ALLOWED_ORIGINS,           // array from env: ['http://localhost:5173']
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// 2. Body parser — parses JSON before routes read req.body
app.use(express.json());

// 3. Optional: request logger (morgan, custom, etc.)
app.use(requestLogger);

// 4. Health check / root endpoint
app.get('/', (req, res) => {
  res.json({ message: 'My API', version: '1.0.0' });
});

// 5. All API routes
app.use('/api', apiRouter);

// 6. 404 handler — must come AFTER routes, BEFORE error handler
// Throws so the error handler formats the response consistently
app.use((req, _res, _next) => {
  throw new NotFoundError(`Route ${req.method} ${req.path} not found`);
});

// 7. Error handler — must be LAST, must have exactly 4 parameters
app.use(errorHandler);

// 8. Listen on 0.0.0.0 for Docker compatibility (not just localhost)
const PORT = env.PORT ?? 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server listening on port ${PORT}`);
});

export default app;
```

## Static File Serving

Mount static file serving per route namespace, before other middleware:

```javascript
app.use('/api/uploads', express.static('uploads'));
```

## Route Index Pattern

Avoid importing every router in `app.js`. Instead, create `routes/index.js`:

```javascript
import { Router } from 'express';
import authRouter from './auth.routes.js';
import usersRouter from './users.routes.js';
import recipesRouter from './recipes.routes.js';

const apiRouter = Router();

apiRouter.use('/auth', authRouter);
apiRouter.use('/users', usersRouter);
apiRouter.use('/recipes', recipesRouter);

export default apiRouter;
```

Then in `app.js`: `app.use('/api', apiRouter);`

## Why 0.0.0.0?

`app.listen(PORT)` defaults to `127.0.0.1` (loopback only). Inside a Docker container, this means the container cannot receive external traffic. Always bind to `0.0.0.0` in production/Docker environments.
```

**Step 2: Validate it exists**

```bash
ls bundles/express-backend-bundle/skills/express-fundamentals/references/
```
Expected: `app-setup-patterns.md`

**Step 3: Commit**

```bash
git add bundles/express-backend-bundle/skills/express-fundamentals/references/app-setup-patterns.md
git commit -m "feat(express-bundle): add app-setup-patterns reference from real projet-cda code"
```

---

### Task 2: Create `express-fundamentals/references/env-config-patterns.md`

**Files:**
- Create: `bundles/express-backend-bundle/skills/express-fundamentals/references/env-config-patterns.md`

**Step 1: Create the file**

```markdown
# Environment Config Patterns

Reference for the `config/env.js` module pattern — centralizes all env var access with validation and defaults.

## The Pattern

```javascript
// src/config/env.js
import dotenv from 'dotenv';
dotenv.config();

export const env = {
  // Server
  PORT: parseInt(process.env.PORT || '5000'),
  NODE_ENV: process.env.NODE_ENV || 'development',

  // JWT
  JWT_SECRET: process.env.JWT_SECRET,
  JWT_EXPIRE: process.env.JWT_EXPIRE || '1h',
  REFRESH_TOKEN_EXPIRE: process.env.REFRESH_TOKEN_EXPIRE || '7d',

  // Database
  DATABASE_URL: process.env.DATABASE_URL,

  // CORS — comma-separated list becomes array
  ALLOWED_ORIGINS: (process.env.ALLOWED_ORIGINS || 'http://localhost:5173').split(','),

  // Mail
  MAIL_HOST: process.env.MAIL_HOST,
  MAIL_PORT: parseInt(process.env.MAIL_PORT || '1025'),
  MAIL_FROM: process.env.MAIL_FROM,

  // Feature flags
  LOG_LEVEL: process.env.LOG_LEVEL || 'debug',
};

// Validate required variables on module load — fail fast before server starts
const required = ['JWT_SECRET', 'DATABASE_URL'];
for (const key of required) {
  if (!process.env[key]) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
}

export default env;
```

## Usage

```javascript
// Anywhere in the app
import env from './config/env.js';

app.listen(env.PORT, '0.0.0.0');
cors({ origin: env.ALLOWED_ORIGINS });
jwt.sign(payload, env.JWT_SECRET, { expiresIn: env.JWT_EXPIRE });
```

## Key Rules

- **One import** in each file: `import env from './config/env.js'` — never `process.env.X` scattered around the codebase
- **Parse early**: `parseInt(process.env.PORT || '5000')` so consumers get a number, not a string
- **Arrays from strings**: `process.env.ALLOWED_ORIGINS.split(',')` — store comma-separated in .env, parse once here
- **Fail fast**: the required validation loop throws on startup, not mid-request
- **Group by feature**: Server / JWT / Database / CORS / Mail sections make the file scannable

## .env File Example

```bash
PORT=5000
NODE_ENV=development
JWT_SECRET=your-secret-here
JWT_EXPIRE=1h
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_FROM=noreply@myapp.local
```
```

**Step 2: Commit**

```bash
git add bundles/express-backend-bundle/skills/express-fundamentals/references/env-config-patterns.md
git commit -m "feat(express-bundle): add env-config-patterns reference"
```

---

### Task 3: Create `middleware-patterns/references/async-handler.md`

**Files:**
- Create: `bundles/express-backend-bundle/skills/middleware-patterns/references/async-handler.md`

**Step 1: Create the file**

```markdown
# The asyncHandler Pattern

A one-liner Higher-Order Function that eliminates try/catch boilerplate from every async route handler.

## The Implementation

```javascript
// src/middleware/asyncHandler.js
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

export default asyncHandler;
```

That's it. Three lines. Here's why it works:

1. `asyncHandler(fn)` returns a new function with the Express `(req, res, next)` signature
2. It calls `fn(req, res, next)` and wraps the result in `Promise.resolve()` — works for both sync and async functions
3. `.catch(next)` converts any rejected promise into a call to `next(err)`, which Express routes to your error handler middleware

## Without asyncHandler (verbose)

```javascript
// Every controller needs this boilerplate
const getRecipeById = async (req, res, next) => {
  try {
    const recipe = await fetchRecipeById(req.params.id);
    res.json(recipe);
  } catch (err) {
    next(err);
  }
};
```

## With asyncHandler (clean)

```javascript
// Controller throws naturally, asyncHandler catches it
const getRecipeById = async (req, res) => {
  const recipe = await fetchRecipeById(req.params.id);
  res.json(recipe);
};
```

```javascript
// Route file wraps handlers
import asyncHandler from '../middleware/asyncHandler.js';
router.get('/:id', asyncHandler(getRecipeById));
router.post('/', authenticate, asyncHandler(createRecipe));
router.patch('/:id/badge', authenticate, requireAdmin, asyncHandler(updateBadge));
```

## Key Points

- Only the **last** argument to `router.get()` needs wrapping — middleware like `authenticate` are synchronous or handle their own errors
- Custom error classes (`NotFoundError`, `ValidationError`) thrown inside controllers flow naturally to the error handler
- The error handler (4-parameter middleware) reads `err.statusCode` and sends the appropriate HTTP response
```

**Step 2: Commit**

```bash
git add bundles/express-backend-bundle/skills/middleware-patterns/references/async-handler.md
git commit -m "feat(express-bundle): add async-handler reference"
```

---

### Task 4: Create `middleware-patterns/references/error-class-hierarchy.md`

**Files:**
- Create: `bundles/express-backend-bundle/skills/middleware-patterns/references/error-class-hierarchy.md`

**Step 1: Create the file**

```markdown
# Custom Error Class Hierarchy

A base `AppError` class plus domain-specific subclasses — gives every error a consistent `statusCode` and `errorCode` that the error handler middleware reads directly.

## The Classes

```javascript
// src/utils/errors.js

export class AppError extends Error {
  constructor(message, statusCode = 500, errorCode = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    // Captures proper stack trace in V8 (Node.js/Chrome)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

export class NotFoundError extends AppError {
  constructor(message = 'Resource not found') {
    super(message, 404, 'NOT_FOUND');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Access denied') {
    super(message, 403, 'FORBIDDEN');
  }
}

export class ValidationError extends AppError {
  constructor(message = 'Validation failed') {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

export class ConflictError extends AppError {
  constructor(message = 'Resource already exists') {
    super(message, 409, 'CONFLICT');
  }
}

export class UnprocessableEntityError extends AppError {
  constructor(message = 'Business validation failed') {
    super(message, 422, 'UNPROCESSABLE_ENTITY');
  }
}
```

## The Error Handler Middleware

```javascript
// src/middleware/errorHandler.js
export const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode ?? 500;
  const errorCode = err.errorCode ?? 'INTERNAL_ERROR';
  const message = err.message ?? 'An unexpected error occurred';

  // Log unexpected errors (not user errors like 400/404)
  if (statusCode >= 500) {
    console.error('[ERROR]', err);
  }

  res.status(statusCode).json({
    error: { code: errorCode, message },
  });
};
```

## Usage in Controllers / Services

```javascript
import { NotFoundError, ValidationError, ForbiddenError, ConflictError } from '../utils/errors.js';

// In a service
const fetchRecipeById = async (id) => {
  const recipe = await findRecipeById(id);
  if (!recipe) throw new NotFoundError("Recipe not found");
  return recipe;
};

// In a controller
const createRecipe = async (req, res) => {
  if (!req.body.title) throw new ValidationError("Title is required");
  const result = await submitRecipe(req.body);
  res.status(201).json(result);
};
```

## JWT Error Conversion in Auth Middleware

JWT library errors have their own error names — convert them to your hierarchy in the auth middleware:

```javascript
import { UnauthorizedError } from '../utils/errors.js';

const authenticate = async (req, res, next) => {
  try {
    // ... verify token, find user ...
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      next(new UnauthorizedError('Session expired, please log in again'));
    } else if (error.name === 'JsonWebTokenError') {
      next(new UnauthorizedError('Invalid authentication token'));
    } else {
      next(error); // Pass through your own AppError subclasses unchanged
    }
  }
};
```

## Why This Approach

- **No scattered status codes**: every `throw new NotFoundError()` always maps to 404 — no magic numbers in controllers
- **Default messages**: single-argument construction (`throw new NotFoundError()`) works for generic cases
- **Custom messages**: `throw new NotFoundError("Recipe #42 not found")` for specific cases
- **Error handler stays simple**: just reads `err.statusCode` — no `if (err instanceof X)` chains
```

**Step 2: Commit**

```bash
git add bundles/express-backend-bundle/skills/middleware-patterns/references/error-class-hierarchy.md
git commit -m "feat(express-bundle): add error-class-hierarchy reference"
```

---

### Task 5: Create `database-integration/references/repository-patterns.md`

**Files:**
- Create: `bundles/express-backend-bundle/skills/database-integration/references/repository-patterns.md`

**Step 1: Create the file**

```markdown
# Repository Patterns with Prisma

The repository layer owns one thing: Prisma queries. No business logic, no error throwing (except Prisma's own errors), no data transformation.

## The Rule

| Repository does | Service does |
|---|---|
| `findUnique`, `findMany`, `create`, `update`, `delete` | Existence checks (`if (!recipe) throw new NotFoundError()`) |
| `include` / `select` for relations | Data transformation (snake_case DB -> camelCase API) |
| Build `where` clauses | Cross-entity business rules |
| Return raw Prisma objects | Shape the API response object |

## Function Naming Convention

```javascript
find*   // queries — findRecipeById, findAllRecipes, findRecipesByUserId
create* // inserts — createRecipe, createRecipeReport
update* // updates — updateRecipe, updateRecipeStatus
delete* // deletes — deleteRecipe
```

## Simple Query

```javascript
// repositories/recipes.repository.js
import { prisma } from '../config/database.js';

export const findRecipeById = async (recipeId) => {
  return prisma.recipes.findUnique({
    where: { recipe_id: Number(recipeId) },
    include: {
      users: {
        select: { user_id: true, pseudonyme: true, anonymized: true },
      },
      status: true,
      steps: true,
      recipe_tags: { include: { tags: true } },
    },
  });
  // Returns null if not found — the SERVICE checks this and throws NotFoundError
};
```

## Nested Create (Many-to-Many)

```javascript
export const createRecipe = async (data) => {
  return prisma.recipes.create({
    data: {
      title: data.title,
      preparation_time: data.preparationTime,  // snake_case for DB
      users: { connect: { user_id: data.userId } },
      status: { connect: { status_id: data.statusId } },
      // Many-to-many: create junction rows via nested relation
      recipe_tags: {
        create: data.tagIds.map(tagId => ({ tag_id: tagId })),
      },
      recipe_ingredients: {
        create: data.ingredients.map(i => ({
          quantity: i.quantity,
          ingredients: { connect: { ingredient_id: i.ingredientId } },
          ingredient_units: {
            connect: {
              ingredient_id_unit_id: {
                ingredient_id: i.ingredientId,
                unit_id: i.unitId,
              },
            },
          },
        })),
      },
    },
  });
};
```

## Simple CRUD (eval-final-express style — for simpler schemas)

```javascript
export const findAllAlbumsWithArtists = () =>
  prisma.album.findMany({ include: { artist: true } });

export const findAlbumById = (albumId) =>
  prisma.album.findUnique({ where: { id: albumId }, include: { artist: true } });

export const createAlbum = (data) =>
  prisma.album.create({ data });

export const updateAlbum = (albumId, data) =>
  prisma.album.update({ where: { id: albumId }, data });

export const deleteAlbum = (albumId) =>
  prisma.album.delete({ where: { id: albumId } });
```

## The Service Layer Owns Existence Checks

```javascript
// services/recipes.service.js — the service calls repo then checks result
import { findRecipeById } from '../repositories/recipes.repository.js';
import { NotFoundError } from '../utils/errors.js';

export const fetchRecipeById = async (recipeId) => {
  const recipe = await findRecipeById(recipeId);       // repo returns null or object
  if (!recipe) throw new NotFoundError("Recipe not found");  // service throws
  return {
    id: recipe.recipe_id,         // transform: snake_case -> camelCase
    title: recipe.title,
    prepTime: recipe.preparation_time,
    author: {
      id: recipe.users.user_id,
      name: recipe.users.pseudonyme,
    },
  };
};
```

## Prisma Client — One Instance

Create the client once and import it everywhere:

```javascript
// config/database.js
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient();
```

Never call `new PrismaClient()` in a repository file — that creates a new connection pool per import.
```

**Step 2: Commit**

```bash
git add bundles/express-backend-bundle/skills/database-integration/references/repository-patterns.md
git commit -m "feat(express-bundle): add repository-patterns reference"
```

---

## Track 2: API Design Bundle Cleanup

### Task 6: Clean up `rest-api-design/SKILL.md`

**Files:**
- Modify: `bundles/api-design-bundle/skills/rest-api-design/SKILL.md`

**Step 1: Find the broken section**

```bash
grep -n "references/" bundles/api-design-bundle/skills/rest-api-design/SKILL.md
```
Expected output around line 482-484 showing the three broken links.

**Step 2: Replace the "Additional Resources" section**

Find this block (around lines 480-485):
```markdown
## Additional Resources

- `references/http-methods-guide.md` - Comprehensive HTTP method semantics
- `references/pagination-patterns.md` - Comparison of pagination approaches
- `references/rest-error-handling.md` - Error handling standards
```

Replace with:
```markdown
> Reference files for this skill are planned for a future release.
```

**Step 3: Commit**

```bash
git add bundles/api-design-bundle/skills/rest-api-design/SKILL.md
git commit -m "fix(api-design-bundle): remove broken reference links from rest-api-design"
```

---

### Task 7: Clean up `graphql-api-design/SKILL.md`

**Files:**
- Modify: `bundles/api-design-bundle/skills/graphql-api-design/SKILL.md`

**Step 1: Find and replace the broken section**

```bash
grep -n "references/" bundles/api-design-bundle/skills/graphql-api-design/SKILL.md
```

Find the "Additional Resources" block with `schema-patterns.md`, `resolver-patterns.md`, `subscriptions-guide.md` and replace the entire section with:

```markdown
> Reference files for this skill are planned for a future release.
```

**Step 2: Commit**

```bash
git add bundles/api-design-bundle/skills/graphql-api-design/SKILL.md
git commit -m "fix(api-design-bundle): remove broken reference links from graphql-api-design"
```

---

### Task 8: Clean up `api-testing/SKILL.md`

**Files:**
- Modify: `bundles/api-design-bundle/skills/api-testing/SKILL.md`

**Step 1: Find and replace the broken section**

```bash
grep -n "references/" bundles/api-design-bundle/skills/api-testing/SKILL.md
```

Find the "Additional Resources" block with `postman-mcp-setup.md`, `testing-strategies.md`, `contract-testing.md` and replace the entire section with:

```markdown
> Reference files for this skill are planned for a future release.
```

**Step 2: Commit**

```bash
git add bundles/api-design-bundle/skills/api-testing/SKILL.md
git commit -m "fix(api-design-bundle): remove broken reference links from api-testing"
```

---

## Track 3: Other Audit Fixes

### Task 9: Update CLAUDE.md "Current Bundles" section

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Find the section**

```bash
grep -n "Current Bundles" CLAUDE.md
```

**Step 2: Replace the section**

Find:
```markdown
## Current Bundles

1. **react-frontend-bundle** - React patterns, hooks, state management (Zustand, Redux, Jotai), UI/UX design, accessibility
2. **dev-toolkit-bundle** - Bundle creation workflow with automation scripts and working examples
```

Replace with:
```markdown
## Current Bundles

1. **react-frontend-bundle** - React patterns, hooks, state management (Zustand, Redux, Jotai), UI/UX design, accessibility
2. **dev-toolkit-bundle** - Bundle creation workflow with automation scripts and working examples
3. **api-design-bundle** - REST API design, GraphQL schemas, API architecture, API testing patterns
4. **express-backend-bundle** - Express.js setup, middleware patterns, database integration, authentication, testing
5. **infra-bundle** - Docker, Nginx, GitHub Actions CI/CD, environment variables, bash scripting
6. **sessions-workflow-bundle** - Session management commands: /session-start, /session-end, /init-project
7. **jest-testing-bundle** - Jest setup, unit testing, integration testing, database testing, mocking
8. **game-jam-toolkit-bundle** - Unity game jam toolkit: feature design, code generation, review, validation
```

**Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with all 8 current bundles"
```

---

### Task 10: Fix game-jam skill trigger descriptions

**Files:**
- Modify: `bundles/game-jam-toolkit-bundle/skills/validate-starter-scripts/SKILL.md`
- Modify: `bundles/game-jam-toolkit-bundle/skills/feature-architect/SKILL.md`
- Modify: `bundles/game-jam-toolkit-bundle/skills/modern-patterns-audit/SKILL.md`

**Step 1: Fix validate-starter-scripts description**

Find:
```yaml
description: validation audit quality check startup initialization integrity
```
Replace with:
```yaml
description: Validate and audit game jam starter scripts for quality, integrity, and correct initialization. Use when running pre-jam checks, verifying startup scripts work, or auditing script quality before a game jam begins.
```

**Step 2: Fix feature-architect description**

Find:
```yaml
description: architecture design system planning structure pattern integration features
```
Replace with:
```yaml
description: Design game feature architecture before writing code. Use when planning a new feature system, deciding on component structure, or mapping out how a feature integrates with existing systems.
```

**Step 3: Fix modern-patterns-audit description**

Find:
```yaml
description: modern practices Input System async await dependency injection pooling optimization
```
Replace with:
```yaml
description: Audit Unity scripts for modern development practices. Use when reviewing code for outdated patterns, checking Input System usage, async/await adoption, dependency injection, or object pooling opportunities.
```

**Step 4: Commit**

```bash
git add bundles/game-jam-toolkit-bundle/skills/validate-starter-scripts/SKILL.md
git add bundles/game-jam-toolkit-bundle/skills/feature-architect/SKILL.md
git add bundles/game-jam-toolkit-bundle/skills/modern-patterns-audit/SKILL.md
git commit -m "fix(game-jam-bundle): rewrite skill descriptions as natural language trigger phrases"
```

---

### Task 11: Fix command pipe violations

**Files:**
- Modify: `bundles/sessions-workflow-bundle/commands/init-project.md`
- Modify: `bundles/sessions-workflow-bundle/commands/session-end.md`

**Step 1: Fix init-project.md piped commands**

Find these 4 piped inline commands:
```
- Git log (commit style): !`git log --oneline -10 2>/dev/null || echo "No git history"`
- Git branches: !`git branch -a --format='%(refname:short)' 2>/dev/null | head -10 || echo "No branches"`
- README (first 50 lines): !`head -50 README.md 2>/dev/null || echo "(no README)"`
- package.json: !`cat package.json 2>/dev/null | head -30 || echo "(no package.json)"`
- pyproject.toml: !`cat pyproject.toml 2>/dev/null | head -20 || echo "(no pyproject.toml)"`
- Cargo.toml: !`cat Cargo.toml 2>/dev/null | head -20 || echo "(no Cargo.toml)"`
```

Replace with single-command equivalents. For file reads, use the Read tool instruction instead of inline bash. For git, use simple commands without pipes:
```
- Git log (commit style): !`git log --oneline -10`
- Git branches: !`git branch -a`
- README: Read `README.md` if it exists
- package.json: Read `package.json` if it exists
- pyproject.toml: Read `pyproject.toml` if it exists
- Cargo.toml: Read `Cargo.toml` if it exists
```

Also update `allowed-tools` frontmatter to remove `Bash(cat)` and `Bash(head)`, and add `Bash(git log)`, `Bash(git branch)` separately.

**Step 2: Fix session-end.md pipe**

Find line 15:
```
- Changed files: !`git diff --name-status HEAD 2>/dev/null | head -10`
```
Replace with:
```
- Changed files: !`git diff --name-status HEAD`
```

**Step 3: Commit**

```bash
git add bundles/sessions-workflow-bundle/commands/init-project.md
git add bundles/sessions-workflow-bundle/commands/session-end.md
git commit -m "fix(sessions-bundle): remove pipe violations from inline commands"
```

---

### Task 12: Fix jest-testing-bundle author email + docs cleanup

**Files:**
- Modify: `bundles/jest-testing-bundle/.claude-plugin/plugin.json`
- Modify: `docs/NEXT_STEPS.md`
- Modify: `docs/INDEX.md`

**Step 1: Add email to jest plugin.json**

Find:
```json
"author": {
    "name": "karchtho",
    "email": ""
}
```
Replace with:
```json
"author": {
    "name": "karchtho",
    "email": "kitadevturtle@gmail.com"
}
```

**Step 2: Archive NEXT_STEPS.md**

Add this header at the top of `docs/NEXT_STEPS.md`:
```markdown
> **ARCHIVED** — This document was written when the marketplace had 1 bundle. It is kept for historical reference only. See CLAUDE.md for the current bundle list.

---

```

**Step 3: Fix INDEX.md broken links**

Find and remove/fix the 3 lines referencing `QUICK_START.md`:
- Line 8: Remove the list item linking to `../QUICK_START.md`
- Line 46: Remove or replace the `→ Read [QUICK_START.md]` line
- Line 101: Remove `QUICK_START.md` from the directory tree

**Step 4: Validate bundle JSON is still valid**

```bash
cat bundles/jest-testing-bundle/.claude-plugin/plugin.json | python3 -m json.tool > /dev/null && echo "Valid JSON"
```
Expected: `Valid JSON`

**Step 5: Commit**

```bash
git add bundles/jest-testing-bundle/.claude-plugin/plugin.json docs/NEXT_STEPS.md docs/INDEX.md
git commit -m "fix: add jest-bundle author email, archive stale docs, remove broken QUICK_START links"
```

---

### Task 13: Final validation

**Step 1: Run validate-bundle.sh on all bundles**

```bash
for bundle in bundles/*/; do
  bundles/dev-toolkit-bundle/skills/bundle-maker/scripts/validate-bundle.sh "$bundle"
done
```
Expected: all bundles pass without errors.

**Step 2: Confirm no broken references remain**

```bash
grep -r "references/" bundles/api-design-bundle/skills/*/SKILL.md
```
Expected: no output (all removed).

**Step 3: Confirm express reference files exist**

```bash
find bundles/express-backend-bundle/skills -name "*.md" -path "*/references/*"
```
Expected: 5 files listed.

**Step 4: Final commit if any loose files remain**

```bash
git status
```
If clean, done. If not, commit remaining changes with `fix: marketplace audit cleanup`.
