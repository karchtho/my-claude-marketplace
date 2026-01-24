---
name: integration-testing
description: Integration testing for Express APIs, HTTP endpoint testing, supertest, API testing patterns, authentication testing, request validation. Activates when user mentions "integration test", "API testing", "Express testing", "supertest", "endpoint testing", "HTTP testing", or wants to test Express routes and middleware.
version: 1.0.0
---

# Integration Testing for Express APIs

Comprehensive patterns for testing Express.js applications with supertest, covering routes, middleware, authentication, and error handling.

## Setup

### Install Dependencies

```bash
npm install --save-dev supertest @types/supertest
```

### Test Configuration

```typescript
// test/setup.ts
import { beforeAll, afterAll, afterEach } from '@jest/globals';
import { prisma } from '../src/lib/prisma';

beforeAll(async () => {
  // Connect to test database
  await prisma.$connect();
});

afterEach(async () => {
  // Clean up test data between tests
  await prisma.$executeRaw`TRUNCATE TABLE users, orders CASCADE`;
});

afterAll(async () => {
  await prisma.$disconnect();
});
```

### App Factory for Testing

```typescript
// src/app.ts
import express from 'express';
import { userRouter } from './routes/user.routes';
import { errorHandler } from './middleware/error.middleware';

export function createApp() {
  const app = express();

  app.use(express.json());
  app.use('/api/users', userRouter);
  app.use(errorHandler);

  return app;
}

// For production
export const app = createApp();
```

## Basic Endpoint Testing

```typescript
// routes/user.routes.test.ts
import request from 'supertest';
import { createApp } from '../app';
import { prisma } from '../lib/prisma';

describe('User Routes', () => {
  const app = createApp();

  describe('GET /api/users', () => {
    it('should return empty array when no users exist', async () => {
      const response = await request(app)
        .get('/api/users')
        .expect(200);

      expect(response.body).toEqual([]);
    });

    it('should return all users', async () => {
      // Arrange - Create test data
      await prisma.user.createMany({
        data: [
          { name: 'John', email: 'john@example.com' },
          { name: 'Jane', email: 'jane@example.com' }
        ]
      });

      // Act
      const response = await request(app)
        .get('/api/users')
        .expect(200);

      // Assert
      expect(response.body).toHaveLength(2);
      expect(response.body[0]).toMatchObject({ name: 'John' });
    });
  });

  describe('GET /api/users/:id', () => {
    it('should return user by id', async () => {
      const user = await prisma.user.create({
        data: { name: 'John', email: 'john@example.com' }
      });

      const response = await request(app)
        .get(`/api/users/${user.id}`)
        .expect(200);

      expect(response.body).toMatchObject({
        id: user.id,
        name: 'John',
        email: 'john@example.com'
      });
    });

    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/users/non-existent-id')
        .expect(404);

      expect(response.body).toMatchObject({
        error: 'User not found'
      });
    });
  });

  describe('POST /api/users', () => {
    it('should create new user', async () => {
      const newUser = { name: 'John', email: 'john@example.com' };

      const response = await request(app)
        .post('/api/users')
        .send(newUser)
        .expect(201);

      expect(response.body).toMatchObject({
        id: expect.any(String),
        name: 'John',
        email: 'john@example.com'
      });

      // Verify persisted to database
      const dbUser = await prisma.user.findUnique({
        where: { id: response.body.id }
      });
      expect(dbUser).not.toBeNull();
    });

    it('should return 400 for invalid data', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({ name: '' }) // Missing email
        .expect(400);

      expect(response.body).toMatchObject({
        error: 'Validation failed',
        details: expect.arrayContaining([
          expect.objectContaining({ field: 'email' })
        ])
      });
    });

    it('should return 409 for duplicate email', async () => {
      await prisma.user.create({
        data: { name: 'Existing', email: 'taken@example.com' }
      });

      const response = await request(app)
        .post('/api/users')
        .send({ name: 'New', email: 'taken@example.com' })
        .expect(409);

      expect(response.body).toMatchObject({
        error: 'Email already exists'
      });
    });
  });

  describe('PUT /api/users/:id', () => {
    it('should update existing user', async () => {
      const user = await prisma.user.create({
        data: { name: 'John', email: 'john@example.com' }
      });

      const response = await request(app)
        .put(`/api/users/${user.id}`)
        .send({ name: 'John Updated' })
        .expect(200);

      expect(response.body.name).toBe('John Updated');
    });
  });

  describe('DELETE /api/users/:id', () => {
    it('should delete user', async () => {
      const user = await prisma.user.create({
        data: { name: 'John', email: 'john@example.com' }
      });

      await request(app)
        .delete(`/api/users/${user.id}`)
        .expect(204);

      const dbUser = await prisma.user.findUnique({
        where: { id: user.id }
      });
      expect(dbUser).toBeNull();
    });
  });
});
```

