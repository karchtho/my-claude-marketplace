---
name: testing-patterns
description: Express testing patterns including unit tests, integration tests, API endpoint testing, mocking databases, testing middleware, testing authentication. Use when writing tests for Express APIs, testing controllers and services, mocking dependencies, or testing middleware.
---

# Express Testing Patterns

Master unit, integration, and E2E testing for Express applications.

## When to Use This Skill

- Writing unit tests for services and repositories
- Testing API endpoints
- Testing middleware
- Mocking databases and external services
- Testing authentication and authorization
- Setting up test fixtures and factories
- Testing error handling
- Writing integration tests

## Testing Setup

**package.json:**
```json
{
  "devDependencies": {
    "vitest": "^1.0.0",
    "supertest": "^6.3.0",
    "@testing-library/node": "^20.0.0",
    "jest-mock-extended": "^3.0.0"
  },
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:coverage": "vitest --coverage"
  }
}
```

**vitest.config.ts:**
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'dist/']
    },
    testTimeout: 10000,
    hookTimeout: 10000
  }
});
```

## Unit Testing Services

```typescript
// services/__tests__/user.service.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { UserService } from '../user.service';
import { UserRepository } from '../../repositories/user.repository';
import { NotFoundError } from '../../utils/errors';

describe('UserService', () => {
  let userService: UserService;
  let userRepository: UserRepository;

  beforeEach(() => {
    // Mock repository
    userRepository = {
      findById: vi.fn(),
      findByEmail: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
      delete: vi.fn()
    } as unknown as UserRepository;

    userService = new UserService(userRepository);
  });

  describe('getUserById', () => {
    it('should return user if found', async () => {
      const mockUser = { id: '1', name: 'John', email: 'john@example.com' };
      vi.mocked(userRepository.findById).mockResolvedValue(mockUser);

      const result = await userService.getUserById('1');

      expect(result).toEqual(mockUser);
      expect(userRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should throw NotFoundError if user not found', async () => {
      vi.mocked(userRepository.findById).mockResolvedValue(null);

      expect(async () => {
        await userService.getUserById('1');
      }).rejects.toThrow(NotFoundError);
    });
  });

  describe('createUser', () => {
    it('should hash password and create user', async () => {
      const input = {
        name: 'John',
        email: 'john@example.com',
        password: 'SecurePass123'
      };

      const mockCreatedUser = { id: '1', ...input, password: 'hashed' };

      vi.mocked(userRepository.findByEmail).mockResolvedValue(null);
      vi.mocked(userRepository.create).mockResolvedValue(mockCreatedUser);

      const result = await userService.createUser(input);

      expect(result).toEqual(mockCreatedUser);
      expect(userRepository.create).toHaveBeenCalled();
      expect(userRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: input.email
        })
      );
    });

    it('should throw error if email already exists', async () => {
      const input = {
        name: 'John',
        email: 'john@example.com',
        password: 'SecurePass123'
      };

      vi.mocked(userRepository.findByEmail).mockResolvedValue({
        id: '1',
        name: 'Existing',
        email: input.email,
        password: 'hash'
      } as any);

      expect(async () => {
        await userService.createUser(input);
      }).rejects.toThrow('Email already exists');
    });
  });
});
```

## Integration Testing API Endpoints

```typescript
// routes/__tests__/users.routes.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import request from 'supertest';
import app from '../../app';
import { pool } from '../../config/database';

describe('User Routes', () => {
  beforeEach(async () => {
    // Setup test database
    await pool.query('DELETE FROM users');
  });

  afterEach(async () => {
    // Cleanup
    await pool.query('DELETE FROM users');
  });

  describe('POST /api/users', () => {
    it('should create user with valid input', async () => {
      const res = await request(app)
        .post('/api/users')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
          password: 'SecurePass123'
        });

      expect(res.status).toBe(201);
      expect(res.body.status).toBe('success');
      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data.email).toBe('john@example.com');
    });

    it('should reject invalid email', async () => {
      const res = await request(app)
        .post('/api/users')
        .send({
          name: 'John Doe',
          email: 'invalid-email',
          password: 'SecurePass123'
        });

      expect(res.status).toBe(400);
      expect(res.body.status).toBe('error');
      expect(res.body.fields).toHaveProperty('email');
    });

    it('should reject duplicate email', async () => {
      // Create first user
      await request(app)
        .post('/api/users')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
          password: 'SecurePass123'
        });

      // Try to create with same email
      const res = await request(app)
        .post('/api/users')
        .send({
          name: 'Jane Doe',
          email: 'john@example.com',
          password: 'SecurePass123'
        });

      expect(res.status).toBe(409);
      expect(res.body.error).toContain('already exists');
    });
  });

  describe('GET /api/users/:id', () => {
    it('should get user by id', async () => {
      // Create user first
      const createRes = await request(app)
        .post('/api/users')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
          password: 'SecurePass123'
        });

      const userId = createRes.body.data.id;

      // Get user
      const res = await request(app).get(`/api/users/${userId}`);

      expect(res.status).toBe(200);
      expect(res.body.data.id).toBe(userId);
      expect(res.body.data.email).toBe('john@example.com');
    });

    it('should return 404 for non-existent user', async () => {
      const res = await request(app).get('/api/users/nonexistent');

      expect(res.status).toBe(404);
      expect(res.body.error).toContain('not found');
    });
  });

  describe('GET /api/users', () => {
    it('should list users with pagination', async () => {
      // Create multiple users
      for (let i = 0; i < 5; i++) {
        await request(app)
          .post('/api/users')
          .send({
            name: `User ${i}`,
            email: `user${i}@example.com`,
            password: 'SecurePass123'
          });
      }

      // Get paginated list
      const res = await request(app)
        .get('/api/users')
        .query({ page: 1, limit: 2 });

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(2);
      expect(res.body.pagination.total).toBe(5);
      expect(res.body.pagination.pages).toBe(3);
    });
  });
});
```

## Testing Middleware

```typescript
// middleware/__tests__/auth.middleware.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { Request, Response, NextFunction } from 'express';
import { authenticate } from '../auth.middleware';
import jwt from 'jsonwebtoken';

