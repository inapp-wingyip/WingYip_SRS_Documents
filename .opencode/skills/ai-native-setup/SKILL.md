---
name: ai-native-setup
description: Automatically set up AI-Native Spec-Driven Development boilerplate in any existing repository. Detects tech stack, generates AGENTS.md, PROJECT.md, docs/, openspec/ structure, and installs the full skill suite.
license: MIT
compatibility: Any Git repository with OpenCode CLI.
metadata:
  author: ai-native
  version: "1.0"
---

Set up the AI-Native SDD boilerplate in the current repository. This skill will:

1. Detect the project's tech stack, CI/CD, and test frameworks
2. Generate `AGENTS.md` with project-specific invariants
3. Generate `PROJECT.md` auto-filled from detected stack
4. Create the `docs/` structure with all topical files
5. Set up `openspec/` with config, schema, and templates
6. Copy the complete `.opencode/skills/` and `.opencode/commands/` suite

**Usage:** `/ai-native-setup` or `/ai-native-setup --dry-run`

---

## Phase 1: Preflight Checks

Before starting, verify:

1. **Git repository**: `git rev-parse --git-dir` → must succeed
2. **OpenCode CLI**: `opencode --version` or `opencode help` → must succeed
3. **Current directory**: Must be project root (contains `.git/`)

If any check fails, stop and report:
> This skill must be run from a Git repository root with OpenCode installed.

If `AGENTS.md` or `PROJECT.md` already exist:
> AI-Native boilerplate files already detected. Run with `--force` to overwrite, or I'll show you what would be set up.

---

## Phase 2: Tech Stack Detection

Run the detection script:

```bash
# Unix/macOS
python3 .opencode/skills/ai-native-setup/scripts/detect-stack.py --json

# Windows (PowerShell)
# python .opencode/skills/ai-native-setup/scripts/detect-stack.py --json
```

Parse the JSON output to get:
- `project_type`: Node.js / Python / Go / Rust / Java / .NET / Unknown
- `language`: Primary language
- `framework`: Web framework (Express, Django, Gin, etc.)
- `runtime`: Node/Python/Go version
- `package_manager`: npm/pnpm/yarn/poetry/cargo/etc.
- `test_framework`: Jest/Vitest/Pytest/Go test/etc.
- `ci_cd`: GitHub Actions / GitLab CI / Azure DevOps / Jenkins / CircleCI / none
- `database`: PostgreSQL / MongoDB / MySQL / SQLite / none
- `orm`: Prisma / TypeORM / Sequelize / Django ORM / GORM / none
- `docker`: Yes / No
- `monorepo`: Yes / No (Turborepo/Nx/Rush)

---

## Phase 3: Generate AGENTS.md

Create `AGENTS.md` at project root using the template:

**Template location:** `.opencode/skills/ai-native-setup/templates/AGENTS.md.template`

**Auto-customizations based on detection:**
- If **Node.js**: Add note about `package.json` scripts
- If **Python**: Add note about `requirements.txt` / `pyproject.toml`
- If **Go**: Add note about `go.mod`
- If **Java**: Add note about `pom.xml` / `build.gradle`
- If **monorepo**: Add workspace navigation rules
- If **no test framework detected**: Flag as required setup step

**Content:** The full AGENTS.md from the boilerplate with `[PROJECT_NAME]` placeholder replaced by actual project name (from `package.json`, `pyproject.toml`, or directory name).

---

## Phase 4: Generate PROJECT.md

Create `PROJECT.md` at project root using the template:

**Template location:** `.opencode/skills/ai-native-setup/templates/PROJECT.md.template`

**Auto-fill rules:**
- **Section 2 (Tech Stack)**: Fill detected technologies from Phase 2
- **Section 3 (Repository Structure)**: Generate tree based on actual directory layout (stop at depth 3)
- **Section 10 (Build/Run/Test)**: Extract commands from:
  - `package.json` scripts (Node.js)
  - `pyproject.toml` scripts or `Makefile` (Python)
  - `Makefile` or README (Go)
  - `pom.xml` / `build.gradle` (Java)
- **Section 11 (Environment)**: Detect `.env.example`, `docker-compose.yml`, `Dockerfile`

Leave unfilled sections with the template placeholder comments intact.

---

## Phase 5: Create docs/ Structure

