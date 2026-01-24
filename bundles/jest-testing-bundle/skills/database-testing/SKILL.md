---
name: database-testing
description: Database testing with Prisma and PostgreSQL, repository testing, transaction testing, migration testing, test data management. Activates when user mentions "database testing", "Prisma testing", "repository test", "PostgreSQL test", "transaction testing", "test database", or wants to test database operations.
version: 1.0.0
---

# Database Testing with Prisma and PostgreSQL

Patterns for testing database operations, repositories, and transactions with Prisma ORM and PostgreSQL.

## Test Database Setup

### Environment Configuration

```bash
# .env.test
DATABASE_URL="postgresql://postgres:password@localhost:5432/myapp_test?schema=public"
```

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  // ... other config
  setupFilesAfterEnv: ['<rootDir>/test/setup.ts'],
  testEnvironment: 'node',
  // Use separate test database
  globalSetup: '<rootDir>/test/global-setup.ts',
  globalTeardown: '<rootDir>/test/global-teardown.ts'
};
```

### Global Setup/Teardown

```typescript
// test/global-setup.ts
import { execSync } from 'child_process';

export default async function globalSetup() {
  // Reset test database
  execSync('npx prisma migrate reset --force --skip-seed', {
    env: {
      ...process.env,
      DATABASE_URL: process.env.TEST_DATABASE_URL
    }
  });
}

// test/global-teardown.ts
import { prisma } from '../src/lib/prisma';

export default async function globalTeardown() {
  await prisma.$disconnect();
}
```

### Test Setup File

```typescript
// test/setup.ts
import { prisma } from '../src/lib/prisma';
import { beforeAll, afterAll, afterEach } from '@jest/globals';

beforeAll(async () => {
  await prisma.$connect();
});

afterEach(async () => {
  // Clean all tables
  const tablenames = await prisma.$queryRaw<
    Array<{ tablename: string }>
  >`SELECT tablename FROM pg_tables WHERE schemaname='public'`;

  for (const { tablename } of tablenames) {
    if (tablename !== '_prisma_migrations') {
      await prisma.$executeRawUnsafe(`TRUNCATE TABLE "public"."${tablename}" CASCADE;`);
    }
  }
});

afterAll(async () => {
  await prisma.$disconnect();
});
```

## Repository Testing

### Basic Repository Tests

```typescript
// repositories/user.repository.ts
import { prisma } from '../lib/prisma';
import { User, Prisma } from '@prisma/client';

export class UserRepository {
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email } });
  }

  async create(data: Prisma.UserCreateInput): Promise<User> {
    return prisma.user.create({ data });
  }

  async update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({ where: { id }, data });
  }

  async delete(id: string): Promise<void> {
    await prisma.user.delete({ where: { id } });
  }

  async findWithOrders(id: string): Promise<User & { orders: Order[] } | null> {
    return prisma.user.findUnique({
      where: { id },
      include: { orders: true }
    });
  }
}

// repositories/user.repository.test.ts
import { UserRepository } from './user.repository';
import { prisma } from '../lib/prisma';
import { createUserFixture } from '../test/factories/user.factory';

describe('UserRepository', () => {
  const repository = new UserRepository();

  describe('findById', () => {
    it('should return user when exists', async () => {
      // Arrange
      const createdUser = await prisma.user.create({
        data: createUserFixture()
      });

      // Act
      const user = await repository.findById(createdUser.id);

      // Assert
      expect(user).not.toBeNull();
      expect(user?.id).toBe(createdUser.id);
    });

    it('should return null when user does not exist', async () => {
      const user = await repository.findById('non-existent-id');
      expect(user).toBeNull();
    });
  });

  describe('create', () => {
    it('should create user with valid data', async () => {
      const userData = createUserFixture();

      const user = await repository.create(userData);

      expect(user.id).toBeDefined();
      expect(user.email).toBe(userData.email);
      expect(user.name).toBe(userData.name);
    });

    it('should throw on duplicate email', async () => {
      const userData = createUserFixture();
      await repository.create(userData);

      await expect(
        repository.create({ ...userData, name: 'Different Name' })
      ).rejects.toThrow();
    });
  });

  describe('findWithOrders', () => {
    it('should return user with orders', async () => {
      // Arrange
      const user = await prisma.user.create({
        data: createUserFixture()
      });
      await prisma.order.createMany({
        data: [
          { userId: user.id, total: 100, status: 'pending' },
          { userId: user.id, total: 200, status: 'completed' }
        ]
      });

      // Act
      const result = await repository.findWithOrders(user.id);

      // Assert
      expect(result?.orders).toHaveLength(2);
      expect(result?.orders[0]).toMatchObject({ userId: user.id });
    });
  });
});
```

## Transaction Testing

```typescript
// services/order.service.ts
import { prisma } from '../lib/prisma';

