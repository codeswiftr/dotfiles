---
name: deps
description: Audit dependencies for security vulnerabilities and updates
---

# Dependency Audit

Use the **dependency-auditor** skill for comprehensive dependency analysis.

## Audit Dimensions

### 1. Security Vulnerabilities
Check for known CVEs in all dependencies.

### 2. Outdated Packages
Identify packages behind latest versions.

### 3. License Compliance
Verify licenses are compatible with project.

## Workflow

### 1. Detect Package Manager
Identify project type:
- Python: `pyproject.toml`, `requirements.txt`
- Node.js: `package.json`
- Go: `go.mod`
- Rust: `Cargo.toml`

### 2. Run Security Audit

#### Python (uv preferred)
```bash
pip-audit
# or: safety check
```

#### Node.js
```bash
npm audit
# or: yarn audit
```

#### Go
```bash
govulncheck ./...
```

#### Rust
```bash
cargo audit
```

### 3. Check for Updates

#### Python
```bash
uv pip list --outdated
```

#### Node.js
```bash
npm outdated
```

### 4. License Check

#### Python
```bash
pip-licenses --format=markdown
```

#### Node.js
```bash
npx license-checker --summary
```

## Output Report

```markdown
## 🔍 Dependency Audit Report - [Date]

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

### Outdated Packages
| Package | Current | Latest | Breaking? |
|---------|---------|--------|-----------|
| react | 17.0.2 | 18.2.0 | Yes |

### License Issues
| Package | License | Concern |
|---------|---------|---------|
| pkg-x | GPL-3.0 | Copyleft |

### Recommended Actions
1. **Immediate**: [Critical security fixes]
2. **This week**: [High severity updates]
3. **Scheduled**: [Minor version updates]
```

## Automation Tip
Add to CI/CD:
```yaml
name: Dependency Audit
on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly Monday
  push:
    paths:
      - 'package.json'
      - 'pyproject.toml'
```