Copy all 9 topical documentation files from the boilerplate:

| Source | Destination |
|---|---|
| `docs/workflow/sdd-pipeline.md` | `docs/workflow/sdd-pipeline.md` |
| `docs/workflow/skills-catalog.md` | `docs/workflow/skills-catalog.md` |
| `docs/workflow/openspec-artifacts.md` | `docs/workflow/openspec-artifacts.md` |
| `docs/workflow/acceptance-criteria.md` | `docs/workflow/acceptance-criteria.md` |
| `docs/architecture/microservice-patterns.md` | `docs/architecture/microservice-patterns.md` |
| `docs/architecture/adr-discipline.md` | `docs/architecture/adr-discipline.md` |
| `docs/standards/coding-standards.md` | `docs/standards/coding-standards.md` |
| `docs/agents/reviewer-council.md` | `docs/agents/reviewer-council.md` |
| `docs/agents/guardrails.md` | `docs/agents/guardrails.md` |
| `docs/agents/context-hygiene.md` | `docs/agents/context-hygiene.md` |

Create directories as needed: `docs/workflow/`, `docs/architecture/`, `docs/standards/`, `docs/agents/`, `docs/adr/`, `docs/decomposition/`.

---

## Phase 6: Set up openspec/

Create the OpenSpec structure:

```
openspec/
├── config.yaml              ← from boilerplate
├── schemas/
│   └── spec-driven-verified/
│       ├── schema.yaml
│       ├── README.md
│       └── templates/
│           ├── proposal.md
│           ├── design.md
│           ├── spec.md
│           ├── tasks.md
│           ├── verification.md
│           └── adr.md
└── changes/
    └── .gitkeep
```

---

## Phase 7: Install Skill Suite

Copy the complete `.opencode/skills/` and `.opencode/commands/` from the boilerplate:

**Skills (16):**
- feature-decomposer
- spec-generator
- ba-reviewer, architect-reviewer, qa-reviewer, dev-reviewer
- review-synthesizer
- openspec-onboard, openspec-propose, openspec-explore, openspec-apply-change, openspec-archive-change
- openspec-new-change, openspec-continue-change, openspec-ff-change, openspec-bulk-archive-change, openspec-verify-change, openspec-sync-specs
- technical-design-document, c4-diagram

**Commands (5):**
- opsx-propose.md
- opsx-apply.md
- opsx-archive.md
- opsx-explore.md
- ask.md

---

## Phase 8: Final Report

Display the setup summary:

```
## AI-Native SDD Boilerplate Setup Complete

### Files Created
- AGENTS.md          ← Baseline agent instructions
- PROJECT.md         ← Project context (auto-filled, review recommended)
- docs/              ← 9 topical policy files
- openspec/          ← Schema, templates, change tracking
- .opencode/skills/  ← 16 production skills
- .opencode/commands/ ← 5 slash commands

### Detected Stack
| Layer | Detected |
|---|---|
| Project Type | [detected] |
| Language | [detected] |
| Framework | [detected] |
| Test Framework | [detected] |
| CI/CD | [detected] |

### Next Steps
1. **Review PROJECT.md** — Fill in any remaining `[REQUIRED]` sections
2. **Read AGENTS.md** — Understand the SDD invariants
3. **Try `/opsx-onboard`** — Walk through your first OpenSpec change

### Verification
Run `opencode skills list` to confirm all skills are available.
```

---

## Guardrails

- **Never overwrite existing files** without `--force` flag
- **Preserve existing `.opencode/` content** — merge, don't replace
- **If detection is uncertain** (e.g., multiple package.json files), ask the user to confirm
- **Always create backups** when overwriting: `.backup.YYYY-MM-DD`
- **Dry-run mode**: With `--dry-run`, show all actions without executing them
- **Partial setup allowed**: If any phase fails, report what succeeded and what needs manual attention

---

## Error Handling

| Scenario | Action |
|---|---|
| Not a git repo | Stop, explain requirement |
| No Python 3 | Fallback to shell-based detection (`scripts/detect-stack.sh`) |
| No package.json / go.mod / etc. | Mark as "Unknown / manual fill required" |
| Existing `.opencode/skills/` | Merge — add missing skills, preserve existing |
| Permission denied | Report file path, suggest manual copy |
| Detection script fails | Use template defaults, flag for manual review |
