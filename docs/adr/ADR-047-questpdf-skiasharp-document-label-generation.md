# ADR-047. QuestPDF and SkiaSharp Document and Label Generation

- **Status:** accepted
- **Date:** 2026-05-31
- **Supersedes:** N/A

## Context

The WingYip SRS platform uses two distinct graphics libraries for document and label generation across different services.

**QuestPDF (Reporting Service):**
- Used for PDF report generation (e.g., list reports, operational reports)
- Provides a modern, composable, C#-native API for building PDF documents
- Community license applies, which imposes revenue/usage restrictions on commercial deployments
- Requires SkiaSharp as a rendering dependency for text and graphics
- Docker deployments require native Linux libraries: `fontconfig`, `libfreetype6`, `fonts-liberation`

**SkiaSharp (Print Service):**
- Used for label image generation (SEL labels, product labels)
- Cross-platform 2D graphics API backed by Google's Skia engine
- Provides good performance for rasterized label output
- Version inconsistency exists: Print service uses SkiaSharp 3.119.1 while the `Print.Label` utility uses 3.119.2
- Also requires native Linux dependencies in Docker containers

**Key concerns:**
- Both libraries require native Linux dependencies, increasing Docker image size
- QuestPDF Community license has revenue restrictions that may conflict with commercial use
- SkiaSharp version mismatch between Print service and Print.Label utility risks runtime behavior differences
- No shared Docker base image strategy for the native dependency installation

## Decision

We use **QuestPDF for PDF report generation** and **SkiaSharp for label image generation**:

1. **QuestPDF** is the PDF generation engine in the Reporting service, using its composable C# API for document layout
2. **SkiaSharp** is the image generation engine in the Print service for SEL and product label rendering
3. Both libraries' native Linux dependencies are installed in their respective Docker images

## Consequences

**Positive:**
- QuestPDF provides a modern, type-safe, composable API for PDF generation — no HTML-to-PDF conversion overhead
- SkiaSharp is cross-platform with good rendering performance for label images
- Clear separation of concerns: PDF reports (QuestPDF) vs. label images (SkiaSharp)

**Negative:**
- **QuestPDF Community license restrictions**: Revenue/usage limits may require upgrading to a paid license for commercial deployment
- **Docker image size**: Both libraries require native Linux dependencies (`fontconfig`, `libfreetype6`, `fonts-liberation`), increasing image size for both Reporting and Print services
- **SkiaSharp version inconsistency**: Print service uses 3.119.1 while `Print.Label` uses 3.119.2 — this mismatch can cause subtle rendering differences or binding failures
- **Dual dependency**: QuestPDF itself depends on SkiaSharp, meaning the Reporting service carries both libraries
- **No shared base image**: Each service independently installs native dependencies, leading to duplicated Dockerfile maintenance

**Future constraints:**
- SkiaSharp versions must be aligned across Print service and Print.Label utility to prevent rendering inconsistencies
- QuestPDF licensing must be reviewed before production deployment exceeding Community license thresholds
- Consider creating a shared Docker base image with native graphics dependencies to reduce duplication
- Evaluate QuestPDF Professional license costs against alternative PDF libraries (e.g., Puppeteer-based, iTextSharp) if revenue restrictions become problematic

---

## References

- `Reporting.csproj` — QuestPDF and SkiaSharp package references in Reporting service
- `Print.Service.csproj` — SkiaSharp package reference in Print service
- `LabelService.cs` — SkiaSharp-based label image generation
- `ListReportEngine.cs` — QuestPDF-based PDF report generation
- ADR-001 (Microservices Architecture) — Service boundary decisions