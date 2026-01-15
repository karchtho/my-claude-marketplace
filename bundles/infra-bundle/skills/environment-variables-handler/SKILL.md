---
name: environment-variables-handler
description: Manage environment variables and configuration across development, staging, and production. Master .env files, secret management, configuration validation, and multi-environment strategies. Use when setting up configuration systems, managing secrets, or deploying to different environments.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Environment Variables Handler

Master configuration management and environment variable handling across development, staging, and production environments.

## When to Use

- Setting up development environments
- Managing secrets and API keys
- Configuring multi-environment deployments
- Docker and container configuration
- CI/CD pipeline environment setup
- Configuration validation
- Database connection management

## Principles

1. **Never commit secrets** - Use .env files (git-ignored)
2. **Separate by environment** - dev, staging, production configs
3. **Validate on startup** - Fail fast if required vars missing
4. **Document requirements** - .env.example for reference
5. **Rotate credentials** - Regular secret updates
6. **Use strong secrets** - 32+ character random strings

## .env File Format

### Basic .env

```bash
# Application
NODE_ENV=development
LOG_LEVEL=debug
PORT=3000
APP_URL=http://localhost:3000

# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=myapp_dev
DATABASE_USER=postgres
DATABASE_PASSWORD=password123

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# API Keys
JWT_SECRET=your-secret-key-here
STRIPE_API_KEY=sk_test_xxx
SENDGRID_API_KEY=SG.xxx

# Email
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_FROM=noreply@example.com
```

### .env.example (Git-safe reference)

```bash
# Application
NODE_ENV=
LOG_LEVEL=
PORT=
APP_URL=

# Database
DATABASE_HOST=
DATABASE_PORT=
DATABASE_NAME=
DATABASE_USER=
DATABASE_PASSWORD=

# Redis
REDIS_HOST=
REDIS_PORT=
REDIS_PASSWORD=

# API Keys
JWT_SECRET=
STRIPE_API_KEY=
SENDGRID_API_KEY=

# Email
MAIL_HOST=
MAIL_PORT=
MAIL_FROM=
```

### .gitignore

```bash
# Environment variables
.env
.env.local
.env.*.local
.env.production.local

# Secrets
*.key
*.pem
secrets/

# Never commit sensitive files
credentials.json
config/secrets.yml
```

## Environment-Specific Files

### Structure

```
.env                    # Defaults (usually ignored)
.env.example           # Template (committed)
.env.development       # Dev overrides (git-ignored)
.env.test             # Test overrides (git-ignored)
.env.staging          # Staging config (git-ignored)
.env.production        # Production config (git-ignored)
```

### Loading Priority

```javascript
// Typical loading order (highest to lowest priority)
1. .env.${NODE_ENV}.local    // Machine-specific prod override
2. .env.${NODE_ENV}           // Environment config
3. .env.local                 // Machine-specific override
4. .env                        // Default
5. Environment variables      // System environment
```

## Node.js Implementation

### Using dotenv

```bash
npm install dotenv
```

```javascript
// index.js - Load at startup
require('dotenv').config({
  path: `.env.${process.env.NODE_ENV || 'development'}`
});

const express = require('express');
const app = express();

// Environment variables now available
const PORT = process.env.PORT || 3000;
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Validation

```javascript
// config.js - Validate and export config
require('dotenv').config();

const requiredVars = [
  'DATABASE_HOST',
  'DATABASE_USER',
  'DATABASE_PASSWORD',
  'JWT_SECRET',
  'STRIPE_API_KEY'
];

const missingVars = requiredVars.filter(
  (varName) => !process.env[varName]
);

if (missingVars.length > 0) {
  throw new Error(
    `Missing required environment variables: ${missingVars.join(', ')}`
  );
}

module.exports = {
  app: {
    env: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT, 10) || 3000,
    logLevel: process.env.LOG_LEVEL || 'info',
  },
  database: {
    host: process.env.DATABASE_HOST,
    port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
    database: process.env.DATABASE_NAME,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
  },
  redis: {
    host: process.env.REDIS_HOST,
    port: parseInt(process.env.REDIS_PORT, 10) || 6379,
    password: process.env.REDIS_PASSWORD || undefined,
  },
  api: {
    jwtSecret: process.env.JWT_SECRET,
    stripeKey: process.env.STRIPE_API_KEY,
    sendgridKey: process.env.SENDGRID_API_KEY,
  },
};
```

## Python Implementation

### Using python-dotenv

```bash
pip install python-dotenv
```

```python
# config.py
from os import getenv
from dotenv import load_dotenv

# Load environment-specific .env file
env = getenv('FLASK_ENV', 'development')
load_dotenv(f'.env.{env}')
load_dotenv('.env')  # Fallback

# Configuration class
class Config:
    # Database
    DATABASE_URL = getenv('DATABASE_URL')
    DATABASE_ECHO = getenv('DATABASE_ECHO', 'false').lower() == 'true'

    # Redis
    REDIS_URL = getenv('REDIS_URL', 'redis://localhost:6379/0')

    # API
    JWT_SECRET = getenv('JWT_SECRET')
    STRIPE_API_KEY = getenv('STRIPE_API_KEY')

    @classmethod
    def validate(cls):
        """Validate required configuration"""
        required = ['JWT_SECRET', 'DATABASE_URL']
        missing = [key for key in required if not getenv(key)]

        if missing:
            raise ValueError(f"Missing required environment variables: {missing}")

# app.py
from config import Config

Config.validate()
app.config.from_object(Config)
```

## Go Implementation

### Using godotenv

```bash
go get github.com/joho/godotenv
```

```go
package main

import (
    "log"
    "os"

    "github.com/joho/godotenv"
)

