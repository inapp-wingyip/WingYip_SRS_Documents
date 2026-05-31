# ADR-018. RSBuild as Frontend Build Tool

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS web frontend requires a modern, fast build tool for React 19 development. The codebase was previously using Create React App (CRA) or a similar webpack-based setup and needed migration to a faster, more maintainable build pipeline.

**Current implementation:**
- `rsbuild.config.mts` — single source of truth for build configuration
- `@rsbuild/plugin-react` for React support
- `@swc/jest` for test compilation (replacing Babel)
- `@` path alias maps to `src/`
- Dev server on port 3000 with `historyApiFallback: true`
- Production build produces static assets served by Nginx

**Alternatives considered:**
- **Vite**: Fast, mature ecosystem, but requires migrating to Rollup-based plugin system
- **Webpack**: Existing familiarity, but slow build times and complex configuration
- **Turbopack**: Next.js-only, not standalone
- **RSBuild**: Rust-based bundler (Rspack), webpack-compatible plugin API, fast builds

## Decision

We selected **RSBuild** (powered by Rspack) as the build tool:

1. **Primary build tool**: RSBuild for development and production builds
2. **Webpack compatibility**: Existing webpack plugins and loaders work without modification
3. **SWC for tests**: Jest uses `@swc/jest` instead of Babel for test compilation
4. **No Webpack/Vite in build pipeline**: RSBuild is the sole build orchestrator

## Consequences

**Positive:**
- Significantly faster builds than webpack (Rust-based bundling)
- Webpack plugin compatibility reduces migration friction
- Minimal configuration (`rsbuild.config.mts` is ~50 lines vs hundreds for webpack)
- Built-in React Fast Refresh and TypeScript support
- Good balance between Vite's speed and webpack's ecosystem

**Negative:**
- **Smaller ecosystem than Vite/Webpack**: Fewer community plugins and Stack Overflow resources
- RSBuild is newer — long-term stability and maintenance are less proven than Vite
- Migration lock-in: Moving from RSBuild to another tool requires config rewrite (though less than webpack)
- Some advanced webpack features may not be fully supported in Rspack

**Future constraints:**
- Build tool migration requires explicit ADR evaluation (RSBuild → Vite/Next.js/Turbopack)
- Keep `rsbuild.config.mts` minimal — avoid complex custom plugins that increase lock-in
- Monitor Rspack/RSBuild release notes for breaking changes

## Related ADRs

- ADR-017: Feature-based modules (build tool affects code splitting and lazy loading)
