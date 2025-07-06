# 🤖 AI-Enhanced Development Workflow Guide

## Quick Reference for Claude Code & Gemini CLI Integration

### 🚀 Shell Aliases
```bash
# Claude Code CLI
cc "question"              # Quick Claude query
ccr file.py               # Code review
ccd file.py               # Generate documentation
cce file.py               # Explain code

# Gemini CLI
gg "question"             # Quick Gemini query
ggr file.py              # Code review
ggd file.py              # Generate documentation
gge file.py              # Explain code
```

### 🔧 Advanced Functions

#### Context-Aware AI
```bash
claude-context "How can I optimize this code?"
# Automatically includes relevant project files based on project type
```

#### Multi-AI Comparison
```bash
ai-compare "Should I use FastAPI or Django for this API?"
# Gets responses from both Claude and Gemini for better decision making
```

#### Project Analysis
```bash
ai-analyze overview      # Project overview and architecture
ai-analyze security      # Security vulnerability scan
ai-analyze performance   # Performance optimization suggestions
ai-analyze documentation # Documentation review and improvements
```

#### Debugging & Error Analysis
```bash
ai-debug "ImportError: No module named 'fastapi'"
ai-debug error.log
python script.py 2>&1 | ai-debug  # Pipe errors directly
```

#### Git Integration
```bash
ai-commit                # Generate commit message from staged changes
ai-review-branch         # Review current branch changes
ai-review-branch feature-x main  # Review specific branch
```

#### Code Quality
```bash
explain file.py          # Explain what code does
ai-refactor file.py      # General refactoring suggestions
ai-refactor file.py performance  # Performance-focused refactoring
ai-refactor file.py readability  # Readability improvements
ai-refactor file.py testing      # Testing strategies
```

### 🎯 Neovim AI Integration

#### Key Bindings (in Neovim)
- `<leader>ac` - Send current file to Claude Code
- `<leader>ag` - Send current file to Gemini
- `<leader>ar` - Claude code review of current file
- `<leader>ad` - Generate documentation with Claude
- `<leader>ae` - Explain selected code (visual mode)
- `<leader>af` - Fix selected code (visual mode)
- `<leader>aq` - Quick Claude question with current file
- `<leader>aQ` - Quick Gemini question with current file

### 🖥️ Tmux AI Workflows

#### Session Management
- `Prefix + A` - Launch AI-assisted development session
  - Window 1: Neovim + Aider + Claude interactive
  - Window 2: Gemini interactive

#### Quick AI Access
- `Prefix + c` - Claude Code interactive session
- `Prefix + G` - Gemini interactive session
- `Prefix + a` - Aider session
- `Prefix + C` - AI code review window
- `Prefix + D` - AI documentation window

### 🏗️ Workflow Examples

#### 1. Starting New Feature Development
```bash
# Switch to project
tm ~/work/my-project

# Launch AI development session
# In tmux: Prefix + A

# Analyze project structure
ai-analyze overview

# Start feature development with AI assistance
# In Neovim: <leader>aq "Help me implement user authentication"
```

#### 2. Code Review Workflow
```bash
# Review your changes before commit
ai-review-branch

# Stage changes
git add .

# Generate AI commit message
ai-commit

# Double-check with multi-AI comparison
ai-compare "Is this implementation following best practices?"
```

#### 3. Debugging Workflow
```bash
# Run code and capture errors
python app.py 2>&1 | ai-debug

# Get explanation of problematic code
explain problematic_function.py

# Get refactoring suggestions
ai-refactor problematic_function.py

# Compare solutions from multiple AIs
ai-compare "How to fix this memory leak issue?"
```

#### 4. Documentation & Content Creation
```bash
# Generate project documentation
ai-analyze documentation

# Create LinkedIn content about your work
linkedin-post "FastAPI microservices architecture"

# Generate API documentation
ccd api_routes.py
```

### 💡 Pro Tips

1. **Use context-aware functions** - `claude-context` is better than plain `claude` for code questions
2. **Multi-AI comparison** - Use `ai-compare` for important architectural decisions
3. **Pipe errors directly** - `command 2>&1 | ai-debug` for instant error analysis
4. **Regular code reviews** - Use `ai-review-branch` before every PR
5. **Auto-commit messages** - `ai-commit` generates better commit messages than manual ones
6. **Project analysis** - Run `ai-analyze security` periodically for security reviews

### 🔄 Integration with Your Existing Workflow

Your current setup now seamlessly integrates:
- **Claude Code CLI** for code analysis and generation
- **Gemini CLI** for alternative perspectives and comparison
- **Aider** for interactive code editing
- **GitHub Copilot** for in-editor suggestions
- **Context-aware prompting** based on your project structure
- **Tmux sessions** optimized for AI-assisted development

### 🎨 Visual Workflow in Tmux

```
┌─────────────────┬─────────────────┐
│                 │                 │
│     Neovim      │   Aider/Claude  │
│   (main code)   │   (AI assist)   │
│                 │                 │
├─────────────────┼─────────────────┤
│                 │                 │
│   Git Status    │  Python REPL    │
│   (version)     │   (testing)     │
│                 │                 │
└─────────────────┴─────────────────┘
```

This setup turns your terminal into an AI-powered development environment optimized for your Python, FastAPI, and React workflows!