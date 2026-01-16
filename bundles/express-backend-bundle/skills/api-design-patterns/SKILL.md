---
name: api-design-patterns
description: REST API design, response formatting, versioning, pagination, filtering, sorting, error responses, status codes. Use when designing REST APIs, implementing pagination, filtering, versioning strategies, designing error response formats, or structuring API response formats.
---

# REST API Design Patterns

Master API design, response formatting, versioning, pagination, filtering, and error handling strategies.

## When to Use This Skill

- Designing REST API endpoints and routes
- Structuring API response formats
- Implementing versioning strategies
- Adding pagination, filtering, and sorting
- Handling errors with consistent response formats
- Designing list endpoints with query parameters
- Creating HATEOAS links for navigation
- Handling different content types

## Response Format Patterns

**Success Response:**
```typescript
// 200 OK - GET, PATCH, PUT, DELETE
{
  "status": "success",
  "data": { /* resource */ },
  "metadata": {
    "timestamp": "2025-01-16T12:00:00Z",
    "requestId": "uuid"
  }
}

// 201 Created - POST
{
  "status": "success",
  "data": { /* new resource */ },
  "message": "User created successfully"
}

// 204 No Content - DELETE
// (no body)
```

**Error Response:**
```typescript
{
  "status": "error",
  "error": "Email already exists",
  "code": "CONFLICT",
  "timestamp": "2025-01-16T12:00:00Z",
  "requestId": "uuid",
  // For validation errors:
  "fields": {
    "email": "Email already registered",
    "password": "Password must be 8+ characters"
  }
}
```

**Paginated List Response:**
```typescript
{
  "status": "success",
  "data": [ /* items */ ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8,
    "hasMore": true
  }
}
```

## Response Utility Class

```typescript
// utils/response.ts
import { Response } from 'express';

export class ApiResponse {
  static success<T>(
    res: Response,
    data: T,
    statusCode: number = 200,
    message?: string
  ) {
    return res.status(statusCode).json({
      status: 'success',
      data,
      ...(message && { message }),
      metadata: {
        timestamp: new Date().toISOString()
      }
    });
  }

  static created<T>(res: Response, data: T, message?: string) {
    return this.success(res, data, 201, message || 'Created successfully');
  }

  static noContent(res: Response) {
    return res.status(204).send();
  }

  static error(
    res: Response,
    error: string,
    statusCode: number = 500,
    code?: string,
    fields?: Record<string, string>
  ) {
    return res.status(statusCode).json({
      status: 'error',
      error,
      ...(code && { code }),
      ...(fields && { fields }),
      metadata: {
        timestamp: new Date().toISOString()
      }
    });
  }

  static paginated<T>(
    res: Response,
    data: T[],
    pagination: {
      page: number;
      limit: number;
      total: number;
    }
  ) {
    const pages = Math.ceil(pagination.total / pagination.limit);
    return res.json({
      status: 'success',
      data,
      pagination: {
        page: pagination.page,
        limit: pagination.limit,
        total: pagination.total,
        pages,
        hasMore: pagination.page < pages
      }
    });
  }
}

// Usage:
// ApiResponse.success(res, user);
// ApiResponse.created(res, user, 'User created');
// ApiResponse.paginated(res, users, { page: 1, limit: 20, total: 150 });
// ApiResponse.error(res, 'Not found', 404);
```

## Pagination Pattern

```typescript
// middleware/pagination.ts
import { Request, Response, NextFunction } from 'express';

export interface PaginationQuery {
  page: number;
  limit: number;
  offset: number;
}

declare global {
  namespace Express {
    interface Request {
      pagination?: PaginationQuery;
    }
  }
}

export const paginate = (maxLimit = 100) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const page = Math.max(1, parseInt(req.query.page as string) || 1);
    const limit = Math.min(
      maxLimit,
      parseInt(req.query.limit as string) || 20
    );

    req.pagination = {
      page,
      limit,
      offset: (page - 1) * limit
    };

    next();
  };
};

// Usage in route:
app.get('/users', paginate(100), async (req, res) => {
  const { offset, limit } = req.pagination!;
  const users = await db.query(
    'SELECT * FROM users LIMIT $1 OFFSET $2',
    [limit, offset]
  );
  const { rows: countResult } = await db.query('SELECT COUNT(*) FROM users');
  const total = parseInt(countResult[0].count);

  ApiResponse.paginated(res, users, { page, limit, total });
});
```

## Filtering Pattern

