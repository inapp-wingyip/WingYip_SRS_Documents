#!/usr/bin/env bash
# AI-Native SDD Boilerplate Setup Script
# Usage: ./setup.sh [--dry-run] [--force] [--skip-detection]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BOILERPLATE_ROOT="$(cd "$SKILL_ROOT/../../.." && pwd)"
PROJECT_ROOT="$(pwd)"
DRY_RUN=false
FORCE=false
SKIP_DETECTION=false

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --force) FORCE=true; shift ;;
    --skip-detection) SKIP_DETECTION=true; shift ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
done

if [ "$DRY_RUN" = true ]; then
  log_info "DRY RUN MODE — no files will be modified"
fi

# Preflight checks
log_info "Running preflight checks..."

if [ ! -d "$PROJECT_ROOT/.git" ]; then
  log_error "Not a git repository. Run from project root."
  exit 1
fi

if ! command -v opencode &> /dev/null; then
  log_warn "OpenCode CLI not found in PATH. Skills will be installed but may not be usable until CLI is available."
fi

# Check for existing files
EXISTING_FILES=()
for f in AGENTS.md PROJECT.md; do
  [ -f "$PROJECT_ROOT/$f" ] && EXISTING_FILES+=("$f")
done

if [ ${#EXISTING_FILES[@]} -gt 0 ] && [ "$FORCE" = false ]; then
  log_warn "Existing boilerplate files detected: ${EXISTING_FILES[*]}"
  log_warn "Run with --force to overwrite, or --dry-run to preview."
  exit 1
fi

# Detect tech stack
DETECTION_JSON="{}"
if [ "$SKIP_DETECTION" = false ]; then
  log_info "Detecting tech stack..."
  
  if command -v python3 &> /dev/null && [ -f "$SKILL_ROOT/scripts/detect-stack.py" ]; then
    DETECTION_JSON=$(python3 "$SKILL_ROOT/scripts/detect-stack.py" --json 2>/dev/null || echo "{}")
  elif command -v python &> /dev/null && [ -f "$SKILL_ROOT/scripts/detect-stack.py" ]; then
    DETECTION_JSON=$(python "$SKILL_ROOT/scripts/detect-stack.py" --json 2>/dev/null || echo "{}")
  else
    log_warn "Python not available. Using shell-based fallback detection."
    DETECTION_JSON=$(bash "$SKILL_ROOT/scripts/detect-stack.sh" --json 2>/dev/null || echo "{}")
  fi
  
  log_success "Detection complete"
fi

# Helper: copy file with backup
copy_file() {
  local src="$1"
  local dst="$2"
  
  if [ "$DRY_RUN" = true ]; then
    log_info "Would copy: $src → $dst"
    return
  fi
  
  if [ -f "$dst" ] && [ "$FORCE" = false ]; then
    log_warn "Skipping existing file: $dst"
    return
  fi
  
  if [ -f "$dst" ] && [ "$FORCE" = true ]; then
    local backup="${dst}.backup.$(date +%Y-%m-%d-%H%M%S)"
    cp "$dst" "$backup"
    log_info "Backup created: $backup"
  fi
  
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  log_success "Copied: $dst"
}

# Helper: write file with backup
write_file() {
  local dst="$1"
  local content="$2"
  
  if [ "$DRY_RUN" = true ]; then
    log_info "Would write: $dst"
    return
  fi
  
  if [ -f "$dst" ] && [ "$FORCE" = false ]; then
    log_warn "Skipping existing file: $dst"
    return
  fi
  
  if [ -f "$dst" ] && [ "$FORCE" = true ]; then
    local backup="${dst}.backup.$(date +%Y-%m-%d-%H%M%S)"
    cp "$dst" "$backup"
    log_info "Backup created: $backup"
  fi
  
  mkdir -p "$(dirname "$dst")"
  echo "$content" > "$dst"
  log_success "Written: $dst"
}

# Generate AGENTS.md
log_info "Generating AGENTS.md..."
PROJECT_NAME=$(basename "$PROJECT_ROOT")
AGENTS_CONTENT=$(cat "$SKILL_ROOT/templates/AGENTS.md.template" | sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g")
write_file "$PROJECT_ROOT/AGENTS.md" "$AGENTS_CONTENT"

# Generate PROJECT.md
log_info "Generating PROJECT.md..."
PROJECT_CONTENT=$(cat "$SKILL_ROOT/templates/PROJECT.md.template")
# Basic auto-fill placeholders
PROJECT_CONTENT=$(echo "$PROJECT_CONTENT" | sed "s/\[Project Name\]/$PROJECT_NAME/g")
write_file "$PROJECT_ROOT/PROJECT.md" "$PROJECT_CONTENT"

# Copy docs/
log_info "Setting up docs/..."
for doc_file in \
  docs/workflow/sdd-pipeline.md \
  docs/workflow/skills-catalog.md \
  docs/workflow/openspec-artifacts.md \
  docs/workflow/acceptance-criteria.md \
  docs/architecture/microservice-patterns.md \
  docs/architecture/adr-discipline.md \
  docs/standards/coding-standards.md \
  docs/agents/reviewer-council.md \
  docs/agents/guardrails.md \
  docs/agents/context-hygiene.md; do
  if [ -f "$BOILERPLATE_ROOT/$doc_file" ]; then
    copy_file "$BOILERPLATE_ROOT/$doc_file" "$PROJECT_ROOT/$doc_file"
  else
    log_warn "Boilerplate doc not found: $doc_file"
  fi
done

# Create docs subdirectories
for dir in docs/adr docs/decomposition; do
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$PROJECT_ROOT/$dir"
    [ ! -f "$PROJECT_ROOT/$dir/.gitkeep" ] && touch "$PROJECT_ROOT/$dir/.gitkeep"
  fi
done

# Set up openspec/
log_info "Setting up openspec/..."
for spec_file in \
  openspec/config.yaml \
  openspec/schemas/spec-driven-verified/schema.yaml \
  openspec/schemas/spec-driven-verified/README.md \
  openspec/schemas/spec-driven-verified/templates/proposal.md \
  openspec/schemas/spec-driven-verified/templates/design.md \
  openspec/schemas/spec-driven-verified/templates/spec.md \
  openspec/schemas/spec-driven-verified/templates/tasks.md \
  openspec/schemas/spec-driven-verified/templates/verification.md \
  openspec/schemas/spec-driven-verified/templates/adr.md; do
  if [ -f "$BOILERPLATE_ROOT/$spec_file" ]; then
    copy_file "$BOILERPLATE_ROOT/$spec_file" "$PROJECT_ROOT/$spec_file"
  else
    log_warn "Boilerplate spec file not found: $spec_file"
  fi
done

if [ "$DRY_RUN" = false ]; then
  mkdir -p "$PROJECT_ROOT/openspec/changes"
  [ ! -f "$PROJECT_ROOT/openspec/changes/.gitkeep" ] && touch "$PROJECT_ROOT/openspec/changes/.gitkeep"
fi

# Copy skills and commands
log_info "Installing skill suite..."

# Merge strategy: copy boilerplate skills, preserve existing
for skill_dir in "$BOILERPLATE_ROOT/.opencode/skills"/*; do
  if [ -d "$skill_dir" ]; then
    skill_name=$(basename "$skill_dir")
    dest_dir="$PROJECT_ROOT/.opencode/skills/$skill_name"
    
    if [ -d "$dest_dir" ] && [ "$FORCE" = false ]; then
      log_warn "Skill already exists: $skill_name (use --force to overwrite)"
      continue
    fi
    
    if [ "$DRY_RUN" = true ]; then
      log_info "Would install skill: $skill_name"
    else
      mkdir -p "$dest_dir"
      cp -r "$skill_dir"/* "$dest_dir/"
      log_success "Installed skill: $skill_name"
    fi
  fi
done

# Copy commands
for cmd_file in "$BOILERPLATE_ROOT/.opencode/commands"/*.md; do
  if [ -f "$cmd_file" ]; then
    cmd_name=$(basename "$cmd_file")
    dest_file="$PROJECT_ROOT/.opencode/commands/$cmd_name"
    
    if [ -f "$dest_file" ] && [ "$FORCE" = false ]; then
      log_warn "Command already exists: $cmd_name"
      continue
    fi
    
    copy_file "$cmd_file" "$dest_file"
  fi
done

# Final report
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  AI-Native SDD Setup Complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Files created/modified:"
echo "  - AGENTS.md"
echo "  - PROJECT.md"
echo "  - docs/ (9 policy files)"
echo "  - openspec/ (config, schema, templates)"
echo "  - .opencode/skills/ (16 skills)"
echo "  - .opencode/commands/ (5 commands)"
echo ""
echo "Next steps:"
echo "  1. Review PROJECT.md and fill in any remaining [REQUIRED] sections"
echo "  2. Read AGENTS.md to understand the SDD invariants"
echo "  3. Run 'opencode skills list' to verify installation"
echo "  4. Try '/opsx-onboard' for your first OpenSpec change"
echo ""

if [ "$DRY_RUN" = true ]; then
  log_warn "This was a DRY RUN. No files were modified."
  log_info "Run without --dry-run to apply changes."
fi
