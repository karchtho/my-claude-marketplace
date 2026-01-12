---
name: rest-api-design
description: Expert REST API design patterns, resource modeling, HTTP semantics, pagination, filtering, and RESTful best practices. Use when designing REST endpoints, reviewing API specifications, establishing REST conventions, or implementing HTTP-based web services.
version: 1.0.0
---

# REST API Design

Master REST API design principles to build intuitive, scalable, and developer-friendly APIs that stand the test of time.

## When to Use This Skill

- Designing new REST APIs or endpoints
- Refactoring existing APIs for better usability
- Establishing REST design standards for your team
- Reviewing REST API specifications before implementation
- Implementing pagination, filtering, and searching
- Designing error handling and status code strategies
- Planning API versioning and deprecation strategies

## Core REST Principles

### Resource-Oriented Architecture

REST APIs should be **resource-oriented**, not action-oriented:

- Resources are **nouns** (users, orders, products), not verbs
- Use **HTTP methods** for actions (GET, POST, PUT, PATCH, DELETE)
- URLs represent **resource hierarchies**
- Consistent naming conventions across endpoints

**Good patterns:**
```
GET    /api/users              # List users
POST   /api/users              # Create user
GET    /api/users/{id}         # Get specific user
PUT    /api/users/{id}         # Replace user
PATCH  /api/users/{id}         # Update user fields
DELETE /api/users/{id}         # Delete user

# Nested resources (shallow)
GET    /api/users/{id}/orders  # Get user's orders
POST   /api/users/{id}/orders  # Create order for user
```

**Bad patterns (avoid):**
```
POST /api/createUser
POST /api/getUserById
POST /api/deleteUser
GET  /api/user  (inconsistent singular)
```

### HTTP Methods Semantics

Each HTTP method has specific semantics that must be respected:

- **GET**: Retrieve resources (idempotent, safe, cacheable)
- **POST**: Create new resources or trigger actions (not idempotent)
- **PUT**: Replace entire resource (idempotent)
- **PATCH**: Partial resource updates (not always idempotent)
- **DELETE**: Remove resources (idempotent)

**Idempotency**: GET, PUT, DELETE must be idempotent (same result when called multiple times)

### URL Structure Best Practices

**Resource Naming:**
- Use plural nouns: `/api/users` not `/api/user`
- Use lowercase: `/api/users` not `/api/Users`
- Use hyphens for multi-word names: `/api/user-profiles` not `/api/userProfiles`

**Nested Resources (Shallow Preferred):**
```
# Shallow nesting (preferred) - easy to understand
GET /api/users/{id}/orders

# Deep nesting (avoid) - hard to route and query
GET /api/users/{id}/orders/{orderId}/items/{itemId}/reviews

# Better approach for deep hierarchies:
GET /api/order-items/{id}/reviews
```

## HTTP Status Codes

Use status codes correctly to communicate request outcomes:

### 2xx Success
- `200 OK` - Successful GET, PATCH, PUT
- `201 Created` - Successful POST (include Location header)
- `204 No Content` - Successful DELETE or empty response

### 4xx Client Errors
- `400 Bad Request` - Malformed request syntax
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource doesn't exist
- `409 Conflict` - State conflict (duplicate email, etc.)
- `422 Unprocessable Entity` - Validation errors

### 5xx Server Errors
- `500 Internal Server Error` - Server error
- `503 Service Unavailable` - Temporary downtime

### Rate Limiting
- `429 Too Many Requests` - Rate limit exceeded

## Resource Collection Patterns

### Standard CRUD Operations

```python
# List collections
GET    /api/users?page=1&limit=20
→ 200 OK
→ Returns: [user1, user2, ...]

# Get specific resource
GET    /api/users/{id}
→ 200 OK or 404 Not Found
→ Returns: {id, name, email, ...}

# Create new resource
POST   /api/users
Body:  {"name": "John", "email": "john@example.com"}
→ 201 Created
→ Location: /api/users/123
→ Returns: {id: "123", name: "John", ...}

# Update entire resource
PUT    /api/users/{id}
Body:  {complete user object with ALL fields}
→ 200 OK or 404 Not Found

# Partial update
PATCH  /api/users/{id}
Body:  {"name": "Jane"}  (only changed fields)
→ 200 OK or 404 Not Found

# Delete resource
DELETE /api/users/{id}
→ 204 No Content or 404 Not Found
```

## Pagination Strategies

Always paginate large collections. Three main approaches:

### 1. Offset-Based Pagination

Best for: Small datasets, traditional pagination UI

```python
GET /api/users?page=2&page_size=20

Response:
{
  "items": [...],
  "page": 2,
  "page_size": 20,
  "total": 150,
  "pages": 8,
  "has_next": true,
  "has_prev": true
}
```

### 2. Cursor-Based Pagination

Best for: Large datasets, real-time data, consistent results

```python
GET /api/users?limit=20&cursor=eyJpZCI6MTIzfQ

Response:
{
  "items": [...],
  "next_cursor": "eyJpZCI6MTQzfQ",
  "prev_cursor": "eyJpZCI6MTA3fQ",
  "has_more": true
}
```

### 3. Link Header Pagination

Most RESTful approach using HTTP Link header:

```
GET /api/users?page=2

Response Headers:
Link: <https://api.example.com/users?page=3>; rel="next",
      <https://api.example.com/users?page=1>; rel="prev",
      <https://api.example.com/users?page=1>; rel="first",
      <https://api.example.com/users?page=8>; rel="last"
```

