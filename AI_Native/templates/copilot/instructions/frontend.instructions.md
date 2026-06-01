---
applyTo: "**/*.ts,**/*.tsx"
name: "Frontend SDD Rules"
---

## Frontend Conventions

- Each component maps to a feature spec in WingYip_SRS_Documents/.
- Use RSBuild for builds, Tailwind for styling.
- Use React Query for server state, Zustand for client state.
- Every UI AC must have a React Testing Library or Cypress test.
- Run `npm run lint && npm test` before committing.
