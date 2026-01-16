---
name: middleware-patterns
description: Express middleware patterns including authentication, validation, error handling, rate limiting, request logging, CORS, compression. Use when implementing auth middleware, input validation, error handlers, rate limiting, request/response logging, or security middleware.
---

# Express Middleware Patterns

Master authentication, validation, error handling, rate limiting, and logging middleware.

## When to Use This Skill

- Implementing authentication middleware (JWT, OAuth, sessions)
- Creating input validation middleware (Zod, Joi)
- Setting up error handling middleware
- Adding rate limiting to prevent abuse
- Implementing request/response logging
- Creating custom middleware for cross-cutting concerns
- Handling async errors in route handlers

## Authentication Middleware

```typescript
// middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface JWTPayload {
  userId: string;
  email: string;
  roles: string[];
}

declare global {
  namespace Express {
    interface Request {
      user?: JWTPayload;
      token?: string;
    }
  }
}

// Bearer token extraction and verification
export const authenticate = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const payload = jwt.verify(
      token,
      process.env.JWT_SECRET!
    ) as JWTPayload;

    req.user = payload;
    req.token = token;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Role-based authorization
export const authorize = (...allowedRoles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    const hasRole = req.user.roles.some(role =>
      allowedRoles.includes(role)
    );

    if (!hasRole) {
      return res.status(403).json({ 
        error: 'Insufficient permissions',
        requiredRoles: allowedRoles,
        userRoles: req.user.roles
      });
    }

    next();
  };
};

// Optional authentication (doesn't fail, just populates req.user if token exists)
export const optionalAuth = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader?.replace('Bearer ', '');

    if (token) {
      const payload = jwt.verify(
        token,
        process.env.JWT_SECRET!
      ) as JWTPayload;
      req.user = payload;
    }
  } catch (error) {
    // Silently ignore invalid tokens
  }

  next();
};

// Usage:
// app.get('/protected', authenticate, authorize('admin'), handler);
// app.get('/public', optionalAuth, handler);
```

## Input Validation Middleware

```typescript
// middleware/validation.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { z, AnyZodObject, ZodError } from 'zod';

// Validation wrapper
export const validate = (schema: AnyZodObject) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params
      });
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const fieldErrors = error.errors.reduce((acc, err) => {
          const path = err.path.join('.');
          acc[path] = err.message;
          return acc;
        }, {} as Record<string, string>);

        return res.status(400).json({
          error: 'Validation failed',
          fields: fieldErrors
        });
      }
      next(error);
    }
  };
};

// Usage example:
const createUserSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Name required'),
    email: z.string().email('Invalid email'),
    password: z.string().min(8, 'Password must be 8+ chars'),
    age: z.number().int().positive().optional()
  }),
  query: z.object({
    sendWelcomeEmail: z.enum(['true', 'false']).optional()
  })
});

// app.post('/users', validate(createUserSchema), createUser);
```

## Error Handling Middleware

```typescript
// utils/errors.ts
export class AppError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public fields?: Record<string, string>) {
    super(message, 400);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string = 'Resource not found') {
    super(message, 404);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super(message, 403);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 409);
  }
}

// middleware/error-handler.ts
import { Request, Response, NextFunction } from 'express';
import { logger } from './logger.middleware';

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof AppError) {
    logger.warn({
      message: err.message,
      statusCode: err.statusCode,
      path: req.path,
      method: req.method
    });

    return res.status(err.statusCode).json({
      error: err.message,
      ...(err instanceof ValidationError && { fields: err.fields })
    });
  }

  // Unexpected error - log detailed info
  logger.error({
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    body: req.body
  });

  // Don't expose error details in production
  const message = process.env.NODE_ENV === 'production'
    ? 'Internal server error'
    : err.message;

  res.status(500).json({ error: message });
};

// Async error wrapper
export const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<any>
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Usage:
// app.post('/users', asyncHandler(createUser));
// app.use(errorHandler); // Last middleware
```

## Rate Limiting Middleware

