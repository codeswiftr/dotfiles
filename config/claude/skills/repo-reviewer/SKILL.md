---
name: repo-reviewer
description: Use repomix and Gemini CLI to perform comprehensive codebase reviews, highlighting architecture, gaps, and actionable next steps.
---

# Repo Reviewer

Comprehensive codebase review using repomix for aggregation and Gemini for analysis.

## When to Use
- Onboarding to a new codebase quickly
- Auditing repos before major refactoring
- Code review for handovers or acquisitions
- Generating project status summaries

## Prerequisites
- Node.js (for npx)
- Gemini CLI configured

## Workflow

### Quick Review
```bash
# Generate codebase summary
npx --yes repomix@latest . > repomix-output.txt

# Analyze with Gemini
gemini -p "Review this codebase summary. Identify: architecture patterns, potential issues, missing tests/docs, recommended improvements." < repomix-output.txt
```

### Detailed Review
1. **Generate Summary** (from project root):
   ```bash
   npx --yes repomix@latest --no-gitignore . > repomix-summary.txt
   ```

2. **Filter Large Repos** (if output > 500KB):
   ```bash
   npx --yes repomix@latest --include="src/**,app/**,lib/**" . > repomix-summary.txt
   ```

3. **Analyze with Gemini**:
   ```bash
   gemini -p "Review repomix-summary.txt:
   - Architecture overview
   - Code quality assessment
   - Test coverage gaps
   - Documentation status
   - Security considerations
   - Top 5 recommendations" > review-output.md
   ```

4. **Structure Findings**:
   - Strengths (what's working well)
   - Risks (technical debt, security issues)
   - Gaps (missing tests, docs, error handling)
   - Actions (prioritized recommendations)

## Review Templates

### Architecture Review
```
Analyze this codebase for:
1. Overall architecture pattern (MVC, Clean, etc.)
2. Dependency structure and coupling
3. Separation of concerns
4. Scalability considerations
```

### Security Review
```
Audit this codebase for security:
1. Input validation patterns
2. Authentication/authorization
3. Sensitive data handling
4. Common vulnerabilities (OWASP Top 10)
```

### Onboarding Summary
```
Create an onboarding guide:
1. Project structure overview
2. Key entry points
3. Build and run instructions
4. Important conventions to follow
```

## Tips
- Note omitted directories (node_modules, vendor, dist)
- Keep reviews actionable: findings + specific next steps
- For large repos, review in sections (backend, frontend, infra)
- Compare against project documentation for discrepancies
