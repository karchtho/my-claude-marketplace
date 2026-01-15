---
name: dockerfile-generator
description: Generate production-ready Dockerfiles with best practices for various tech stacks. Covers multi-stage builds, optimization, security, and language-specific patterns (Node.js, Python, Go, Rust, Java). Use when creating new application containers.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Dockerfile Generator

Generate optimized, production-ready Dockerfiles for common application stacks with built-in best practices.

## When to Use

- Creating new application containers
- Optimizing existing Dockerfiles
- Multi-stage builds for size reduction
- Language-specific containerization
- Security hardening
- Build performance optimization
- Implementing health checks

## Universal Principles

### Base Image Selection

| Use Case | Base Image | Notes |
|----------|-----------|-------|
| Node.js | `node:20-alpine` | Slim, fast, widely compatible |
| Python | `python:3.11-slim` | Minimal footprint |
| Go | `golang:1.21-alpine` | Compiler included for builds |
| Rust | `rust:latest` | Large but efficient |
| Java | `eclipse-temurin:21-jre-alpine` | JRE only for production |
| General | `debian:bookworm-slim` | Full tooling when needed |

**Rule of thumb:** Use Alpine for production (smaller, faster), Debian/Ubuntu for development (more tools).

## Node.js/TypeScript

### Multi-Stage Production Build

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies (including dev)
RUN npm ci

# Copy source
COPY . .

# Build/compile
RUN npm run build

# Lint and test (optional)
RUN npm run lint && npm run test:unit

# Production stage
FROM node:20-alpine
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Copy built artifacts from builder
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs package*.json ./

# Switch to non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if(r.statusCode!==200) throw new Error(r.statusCode)})"

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

### Development Container

```dockerfile
FROM node:20-alpine

WORKDIR /app

RUN npm install -g nodemon

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["nodemon", "src/server.js"]
```

## Python

### Multi-Stage Build

```dockerfile
# Build stage
FROM python:3.11-slim AS builder
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim
WORKDIR /app

# Create non-root user
RUN useradd -m -u 1001 appuser

# Copy virtual environment
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application
COPY --chown=appuser:appuser . .

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

EXPOSE 8000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]
```

## Go

### Minimal Binary Container

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app

# Install build tools
RUN apk add --no-cache git

# Copy source
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o myapp .

# Production stage (minimal distroless)
FROM gcr.io/distroless/base-debian11

WORKDIR /app

# Copy binary
COPY --from=builder /app/myapp .

EXPOSE 8080

ENTRYPOINT ["./myapp"]
```

### Standard Go Container

```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o app .

# Runtime stage
FROM alpine:3.18
RUN apk add --no-cache ca-certificates
WORKDIR /root/

COPY --from=builder /app/app .

EXPOSE 8080

CMD ["./app"]
```

## Rust

### Release Build

```dockerfile
# Build stage
FROM rust:latest AS builder
WORKDIR /app

COPY . .

RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/myapp /usr/local/bin/

EXPOSE 8080

CMD ["myapp"]
```

## Java

### Spring Boot Application

```dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S appgroup && adduser -S appuser -u 1001 -G appgroup

# Copy JAR
COPY --from=builder /app/target/app.jar .

USER appuser

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
```

## Key Optimization Techniques

### Layer Caching

```dockerfile
# BAD - changes frequently, invalidates cache
COPY . .
RUN npm ci
RUN npm run build

# GOOD - stable layers cached longer
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```

### .dockerignore

```
node_modules/
npm-debug.log
.git/
.gitignore
.env*
.vscode/
dist/
build/
coverage/
.DS_Store
```

### Combine RUN Commands

```dockerfile
# BAD - 3 layers
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# GOOD - 1 layer
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
```

## Security Patterns

### Non-Root User

```dockerfile
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
USER appuser
```

### Read-Only Filesystem

```bash
docker run --read-only -v /tmp:/tmp myapp:latest
```

### Drop Capabilities

```dockerfile
# Dockerfile
USER nobody:nobody

# Or runtime
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp:latest
```

## Health Checks

### HTTP Endpoint

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### Custom Script

```dockerfile
COPY healthcheck.sh .
RUN chmod +x healthcheck.sh
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ./healthcheck.sh
```

### Database Connectivity

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD pg_isready -h localhost -U postgres || exit 1
```

## Build Arguments

```dockerfile
ARG NODE_ENV=production
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.version=$VERSION

ENV NODE_ENV=$NODE_ENV

# Build
RUN npm run build:$NODE_ENV
```

### Build Command

```bash
DOCKER_BUILDKIT=1 docker build \
  --build-arg NODE_ENV=production \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  --build-arg VERSION=1.0.0 \
  -t myapp:1.0.0 \
  .
```

## Common Issues & Solutions

### Issue: Large Image Size

**Solution:** Use multi-stage builds, Alpine base images, and `.dockerignore`

```dockerfile
# Before: 1.2GB
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y python3 pip ...
COPY . .

# After: 120MB
FROM python:3.11-slim AS builder
RUN pip install --user ...
FROM python:3.11-slim
COPY --from=builder ...
```

### Issue: Layer Cache Invalidation

**Solution:** Order commands by change frequency

```dockerfile
# Stable → Frequently changing
COPY package.json .
RUN npm ci
COPY . .
RUN npm run build
```

### Issue: Slow Builds

**Solution:** Enable BuildKit and use layer caching

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with progress output
docker buildx build --progress=plain -t myapp .
```

## Testing Dockerfile

```bash
# Build image
docker build -t myapp:test .

# Run with shell for inspection
docker run -it myapp:test /bin/sh

# Verify file contents
docker run myapp:test ls -la /app

# Check environment
docker run myapp:test env
```

## References

- Official Dockerfile reference: https://docs.docker.com/engine/reference/builder/
- Best practices: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- BuildKit: https://docs.docker.com/build/buildkit/
