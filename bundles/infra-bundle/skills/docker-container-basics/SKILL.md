---
name: docker-container-basics
description: Docker containerization fundamentals. Master container lifecycle, image management, networking, volumes, resource limits, and production deployment patterns. Use when building, running, debugging containers or implementing container orchestration.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
---

# Docker Container Basics

Comprehensive guide to containerization with Docker, from image fundamentals to production deployments.

## When to Use

- Building and running Docker containers
- Understanding Docker networking and volumes
- Debugging container issues
- Resource management and limits
- Container security best practices
- Multi-stage builds for optimization
- Registry operations (push/pull/login)
- Debugging container runtime issues

## Core Concepts

### Container Lifecycle

```bash
# Build image
docker build -t myapp:latest .

# Run container (foreground)
docker run --rm -it myapp:latest

# Run container (background)
docker run -d --name my-container myapp:latest

# View logs
docker logs -f my-container

# Stop/start container
docker stop my-container
docker start my-container

# Remove container
docker rm my-container

# View processes
docker ps -a
```

### Image Management

```bash
# List images
docker images

# Tag image
docker tag myapp:latest myapp:v1.0.0

# Remove image
docker rmi myapp:latest

# Inspect image
docker inspect myapp:latest

# View image layers
docker history myapp:latest
```

## Dockerfile Best Practices

### Structure

```dockerfile
# Use specific version tags (NOT latest)
FROM node:20.11-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Expose port (documentation only)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node healthcheck.js

# Run application
CMD ["node", "server.js"]
```

### Multi-Stage Builds

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm ci --only=production
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Optimization

- Use `.dockerignore` to exclude unnecessary files
- Minimize layer count (combine RUN commands with `&&`)
- Order commands by change frequency (stable → frequently changing)
- Use specific base image versions (not `latest`)
- Leverage layer caching for faster builds

## Networking

### Network Types

```bash
# List networks
docker network ls

# Create custom bridge network
docker network create myapp-net

# Run container on network
docker run -d --network myapp-net --name db postgres:15
docker run -d --network myapp-net --name api myapp:latest

# Container DNS resolution
# Services on same network can reach each other by container name
```

### Port Mapping

```bash
# Map single port
docker run -p 8080:3000 myapp:latest

# Map multiple ports
docker run -p 8080:3000 -p 8443:3000 myapp:latest

# Map to random port
docker run -p 3000 myapp:latest

# View port mappings
docker port my-container
```

## Volumes and Mounts

### Named Volumes

```bash
# Create volume
docker volume create mydata

# Run container with volume
docker run -v mydata:/app/data myapp:latest

# View volume details
docker volume inspect mydata

# Clean up unused volumes
docker volume prune
```

### Bind Mounts

```bash
# Mount host directory into container
docker run -v /host/path:/container/path myapp:latest

# Read-only mount
docker run -v /host/path:/container/path:ro myapp:latest
```

### Tmpfs Mounts

```bash
# Mount temporary filesystem (memory-backed)
docker run --tmpfs /tmp:rw,size=1gb myapp:latest
```

## Resource Limits

### Memory and CPU

```bash
# Limit memory
docker run -m 512m myapp:latest

# Limit CPU (1.0 = 1 core, 0.5 = half core)
docker run --cpus 1.0 myapp:latest

# Memory swap limit
docker run -m 512m --memory-swap 1g myapp:latest

# CPU shares (relative priority)
docker run --cpu-shares 1024 myapp:latest
```

### Viewing Resource Usage

```bash
# Monitor container resources
docker stats

# Specific container
docker stats my-container
```

## Container Debugging

### Execute Commands

```bash
# Execute command in running container
docker exec -it my-container /bin/sh

# Run one-off command
docker exec my-container npm test
```

### Inspect Container

```bash
# View detailed container info
docker inspect my-container

# View environment variables
docker inspect my-container | grep -A 20 "Env"

# View mounted volumes
docker inspect my-container | grep -A 10 "Mounts"
```

### View Logs

```bash
# Tail logs
docker logs -f my-container

# Last 100 lines
docker logs --tail 100 my-container

# With timestamps
docker logs -t my-container

# Since specific time
docker logs --since 2025-01-15T10:00:00 my-container
```

## Security Best Practices

### Non-Root User

```dockerfile
# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Use non-root user
USER appuser
```

### Read-Only Filesystem

```bash
docker run --read-only -v /tmp:/tmp myapp:latest
```

### Capability Dropping

```bash
# Drop unnecessary capabilities
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp:latest
```

### Security Scanning

```bash
# Scan image for vulnerabilities
docker scan myapp:latest

# Build with BuildKit (enables better layer caching and features)
DOCKER_BUILDKIT=1 docker build .
```

## Registry Operations

### Docker Hub

```bash
# Login
docker login

# Tag for registry
docker tag myapp:latest username/myapp:latest

# Push image
docker push username/myapp:latest

# Pull image
docker pull username/myapp:latest

# Logout
docker logout
```

### Private Registry

```bash
# Login to private registry
docker login registry.example.com

# Tag for private registry
docker tag myapp:latest registry.example.com/myapp:latest

# Push to private registry
docker push registry.example.com/myapp:latest
```

## Troubleshooting

### Container Won't Start

```bash
# Check exit code and error logs
docker logs my-container

# View container events
docker events --filter "container=my-container"

# Inspect container config
docker inspect my-container | grep -A 20 "State"
```

### High Resource Usage

```bash
# Monitor in real-time
docker stats

# Identify processes consuming resources
docker top my-container
```

### Network Issues

```bash
# Test DNS resolution
docker exec my-container nslookup db

# Test connectivity
docker exec my-container curl http://db:5432

# View network settings
docker network inspect myapp-net
```

## Production Patterns

### Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

### Signal Handling

```bash
# Applications should handle SIGTERM gracefully
# Docker gives 10 seconds (default) before SIGKILL
docker stop --time 30 my-container
```

### Graceful Shutdown

```bash
# Wait for container to stop (with timeout)
docker stop -t 30 my-container

# Verify container stopped
docker wait my-container
echo $?  # Exit code
```

## Common Patterns

### Development Container

```bash
docker run -it \
  -v $(pwd):/app \
  -p 3000:3000 \
  -e NODE_ENV=development \
  myapp:dev
```

### Production Container

```bash
docker run -d \
  --name myapp \
  --restart unless-stopped \
  -m 1g \
  --cpus 2 \
  -p 3000:3000 \
  -e NODE_ENV=production \
  --health-cmd="curl -f http://localhost:3000/health" \
  --health-interval=30s \
  myapp:latest
```

### Sidecar Pattern

```bash
# Main application
docker run -d --name app myapp:latest

# Sidecar (logging, monitoring, etc)
docker run -d --network container:app --volumes-from app logging-agent:latest
```

## References

- Docker documentation: https://docs.docker.com/
- Best practices: https://docs.docker.com/develop/dev-best-practices/
- Security: https://docs.docker.com/engine/security/
