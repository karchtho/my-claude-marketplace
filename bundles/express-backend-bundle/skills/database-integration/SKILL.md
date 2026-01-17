---
name: database-integration
description: Database integration patterns for PostgreSQL and MongoDB, connection pooling, query patterns, transactions, repositories, ORM setup (Prisma, TypeORM). Use when setting up database connections, writing database queries, implementing repositories, managing migrations, or handling transactions.
---

# Database Integration Patterns

Master database connections, query patterns, repositories, and transaction handling.

## When to Use This Skill

- Setting up database connections (PostgreSQL, MongoDB)
- Implementing connection pooling
- Writing parameterized queries
- Creating repository pattern for data access
- Managing database migrations
- Handling transactions
- Implementing caching strategies
- Optimizing queries with indexes

## PostgreSQL Connection Setup

```typescript
// config/database.ts
import { Pool, PoolClient, PoolConfig } from 'pg';

const poolConfig: PoolConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  // Connection pooling
  max: 20,                        // Max connections
  idleTimeoutMillis: 30000,      // Close idle connections
  connectionTimeoutMillis: 2000, // Connection timeout
  statement_timeout: 30000       // Query timeout
};

export const pool = new Pool(poolConfig);

// Connection events
pool.on('connect', () => {
  console.log('Database connected');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Graceful shutdown
export const closeDatabase = async () => {
  await pool.end();
  console.log('Database pool closed');
};

// Test connection on startup
export async function testConnection() {
  try {
    const result = await pool.query('SELECT NOW()');
    console.log('Database test query successful:', result.rows[0]);
  } catch (error) {
    console.error('Database connection failed:', error);
    process.exit(1);
  }
}
```

## Query Patterns (PostgreSQL)

**Always use parameterized queries to prevent SQL injection:**

```typescript
// ✅ SAFE - Parameterized query
const result = await pool.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// ❌ DANGEROUS - String interpolation
const result = await pool.query(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

**Common Query Patterns:**

```typescript
// SELECT single row
const result = await pool.query(
  'SELECT * FROM users WHERE id = $1',
  [userId]
);
const user = result.rows[0];

// SELECT multiple rows
const result = await pool.query(
  'SELECT * FROM users WHERE status = $1 LIMIT $2 OFFSET $3',
  [status, limit, offset]
);
const users = result.rows;

// INSERT returning generated ID
const result = await pool.query(
  'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, created_at',
  [name, email]
);
const { id, created_at } = result.rows[0];

// UPDATE
const result = await pool.query(
  'UPDATE users SET name = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
  [name, userId]
);

// DELETE
const result = await pool.query(
  'DELETE FROM users WHERE id = $1 RETURNING id',
  [userId]
);

// COUNT
const result = await pool.query(
  'SELECT COUNT(*) FROM users WHERE status = $1',
  [status]
);
const count = parseInt(result.rows[0].count);
```

## Repository Pattern

```typescript
// repositories/user.repository.ts
import { Pool } from 'pg';
import { User, CreateUserInput, UpdateUserInput } from '../types/user.types';
import { NotFoundError } from '../utils/errors';

export class UserRepository {
  constructor(private db: Pool) {}

  async findById(id: string): Promise<User> {
    const result = await this.db.query(
      'SELECT * FROM users WHERE id = $1',
      [id]
    );

    if (!result.rows[0]) {
      throw new NotFoundError('User not found');
    }

    return result.rows[0];
  }

  async findByEmail(email: string): Promise<User | null> {
    const result = await this.db.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    return result.rows[0] || null;
  }

  async findAll(limit: number, offset: number): Promise<{
    users: User[];
    total: number;
  }> {
    const [usersResult, countResult] = await Promise.all([
      this.db.query(
        'SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2',
        [limit, offset]
      ),
      this.db.query('SELECT COUNT(*) FROM users')
    ]);

    return {
      users: usersResult.rows,
      total: parseInt(countResult.rows[0].count)
    };
  }

  async create(input: CreateUserInput): Promise<User> {
    const result = await this.db.query(
      `INSERT INTO users (name, email, password, created_at, updated_at)
       VALUES ($1, $2, $3, NOW(), NOW())
       RETURNING *`,
      [input.name, input.email, input.password]
    );
    return result.rows[0];
  }

  async update(id: string, input: Partial<UpdateUserInput>): Promise<User> {
    const fields = Object.keys(input);
    const values = Object.values(input);

    if (fields.length === 0) {
      return this.findById(id);
    }

    const setClause = fields
      .map((field, idx) => `${field} = $${idx + 2}`)
      .join(', ');

    const result = await this.db.query(
      `UPDATE users SET ${setClause}, updated_at = NOW()
       WHERE id = $1 RETURNING *`,
      [id, ...values]
    );

    if (!result.rows[0]) {
      throw new NotFoundError('User not found');
    }

    return result.rows[0];
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.db.query(
      'DELETE FROM users WHERE id = $1',
      [id]
    );
    return result.rowCount > 0;
  }
}
```

## Transactions

```typescript
export class OrderRepository {
  constructor(private db: Pool) {}

