# 🔒 **Security & Privacy Guide**

Your development environment includes enterprise-grade security controls for AI integrations and sensitive data protection.

## 🛡️ **Security Overview**

### **AI Security Framework**
Your dotfiles include a comprehensive security system that:
- **🔍 Detects sensitive content** before sending to AI services
- **👤 Requires user consent** for external AI calls
- **🏢 Supports enterprise policies** with configurable restrictions
- **🛡️ Uses safe defaults** with strict mode available

### **Protected Content Types**
**Sensitive Files** (automatically blocked):
- `*.key`, `*.pem`, `*.p12`, `*.pfx` - Cryptographic keys
- `*.env*`, `*secret*`, `*password*` - Environment and secret files
- `id_rsa*`, `*.ssh/*` - SSH keys
- `*token*`, `*credential*` - Authentication tokens

**Sensitive Content** (detected in code):
- `password=`, `api_key=`, `secret=` - Secret assignments
- `private_key`, `access_token` - Authentication data
- Credit card patterns, social security numbers
- Database connection strings with credentials

## ⚙️ **Security Configuration**

### **Check Current Status**
```bash
# View current security settings
ai-security-status
```

**Expected Output**:
```
🔒 AI Security Status:
✅ Security Framework: ENABLED
✅ Sensitive Content Detection: ACTIVE
✅ User Consent Required: YES
✅ Git Data Sharing: RESTRICTED
✅ Code Sharing: REQUIRES_CONFIRMATION
⚠️  Security Level: BALANCED
```

### **Security Modes**

#### **Strict Mode** (Recommended for Corporate)
```bash
ai-security-strict
```

**Features**:
- Blocks all file sharing with AI services
- Requires explicit confirmation for every AI call
- Disables automatic context inclusion
- Logs all AI interactions
- Maximum privacy protection

#### **Permissive Mode** (Personal Projects)
```bash
ai-security-permissive
```

**Features**:
- Allows file sharing with consent
- Streamlined confirmation prompts
- Enables project context awareness
- Balanced security and productivity

#### **Custom Configuration**
```bash
# Fine-grained control
export AI_SECURITY_ENABLED=true
export AI_ALLOW_CODE_SHARING=false
export AI_ALLOW_GIT_DATA=false
export AI_WARN_ON_SENSITIVE=true
export AI_REQUIRE_CONFIRMATION=true
```

## 🔐 **Enterprise Security**

### **Corporate Environment Setup**

For company/work computers:

```bash
# 1. Enable maximum security
ai-security-strict

# 2. Disable AI features entirely (if required)
export DISABLE_AI_FEATURES=true
src  # Reload shell

# 3. Verify no AI tools are accessible
ai-security-status
```

### **Team Security Policies**

**Option 1: Company-wide restrictions**
```bash
# Add to company dotfiles or /etc/profile
export AI_SECURITY_ENTERPRISE=true
export AI_BLOCK_ALL_SHARING=true
export AI_LOG_INTERACTIONS=true
```

**Option 2: Department-specific policies**
```bash
# Development teams
export AI_SECURITY_LEVEL="development"
export AI_ALLOW_CODE_REVIEW=true
export AI_BLOCK_PRODUCTION_DATA=true

# Security teams
export AI_SECURITY_LEVEL="security"
export AI_BLOCK_ALL_SHARING=true
export AI_AUDIT_MODE=true
```

### **Compliance Features**

#### **Audit Logging**
```bash
# Enable audit logging
export AI_AUDIT_LOG=true
export AI_AUDIT_PATH="~/.ai-audit.log"

# View audit log
tail -f ~/.ai-audit.log
```

**Log Format**:
```
[2025-01-15 10:30:45] AI_CALL user=johndoe tool=claude prompt="code review" files=app.py status=BLOCKED reason=sensitive_content
[2025-01-15 10:31:12] AI_CALL user=johndoe tool=gemini prompt="explain function" files=none status=ALLOWED
```

