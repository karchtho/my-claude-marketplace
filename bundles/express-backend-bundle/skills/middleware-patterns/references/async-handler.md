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