## Authentication Testing

```typescript
// test/helpers/auth.helper.ts
import jwt from 'jsonwebtoken';

interface TokenPayload {
  userId: string;
  role: 'user' | 'admin';
}

export function generateTestToken(payload: TokenPayload): string {
  return jwt.sign(payload, process.env.JWT_SECRET!, { expiresIn: '1h' });
}

export function authHeader(token: string): [string, string] {
  return ['Authorization', `Bearer ${token}`];
}

// routes/protected.routes.test.ts
import request from 'supertest';
import { createApp } from '../app';
import { generateTestToken, authHeader } from '../test/helpers/auth.helper';
import { prisma } from '../lib/prisma';

describe('Protected Routes', () => {
  const app = createApp();
  let userToken: string;
  let adminToken: string;
  let testUser: { id: string };

  beforeEach(async () => {
    testUser = await prisma.user.create({
      data: { name: 'Test User', email: 'test@example.com', role: 'user' }
    });

    userToken = generateTestToken({ userId: testUser.id, role: 'user' });
    adminToken = generateTestToken({ userId: 'admin-id', role: 'admin' });
  });

  describe('GET /api/profile', () => {
    it('should return 401 without token', async () => {
      await request(app)
        .get('/api/profile')
        .expect(401);
    });

    it('should return 401 with invalid token', async () => {
      await request(app)
        .get('/api/profile')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });

    it('should return profile with valid token', async () => {
      const response = await request(app)
        .get('/api/profile')
        .set(...authHeader(userToken))
        .expect(200);

      expect(response.body).toMatchObject({
        id: testUser.id,
        name: 'Test User'
      });
    });
  });

  describe('DELETE /api/users/:id (admin only)', () => {
    it('should return 403 for non-admin user', async () => {
      await request(app)
        .delete(`/api/users/${testUser.id}`)
        .set(...authHeader(userToken))
        .expect(403);
    });

    it('should allow admin to delete user', async () => {
      await request(app)
        .delete(`/api/users/${testUser.id}`)
        .set(...authHeader(adminToken))
        .expect(204);
    });
  });
});
```

## Request Validation Testing

```typescript
describe('Input Validation', () => {
  const app = createApp();

  describe('POST /api/orders', () => {
    const validOrder = {
      items: [{ productId: 'prod-1', quantity: 2 }],
      shippingAddress: {
        street: '123 Main St',
        city: 'New York',
        zipCode: '10001'
      }
    };

    it('should accept valid order', async () => {
      await request(app)
        .post('/api/orders')
        .send(validOrder)
        .expect(201);
    });

    it('should reject empty items array', async () => {
      const response = await request(app)
        .post('/api/orders')
        .send({ ...validOrder, items: [] })
        .expect(400);

      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          field: 'items',
          message: 'At least one item is required'
        })
      );
    });

    it('should reject negative quantity', async () => {
      const response = await request(app)
        .post('/api/orders')
        .send({
          ...validOrder,
          items: [{ productId: 'prod-1', quantity: -1 }]
        })
        .expect(400);

      expect(response.body.details).toContainEqual(
        expect.objectContaining({
          field: 'items.0.quantity',
          message: 'Quantity must be positive'
        })
      );
    });

    it('should reject missing shipping address fields', async () => {
      const response = await request(app)
        .post('/api/orders')
        .send({
          ...validOrder,
          shippingAddress: { street: '123 Main St' }
        })
        .expect(400);

      expect(response.body.details).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ field: 'shippingAddress.city' }),
          expect.objectContaining({ field: 'shippingAddress.zipCode' })
        ])
      );
    });

    it('should sanitize XSS in string fields', async () => {
      const response = await request(app)
        .post('/api/orders')
        .send({
          ...validOrder,
          shippingAddress: {
            ...validOrder.shippingAddress,
            street: '<script>alert("xss")</script>'
          }
        })
        .expect(201);

      expect(response.body.shippingAddress.street).not.toContain('<script>');
    });
  });
});
```

## Query Parameter Testing

