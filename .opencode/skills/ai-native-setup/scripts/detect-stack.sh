#!/usr/bin/env bash
# Fallback shell-based stack detector (when Python is not available)
# Usage: ./detect-stack.sh [--json]

PROJECT_ROOT="${1:-.}"
OUTPUT_JSON=false

if [ "$2" = "--json" ] || [ "$1" = "--json" ]; then
  OUTPUT_JSON=true
fi

cd "$PROJECT_ROOT" || exit 1

# Initialize results
PROJECT_TYPE="Unknown"
LANGUAGES=""
FRAMEWORK=""
RUNTIME=""
PACKAGE_MANAGER=""
TEST_FRAMEWORKS=""
CI_CD=""
DATABASE=""
ORM=""
DOCKER="false"
MONOREPO="false"
MONOREPO_TOOL=""

# Detect languages
FILE_COUNTS=$(find . -type f -not -path './node_modules/*' -not -path './.git/*' | awk -F. '{if (NF>1) {ext=tolower($NF); count[ext]++}} END {for (e in count) print count[e], e}' | sort -rn | head -5)

# Detect Node.js
if [ -f "package.json" ]; then
  PROJECT_TYPE="Node.js"
  
  if [ -f "pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
  elif [ -f "yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"
  elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
    PACKAGE_MANAGER="bun"
  elif [ -f "package-lock.json" ]; then
    PACKAGE_MANAGER="npm"
  else
    PACKAGE_MANAGER="npm"
  fi

  # Detect framework from package.json
  if [ -f "package.json" ]; then
    PKG=$(cat package.json | tr '[:upper:]' '[:lower:]')
    for fw in next react vue express fastify koa nest angular svelte; do
      if echo "$PKG" | grep -q "\"$fw\""; then
        FRAMEWORK=$(echo "$fw" | sed 's/.*/\u&/')
        [ "$fw" = "next" ] && FRAMEWORK="Next.js"
        [ "$fw" = "express" ] && FRAMEWORK="Express"
        [ "$fw" = "fastify" ] && FRAMEWORK="Fastify"
        [ "$fw" = "koa" ] && FRAMEWORK="Koa"
        [ "$fw" = "nest" ] && FRAMEWORK="NestJS"
        [ "$fw" = "react" ] && FRAMEWORK="React"
        [ "$fw" = "vue" ] && FRAMEWORK="Vue.js"
        break
      fi
    done
  fi

  # Runtime
  if [ -f ".nvmrc" ]; then
    RUNTIME="Node.js $(cat .nvmrc | tr -d 'v')"
  else
    RUNTIME="Node.js"
  fi

  # Test frameworks
  for tf in jest vitest mocha cypress playwright; do
    if echo "$PKG" | grep -q "\"$tf\""; then
      TEST_FRAMEWORKS="$TEST_FRAMEWORKS, $tf"
    fi
  done
fi

# Detect Python
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "Pipfile" ]; then
  if [ "$PROJECT_TYPE" = "Unknown" ]; then
    PROJECT_TYPE="Python"
  fi

  if [ -f "Pipfile" ]; then
    PACKAGE_MANAGER="pipenv"
  elif [ -f "poetry.lock" ]; then
    PACKAGE_MANAGER="poetry"
  elif [ -f "pyproject.toml" ]; then
    PACKAGE_MANAGER="pip (pyproject)"
  else
    PACKAGE_MANAGER="pip"
  fi

  if [ -f ".python-version" ]; then
    RUNTIME="Python $(cat .python-version)"
  else
    RUNTIME="Python"
  fi
fi

# Detect Go
if [ -f "go.mod" ]; then
  if [ "$PROJECT_TYPE" = "Unknown" ]; then
    PROJECT_TYPE="Go"
  fi
  PACKAGE_MANAGER="go modules"
  RUNTIME="Go"
  
  GO_MOD=$(cat go.mod | tr '[:upper:]' '[:lower:]')
  for fw in gin echo fiber chi; do
    if echo "$GO_MOD" | grep -q "$fw"; then
      FRAMEWORK="$(echo "$fw" | sed 's/.*/\u&/')"
      [ "$fw" = "chi" ] && FRAMEWORK="Chi"
      break
    fi
  done
fi

# Detect Rust
if [ -f "Cargo.toml" ]; then
  if [ "$PROJECT_TYPE" = "Unknown" ]; then
    PROJECT_TYPE="Rust"
  fi
  PACKAGE_MANAGER="cargo"
  RUNTIME="Rust"
fi

# Detect Java
if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  if [ "$PROJECT_TYPE" = "Unknown" ]; then
    PROJECT_TYPE="Java / JVM"
  fi
  
  if [ -f "pom.xml" ]; then
    PACKAGE_MANAGER="Maven"
  elif [ -f "build.gradle.kts" ]; then
    PACKAGE_MANAGER="Gradle (Kotlin DSL)"
  else
    PACKAGE_MANAGER="Gradle"
  fi
  
  RUNTIME="Java / JVM"
fi

# Detect CI/CD
if [ -d ".github/workflows" ]; then
  CI_CD="GitHub Actions"
elif [ -f ".gitlab-ci.yml" ]; then
  CI_CD="GitLab CI"
elif [ -f "azure-pipelines.yml" ]; then
  CI_CD="Azure DevOps"
elif [ -f "Jenkinsfile" ]; then
  CI_CD="Jenkins"
elif [ -f ".circleci/config.yml" ]; then
  CI_CD="CircleCI"
fi

# Detect Docker
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] || [ -f ".dockerignore" ]; then
  DOCKER="true"