type Config struct {
    DatabaseURL string
    JWTSecret   string
    Port        string
}

func LoadConfig() *Config {
    // Load environment-specific .env
    env := os.Getenv("GO_ENV")
    if env == "" {
        env = "development"
    }

    _ = godotenv.Load(".env." + env)
    _ = godotenv.Load() // Fallback

    return &Config{
        DatabaseURL: getEnv("DATABASE_URL", ""),
        JWTSecret:   getEnv("JWT_SECRET", ""),
        Port:        getEnv("PORT", "8080"),
    }
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func main() {
    config := LoadConfig()
    if config.JWTSecret == "" {
        log.Fatal("JWT_SECRET not set")
    }

    // Use config
    log.Printf("Starting server on port %s", config.Port)
}
```

## Docker/Docker Compose

### Dockerfile

```dockerfile
# Set default, override with --build-arg or -e
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

# Use build args in RUN commands
RUN if [ "$NODE_ENV" = "development" ]; then npm install; else npm ci --only=production; fi
```

### docker-compose.yml

```yaml
version: '3.14'

services:
  api:
    build:
      context: .
      args:
        - NODE_ENV=development
    environment:
      - NODE_ENV=development
      - DATABASE_HOST=postgres
      - REDIS_HOST=redis
    env_file:
      - .env
      - .env.development
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=${DATABASE_NAME}
      - POSTGRES_USER=${DATABASE_USER}
      - POSTGRES_PASSWORD=${DATABASE_PASSWORD}
```

## Kubernetes

### Secrets

```yaml
# Create secret from file
kubectl create secret generic app-secrets \
  --from-env-file=.env.production \
  -n production

# Create secret from literal values
kubectl create secret generic app-secrets \
  --from-literal=JWT_SECRET=your-secret \
  --from-literal=STRIPE_API_KEY=sk_live_xxx \
  -n production
```

### Secret References in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
    - name: api
      image: myapp:latest
      env:
        - name: NODE_ENV
          value: "production"

        # Single secret key
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: JWT_SECRET

        # All secrets as environment variables
      envFrom:
        - secretRef:
            name: app-secrets
```

## CI/CD Integration

### GitHub Actions

```yaml
# Secrets stored in repository settings
# Access via ${{ secrets.SECRET_NAME }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - run: |
          cat > .env << EOF
          DATABASE_URL=${{ secrets.DATABASE_URL }}
          JWT_SECRET=${{ secrets.JWT_SECRET }}
          STRIPE_API_KEY=${{ secrets.STRIPE_API_KEY }}
          EOF
      - run: npm run deploy
```

### GitLab CI

```yaml
deploy:
  stage: deploy
  environment: production
  script:
    - export DATABASE_URL=$DATABASE_URL
    - export JWT_SECRET=$JWT_SECRET
    - npm run deploy
```

## Secret Management Best Practices

### Local Development

```bash
# 1. Copy template
cp .env.example .env

# 2. Fill in local values
nano .env

# 3. Ensure it's ignored
grep ".env" .gitignore

# 4. Share secrets securely
# Use password manager or team secret store
```

### Production

```bash
# 1. Use managed secret storage
# - AWS Secrets Manager
# - HashiCorp Vault
# - Azure Key Vault
# - Kubernetes Secrets

# 2. Rotate regularly
# - Monthly or after team changes
# - Immediately if compromised

# 3. Audit access
# - Log who accesses secrets
# - Alert on unusual access patterns

# 4. Least privilege
# - Give only required secrets
# - Use IAM roles instead of long-lived keys
```

## Validation Patterns

### Startup Validation

```javascript
function validateConfig() {
  const required = {
    'DATABASE_URL': 'Database connection string',
    'JWT_SECRET': 'JWT signing key',
    'STRIPE_API_KEY': 'Stripe API key'
  };

  const errors = [];

  for (const [key, description] of Object.entries(required)) {
    if (!process.env[key]) {
      errors.push(`${key}: ${description}`);
    }
  }

  if (errors.length > 0) {
    console.error('Missing required environment variables:');
    errors.forEach(err => console.error(`  - ${err}`));
    process.exit(1);
  }
}

// Call before starting app
validateConfig();
```

### Type Validation

```javascript
function validateAndParse() {
  const config = {
    port: parseInt(process.env.PORT, 10),
    logLevel: process.env.LOG_LEVEL,
    enableDebug: process.env.DEBUG === 'true',
    maxConnections: parseInt(process.env.MAX_CONNECTIONS || '100', 10),
  };

  if (isNaN(config.port)) {
    throw new Error('PORT must be a valid number');
  }

  if (!['debug', 'info', 'warn', 'error'].includes(config.logLevel)) {
    throw new Error(`Invalid LOG_LEVEL: ${config.logLevel}`);
  }

  return config;
}
```

## Common Issues & Solutions

### Issue: "Cannot find module 'dotenv'"

**Solution:** Install the package
```bash
npm install dotenv
```

### Issue: Variables work in development but not production

**Solution:** Ensure .env file is loaded before imports
```javascript
// MUST be first line
require('dotenv').config();

// Then import everything else
const express = require('express');
```

### Issue: Secrets leaked in logs

**Solution:** Sanitize logs
```javascript
function sanitizeLog(obj) {
  const secrets = ['PASSWORD', 'SECRET', 'KEY', 'TOKEN'];
  const sanitized = { ...obj };

  for (const key in sanitized) {
    if (secrets.some(s => key.toUpperCase().includes(s))) {
      sanitized[key] = '***REDACTED***';
    }
  }

  return sanitized;
}
```

## References

- dotenv documentation: https://github.com/motdotla/dotenv
- 12-Factor App: https://12factor.net/config
- OWASP secrets management: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
