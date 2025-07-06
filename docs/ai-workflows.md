# 🤖 **Complete AI Development Workflows**

Your development environment includes **enterprise-grade AI integration** with multiple providers and security controls.

## 🚀 **Overview**

### **AI Providers Integrated**
- **Claude Code CLI** (Anthropic) - Advanced reasoning and coding
- **Gemini CLI** (Google) - Fast responses and broad knowledge  
- **Direct API Integration** - Fallback when CLI tools unavailable
- **Multi-Provider Support** - Compare responses across models

### **Security Features**
- **🔒 Sensitive Data Protection** - Automatic detection of keys, passwords, tokens
- **👤 User Consent** - Explicit confirmation before sending code to external services
- **🏢 Enterprise Controls** - Configurable security levels for corporate environments
- **🛡️ Safe Defaults** - Security-first approach with strict mode available

## ⚙️ **Security Configuration**

### **Check Current Status**
```bash
ai-security-status
```

### **Security Modes**
```bash
# Maximum security (recommended for work)
ai-security-strict

# Balanced mode (personal projects)
ai-security-permissive  

# Custom configuration
export AI_SECURITY_ENABLED=true
export AI_ALLOW_CODE_SHARING=false
export AI_ALLOW_GIT_DATA=false
```

## 🖥️ **Shell AI Commands**

### **Quick AI Queries**
```bash
cc "How do I optimize Python performance?"
gg "Explain React hooks"
ai-compare "Which is better: REST or GraphQL?"
```

### **Project Analysis** (Secure)
```bash
ai-analyze overview      # Project structure analysis
ai-analyze security      # Security vulnerability review  
ai-analyze performance   # Performance optimization suggestions
ai-analyze documentation # Documentation improvements
```

### **Code Assistance** (Secure)
```bash
explain main.py          # Explain code functionality
ai-refactor app.js performance  # Performance-focused refactoring
ai-debug error.log       # Debug error messages
```

### **Git Integration** (Secure)
```bash
ai-commit               # Generate commit messages from staged changes
ai-review-branch        # Review code changes before push
```

### **Context-Aware AI** (Secure)
```bash
claude-context "How can I improve this codebase?"
# Automatically includes relevant project files
```

## 🔧 **Neovim AI Integration**

### **Essential Keybindings**

#### **Core AI Actions**
```vim
<leader>aa              " AI Actions menu
<leader>ac              " AI Chat interface
<leader>ai              " AI Inline assistance (visual mode)
```

#### **Code Analysis & Review**
```vim
" In visual mode, select code then:
<leader>acr             " AI Code Review (detailed analysis)
<leader>ace             " AI Explain Code (how it works)
<leader>act             " AI Generate Tests (unit tests)
<leader>aco             " AI Optimize Code (performance)
<leader>acc             " AI Add Comments (documentation)
```

#### **AI Generation**
```vim
<leader>ag              " AI Generate (general)
<leader>agc             " AI Chat mode  
<leader>age             " AI Enhance Code
<leader>agr             " AI Review Code
```

#### **Terminal Integration**
```vim
<leader>av              " Send visual selection to Claude
<leader>al              " Send current line to Claude
<leader>ab              " Send entire buffer to Claude
<leader>at              " Toggle AI terminal
```

#### **Quick AI Prompts**
```vim
<leader>aqc             " Quick Claude with context
<leader>aqg             " Quick Gemini with context
```

### **Advanced Workflows**
```vim
<leader>awr             " AI Review Workflow (Git + AI)
<leader>awt             " AI Test Workflow
<leader>awd             " AI Documentation Workflow
```

## 🎯 **Practical Workflows**

### **1. Code Review Workflow**
```bash
# 1. Stage your changes
git add .

# 2. Get AI review
ai-review-branch
# 🔒 Security prompt will ask for confirmation

# 3. In Neovim, select specific code for detailed review
# Visual mode → <leader>acr

# 4. Apply suggestions and commit
ai-commit
```

### **2. Test-Driven Development**
```bash
# 1. Write your function
nvim calculator.py

# 2. In Neovim, select the function (visual mode)
# 3. Generate tests: <leader>act

# 4. Review and save generated tests
# 5. Run tests and iterate
```

### **3. Performance Optimization**
```bash
# 1. Analyze project performance
ai-analyze performance

# 2. In Neovim, select slow code sections
# 3. Get optimization suggestions: <leader>aco

# 4. Benchmark improvements
```

### **4. Documentation Generation**
```bash
# 1. Select function/class in Neovim (visual mode)
# 2. Generate documentation: <leader>acc

# 3. For project-wide docs:
ai-analyze documentation
```

## 🛡️ **Security Best Practices**