export class OrderService {
  async createOrderWithItems(
    userId: string,
    items: Array<{ productId: string; quantity: number }>
  ) {
    return prisma.$transaction(async (tx) => {
      // Create order
      const order = await tx.order.create({
        data: {
          userId,
          status: 'pending',
          total: 0
        }
      });

      // Create order items and calculate total
      let total = 0;
      for (const item of items) {
        const product = await tx.product.findUniqueOrThrow({
          where: { id: item.productId }
        });

        // Check stock
        if (product.stock < item.quantity) {
          throw new Error(`Insufficient stock for ${product.name}`);
        }

        // Decrement stock
        await tx.product.update({
          where: { id: item.productId },
          data: { stock: { decrement: item.quantity } }
        });

        // Create order item
        await tx.orderItem.create({
          data: {
            orderId: order.id,
            productId: item.productId,
            quantity: item.quantity,
            price: product.price
          }
        });

        total += product.price * item.quantity;
      }

      // Update order total
      return tx.order.update({
        where: { id: order.id },
        data: { total },
        include: { items: true }
      });
    });
  }
}

// services/order.service.test.ts
describe('OrderService', () => {
  const service = new OrderService();

  describe('createOrderWithItems', () => {
    it('should create order and decrement stock atomically', async () => {
      // Arrange
      const user = await prisma.user.create({
        data: createUserFixture()
      });
      const product = await prisma.product.create({
        data: { name: 'Widget', price: 25, stock: 10 }
      });

      // Act
      const order = await service.createOrderWithItems(user.id, [
        { productId: product.id, quantity: 3 }
      ]);

      // Assert
      expect(order.total).toBe(75);
      expect(order.items).toHaveLength(1);

      const updatedProduct = await prisma.product.findUnique({
        where: { id: product.id }
      });
      expect(updatedProduct?.stock).toBe(7);
    });

    it('should rollback on insufficient stock', async () => {
      // Arrange
      const user = await prisma.user.create({
        data: createUserFixture()
      });
      const product = await prisma.product.create({
        data: { name: 'Widget', price: 25, stock: 2 }
      });

      // Act & Assert
      await expect(
        service.createOrderWithItems(user.id, [
          { productId: product.id, quantity: 5 }
        ])
      ).rejects.toThrow('Insufficient stock');

      // Verify rollback - no order created
      const orders = await prisma.order.findMany({
        where: { userId: user.id }
      });
      expect(orders).toHaveLength(0);

      // Stock unchanged
      const updatedProduct = await prisma.product.findUnique({
        where: { id: product.id }
      });
      expect(updatedProduct?.stock).toBe(2);
    });

    it('should handle multiple items in single transaction', async () => {
      const user = await prisma.user.create({
        data: createUserFixture()
      });
      const [product1, product2] = await Promise.all([
        prisma.product.create({ data: { name: 'Widget', price: 10, stock: 5 } }),
        prisma.product.create({ data: { name: 'Gadget', price: 20, stock: 10 } })
      ]);

      const order = await service.createOrderWithItems(user.id, [
        { productId: product1.id, quantity: 2 },
        { productId: product2.id, quantity: 3 }
      ]);

      expect(order.total).toBe(80); // 20 + 60
      expect(order.items).toHaveLength(2);
    });
  });
});
```

## Query Testing

```typescript
// repositories/product.repository.ts
export class ProductRepository {
  async findWithFilters(filters: {
    category?: string;
    minPrice?: number;
    maxPrice?: number;
    inStock?: boolean;
    search?: string;
  }) {
    const where: Prisma.ProductWhereInput = {};

    if (filters.category) {
      where.category = filters.category;
    }
    if (filters.minPrice !== undefined) {
      where.price = { ...where.price as object, gte: filters.minPrice };
    }
    if (filters.maxPrice !== undefined) {
      where.price = { ...where.price as object, lte: filters.maxPrice };
    }
    if (filters.inStock) {
      where.stock = { gt: 0 };
    }
    if (filters.search) {
      where.name = { contains: filters.search, mode: 'insensitive' };
    }

    return prisma.product.findMany({ where });
  }
}

