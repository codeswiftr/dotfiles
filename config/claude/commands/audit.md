---
name: audit
description: Security audit. Use --full for comprehensive codebase audit.
arguments: target
---

# Security Audit: $ARGUMENTS

Security-focused analysis. Add `--full` for full codebase health check.

## Modes

| Mode | Scope |
|------|-------|
| Default | Target file/component |
| `--full` | Entire codebase + health check |

Use the **security-auditor agent** for comprehensive analysis.

## Audit Scope

### OWASP Top 10 Checks
1. Injection (SQL, Command, LDAP)
2. Broken Authentication
3. Sensitive Data Exposure
4. XML External Entities (XXE)
5. Broken Access Control
6. Security Misconfiguration
7. Cross-Site Scripting (XSS)
8. Insecure Deserialization
9. Using Components with Known Vulnerabilities
10. Insufficient Logging & Monitoring

## Workflow

### 1. Define Scope
- What code/system to audit?
- What's the threat model?
- What compliance requirements apply?

### 2. Spawn Security Auditor Agent
Use the Task tool with `subagent_type: security-auditor` to:
- Analyze code for vulnerabilities
- Check authentication/authorization flows
- Review secrets management
- Assess dependency security
- Identify security misconfigurations

### 3. Output Format

```markdown
## 🔒 Security Audit: [Target]

### Executive Summary
- Risk Level: [Critical/High/Medium/Low]
- Vulnerabilities Found: [Count by severity]
- Immediate Actions Required: [Count]

### Critical Findings 🔴
#### [VULN-001] Issue Title
- **Severity**: Critical
- **Location**: `file.py:42`
- **Description**: [What's wrong]
- **Impact**: [What could happen]
- **Remediation**: [How to fix]
- **References**: [CVE, OWASP, etc.]

### High Findings 🟠
[Same structure...]

### Medium Findings 🟡
[Same structure...]

### Low Findings 🔵
[Same structure...]

### Positive Observations ✅
- [Good security practice found]

### Recommendations
1. [Priority action 1]
2. [Priority action 2]

### Compliance Notes
- [GDPR/HIPAA/SOC2 relevant findings]
```

## Common Checks
- [ ] Input validation on all user inputs
- [ ] Parameterized queries (no SQL injection)
- [ ] Output encoding (no XSS)
- [ ] Authentication properly implemented
- [ ] Authorization checks on all endpoints
- [ ] Secrets in environment, not code
- [ ] Dependencies up to date
- [ ] HTTPS enforced
- [ ] CORS properly configured
- [ ] Rate limiting in place