```typescript
describe('GET /api/products', () => {
  const app = createApp();

  beforeEach(async () => {
    await prisma.product.createMany({
      data: [
        { name: 'Widget A', price: 10, category: 'widgets' },
        { name: 'Widget B', price: 20, category: 'widgets' },
        { name: 'Gadget A', price: 50, category: 'gadgets' },
        { name: 'Gadget B', price: 100, category: 'gadgets' }
      ]
    });
  });

  describe('pagination', () => {
    it('should paginate results', async () => {
      const response = await request(app)
        .get('/api/products')
        .query({ page: 1, limit: 2 })
        .expect(200);

      expect(response.body.data).toHaveLength(2);
      expect(response.body.pagination).toMatchObject({
        page: 1,
        limit: 2,
        total: 4,
        totalPages: 2
      });
    });

    it('should return second page', async () => {
      const response = await request(app)
        .get('/api/products')
        .query({ page: 2, limit: 2 })
        .expect(200);

      expect(response.body.data).toHaveLength(2);
      expect(response.body.pagination.page).toBe(2);
    });
  });

  describe('filtering', () => {
    it('should filter by category', async () => {
      const response = await request(app)
        .get('/api/products')
        .query({ category: 'widgets' })
        .expect(200);

      expect(response.body.data).toHaveLength(2);
      expect(response.body.data.every((p: any) => p.category === 'widgets')).toBe(true);
    });

    it('should filter by price range', async () => {
      const response = await request(app)
        .get('/api/products')
        .query({ minPrice: 15, maxPrice: 60 })
        .expect(200);

      expect(response.body.data).toHaveLength(2);
    });
  });

  describe('sorting', () => {
    it('should sort by price ascending', async () => {
      const response = await request(app)
        .get('/api/products')
        .query({ sortBy: 'price', order: 'asc' })
        .expect(200);

      const prices = response.body.data.map((p: any) => p.price);
      expect(prices).toEqual([10, 20, 50, 100]);
    });

    it('should sort by price descending', async () => {
      const response = await request(app)
        .get('/api/products')
        .query({ sortBy: 'price', order: 'desc' })
        .expect(200);

      const prices = response.body.data.map((p: any) => p.price);
      expect(prices).toEqual([100, 50, 20, 10]);
    });
  });
});
```

## Error Handling Testing

```typescript
describe('Error Handling', () => {
  const app = createApp();

  it('should return 404 for unknown routes', async () => {
    const response = await request(app)
      .get('/api/unknown-route')
      .expect(404);

    expect(response.body).toMatchObject({
      error: 'Not Found',
      path: '/api/unknown-route'
    });
  });

  it('should return 500 for internal errors', async () => {
    // Mock a service to throw
    jest.spyOn(userService, 'findAll').mockRejectedValueOnce(
      new Error('Database connection lost')
    );

    const response = await request(app)
      .get('/api/users')
      .expect(500);

    expect(response.body).toMatchObject({
      error: 'Internal Server Error'
    });
    // Should not leak error details
    expect(response.body.message).not.toContain('Database');
  });

  it('should return 400 for malformed JSON', async () => {
    const response = await request(app)
      .post('/api/users')
      .set('Content-Type', 'application/json')
      .send('{ invalid json }')
      .expect(400);

    expect(response.body).toMatchObject({
      error: 'Invalid JSON'
    });
  });
});
```

## File Upload Testing

```typescript
describe('POST /api/upload', () => {
  const app = createApp();

  it('should upload file successfully', async () => {
    const response = await request(app)
      .post('/api/upload')
      .attach('file', Buffer.from('test content'), 'test.txt')
      .expect(200);

    expect(response.body).toMatchObject({
      filename: expect.stringContaining('test'),
      size: expect.any(Number)
    });
  });

  it('should reject files too large', async () => {
    const largeBuffer = Buffer.alloc(10 * 1024 * 1024); // 10MB

    await request(app)
      .post('/api/upload')
      .attach('file', largeBuffer, 'large.txt')
      .expect(413);
  });

  it('should reject invalid file types', async () => {
    await request(app)
      .post('/api/upload')
      .attach('file', Buffer.from('test'), 'test.exe')
      .expect(400);
  });
});
```

## Best Practices

1. **Use test database** - Never run integration tests against production
2. **Isolate tests** - Clean data between tests with TRUNCATE or transactions
3. **Test full request cycle** - Include middleware, validation, and error handling
4. **Use factories** - Create consistent test data with factory functions
5. **Test authentication** - Cover both authenticated and unauthenticated scenarios
6. **Test error responses** - Verify error format and status codes
7. **Check side effects** - Verify database changes after operations
8. **Use realistic data** - Test with data similar to production