fi

# Detect monorepo
if [ -f "turbo.json" ] || [ -f "pnpm-workspace.yaml" ]; then
  MONOREPO="true"
  MONOREPO_TOOL="Turborepo"
  [ -f "pnpm-workspace.yaml" ] && MONOREPO_TOOL="pnpm workspaces"
elif [ -f "nx.json" ]; then
  MONOREPO="true"
  MONOREPO_TOOL="Nx"
elif [ -f "lerna.json" ]; then
  MONOREPO="true"
  MONOREPO_TOOL="Lerna"
fi

# Output
if [ "$OUTPUT_JSON" = true ]; then
  cat <<EOF
{
  "project_type": "$PROJECT_TYPE",
  "languages": [],
  "framework": ${FRAMEWORK:+"$FRAMEWORK"}${FRAMEWORK:-null},
  "runtime": ${RUNTIME:+"$RUNTIME"}${RUNTIME:-null},
  "package_manager": ${PACKAGE_MANAGER:+"$PACKAGE_MANAGER"}${PACKAGE_MANAGER:-null},
  "test_frameworks": [${TEST_FRAMEWORKS:+, }${TEST_FRAMEWORKS:-}],
  "ci_cd": ${CI_CD:+"$CI_CD"}${CI_CD:-null},
  "database": ${DATABASE:+"$DATABASE"}${DATABASE:-null},
  "orm": ${ORM:+"$ORM"}${ORM:-null},
  "docker": $DOCKER,
  "monorepo": $MONOREPO,
  "monorepo_tool": ${MONOREPO_TOOL:+"$MONOREPO_TOOL"}${MONOREPO_TOOL:-null},
  "has_tests": ${TEST_FRAMEWORKS:+true}${TEST_FRAMEWORKS:-false},
  "confidence": "medium"
}
EOF
else
  echo "Project Type: $PROJECT_TYPE"
  echo "Framework: ${FRAMEWORK:-Not detected}"
  echo "Runtime: ${RUNTIME:-Not detected}"
  echo "Package Manager: ${PACKAGE_MANAGER:-Not detected}"
  echo "Test Frameworks: ${TEST_FRAMEWORKS:-Not detected}"
  echo "CI/CD: ${CI_CD:-Not detected}"
  echo "Docker: ${DOCKER}"
  echo "Monorepo: ${MONOREPO} ${MONOREPO_TOOL}"
fi
