---
name: dependency-auditor
description: Audit project dependencies for security vulnerabilities, outdated packages, and license compliance.
---

# Dependency Auditor

## When to Use
- Before releases to ensure security.
- Regularly (weekly/monthly) for maintenance.
- After adding new dependencies.
- For compliance audits.

## Audit Dimensions

### 1. Security Vulnerabilities
Check for known CVEs in dependencies.

### 2. Outdated Packages
Identify packages behind latest versions.

### 3. License Compliance
Verify licenses are compatible with project.

### 4. Dependency Health
Assess maintenance status and popularity.

## Commands by Ecosystem

### Python (uv preferred)
```bash
# Security audit
pip-audit
# or
safety check

# Outdated packages
uv pip list --outdated

# License check
pip-licenses --format=markdown
```

### JavaScript/Node
```bash
# Security audit
npm audit
# or
yarn audit

# Outdated packages
npm outdated

# License check
npx license-checker --summary
```

### Go
```bash
# Security audit
govulncheck ./...

# Outdated packages
go list -u -m all

# Module tidy
go mod tidy
```

### Rust
```bash
# Security audit
cargo audit

# Outdated packages
cargo outdated

# License check
cargo license
```

## Workflow

### 1. Run Security Scan
```bash
# Capture vulnerabilities
[audit command] > security-report.txt
```

### 2. Analyze Results
- **Critical**: Fix immediately.
- **High**: Fix within 24 hours.
- **Medium**: Fix within 1 week.
- **Low**: Schedule for next maintenance.

### 3. Check for Updates
- **Major versions**: Review breaking changes.
- **Minor versions**: Generally safe to update.
- **Patch versions**: Update immediately.

### 4. License Review
- **Permissive (MIT, Apache, BSD)**: Generally safe.
- **Copyleft (GPL, AGPL)**: May require disclosure.
- **Proprietary**: Verify licensing terms.

## Output Report Template
```markdown
## Dependency Audit Report - [Date]

### Security Summary
| Severity | Count | Action Required |
|----------|-------|-----------------|
| Critical | 0 | Immediate |
| High | 2 | 24 hours |
| Medium | 5 | 1 week |
| Low | 12 | Scheduled |

### Critical/High Vulnerabilities
| Package | Version | Vulnerability | Fix Version |
|---------|---------|---------------|-------------|
| lodash | 4.17.20 | CVE-2021-23337 | 4.17.21 |

### Outdated Packages (Major)
| Package | Current | Latest | Breaking Changes |
|---------|---------|--------|------------------|
| react | 17.0.2 | 18.2.0 | Concurrent features |

### License Issues
| Package | License | Issue |
|---------|---------|-------|
| package-x | GPL-3.0 | Copyleft requires review |

### Recommendations
1. [Immediate action 1]
2. [Scheduled action 2]
```

## Automation
```yaml
# GitHub Actions example
name: Dependency Audit
on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly Monday 9am
  push:
    paths:
      - 'package.json'
      - 'requirements.txt'
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=moderate
```
