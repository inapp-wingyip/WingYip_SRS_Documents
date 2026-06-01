# WingYip AI-Native Cross-Platform Development Setup

> **Canonical reference**: This document defines the cross-platform AI-native development configuration for all WingYip repositories. It ensures consistent AI agent behavior across **OpenCode**, **Claude Code**, **Cursor**, and **GitHub Copilot**.
>
> **Status**: Implementation Plan (Pending User Confirmation)

---

## Table of Contents

1. [Current State Audit](#1-current-state-audit)
2. [Target State Architecture](#2-target-state-architecture)
3. [Gap Analysis](#3-gap-analysis)
4. [Implementation Plan](#4-implementation-plan)
5. [Shared Template Specifications](#5-shared-template-specifications)
6. [Per-Repo Rollout Matrix](#6-per-repo-rollout-matrix)
7. [Best Practices & Constraints](#7-best-practices--constraints)
8. [Quick Start Checklist](#8-quick-start-checklist)

---

## 1. Current State Audit

### 1.1 Repository Inventory

| Repo | OpenCode (`.opencode/`) | Claude (`.claude/`) | Cursor (`.cursor/`) | Copilot (`.github/copilot-instructions.md`) |
|---|---|---|---|---|
| **BE_EcoSystem** | ✅ 21 skills + 12 commands | ❌ Missing | ⚠️ Stray `.cursor/plans/` only | ❌ |
| **FE_EcoSystem** | ✅ 21 skills + 12 commands | ✅ 10 skills + 11 commands | ❌ | ❌ |
| **HH_EcoSystem** | ✅ 21 skills + 12 commands | ❌ Missing | ❌ | ✅ (1 file exists) |
| **DE_EcoSystem** | ✅ 21 skills + 12 commands | ❌ Missing | ❌ | ❌ |
| **Infrastructure** | ✅ 21 skills + 12 commands | ✅ 10 skills + 11 commands | ❌ | ❌ |
| **UI_EcoSystem** | ✅ 21 skills + 12 commands | ✅ 10 skills + 11 commands | ❌ | ❌ |
| **Artifacts** | ❌ | ❌ | ❌ | ❌ |
| **Legacy** | ❌ (read-only) | ❌ (read-only) | ❌ (read-only) | ❌ (read-only) |

### 1.2 Existing AI-Native Infrastructure

All active service repos (except Artifacts/Legacy) share:

- `PROJECT.md` — Project context
- `.ai-native/manifest.json` — Installer manifest
- `.openspec/config.yaml` — OpenSpec configuration
- `AGENTS.md` — Router + conflict resolution
- `README.md` — Getting started

The **installer** (`install.ps1`) currently bootstraps only **OpenCode + Claude**.

### 1.3 Missing Components

| Component | Rationale |
|---|---|
| **Cursor rules** (`.cursor/rules/*.mdc`) | Deprecated `.cursorrules` in favor of MDC files with YAML frontmatter |
| **Cursor commands** (`.cursor/commands/*.md`) | Slash commands for SDD workflows |
| **Copilot instructions** (`.github/copilot-instructions.md`) | Only present in HH_EcoSystem |
| **Copilot path-specific rules** (`.github/instructions/*.md`) | Per-tech-stack enforcement |
| **Copilot custom agents** (`.github/agents/*.md`) | Role-based review agents |
| **Copilot reusable prompts** (`.github/prompts/*.md`) | Reusable AC verification prompts |
| **VS Code settings** (`.vscode/settings.json`) | Enable prompt files + monorepo discovery |
| **Claude in BE/HH/DE** | Gap identified — only FE/Infrastructure/UI have it |

---

## 2. Target State Architecture

### 2.1 Shared Source of Truth (in `WingYip_SRS_Documents/`)

```
WingYip_SRS_Documents/
├── AI_Native/
│   ├── setup/                          ← NEW: Cross-platform setup docs
│   │   ├── cross-platform-setup.md     ← THIS FILE (master plan)
│   │   ├── cursor-setup.md             ← Cursor-specific guide
│   │   ├── copilot-setup.md            ← Copilot-specific guide
│   │   └── vscode-workspace.md         ← VS Code monorepo settings
│   ├── templates/                      ← NEW: Shared canonical templates
│   │   ├── cursor/
│   │   │   ├── rules/
│   │   │   │   ├── sdd-invariants.mdc
│   │   │   │   ├── backend-conventions.mdc
│   │   │   │   ├── frontend-conventions.mdc
│   │   │   │   ├── mobile-conventions.mdc
│   │   │   │   ├── devops-conventions.mdc
│   │   │   │   └── data-engineering-conventions.mdc
│   │   │   └── commands/
│   │   │       ├── generate-spec.md
│   │   │       ├── verify-ac.md
│   │   │       └── review-code.md
│   │   ├── copilot/
│   │   │   ├── copilot-instructions.md
│   │   │   ├── instructions/
│   │   │   │   ├── backend.instructions.md
│   │   │   │   ├── frontend.instructions.md
│   │   │   │   ├── mobile.instructions.md
│   │   │   │   ├── devops.instructions.md
│   │   │   │   └── data-engineering.instructions.md
│   │   │   ├── agents/
│   │   │   │   ├── spec-reviewer.agent.md
│   │   │   │   ├── backend-reviewer.agent.md
│   │   │   │   ├── frontend-reviewer.agent.md
│   │   │   │   └── security-reviewer.agent.md
│   │   │   └── prompts/
│   │   │       ├── verify-ac.prompt.md
│   │   │       ├── generate-tests.prompt.md
│   │   │       └── implement-from-spec.prompt.md
│   │   └── vscode/
│   │       └── settings.json
│   └── workflow/                       ← EXISTING: SDD pipeline docs
```

### 2.2 Per-Repo Structure (after rollout)

Every service repo will contain:

```
<repo-root>/
├── .opencode/                          ← OpenCode (existing)
│   ├── skills/
│   └── commands/
├── .claude/                            ← Claude Code (existing or new)
│   ├── skills/
│   ├── commands/
│   └── CLAUDE.md
├── .cursor/                            ← Cursor (new)
│   ├── rules/
│   │   ├── 00-sdd-invariants.mdc       ← symlink/copy from templates
│   │   ├── 10-stack-conventions.mdc    ← stack-specific
│   │   └── 20-security-checklist.mdc
│   └── commands/
│       ├── generate-spec.md
│       ├── verify-ac.md
│       └── review-code.md
├── .github/
│   ├── copilot-instructions.md         ← Copilot (new)
│   ├── instructions/                   ← Path-specific rules (new)
│   │   └── <stack>.instructions.md
│   ├── agents/                         ← Custom agents (new)
│   │   └── <role>.agent.md
│   └── prompts/                        ← Reusable prompts (new)
│       └── <task>.prompt.md
├── .vscode/
│   └── settings.json                   ← VS Code workspace settings (new)
├── AGENTS.md                           ← Universal router (existing)
├── PROJECT.md                          ← Project context (existing)
└── .ai-native/
    └── manifest.json                   ← Updated with all platforms
```

### 2.3 Cross-Platform Consistency Strategy

| Platform | Config File(s) | How It References Shared Docs |
|---|---|---|
| **OpenCode** | `.opencode/skills/*.md`, `.opencode/commands/*.md` | Skills reference `../WingYip_SRS_Documents/AI_Native/workflow/` |
| **Claude Code** | `.claude/skills/*.md`, `.claude/commands/*.md`, `CLAUDE.md` | `CLAUDE.md` references shared docs via relative paths |
| **Cursor** | `.cursor/rules/*.mdc`, `.cursor/commands/*.md` | MDC files use `globs` to match stack, content references shared docs |
| **Copilot** | `.github/copilot-instructions.md`, `.github/instructions/*.md` | Instructions use `#file:` tokens and relative markdown links |
| **VS Code** | `.vscode/settings.json` | Settings enable cross-repo discovery |

**Key principle**: Platform-specific files are thin wrappers that reference the canonical documentation in `WingYip_SRS_Documents/`. No duplication of policy text.

---

## 3. Gap Analysis

### 3.1 Critical Gaps (P0 — Blocks AI-native workflow)

| Gap | Impact | Repos Affected |
|---|---|---|
| No Cursor rules | Cursor IDE users lack SDD enforcement | ALL 9 repos |
| No Copilot instructions | Copilot Chat/Agent mode unaware of specs | 8 of 9 repos (only HH has it) |
| Missing Claude in BE/HH/DE | Claude Code users lack tooling | 3 repos |
| No VS Code settings | Prompt files, agent mode, monorepo discovery disabled | ALL 9 repos |

### 3.2 High Gaps (P1 — Degrades experience)

| Gap | Impact | Repos Affected |
|---|---|---|
| No path-specific Copilot rules | Copilot generates wrong patterns per file type | ALL 9 repos |
| No custom Copilot agents | Can't run automated spec review | ALL 9 repos |
| No reusable prompts | Repetitive manual prompting for AC verification | ALL 9 repos |
| No Cursor commands | No slash-command workflow for SDD tasks | ALL 9 repos |

### 3.3 Medium Gaps (P2 — Nice to have)

| Gap | Impact |
|---|---|
| Installer doesn't support selective platform install | Forces all-or-nothing bootstrap |
| No drift detection between platform configs | Configs can diverge over time |
| No documentation for AI-native setup | New team members lack onboarding guide |

---

## 4. Implementation Plan

### Phase 1: Shared Templates (Single source of truth)

**Goal**: Create canonical templates in `WingYip_SRS_Documents/AI_Native/templates/`.

| Task | File(s) | Description |
|---|---|---|
| 1.1 | `templates/cursor/rules/*.mdc` | Stack-agnostic + stack-specific Cursor rules |
| 1.2 | `templates/cursor/commands/*.md` | SDD slash commands for Cursor |
| 1.3 | `templates/copilot/copilot-instructions.md` | Master repo-level instructions |
| 1.4 | `templates/copilot/instructions/*.md` | Path-specific rules per stack |
| 1.5 | `templates/copilot/agents/*.md` | Custom agent definitions |
| 1.6 | `templates/copilot/prompts/*.md` | Reusable prompt templates |
| 1.7 | `templates/vscode/settings.json` | Monorepo-optimized VS Code settings |

**Acceptance criteria**:
- All templates reference canonical docs via relative paths (no duplication)
- Templates are under 500 lines each (per Cursor best practices)
- YAML frontmatter is valid for MDC and agent files

### Phase 2: Per-Repo Rollout

**Goal**: Deploy platform-specific configs to all 9 active service repos.

| Repo | Stack | Files to Create |
|---|---|---|
| BE_EcoSystem | .NET/C# | `.cursor/rules/`, `.cursor/commands/`, `.github/copilot-instructions.md`, `.github/instructions/backend.instructions.md`, `.github/agents/`, `.github/prompts/`, `.vscode/settings.json`, `.claude/` (missing) |
| FE_EcoSystem | React/TS | `.cursor/rules/`, `.cursor/commands/`, `.github/copilot-instructions.md`, `.github/instructions/frontend.instructions.md`, `.github/agents/`, `.github/prompts/`, `.vscode/settings.json` |
| HH_EcoSystem | React Native | `.cursor/rules/`, `.cursor/commands/`, `.github/instructions/mobile.instructions.md`, `.github/agents/`, `.github/prompts/`, `.vscode/settings.json`, `.claude/` (missing) |
| DE_EcoSystem | SSIS/SQL | `.cursor/rules/`, `.cursor/commands/`, `.github/copilot-instructions.md`, `.github/instructions/data-engineering.instructions.md`, `.github/agents/`, `.github/prompts/`, `.vscode/settings.json`, `.claude/` (missing) |
| Infrastructure | K8s/DevOps | `.cursor/rules/`, `.cursor/commands/`, `.github/copilot-instructions.md`, `.github/instructions/devops.instructions.md`, `.github/agents/`, `.github/prompts/`, `.vscode/settings.json` |
| UI_EcoSystem | Design/Placeholder | `.cursor/rules/`, `.cursor/commands/`, `.github/copilot-instructions.md`, `.github/instructions/frontend.instructions.md`, `.github/agents/`, `.github/prompts/`, `.vscode/settings.json` |

**Note**: Artifacts and Legacy repos are excluded per workspace conventions.

### Phase 3: Installer Update

**Goal**: Update `install.ps1` to support selective and full platform installation.

```powershell
# New CLI interface
./install.ps1 --platform all      # Default: installs all platforms
./install.ps1 --platform cursor   # Cursor only
./install.ps1 --platform copilot  # Copilot only
./install.ps1 --platform opencode # OpenCode only (existing behavior)
./install.ps1 --platform claude   # Claude Code only
./install.ps1 --platform cursor,copilot  # Multiple platforms
```

**Changes**:
1. Add `--platform` parameter with validation
2. Add `Install-CursorConfig` function (copies `.cursor/` from templates)
3. Add `Install-CopilotConfig` function (copies `.github/` configs from templates)
4. Add `Install-VSCodeConfig` function (copies `.vscode/settings.json`)
5. Add `Install-ClaudeConfig` function (for BE/HH/DE gap fill)
6. Update manifest.json to track installed platforms per repo

### Phase 4: Documentation & Onboarding

**Goal**: Ensure the setup is discoverable and maintainable.

| Task | File | Description |
|---|---|---|
| 4.1 | Update `SRS_Documents/AGENTS.md` | Add "AI-Native Tooling" section with platform matrix |
| 4.2 | Create `AI_Native/setup/cursor-setup.md` | Cursor-specific setup guide |
| 4.3 | Create `AI_Native/setup/copilot-setup.md` | Copilot-specific setup guide |
| 4.4 | Create `AI_Native/setup/vscode-workspace.md` | VS Code monorepo workspace guide |
| 4.5 | Update `AI_Native/workflow/skills-catalog.md` | Add cross-platform skill mapping |
| 4.6 | Update `ONBOARDING.md` | Add AI-native IDE setup steps |

### Phase 5: Verification & Drift Detection

**Goal**: Ensure configs stay consistent across repos.

| Task | Description |
|---|---|
| 5.1 | Create `scripts/verify-ai-native.ps1` — validates all repos have required configs |
| 5.2 | Create `scripts/check-drift.ps1` — compares per-repo configs against templates |
| 5.3 | Add CI workflow (optional) — runs verification on PR |

---

## 5. Shared Template Specifications

### 5.1 Cursor Rules (`.cursor/rules/*.mdc`)

**Format**: Markdown with YAML frontmatter.

```yaml
---
description: <what this rule enforces>
globs: <comma-separated file globs>
alwaysApply: <true|false>
---

# Rule content
- Bullet-point instructions
- Reference external docs: [SDD Pipeline](../workflow/sdd-pipeline.md)
```

**Precedence** (Cursor internal): Team Rules > Project Rules > User Rules > Legacy > AGENTS.md

**Proposed rule files**:

| File | `globs` | Purpose |
|---|---|---|
| `00-sdd-invariants.mdc` | `*` | Universal SDD rules (spec-first, AC verification) |
| `10-backend-conventions.mdc` | `**/*.cs` | C# / .NET / CQRS / EF Core patterns |
| `11-frontend-conventions.mdc` | `**/*.ts,**/*.tsx` | React / RSBuild / Tailwind patterns |
| `12-mobile-conventions.mdc` | `**/*.tsx,**/*.ts` (HH) | React Native / Android patterns |
| `13-devops-conventions.mdc` | `**/*.yaml,**/*.yml,**/*.json` (K8s) | K8s / ArgoCD / Jenkins patterns |
| `14-data-engineering-conventions.mdc` | `**/*.sql,**/*.dtsx` | SSIS / Bronze-Silver / SQL patterns |
| `20-security-checklist.mdc` | `*` | OWASP / RBAC / security review checklist |

### 5.2 Cursor Commands (`.cursor/commands/*.md`)

**Format**: Markdown, filename = command name.

```markdown
# /generate-spec

Generate a new OpenSpec feature specification from a user description.

## Steps
1. Ask user for feature name and brief description
2. Load `../WingYip_SRS_Documents/AI_Native/openspec/templates/spec.md`
3. Generate spec with proper ACs using Gherkin syntax
4. Save to `docs/specs/<feature>.spec.md`

## References
- [SDD Pipeline](../workflow/sdd-pipeline.md)
- [OpenSpec Templates](../openspec/templates)
```

**Proposed commands**:

| Command | Purpose |
|---|---|
| `/generate-spec` | Create OpenSpec spec from description |
| `/verify-ac` | Check all ACs in a spec have matching tests |
| `/review-code` | Run 4-persona review council on current PR |
| `/generate-tests` | Generate test skeletons from spec ACs |
| `/update-adr` | Create or update Architecture Decision Record |

### 5.3 Copilot Instructions (`.github/copilot-instructions.md`)

**Format**: Pure Markdown (no frontmatter for top-level file).

**Key constraints**:
- Copilot reads only first **4,000 characters** — keep it concise, reference external files
- Use `#file:<path>` tokens for file loading in prompts
- Use relative markdown links for discoverability

```markdown
# WingYip Copilot Instructions

## SDD Invariants (Non-Negotiable)
1. **No code without spec** — Reference a spec before generating any implementation.
2. **Every AC needs verification** — All acceptance criteria must have executable tests.
3. **Spec-first workflow** — Read the spec before editing; include spec path in PRs.
4. **Build & validate** — Run `dotnet build` / `npm run lint` / `pytest` before committing.

## Project Structure
- Backend: `WingYip_SRS_BE_EcoSystem/` (.NET 8, CQRS, EF Core)
- Frontend: `WingYip_SRS_FE_EcoSystem/` (React 19, RSBuild, Tailwind)
- Mobile: `WingYip_SRS_HH_EcoSystem/` (React Native 0.72, Android)
- Data Engineering: `WingYip_SRS_DE_EcoSystem/` (SSIS, Bronze/Silver)
- Infrastructure: `WingYip_SRS_Infrastructure/` (K8s, ArgoCD, Keycloak)
- Documentation: `WingYip_SRS_Documents/` (SRS, LLD, BRD, ADR)

## References
- [SDD Pipeline](../workflow/sdd-pipeline.md)
- [OpenSpec Config](../openspec/config.yaml)
- `Coding Standards`
```

### 5.4 Copilot Path-Specific Instructions (`.github/instructions/*.md`)

**Format**: Markdown with YAML frontmatter (requires `applyTo` glob).

```yaml
---
applyTo: "**/*.cs"
name: "Backend SDD Rules"
---

## Backend Conventions
- Every controller action must reference its API spec.
- Use CQRS: Commands → `*.Commands/`, Queries → `*.Queries/`.
- EF Core entities are database-first — never edit without updating the DB model.
- Cross-cutting concerns go to Core shared library (`../Core/`).
- Follow `Coding Standards`.
```

### 5.5 Copilot Custom Agents (`.github/agents/*.md`)

**Format**: Markdown with YAML frontmatter.

```yaml
---
name: spec-reviewer
description: Reviews code changes against specification documents and acceptance criteria.
tools: ["read", "grep", "terminal"]
---

You are a specification compliance reviewer. Your responsibilities:

1. Load the spec referenced in the PR (e.g., `#file:../docs/FEATURE_SPEC.md`).
2. Compare each Acceptance Criterion (AC) with the implementation.
3. Identify missing tests, undocumented behaviors, or deviations.
4. Respond with a structured checklist:
   - ✅ AC covered & tested
   - ❌ AC missing — suggest test skeleton
   - ⚠️ Potential spec-drift — flag for clarification
```

**Proposed agents**:

| Agent | Role | Tools |
|---|---|---|
| `spec-reviewer` | Validates code against specs | read, grep, terminal |
| `backend-reviewer` | .NET/C# specific review | read, grep, terminal |
| `frontend-reviewer` | React/TS specific review | read, grep, terminal |
| `security-reviewer` | OWASP/security check | read, grep, terminal |

### 5.6 Copilot Reusable Prompts (`.github/prompts/*.md`)

**Format**: Markdown. Requires `chat.promptFiles: true` in `.vscode/settings.json`.

```markdown
# Verify Acceptance Criteria

Verify that all acceptance criteria listed in #file:SPEC.md have matching test cases.

- List any uncovered ACs.
- Suggest a skeleton test for each missing case.
- Return a checklist of AC → test mapping.
```

**Proposed prompts**:

| Prompt | Purpose |
|---|---|
| `verify-ac` | Check spec ACs against test coverage |
| `generate-tests` | Generate test skeletons from spec |
| `implement-from-spec` | Implement feature from OpenSpec document |
| `review-adr` | Review Architecture Decision Record |

### 5.7 VS Code Settings (`.vscode/settings.json`)

```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "chat.useAgentsMdFile": true,
  "chat.useClaudeMdFile": true,
  "chat.useCustomizationsInParentRepositories": true,
  "chat.promptFiles": true,
  "chat.agent.enabled": true,
  "chat.subagents.enabled": true,
  "chat.checkpoints.enabled": true,
  "chat.checkpoints.showFileChanges": true,
  "github.copilot.chat.codesearch.enabled": true,
  "chat.instructionsFilesLocations": {
    ".github/instructions": true,
    ".claude/rules": true
  },
  "chat.editing.confirmEditRequestRemoval": true,
  "chat.editing.confirmEditRequestRetry": true,
  "chat.editing.autoAcceptDelay": 0
}
```

---

## 6. Per-Repo Rollout Matrix

### 6.1 Files Per Repo

| Repo | Stack | `.cursor/rules/` | `.cursor/commands/` | `.github/copilot-instructions.md` | `.github/instructions/` | `.github/agents/` | `.github/prompts/` | `.vscode/settings.json` | `.claude/` (if missing) |
|---|---|---|---|---|---|---|---|---|---|
| BE_EcoSystem | .NET | 7 files | 5 files | ✅ | backend.md | 4 agents | 4 prompts | ✅ | ✅ (add) |
| FE_EcoSystem | React | 7 files | 5 files | ✅ | frontend.md | 4 agents | 4 prompts | ✅ | existing |
| HH_EcoSystem | RN | 7 files | 5 files | existing | mobile.md | 4 agents | 4 prompts | ✅ | ✅ (add) |
| DE_EcoSystem | SSIS | 7 files | 5 files | ✅ | data-eng.md | 4 agents | 4 prompts | ✅ | ✅ (add) |
| Infrastructure | K8s | 7 files | 5 files | ✅ | devops.md | 4 agents | 4 prompts | ✅ | existing |
| UI_EcoSystem | Design | 7 files | 5 files | ✅ | frontend.md | 4 agents | 4 prompts | ✅ | existing |

**Total new files**: ~200 files across all repos
**Total updated files**: `install.ps1`, `manifest.json`, `AGENTS.md` (9 repos), `ONBOARDING.md`

---

## 7. Best Practices & Constraints

### 7.1 File Size Limits

| Platform | Max Size | Rationale |
|---|---|---|
| Cursor rules (`.mdc`) | < 500 lines | Cursor performance |
| Copilot instructions | < 4,000 chars | Copilot truncation |
| Copilot path-specific | < 4,000 chars | Copilot truncation |
| AGENTS.md | No hard limit | Universal reference |

### 7.2 Content Strategy

- **DRY**: Never duplicate policy text. Reference `WingYip_SRS_Documents/` via relative paths.
- **Thin wrappers**: Per-repo files are 80% references, 20% repo-specific context.
- **Versioned templates**: Templates live in `SRS_Documents/` and are version-controlled. Per-repo files get updated by re-running installer.

### 7.3 Naming Conventions

| Platform | Convention | Example |
|---|---|---|
| Cursor rules | `NN-descriptive-name.mdc` | `00-sdd-invariants.mdc` |
| Cursor commands | `command-name.md` | `generate-spec.md` |
| Copilot instructions | `copilot-instructions.md` (fixed) | — |
| Copilot path rules | `<stack>.instructions.md` | `backend.instructions.md` |
| Copilot agents | `<role>.agent.md` | `spec-reviewer.agent.md` |
| Copilot prompts | `<task>.prompt.md` | `verify-ac.prompt.md` |

### 7.4 Conflict Resolution (Updated)

When instructions disagree, apply this precedence (highest wins):

```
ADR > PROJECT.md > AGENTS.md > Platform-specific rules > docs/ > ../WingYip_SRS_Documents/AI_Native/
```

Within platform-specific rules:
```
Copilot path-specific (`.github/instructions/*.md`) > Cursor stack-specific (`.cursor/rules/*.mdc`) > Universal AGENTS.md
```

---

## 8. Quick Start Checklist

### For Developers (Setting Up Their IDE)

- [ ] Clone all repos into a single VS Code multi-root workspace
- [ ] Install Cursor IDE (if using Cursor)
- [ ] Install GitHub Copilot extension in VS Code (if using Copilot)
- [ ] Install Claude Code CLI (if using Claude)
- [ ] Install OpenCode CLI (if using OpenCode)
- [ ] Run `./install.ps1 --platform all` from `WingYip_SRS_AI_Native/installer/`
- [ ] Verify `.cursor/`, `.github/copilot-instructions.md`, `.vscode/settings.json` exist in active repos
- [ ] Open a spec file and test: "Copilot/Cursor/Claude, review this code against the spec"

### For Maintainers (Updating Templates)

- [ ] Edit templates in `WingYip_SRS_Documents/AI_Native/templates/`
- [ ] Run `./install.ps1 --platform all --update` to propagate changes
- [ ] Run `scripts/verify-ai-native.ps1` to validate all repos
- [ ] Run `scripts/check-drift.ps1` to detect config divergence

---

## Appendices

### A. Cross-Platform Feature Matrix

| Feature | OpenCode | Claude Code | Cursor | Copilot |
|---|---|---|---|---|
| **Skills** | `.opencode/skills/*.md` | `.claude/skills/*.md` | `.cursor/rules/*.mdc` | `.github/agents/*.md` |
| **Commands** | `.opencode/commands/*.md` | `.claude/commands/*.md` | `.cursor/commands/*.md` | `.github/prompts/*.md` |
| **Universal config** | `AGENTS.md` | `CLAUDE.md` + `AGENTS.md` | `AGENTS.md` | `AGENTS.md` + `copilot-instructions.md` |
| **Path-specific rules** | N/A | N/A | `globs` in MDC | `applyTo` in `.instructions.md` |
| **Agent mode** | Built-in | Experimental | Chat with AI | Copilot Agent + subagents |
| **Monorepo support** | Native | Native | Native | `useCustomizationsInParentRepositories` |
| **Hooks** | N/A | N/A | N/A | `.github/hooks/*.json` (beta) |

### B. External References

- [Cursor Rules Documentation](https://docs.cursor.com/context/rules)
- [Copilot Custom Instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions-in-your-ide)
- [VS Code AI Settings](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [OpenCode Documentation](https://docs.opencode.ai) *(internal)*
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code) *(internal)*

---

> **Document Status**: DRAFT — Pending user confirmation to proceed with implementation.
>
> **Last Updated**: 2025-06-01
>
> **Owner**: AI-Native Development Team