#### **Data Classification**
```bash
# Classify project sensitivity
echo "CONFIDENTIAL" > .security-level
# or
echo "PUBLIC" > .security-level
echo "INTERNAL" > .security-level

# Security framework will adjust restrictions automatically
```

## 🚨 **Security Warnings & Prompts**

### **Typical Security Prompt**
```
⚠️  SECURITY WARNING: AI Code Analysis Request

🔍 Tool: Claude Code CLI
📄 Files: src/auth.py (contains potential secrets)
🎯 Action: Code review and explanation

⚠️  DETECTED SENSITIVE CONTENT:
  - Line 23: api_key = "sk-..."
  - Line 45: password = "..."

❓ Do you want to proceed? This will send code to external AI service.
   [y] Yes, send anyway
   [n] No, cancel
   [e] Edit file to remove sensitive content first
   [s] Show what would be sent
```

### **Response Options**
- **`y`** - Proceed with caution (logs interaction)
- **`n`** - Cancel safely
- **`e`** - Open file in editor to clean sensitive data
- **`s`** - Preview exactly what would be sent

### **Bypass Options** (Use Carefully)
```bash
# Temporary bypass for current session
export AI_SKIP_SECURITY_PROMPT=true

# Bypass for specific command
AI_SKIP_CONFIRMATION=true explain app.py

# Re-enable security
unset AI_SKIP_SECURITY_PROMPT
```

## 🛠️ **Security Tools & Commands**

### **Content Analysis**
```bash
# Scan file for sensitive content
ai-scan-sensitive file.py

# Scan entire project
ai-scan-sensitive .

# Generate security report
ai-security-report
```

### **Safe AI Usage**
```bash
# AI with automatic security filtering
safe-ai-call claude "review this code" app.py

# AI with manual content review
preview-ai-content app.py  # Shows what would be sent
ai-call-approved claude "review this code" app.py
```

### **Emergency Security**
## 🔎 **Repository Secret Scans**

The built-in `dot security scan` performs three checks: dependencies, static analysis, and secret scanning. To reduce noise, the basic secret scanner skips fixtures and docs by default:

- Ignored paths: `tests/**`, `templates/testing/**`, `docs/**`, `hooks/**`, `.git`, `node_modules`
- Known example placeholders allowed in: `config/zsh/web-pwa.zsh`, `lib/cli/database.sh`

Notes:
- This does not relax third-party tools like gitleaks/truffleHog if installed; those take precedence.
- If you intentionally include examples that look like secrets, add a short comment explaining they are placeholders.
- For CI, you can run a quick scan with: `./bin/dot security scan --quiet`.

```bash
# Immediately disable all AI features
ai-emergency-disable

# Re-enable with security reset
ai-emergency-enable
ai-security-strict
```

## 🔍 **Privacy Protection**

### **Data Minimization**
The security framework implements data minimization:

```bash
# Only send relevant code sections
ai-context-minimal file.py  # Sends only function, not entire file

# Strip comments and metadata
ai-sanitize-code file.py | claude "review this"

# Remove personal information
ai-anonymize-code file.py
```

### **Local AI Alternatives**
For maximum privacy, consider local AI tools:

```bash
# Install Ollama for local LLMs
# brew install ollama  # (not included by default)

# Use local AI instead of cloud services
# export AI_PREFER_LOCAL=true
# ollama-code-review file.py
```

### **Network Security**
```bash
# Check AI tool network connections
netstat -an | grep -E "(claude|gemini|anthropic|google)"

# Use proxy for AI connections (if required)
export HTTPS_PROXY="http://corporate-proxy:8080"
export AI_USE_PROXY=true
```

## 📋 **Security Checklist**

### **Initial Setup**
- [ ] Run `ai-security-status` to check configuration
- [ ] Choose appropriate security mode for environment
- [ ] Test security prompts with dummy files
- [ ] Configure audit logging if required
- [ ] Verify team security policies

### **Daily Usage**
- [ ] Review security prompts carefully
- [ ] Never bypass security for sensitive projects
- [ ] Regularly check `ai-security-status`
- [ ] Clean sensitive data before AI analysis
- [ ] Use minimal context when possible

