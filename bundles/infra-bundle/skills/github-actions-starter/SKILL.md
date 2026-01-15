---
name: github-actions-starter
description: Automate CI/CD pipelines with GitHub Actions. Master workflow syntax, event triggers, jobs, steps, environment variables, secrets, artifacts, matrix builds, and deployment patterns. Use when setting up automated testing, building, and deployment workflows.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# GitHub Actions Starter

Build robust CI/CD pipelines with GitHub Actions for automated testing, building, and deployment.

## When to Use

- Automated testing on push/pull request
- Building and publishing Docker images
- Deploying to production
- Running linters and security scans
- Publishing releases
- Scheduled tasks and backups
- Multi-environment deployments

## Workflow Structure

GitHub Actions workflows are YAML files in `.github/workflows/` directory.

### Basic Workflow

```yaml
# .github/workflows/test.yml
name: Tests

# Trigger conditions
on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main

# Jobs
jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      # Checkout code
      - uses: actions/checkout@v4

      # Setup Node.js
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      # Install dependencies
      - run: npm ci

      # Run tests
      - run: npm test
```

## Triggers (on:)

### Push Events

```yaml
on:
  push:
    branches:
      - main
      - develop
    paths:
      - 'src/**'
      - 'package.json'
    tags:
      - 'v*'
```

### Pull Request Events

```yaml
on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize
      - reopened
```

### Scheduled Events

```yaml
on:
  schedule:
    # Run daily at 2 AM UTC
    - cron: '0 2 * * *'
    # Run weekly on Monday at 9 AM UTC
    - cron: '0 9 * * MON'
```

### Manual Dispatch

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options:
          - staging
          - production
      version:
        description: 'Version to deploy'
        required: true
```

### Release Events

```yaml
on:
  release:
    types:
      - created
      - published
      - edited
```

## Jobs

### Basic Job

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    name: Run Tests

    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

### Job with Environment Variables

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    env:
      NODE_ENV: test
      LOG_LEVEL: debug

    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

### Multiple Jobs (Sequential)

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint  # Wait for lint to complete
    steps:
      - uses: actions/checkout@v4
      - run: npm test

  build:
    runs-on: ubuntu-latest
    needs: test  # Wait for test to complete
    steps:
      - uses: actions/checkout@v4
      - run: npm run build
```

## Runners

### Standard Runners

| Runner | OS | Specs |
|--------|-------|-------|
| `ubuntu-latest` | Ubuntu 22.04 | 2 vCPU, 7 GB RAM |
| `ubuntu-20.04` | Ubuntu 20.04 | 2 vCPU, 7 GB RAM |
| `windows-latest` | Windows Server 2022 | 2 vCPU, 7 GB RAM |
| `macos-latest` | macOS 12.x | 3 vCPU, 14 GB RAM |

### Self-Hosted Runners

```yaml
jobs:
  deploy:
    runs-on: [self-hosted, linux, x64]
```

## Steps

### Run Shell Commands

```yaml
steps:
  # Default shell (bash on Linux/Mac, PowerShell on Windows)
  - run: npm test

  # Specific shell
  - shell: bash
    run: npm test

  # Multi-line commands
  - run: |
      npm run lint
      npm run test
      npm run build
```

### Use Actions

```yaml
steps:
  # Official actions
  - uses: actions/checkout@v4
  - uses: actions/setup-node@v4
    with:
      node-version: '20'

  # Community actions
  - uses: docker/setup-qemu-action@v3
  - uses: docker/build-push-action@v5
```

### Conditional Steps

```yaml
steps:
  - uses: actions/checkout@v4
  - run: npm test
    if: github.event_name == 'pull_request'

  - run: npm run deploy
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'

  - run: echo "PR from fork"
    if: github.event.pull_request.head.repo.full_name != github.repository
```

## Secrets

### Using Secrets

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          curl -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
               https://api.github.com/repos/${{ github.repository }}
```

### Environment Secrets

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v4
      - run: deploy.sh
        env:
          API_KEY: ${{ secrets.PROD_API_KEY }}
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
```

### Encrypted Secrets

```bash
# Create secret via GitHub CLI
gh secret set MY_SECRET --body "secret-value"

# Use in workflow
env:
  MY_VAR: ${{ secrets.MY_SECRET }}
```

## Artifacts

### Upload Artifacts

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
          retention-days: 5
```

### Download Artifacts

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
      - uses: actions/checkout@v4
      - id: version
        run: echo "version=$(npm pkg get version | tr -d '"')" >> $GITHUB_OUTPUT

  deploy:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      - run: npm run deploy
```

## Matrix Builds

### Multi-Version Testing

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
        os: [ubuntu-latest, ubuntu-20.04]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test
```

### Matrix with Exclude

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    node-version: [18, 20, 22]
    exclude:
      - os: windows-latest
        node-version: 18  # Skip Windows with Node 18
```

## Common Workflows

### Node.js Testing

```yaml
name: Node.js Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - run: npm ci

      - run: npm run lint

      - run: npm test

      - run: npm run build
```

### Docker Build & Push

```yaml
name: Docker Build & Push

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache
          cache-to: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache,mode=max
```

### Deploy to Production

```yaml
name: Deploy to Production

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to deploy'
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    concurrency: production

    steps:
      - uses: actions/checkout@v4
        with:
          ref: v${{ github.event.inputs.version }}

      - name: Deploy
        run: |
          curl -X POST https://api.example.com/deploy \
            -H "Authorization: Bearer ${{ secrets.DEPLOY_TOKEN }}" \
            -d '{"version":"${{ github.event.inputs.version }}"}'

      - name: Verify Deployment
        run: |
          for i in {1..30}; do
            if curl -f https://api.example.com/health | grep -q "healthy"; then
              echo "Deployment successful"
              exit 0
            fi
            sleep 10
          done
          echo "Deployment failed"
          exit 1
```

### Pull Request Quality Checks

```yaml
name: PR Quality Checks

on:
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## Context Variables

### Common Variables

```yaml
${{ github.repository }}        # owner/repo
${{ github.ref }}                # refs/heads/main
${{ github.ref_name }}           # main
${{ github.sha }}                # Full commit SHA
${{ github.actor }}              # Username triggering workflow
${{ github.event_name }}         # push, pull_request, etc.
${{ github.run_id }}             # Unique run ID
${{ github.run_number }}         # Sequential run number
```

### Pull Request Context

```yaml
${{ github.event.pull_request.number }}      # PR number
${{ github.event.pull_request.title }}       # PR title
${{ github.event.pull_request.head.sha }}    # PR head commit
${{ github.event.pull_request.base.sha }}    # PR base commit
```

## Status Checks

### Mark as Required

1. Go to repository Settings
2. Branches → Branch protection rules
3. Add rule for `main` branch
4. Check "Require status checks to pass"
5. Select workflow jobs to require

## Debugging

### Enable Debug Logging

```yaml
env:
  RUNNER_DEBUG: 1
  ACTIONS_STEP_DEBUG: true
```

### View Logs

1. Go to Actions tab
2. Select workflow run
3. Click job name
4. View detailed logs

## Best Practices

- Cache dependencies for faster builds
- Run security scans on every PR
- Use GitHub's CODEOWNERS for required reviews
- Set concurrency limits for deploy jobs
- Use environments for secret separation
- Always pin action versions
- Test workflows locally with `act`
- Use matrix builds for multi-version testing

## References

- GitHub Actions documentation: https://docs.github.com/en/actions
- Workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- Action marketplace: https://github.com/marketplace?type=actions