**Implementation pattern (FastAPI):**

```python
from fastapi import FastAPI, Query
from typing import Optional

@app.get("/api/users")
async def list_users(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100)
):
    offset = (page - 1) * page_size
    total = await count_users()
    users = await fetch_users(limit=page_size, offset=offset)

    return {
        "items": users,
        "total": total,
        "page": page,
        "page_size": page_size,
        "pages": (total + page_size - 1) // page_size
    }
```

## Filtering, Sorting, and Searching

### Query Parameters

**Filtering:**
```
GET /api/users?status=active
GET /api/users?role=admin&status=active
```

**Sorting:**
```
GET /api/users?sort=created_at
GET /api/users?sort=-created_at        # descending
GET /api/users?sort=name,created_at    # multiple fields
```

**Searching:**
```
GET /api/users?search=john
GET /api/users?q=john
```

**Field Selection (Sparse Fieldsets):**
```
GET /api/users?fields=id,name,email
```

## Error Response Format

Standardize error responses for consistency:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "value": "not-an-email"
      }
    ],
    "timestamp": "2025-10-16T12:00:00Z",
    "path": "/api/users"
  }
}
```

## API Versioning

Plan for breaking changes from day one:

### URL Versioning (Recommended)

Clear and easy to route:
```
/api/v1/users
/api/v2/users
```

### Header Versioning

Clean URLs but less visible:
```
GET /api/users
Accept: application/vnd.api+json; version=2
```

### Query Parameter Versioning

Easy to test but easy to forget:
```
GET /api/users?version=2
```

## Security Patterns

### Authentication & Authorization

**Bearer Token (JWT):**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

401 Unauthorized - Missing/invalid token
403 Forbidden - Valid token, insufficient permissions
```

**API Keys:**
```
X-API-Key: your-api-key-here
```

### Rate Limiting

Protect APIs from abuse:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 742
X-RateLimit-Reset: 1640000000

Response when limited:
429 Too Many Requests
Retry-After: 3600
```

### CORS Configuration

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://example.com"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["*"],
)
```

## Advanced Patterns

### Idempotency

For non-idempotent operations (POST), use idempotency keys:

```
POST /api/orders
Idempotency-Key: unique-key-123

If duplicate request: → 200 OK (return cached response)
```

### Bulk Operations

```
POST /api/users/batch
{
  "items": [
    {"name": "User1", "email": "user1@example.com"},
    {"name": "User2", "email": "user2@example.com"}
  ]
}

Response:
{
  "results": [
    {"id": "1", "status": "created"},
    {"id": null, "status": "failed", "error": "Email already exists"}
  ]
}
```

### HATEOAS (Hypermedia Links)

Include links for related resources:

```json
{
  "id": "123",
  "name": "John",
  "email": "john@example.com",
  "_links": {
    "self": {"href": "/api/users/123"},
    "orders": {"href": "/api/users/123/orders"},
    "update": {"href": "/api/users/123", "method": "PATCH"},
    "delete": {"href": "/api/users/123", "method": "DELETE"}
  }
}
```

### Caching

**Cache Headers:**
```
# Client caching
Cache-Control: public, max-age=3600

# No caching
Cache-Control: no-cache, no-store, must-revalidate

# Conditional requests
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
If-None-Match: "33a64df551425fcc55e4d42a148795d9f25f89d4"
→ 304 Not Modified
```

## Documentation

### OpenAPI/Swagger

Generate interactive API documentation:

```python
from fastapi import FastAPI, Path

app = FastAPI(
    title="My API",
    description="API for managing users",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

@app.get(
    "/api/users/{user_id}",
    summary="Get user by ID",
    response_description="User details",
    tags=["Users"]
)
async def get_user(
    user_id: str = Path(..., description="The user ID")
):
    """
    Retrieve user by ID.

    Returns full user profile including:
    - Basic information
    - Contact details
    - Account status
    """
    pass
```

## Best Practices Summary

1. **Resource-Oriented**: Use nouns for endpoints, verbs for HTTP methods
2. **Stateless**: Each request contains all necessary information
3. **HTTP Semantics**: Respect GET/POST/PUT/PATCH/DELETE meanings
4. **Status Codes**: Use correct codes (2xx, 4xx, 5xx appropriately)
5. **Pagination**: Always paginate large collections
6. **Versioning**: Plan for breaking changes from day one
7. **Documentation**: Use OpenAPI for interactive docs
8. **Error Handling**: Standardize error response format
9. **Security**: Implement authentication, authorization, rate limiting
10. **Consistency**: Maintain consistent naming and structure

## Common Pitfalls to Avoid

- Using verbs in endpoints: `/api/createUser` (wrong)
- Inconsistent naming: Mixing `/users` and `/user`
- Ignoring HTTP semantics: POST for idempotent operations
- Missing status codes: Not using 201 for creation
- Poor pagination: Returning all results
- No rate limiting: APIs vulnerable to abuse
- Tight coupling: API structure mirrors database schema
- Undocumented APIs: No OpenAPI/documentation

## Cross-Skill References

- **graphql-api-design skill** - For comparison and GraphQL alternatives
- **api-architecture skill** - For versioning strategies, security, and monitoring
- **api-testing skill** - For testing REST endpoints and validation

## Additional Resources

For detailed guidance, see:
- `references/http-methods-guide.md` - Comprehensive HTTP method semantics
- `references/pagination-patterns.md` - Comparison of pagination approaches
- `references/rest-error-handling.md` - Error handling standards