```typescript
// middleware/rate-limit.middleware.ts
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT || '6379')
});

// General API rate limiter
export const apiLimiter = rateLimit({
  store: new RedisStore({
    client: redis,
    prefix: 'rl:api:'
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,                  // 100 requests per window
  message: 'Too many requests, please try again later',
  standardHeaders: true,     // Return rate limit in headers
  legacyHeaders: false,
  skipSuccessfulRequests: false,
  skipFailedRequests: false,
  keyGenerator: (req) => req.user?.userId || req.ip // Use userId if authenticated
});

// Stricter limit for authentication endpoints
export const authLimiter = rateLimit({
  store: new RedisStore({
    client: redis,
    prefix: 'rl:auth:'
  }),
  windowMs: 15 * 60 * 1000,
  max: 5,                    // Only 5 attempts
  skipSuccessfulRequests: true, // Don't count successful requests
  message: 'Too many login attempts, please try again later'
});

// Usage:
// app.use(apiLimiter);
// app.post('/login', authLimiter, login);
```

## Request Logging Middleware

```typescript
// middleware/logger.middleware.ts
import { Request, Response, NextFunction } from 'express';
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: {
    target: 'pino-pretty',
    options: {
      colorize: true,
      singleLine: false,
      translateTime: 'SYS:standard'
    }
  }
});

// Request logging middleware
export const requestLogger = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const startTime = Date.now();
  const requestId = crypto.randomUUID();

  // Attach to request for use in handlers
  req.requestId = requestId;

  // Log response when finished
  res.on('finish', () => {
    const duration = Date.now() - startTime;

    logger.info({
      requestId,
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.headers['user-agent'],
      userId: req.user?.userId,
      ip: req.ip,
      query: req.query,
      // Don't log sensitive fields
      bodySize: JSON.stringify(req.body).length
    });
  });

  next();
};

export { logger };

// Extend Express Request
declare global {
  namespace Express {
    interface Request {
      requestId?: string;
    }
  }
}
```

## CORS Middleware

```typescript
// Security: Only allow specific origins
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:3001',
  'https://example.com',
  'https://www.example.com'
];

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps or Postman)
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  exposedHeaders: ['X-Total-Count', 'X-Page-Number'],
  maxAge: 86400 // 24 hours
}));
```

## Middleware Composition

```typescript
// Create reusable middleware chains
const publicRoutes = [express.json()];

const protectedRoutes = [
  express.json(),
  authenticate,
  requestLogger
];

const adminRoutes = [
  express.json(),
  authenticate,
  authorize('admin'),
  requestLogger
];

// Usage
app.use('/api/public', publicRoutes);
app.use('/api/protected', protectedRoutes);
app.use('/api/admin', adminRoutes);
```

## Middleware Order (Critical!)

```typescript
// 1. Security headers first
app.use(helmet());

// 2. CORS before routes
app.use(cors(corsOptions));

// 3. Compression
app.use(compression());

// 4. Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 5. Request logging
app.use(requestLogger);

// 6. Rate limiting (before routes)
app.use(apiLimiter);

// 7. Static files
app.use(express.static('public'));

// 8. Routes
app.use('/api', apiRoutes);

// 9. 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// 10. Error handler (MUST be last)
app.use(errorHandler);
```

## Best Practices

1. **Middleware executes in order** - Order matters!
2. **Call next() to continue chain** - Forgetting it stops the chain
3. **Error middleware needs 4 params** - `(err, req, res, next)`
4. **Use async handlers wrapper** - Prevents unhandled rejections
5. **Log security events** - Auth failures, rate limit hits, etc
6. **Use custom errors** - Makes error handling consistent
7. **Validate all input** - Always validate user input
8. **Never expose secrets** - Filter sensitive data from logs
9. **Rate limit early** - Apply before expensive operations
10. **Test middleware in isolation** - Mock req, res, next

## Common Patterns

| Pattern | Use Case |
|---------|----------|
| `authenticate` → `authorize` | Protected routes |
| `validate()` | Input validation |
| `asyncHandler()` | Async error handling |
| `apiLimiter` | Prevent abuse |
| `requestLogger` | Observability |
| `errorHandler` | Centralized error handling |

## See Also

- express-fundamentals - Core middleware setup
- authentication-patterns - JWT, OAuth, sessions
- api-design-patterns - Response formatting, error responses
