---
applyTo: "**/*.sql,**/*.dtsx"
name: "Data Engineering SDD Rules"
---

## Data Engineering Conventions

- Follow Bronze-Silver-Gold medallion architecture.
- Use project deployment model for SSIS packages.
- Include logging and error handling in every package.
- Validate data quality at Bronze -> Silver transition.
- Use snake_case for table and column names.
- Document table schemas in docs/DATABASE_SCHEMA.md.
- Run full pipeline in staging before production.
