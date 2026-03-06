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