### **For Corporate/Work Environments**
```bash
# 1. Enable strict security
ai-security-strict

# 2. Verify settings
ai-security-status

# 3. Use with caution
# - Only use on non-sensitive code
# - Consider local LLMs (Ollama, LM Studio)
# - Check company policies first
```

### **Sensitive Content Detection**
The system automatically detects and blocks:
- **Files**: `*.key`, `*.env`, `*secret*`, `*password*`, etc.
- **Content**: `password=`, `api_key=`, `private_key`, etc.

### **Safe Usage Guidelines**
1. **Always review** security prompts carefully
2. **Use local LLMs** when possible for sensitive code
3. **Check git diffs** before using `ai-commit` or `ai-review-branch`
4. **Configure team policies** using environment variables

## 🔧 **Configuration & Customization**

### **Environment Variables**
```bash
# Security Configuration
export AI_SECURITY_ENABLED=true
export AI_ALLOW_CODE_SHARING=false  
export AI_ALLOW_GIT_DATA=false
export AI_WARN_ON_SENSITIVE=true

# Performance
export DOTFILES_FAST_MODE=1  # Skip AI init for speed
```

### **Custom AI Prompts in Neovim**
Edit `~/.config/nvim/init.lua`:
```lua
-- Add custom prompts to CodeCompanion
prompt_library = {
  ["Custom Review"] = {
    strategy = "chat",
    description = "Custom code review workflow",
    opts = {
      mapping = "<leader>acx",
      modes = { "v" },
    },
    prompts = {
      {
        role = "system",
        content = "You are a senior code reviewer. Focus on security and performance.",
      },
      {
        role = "user",
        content = function(context)
          return "Review this code for security and performance issues:\n\n" .. context.selection
        end,
      },
    },
  },
}
```

## 📊 **AI Tools Comparison**

| Feature | Claude Code CLI | Gemini CLI | Neovim Integration |
|---------|----------------|------------|-------------------|
| **Code Analysis** | ✅ Excellent | ✅ Good | ✅ Native |
| **Context Awareness** | ✅ Advanced | ✅ Good | ✅ Project-aware |
| **Security Controls** | ✅ Built-in | ✅ Built-in | ✅ Enhanced |
| **Performance** | ⚡ Fast | ⚡ Very Fast | ⚡ Instant |
| **Offline Usage** | ❌ Online only | ❌ Online only | ⚠️ Partial |

## 🆘 **Troubleshooting**

### **AI Functions Not Working**
```bash
# 1. Check CLI tools
which claude gemini

# 2. Test basic functionality  
cc "hello world"

# 3. Check security settings
ai-security-status

# 4. Verify API keys (if using direct API)
echo $ANTHROPIC_API_KEY
```

### **Neovim AI Issues**
```bash
# 1. Check plugin status
nvim +Lazy

# 2. Reinstall AI plugins
nvim +Lazy! sync +qall

# 3. Check health
nvim +checkhealth
```

### **Security Prompts Not Appearing**
```bash
# 1. Check if security is enabled
ai-security-status

# 2. Re-enable if needed
ai-security-enable

# 3. Test with a dummy file
echo "test" > test.txt
explain test.txt  # Should prompt
rm test.txt
```

## 🎯 **Tips for Effective AI Usage**

### **Best Practices**
1. **Be Specific**: Select relevant code, not entire files
2. **Provide Context**: Use context-aware prompts for better results  
3. **Iterate**: Use AI suggestions as starting points
4. **Review**: Always review AI-generated code before using
5. **Learn**: Use AI explanations to improve your understanding

### **Prompt Engineering**
```bash
# Instead of: "Fix this code"
# Use: "Optimize this Python function for better performance and readability"

# Instead of: "What does this do?"  
# Use: "Explain the purpose and implementation of this authentication middleware"
```

### **Workflow Integration**
- **Code Reviews**: Use AI for initial review, then human review
- **Documentation**: Generate drafts with AI, then refine manually
- **Testing**: Let AI suggest test cases, then implement and verify
- **Debugging**: Use AI to understand errors, then implement fixes

## 🚀 **Advanced Features**

### **Multi-Model Comparison**
```bash
ai-compare "Should I use TypeScript or JavaScript for this project?"
# Gets opinions from both Claude and Gemini
```

### **Project-Specific AI Context**
```bash
# AI automatically detects project type and includes relevant files
claude-context "How can I improve the architecture of this application?"
```

### **Integration with Git Workflows**
```bash
# Smart commit messages based on actual changes
git add .
ai-commit

# Pre-push code review
ai-review-branch main
```

Your AI-enhanced development environment is now ready for **enterprise-grade development** with both powerful features and comprehensive security! 🤖🔒

---

**Next Steps:**
- 🎓 Practice with the [Interactive Tutorial](tutorial.md)
- 🔧 Configure [Security Settings](security.md) for your environment
- ⚡ Optimize [Performance](performance.md) for your workflow