#!/bin/bash
# detect-project-type.sh - Identify project type and framework
#
# Output: comma-separated list of detected frameworks
# Examples: "Node.js,React", "Python,Django", "Rust"

TYPES=()

# Check for Node.js
if [ -f "package.json" ]; then
  if grep -q '"react"' package.json 2>/dev/null; then
    TYPES+=("React")
  fi
  if grep -q '"@angular' package.json 2>/dev/null; then
    TYPES+=("Angular")
  fi
  if grep -q '"next"' package.json 2>/dev/null; then
    TYPES+=("Next.js")
  fi
  if grep -q '"vue"' package.json 2>/dev/null; then
    TYPES+=("Vue")
  fi
  TYPES+=("Node.js")
fi

# Check for Python
if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
  if [ -f "requirements.txt" ]; then
    if grep -q 'django' requirements.txt 2>/dev/null; then
      TYPES+=("Django")
    elif grep -q 'flask' requirements.txt 2>/dev/null; then
      TYPES+=("Flask")
    elif grep -q 'fastapi' requirements.txt 2>/dev/null; then
      TYPES+=("FastAPI")
    fi
  fi
  TYPES+=("Python")
fi

# Check for Rust
if [ -f "Cargo.toml" ]; then
  TYPES+=("Rust")
fi

# Check for Go
if [ -f "go.mod" ]; then
  TYPES+=("Go")
fi

# Check for Java
if [ -f "pom.xml" ]; then
  TYPES+=("Java/Maven")
elif [ -f "build.gradle" ]; then
  TYPES+=("Java/Gradle")
fi

# Check for Ruby
if [ -f "Gemfile" ]; then
  if grep -q 'rails' Gemfile 2>/dev/null; then
    TYPES+=("Rails")
  fi
  TYPES+=("Ruby")
fi

# Check for Claude Code marketplace
if [ -f ".claude-plugin/marketplace.json" ] && [ -d "bundles" ]; then
  TYPES+=("Claude Plugins Marketplace")
fi

# Remove duplicates and join with comma
if [ ${#TYPES[@]} -eq 0 ]; then
  echo "Unknown"
else
  printf '%s\n' "${TYPES[@]}" | sort -u | paste -sd ',' -
fi