// repositories/product.repository.test.ts
describe('ProductRepository', () => {
  const repository = new ProductRepository();

  beforeEach(async () => {
    await prisma.product.createMany({
      data: [
        { name: 'Blue Widget', price: 10, stock: 5, category: 'widgets' },
        { name: 'Red Widget', price: 20, stock: 0, category: 'widgets' },
        { name: 'Green Gadget', price: 50, stock: 10, category: 'gadgets' },
        { name: 'Yellow Gadget', price: 100, stock: 3, category: 'gadgets' }
      ]
    });
  });

  describe('findWithFilters', () => {
    it('should filter by category', async () => {
      const products = await repository.findWithFilters({ category: 'widgets' });
      expect(products).toHaveLength(2);
      expect(products.every(p => p.category === 'widgets')).toBe(true);
    });

    it('should filter by price range', async () => {
      const products = await repository.findWithFilters({
        minPrice: 15,
        maxPrice: 60
      });
      expect(products).toHaveLength(2);
      expect(products.map(p => p.price)).toEqual([20, 50]);
    });

    it('should filter in stock only', async () => {
      const products = await repository.findWithFilters({ inStock: true });
      expect(products).toHaveLength(3);
      expect(products.every(p => p.stock > 0)).toBe(true);
    });

    it('should search by name (case insensitive)', async () => {
      const products = await repository.findWithFilters({ search: 'widget' });
      expect(products).toHaveLength(2);
    });

    it('should combine multiple filters', async () => {
      const products = await repository.findWithFilters({
        category: 'gadgets',
        minPrice: 40,
        inStock: true
      });
      expect(products).toHaveLength(2);
    });

    it('should return empty array when no matches', async () => {
      const products = await repository.findWithFilters({
        category: 'nonexistent'
      });
      expect(products).toHaveLength(0);
    });
  });
});
```

## Test Data Isolation Strategies

### Strategy 1: TRUNCATE Between Tests

```typescript
afterEach(async () => {
  await prisma.$executeRaw`TRUNCATE TABLE users, orders, products CASCADE`;
});
```

### Strategy 2: Unique IDs Per Test

```typescript
import { randomUUID } from 'crypto';

describe('UserService', () => {
  it('should create user', async () => {
    const uniqueEmail = `test-${randomUUID()}@example.com`;
    const user = await userService.create({ email: uniqueEmail, name: 'Test' });
    expect(user.email).toBe(uniqueEmail);
  });
});
```

### Strategy 3: Transactions with Rollback

```typescript
describe('With transaction rollback', () => {
  let transaction: PrismaClient;

  beforeEach(async () => {
    // Start transaction
    transaction = await prisma.$begin();
  });

  afterEach(async () => {
    // Rollback after each test
    await transaction.$rollback();
  });

  it('should test with isolated data', async () => {
    await transaction.user.create({ data: createUserFixture() });
    // This data will be rolled back
  });
});
```

## Testing Migrations

```typescript
// test/migrations.test.ts
import { execSync } from 'child_process';
import { prisma } from '../src/lib/prisma';

describe('Database Migrations', () => {
  it('should apply all migrations successfully', async () => {
    // Reset and apply migrations
    execSync('npx prisma migrate reset --force', {
      env: { ...process.env, DATABASE_URL: process.env.TEST_DATABASE_URL }
    });

    // Verify schema
    const tables = await prisma.$queryRaw<Array<{ tablename: string }>>`
      SELECT tablename FROM pg_tables WHERE schemaname='public'
    `;

    const tableNames = tables.map(t => t.tablename);
    expect(tableNames).toContain('users');
    expect(tableNames).toContain('orders');
    expect(tableNames).toContain('products');
  });

  it('should have correct column types', async () => {
    const columns = await prisma.$queryRaw<Array<{
      column_name: string;
      data_type: string;
    }>>`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'users'
    `;

    const columnMap = Object.fromEntries(
      columns.map(c => [c.column_name, c.data_type])
    );

    expect(columnMap.id).toBe('uuid');
    expect(columnMap.email).toBe('character varying');
    expect(columnMap.created_at).toBe('timestamp with time zone');
  });
});
```

## Factory Functions for Test Data

```typescript
// test/factories/user.factory.ts
import { faker } from '@faker-js/faker';
import { Prisma } from '@prisma/client';

export function createUserFixture(
  overrides?: Partial<Prisma.UserCreateInput>
): Prisma.UserCreateInput {
  return {
    name: faker.person.fullName(),
    email: faker.internet.email(),
    role: 'user',
    ...overrides
  };
}

// test/factories/order.factory.ts
export function createOrderFixture(
  userId: string,
  overrides?: Partial<Prisma.OrderCreateInput>
): Prisma.OrderCreateInput {
  return {
    user: { connect: { id: userId } },
    status: 'pending',
    total: faker.number.float({ min: 10, max: 500, fractionDigits: 2 }),
    ...overrides
  };
}

// test/factories/product.factory.ts
export function createProductFixture(
  overrides?: Partial<Prisma.ProductCreateInput>
): Prisma.ProductCreateInput {
  return {
    name: faker.commerce.productName(),
    price: faker.number.float({ min: 5, max: 200, fractionDigits: 2 }),
    stock: faker.number.int({ min: 0, max: 100 }),
    category: faker.commerce.department().toLowerCase(),
    ...overrides
  };
}
```

## Best Practices

1. **Use test database** - Never run tests against production or development databases
2. **Isolate tests** - Each test should be independent and not affect others
3. **Use unique identifiers** - Generate unique IDs to prevent test interference
4. **Clean up data** - TRUNCATE tables or use rollback between tests
5. **Test transactions** - Verify rollback behavior on errors
6. **Use factories** - Create consistent test data with factory functions
7. **Test edge cases** - Include boundary conditions and error scenarios
8. **Verify side effects** - Check that database state is correct after operations