### **Corporate Compliance**
- [ ] Enable enterprise mode if required
- [ ] Configure audit logging
- [ ] Set up centralized security policies
- [ ] Train team on security procedures
- [ ] Regular security audits

## 🆘 **Troubleshooting Security Issues**

### **Security Prompts Not Appearing**
```bash
# Check if security is enabled
ai-security-status

# Re-enable security framework
ai-security-enable
src  # Reload shell

# Test with known sensitive file
echo "password=secret" > test-sensitive.txt
explain test-sensitive.txt  # Should prompt
rm test-sensitive.txt
```

### **False Positive Detection**
```bash
# Whitelist specific patterns (use carefully)
export AI_SECURITY_WHITELIST="example_key,test_password"

# Temporarily disable specific checks
export AI_SKIP_FILE_CHECKS=true  # Skip filename checks
export AI_SKIP_CONTENT_CHECKS=true  # Skip content checks
```

### **Audit Log Issues**
```bash
# Check audit log location
echo $AI_AUDIT_PATH

# Test audit logging
echo "test audit" | ai-audit-test

# Verify log permissions
ls -la ~/.ai-audit.log
```

### **Performance Impact**
```bash
# Check security overhead
time ai-scan-sensitive large-file.py

# Reduce security checks for performance
export AI_SECURITY_FAST_MODE=true

# Profile security impact
perf-profile-startup | grep security
```

## 🎯 **Security Best Practices**

### **Code Review Security**
1. **Review prompts carefully** before confirming AI calls
2. **Use minimal context** - select specific functions, not entire files
3. **Clean sensitive data** before AI analysis
4. **Verify what's being sent** using preview options
5. **Use local alternatives** when possible for sensitive code

### **Team Security Guidelines**
1. **Standard security mode** for all team members
2. **Shared security policies** via environment variables
3. **Regular security training** on AI tool usage
4. **Audit log reviews** for compliance
5. **Incident response plan** for security breaches

### **Corporate Security Controls**
1. **Enterprise security mode** mandatory
2. **Centralized policy management** via configuration files
3. **Network restrictions** on AI service access
4. **Regular security assessments** of AI tool usage
5. **Employee security training** on AI risks

## 🔮 **Advanced Security Configuration**

### **Custom Sensitive Content Patterns**
```bash
# Add custom patterns to detect
export AI_CUSTOM_SENSITIVE_PATTERNS="company_id,internal_api,secret_sauce"

# Custom file patterns to block
export AI_CUSTOM_BLOCKED_FILES="*.company,*internal*,*confidential*"
```

### **Security Hooks**
```bash
# Pre-AI security hook
echo '#!/bin/bash
echo "Custom security check"
# Add custom security logic here
' > ~/.dotfiles-hooks/pre-ai-call

# Post-AI security hook (for audit)
echo '#!/bin/bash
echo "AI call completed: $1" >> ~/.ai-usage.log
' > ~/.dotfiles-hooks/post-ai-call
```

### **Integration with Security Tools**
```bash
# Integration with git-secrets
# git secrets --install
# git secrets --register-aws

# Integration with detect-secrets
# pip install detect-secrets
# detect-secrets scan --all-files

# Integration with truffleHog
# trufflehog git file://.
```

## 🎉 **Security Summary**

Your development environment now provides **enterprise-grade security** with:

✅ **Comprehensive Content Detection** - Protects sensitive data automatically  
✅ **User Consent Framework** - You control what gets shared  
✅ **Enterprise Compliance** - Configurable for corporate policies  
✅ **Audit Capabilities** - Full logging and monitoring  
✅ **Zero Trust Approach** - Secure by default, permissive by choice  

**Your data stays secure while you benefit from AI assistance!** 🔒🚀

---

**Related Guides**:
- 🤖 [AI Workflows](ai-workflows.md) - Using AI securely
- ⚡ [Performance](performance.md) - Security performance impact
- 🎯 [Getting Started](getting-started.md) - Security configuration basics