describe('Auth Middleware', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;
  let next: jest.Mock;

  beforeEach(() => {
    req = {
      headers: {}
    };
    res = {
      status: () => res,
      json: vi.fn()
    };
    next = vi.fn();
  });

  it('should attach user to request with valid token', () => {
    const payload = { userId: '1', email: 'test@example.com', roles: [] };
    const token = jwt.sign(payload, process.env.JWT_SECRET!);

    req.headers = { authorization: `Bearer ${token}` };

    authenticate(req as Request, res as Response, next);

    expect(next).toHaveBeenCalled();
    expect(req.user).toEqual(payload);
  });

  it('should reject request with missing token', () => {
    authenticate(req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(next).not.toHaveBeenCalled();
  });

  it('should reject request with invalid token', () => {
    req.headers = { authorization: 'Bearer invalid.token.here' };

    authenticate(req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(next).not.toHaveBeenCalled();
  });
});
```

## Testing Error Handling

```typescript
// middleware/__tests__/error-handler.test.ts
import { describe, it, expect } from 'vitest';
import { Request, Response, NextFunction } from 'express';
import { errorHandler } from '../error-handler';
import { AppError, ValidationError } from '../../utils/errors';

describe('Error Handler', () => {
  let req: Partial<Request>;
  let res: Partial<Response>;
  let next: jest.Mock;

  beforeEach(() => {
    req = { path: '/api/users', method: 'POST' };
    res = {
      status: () => res,
      json: vi.fn().mockReturnValue(res)
    };
    next = vi.fn();
  });

  it('should handle AppError', () => {
    const error = new AppError('Resource not found', 404);

    errorHandler(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({
      error: 'Resource not found'
    });
  });

  it('should handle ValidationError with fields', () => {
    const error = new ValidationError('Validation failed', {
      email: 'Invalid email',
      password: 'Too short'
    });

    errorHandler(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        error: 'Validation failed',
        fields: expect.any(Object)
      })
    );
  });

  it('should hide error details in production', () => {
    process.env.NODE_ENV = 'production';
    const error = new Error('Sensitive error details');

    errorHandler(error, req as Request, res as Response, next);

    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith({
      error: 'Internal server error'
    });

    process.env.NODE_ENV = 'test';
  });
});
```

## Test Factories/Builders

```typescript
// __tests__/factories/user.factory.ts
import { User } from '../../types/user.types';

export class UserFactory {
  static create(overrides?: Partial<User>): User {
    return {
      id: 'user-' + Math.random().toString(36).substr(2, 9),
      name: 'Test User',
      email: 'test@example.com',
      password: 'SecurePass123',
      roles: ['user'],
      createdAt: new Date(),
      updatedAt: new Date(),
      ...overrides
    };
  }

  static createMany(count: number, overrides?: Partial<User>): User[] {
    return Array.from({ length: count }, (_, i) =>
      this.create({
        name: `User ${i}`,
        email: `user${i}@example.com`,
        ...overrides
      })
    );
  }

  static createAdmin(overrides?: Partial<User>): User {
    return this.create({
      roles: ['admin'],
      ...overrides
    });
  }
}

// Usage:
const user = UserFactory.create();
const admin = UserFactory.createAdmin();
const users = UserFactory.createMany(5);
```

## Best Practices

1. **Test behavior, not implementation** - Focus on inputs/outputs
2. **Mock external dependencies** - Database, APIs, services
3. **Use test fixtures** - Consistent test data
4. **Test error cases** - Invalid input, not found, etc
5. **Test edge cases** - Boundaries, empty, very large
6. **Isolate tests** - Each test independent
7. **Clear test names** - Describe what is being tested
8. **Arrange-Act-Assert** - Clear test structure
9. **Avoid flaky tests** - Don't depend on timing
10. **Aim for >80% coverage** - But focus on critical paths

## Test Structure Template

```typescript
describe('Feature Name', () => {
  // Setup
  beforeEach(() => {
    // Setup test data
  });

  // Cleanup
  afterEach(() => {
    // Cleanup
  });

  describe('Specific Function', () => {
    it('should [expected behavior] when [condition]', async () => {
      // Arrange - Setup test data
      const input = { /* ... */ };

      // Act - Execute function
      const result = await functionUnderTest(input);

      // Assert - Verify results
      expect(result).toEqual({ /* ... */ });
    });
  });
});
```

## Coverage Goals

| Category | Target |
|----------|--------|
| Services | 90%+ |
| Middleware | 85%+ |
| Routes | 80%+ |
| Utils | 80%+ |
| Database | 70%+ |

## See Also

- middleware-patterns - Testing middleware
- database-integration - Database test setup
- authentication-patterns - Testing auth flows
