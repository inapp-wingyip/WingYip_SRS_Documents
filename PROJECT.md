# PROJECT.md — WingYip SRS Documents

> **AI Native Project Context**
> For shared standards, workflows, and agent guidelines, see:
> - [AI Native Workflow](../../WingYip_SRS_Documents/AI_Native/workflow/)
> - [Architecture Patterns](../../WingYip_SRS_Documents/AI_Native/architecture/)
> - [Coding Standards](../../WingYip_SRS_Documents/AI_Native/standards/coding-standards.md)
> - [Agent Guidelines](../../WingYip_SRS_Documents/AI_Native/agents/)

---

## 1. Project Overview

**Name**: WingYip SRS Documents
**Purpose**: Master knowledge base and cross-repo documentation source of truth for the WingYip ecosystem.
**Stage**: Active (continuously updated)
**Team size**: All engineers contribute

---

## 2. Tech Stack

| Layer | Technology | Version |
|---|---|---|
| Format | Markdown | CommonMark |
| Diagrams | Mermaid | 10.x |
| Documentation | Markdown files in Git | |

---

## 3. Repository Structure

```
WingYip_SRS_Documents/
├── Architecture/               ← System architecture documents
├── BRD/                        ← Business Requirement Documents
├── LLD/                        ← Low-Level Design documents
├── Runbooks/                   ← Operational runbooks
├── AI_Native/                  ← AI Native shared documentation
│   ├── workflow/
│   ├── architecture/
│   ├── standards/
│   ├── agents/
│   └── openspec/
├── AGENTS.md                   ← Repo-specific AGENTS.md
└── README.md
```

**Monorepo**: No (documentation hub)

---

## 4. Documentation Index

| Category | Path | Description |
|---|---|---|
| Architecture | Architecture/ | System-wide architecture decisions |
| BRDs | BRD/ | Business requirements per feature |
| LLDs | LLD/ | Technical designs per service |
| Runbooks | Runbooks/ | Operational procedures |
| AI Native | AI_Native/ | Shared AI Native development standards |
| **ADRs** | `docs/adr/` | **61 Architecture Decision Records** |

---

## 5. ADR Quick Reference

All Architecture Decision Records live in `docs/adr/`. See the complete index in [docs/adr/README.md](docs/adr/README.md).

---

## 6. Cross-Repo References

All other WingYip repos reference this repository for:
- Architecture decisions
- Business requirements
- Low-level designs
- AI Native shared documentation

---

## 6. Changelog

| Date | Change | Author |
|---|---|---|
| 2026-05-31 | Added ADR-040 through ADR-061 documenting 84+ uncovered architectural decisions | AI Native Setup |
| 2026-05-31 | Fixed ADR-004 (HAProxy reality), removed phantom BE-ADR references, clarified WingYip_Legacy as READ-ONLY | AI Native Setup |
| 2026-05-30 | Created ADR-001 through ADR-039 covering microservices, security, messaging, frontend, DE, infrastructure | AI Native Setup |
| 2026-05-30 | Initial PROJECT.md for AI Native setup | AI Native Setup |