```typescript
// Query string: ?status=active&role=admin&age_gt=18

interface FilterOptions {
  field: string;
  operator: 'eq' | 'gt' | 'gte' | 'lt' | 'lte' | 'ne' | 'in';
  value: any;
}

function parseFilters(query: any): FilterOptions[] {
  const filters: FilterOptions[] = [];

  for (const [key, value] of Object.entries(query)) {
    const match = key.match(/^(\w+)(?:_(.+))?$/);
    if (!match) continue;

    const [, field, operator = 'eq'] = match;

    filters.push({
      field,
      operator: operator as FilterOptions['operator'],
      value
    });
  }

  return filters;
}

// Build WHERE clause
function buildWhereClause(filters: FilterOptions[]): {
  clause: string;
  params: any[];
} {
  const clauses: string[] = [];
  const params: any[] = [];

  filters.forEach(({ field, operator, value }, index) => {
    const paramIndex = index + 1;

    switch (operator) {
      case 'eq':
        clauses.push(`${field} = $${paramIndex}`);
        params.push(value);
        break;
      case 'gt':
        clauses.push(`${field} > $${paramIndex}`);
        params.push(value);
        break;
      case 'gte':
        clauses.push(`${field} >= $${paramIndex}`);
        params.push(value);
        break;
      case 'lt':
        clauses.push(`${field} < $${paramIndex}`);
        params.push(value);
        break;
      case 'lte':
        clauses.push(`${field} <= $${paramIndex}`);
        params.push(value);
        break;
      case 'ne':
        clauses.push(`${field} != $${paramIndex}`);
        params.push(value);
        break;
      case 'in':
        const ids = (value as string).split(',');
        const placeholders = ids.map((_, i) => `$${paramIndex + i}`).join(',');
        clauses.push(`${field} IN (${placeholders})`);
        params.push(...ids);
        break;
    }
  });

  return {
    clause: clauses.length ? 'WHERE ' + clauses.join(' AND ') : '',
    params
  };
}

// Usage: GET /users?status=active&age_gte=18&role_in=admin,moderator
```

## Sorting Pattern

```typescript
// Query string: ?sort=name&sort=-created_at (- for descending)

interface SortOption {
  field: string;
  direction: 'ASC' | 'DESC';
}

function parseSortQuery(sort: string | string[] | undefined): SortOption[] {
  if (!sort) return [];

  const sortArray = Array.isArray(sort) ? sort : [sort];
  const allowedFields = ['name', 'email', 'created_at', 'updated_at'];

  return sortArray
    .map(s => {
      const isDesc = s.startsWith('-');
      const field = isDesc ? s.slice(1) : s;

      if (!allowedFields.includes(field)) {
        throw new Error(`Invalid sort field: ${field}`);
      }

      return {
        field,
        direction: isDesc ? 'DESC' : 'ASC'
      };
    });
}

function buildOrderByClause(sorts: SortOption[]): string {
  if (!sorts.length) return '';
  return 'ORDER BY ' + sorts
    .map(s => `${s.field} ${s.direction}`)
    .join(', ');
}

// Usage: GET /users?sort=created_at&sort=-name
```

## Versioning Strategies

**URL Path Versioning:**
```typescript
// /api/v1/users
// /api/v2/users

app.get('/api/v1/users', handleV1);
app.get('/api/v2/users', handleV2);
```

**Header Versioning:**
```typescript
// Header: API-Version: 2.0

app.get('/api/users', (req, res) => {
  const version = parseInt(req.get('API-Version') || '1');

  if (version === 2) {
    return handleV2(req, res);
  }
  handleV1(req, res);
});
```

**Query Parameter Versioning:**
```typescript
// /api/users?api_version=2

app.get('/api/users', (req, res) => {
  const version = parseInt(req.query.api_version as string || '1');
  // ...
});
```

**Recommended: URL Path Versioning**
- Clearest for developers
- Easy to maintain separate code paths
- Clear in documentation

## Standard HTTP Status Codes

| Code | Meaning | Use Case |
|------|---------|----------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input validation |
| 401 | Unauthorized | Missing/invalid authentication |
| 403 | Forbidden | Authenticated but no access |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource, version conflict |
| 422 | Unprocessable Entity | Validation failed |
| 429 | Too Many Requests | Rate limited |
| 500 | Server Error | Unexpected error |
| 503 | Service Unavailable | Temporarily down |

## Error Response Codes

```typescript
export enum ErrorCode {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  NOT_FOUND = 'NOT_FOUND',
  CONFLICT = 'CONFLICT',
  RATE_LIMITED = 'RATE_LIMITED',
  SERVER_ERROR = 'SERVER_ERROR'
}

// Usage:
res.status(400).json({
  status: 'error',
  code: ErrorCode.VALIDATION_ERROR,
  error: 'Email already exists',
  fields: { email: 'Email must be unique' }
});
```

## HATEOAS Links (Optional)

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  _links?: {
    self: { href: string };
    update: { href: string };
    delete: { href: string };
  };
}

function addLinks(user: User): User {
  return {
    ...user,
    _links: {
      self: { href: `/api/v1/users/${user.id}` },
      update: { href: `/api/v1/users/${user.id}` },
      delete: { href: `/api/v1/users/${user.id}` }
    }
  };
}
```

## Content Negotiation

```typescript
app.get('/users/:id', (req, res) => {
  const accept = req.get('Accept');
  const user = { id: '1', name: 'John' };

  if (accept?.includes('application/xml')) {
    res.type('application/xml').send(`<user>${user.name}</user>`);
  } else {
    res.json(user); // Default to JSON
  }
});
```

## Best Practices

1. **Consistent status codes** - Use correct HTTP status
2. **Consistent error format** - Same structure for all errors
3. **Version APIs** - Plan for evolution
4. **Document endpoints** - OpenAPI/Swagger spec
5. **Pagination by default** - Even if not required now
6. **Filter sensitive data** - Don't expose passwords, secrets
7. **Include request IDs** - For debugging
8. **Provide timestamps** - When data was created/modified
9. **Use JSON** - De facto standard for REST
10. **Cache appropriately** - Add Cache-Control headers

## See Also

- middleware-patterns - Error handling, validation
- authentication-patterns - Authorization headers
- database-integration - Query optimization for pagination