  async createOrder(userId: string, items: OrderItem[]): Promise<string> {
    const client = await this.db.connect();

    try {
      await client.query('BEGIN');

      // Create order
      const orderResult = await client.query(
        `INSERT INTO orders (user_id, total, status, created_at)
         VALUES ($1, $2, $3, NOW())
         RETURNING id`,
        [userId, calculateTotal(items), 'pending']
      );
      const orderId = orderResult.rows[0].id;

      // Create order items
      for (const item of items) {
        await client.query(
          `INSERT INTO order_items (order_id, product_id, quantity, price)
           VALUES ($1, $2, $3, $4)`,
          [orderId, item.productId, item.quantity, item.price]
        );

        // Update inventory
        await client.query(
          'UPDATE products SET stock = stock - $1 WHERE id = $2',
          [item.quantity, item.productId]
        );
      }

      await client.query('COMMIT');
      return orderId;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}
```

## MongoDB with Mongoose

```typescript
// config/mongoose.ts
import mongoose from 'mongoose';

export async function connectMongoDB() {
  try {
    await mongoose.connect(process.env.MONGODB_URI!, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000
    });
    console.log('MongoDB connected');
  } catch (error) {
    console.error('MongoDB connection failed:', error);
    process.exit(1);
  }
}

mongoose.connection.on('disconnected', () => {
  console.log('MongoDB disconnected');
});

mongoose.connection.on('error', (err) => {
  console.error('MongoDB error:', err);
});

export async function closeDatabase() {
  await mongoose.disconnect();
}

// models/user.model.ts
import { Schema, model, Document } from 'mongoose';

interface IUser extends Document {
  name: string;
  email: string;
  password: string;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true }
  },
  { timestamps: true }
);

// Indexes for performance
userSchema.index({ email: 1 });
userSchema.index({ createdAt: -1 });

export const User = model<IUser>('User', userSchema);

// Repository pattern with Mongoose
export class UserMongoRepository {
  async findById(id: string): Promise<IUser | null> {
    return User.findById(id);
  }

  async findByEmail(email: string): Promise<IUser | null> {
    return User.findOne({ email });
  }

  async findAll(skip: number, limit: number) {
    const [users, total] = await Promise.all([
      User.find().skip(skip).limit(limit).sort({ createdAt: -1 }),
      User.countDocuments()
    ]);
    return { users, total };
  }

  async create(data: Partial<IUser>): Promise<IUser> {
    return User.create(data);
  }

  async update(id: string, data: Partial<IUser>): Promise<IUser | null> {
    return User.findByIdAndUpdate(id, data, { new: true });
  }

  async delete(id: string): Promise<boolean> {
    const result = await User.findByIdAndDelete(id);
    return !!result;
  }
}
```

## Query Optimization with Indexes

```typescript
// Always add indexes for frequently queried fields
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

// Composite indexes for common queries
CREATE INDEX idx_users_status_created ON users(status, created_at DESC);

// Verify index usage
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';
```

## Connection Pooling Best Practices

```typescript
// ✅ Good - Reuse connection pool
const db = new Pool(config);

app.get('/users/:id', async (req, res) => {
  const result = await db.query(
    'SELECT * FROM users WHERE id = $1',
    [req.params.id]
  );
  res.json(result.rows[0]);
});

// ❌ Bad - Create new connection per request
app.get('/users/:id', async (req, res) => {
  const client = new Client(config);
  await client.connect();
  const result = await client.query('...');
  await client.end(); // Slow!
});
```

## Caching Strategy

```typescript
// Cache frequently accessed data
export class UserCache {
  constructor(
    private repo: UserRepository,
    private redis: Redis
  ) {}

  async findById(id: string): Promise<User> {
    const cached = await this.redis.get(`user:${id}`);
    if (cached) return JSON.parse(cached);

    const user = await this.repo.findById(id);
    await this.redis.set(
      `user:${id}`,
      JSON.stringify(user),
      'EX',
      3600 // 1 hour
    );

    return user;
  }

  async invalidate(id: string): Promise<void> {
    await this.redis.del(`user:${id}`);
  }

  async invalidateList(): Promise<void> {
    const keys = await this.redis.keys('users:*');
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }
}
```

## Best Practices

1. **Always parameterize queries** - Prevent SQL injection
2. **Use connection pooling** - Never create per-request
3. **Set timeouts** - Prevent hanging connections
4. **Add indexes strategically** - For frequently queried columns
5. **Use transactions** - For multi-step operations
6. **Implement repositories** - Abstract database access
7. **Cache appropriately** - Reduce database load
8. **Handle null results** - Check for rows before accessing
9. **Monitor slow queries** - Use EXPLAIN ANALYZE
10. **Test migrations** - Test schema changes before production

## Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "relation does not exist" | Table not created | Run migrations |
| "column does not exist" | Field not in schema | Check schema/migration |
| "no more connections available" | Pool exhausted | Increase pool size |
| "query timeout" | Slow query | Optimize with indexes |
| "deadlock detected" | Transaction conflict | Retry with exponential backoff |

## See Also

- middleware-patterns - Error handling
- authentication-patterns - Password hashing
- testing-patterns - Database mocking
