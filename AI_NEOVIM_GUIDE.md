# 🤖 AI Coding Agents in Neovim - Complete Guide

## 🚀 **Overview**

Your Neovim setup now includes **cutting-edge AI coding agent integration** with multiple AI providers and sophisticated workflows. This creates a seamless AI-assisted development experience directly within your editor.

## 🧠 **AI Plugins Integrated**

### 1. **CodeCompanion.nvim** - Advanced AI Assistant
- **Multi-provider support**: Claude (Anthropic), Gemini, and more
- **Context-aware assistance**: Understands your code and project
- **Multiple interaction modes**: Chat, inline, and agent modes
- **Custom prompts**: Tailored for specific development tasks

### 2. **Gen.nvim** - AI Code Generation
- **Direct CLI integration**: Works with Claude Code CLI and Gemini CLI
- **Flexible prompting**: Custom generation workflows
- **Split view**: AI responses alongside your code

### 3. **AI-Terminals.nvim** - Terminal Integration
- **Seamless CLI access**: Direct integration with AI terminals
- **Visual selections**: Send code directly to AI
- **Multiple terminals**: Switch between different AI providers

### 4. **NeoAI.nvim** - Smart AI Assistant
- **Git integration**: AI-generated commit messages
- **Text processing**: Smart text improvement and summarization
- **Context injection**: Include surrounding code in prompts

## ⌨️ **Complete Keybinding Reference**

### **Core AI Actions**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>aa` | n,v | Open AI Actions menu |
| `<leader>ac` | n,v | Start AI Chat |
| `<leader>ai` | v | AI Inline assistance |

### **Code Analysis & Review**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>acr` | v | AI Code Review (detailed analysis) |
| `<leader>ace` | v | AI Explain Code (how it works) |
| `<leader>act` | v | AI Generate Tests (unit tests) |
| `<leader>aco` | v | AI Optimize Code (performance) |
| `<leader>acc` | v | AI Add Comments (documentation) |

### **AI Generation**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>ag` | n,v | AI Generate (general) |
| `<leader>agc` | n,v | AI Chat mode |
| `<leader>age` | n,v | AI Enhance Code |
| `<leader>agr` | n,v | AI Review Code |

### **Terminal Integration**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>av` | v | Send visual selection to AI |
| `<leader>al` | n | Send current line to AI |
| `<leader>ab` | n | Send entire buffer to AI |
| `<leader>at` | n | Toggle AI terminal |

### **Smart Workflows**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>awr` | n | AI Review Workflow (Git + AI) |
| `<leader>awt` | n | AI Test Workflow |
| `<leader>awd` | n | AI Documentation Workflow |

### **Direct CLI Access**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>afc` | n | Claude CLI: Send file |
| `<leader>afg` | n | Gemini CLI: Send file |
| `<leader>afr` | n | Claude CLI: Review |
| `<leader>afd` | n | Claude CLI: Document |

### **Context-Aware Prompts**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>aqc` | n | Quick Claude with context |
| `<leader>aqg` | n | Quick Gemini with context |

### **Specialized Actions**
| Shortcut | Mode | Action |
|----------|------|--------|
| `<leader>as` | v | AI Summarize/Fix text |
| `<leader>agm` | n | AI Generate git message |

## 🎯 **Practical Workflows**

### **1. Code Review Workflow**
```vim
1. Stage changes: :Git add .
2. Start review: <leader>awr
3. AI analyzes staged changes
4. Receive detailed feedback
5. Apply suggestions
```

### **2. Test Generation Workflow**
```vim
1. Select function/class: v (visual mode)
2. Generate tests: <leader>act
3. AI creates comprehensive tests
4. Review and integrate
```

### **3. Code Optimization Workflow**
```vim
1. Select code block: v (visual mode)
2. Optimize: <leader>aco
3. AI suggests performance improvements
4. Compare and apply changes
```

### **4. Documentation Workflow**
```vim
1. Position cursor in function: n (normal mode)
2. Generate docs: <leader>awd
3. AI creates comprehensive documentation
4. Review and integrate
```

### **5. Bug Analysis Workflow**
```vim
1. Select problematic code: v (visual mode)
2. Explain code: <leader>ace
3. AI explains potential issues
4. Get suggestions for fixes
```

## 🔧 **Configuration & Setup**

### **Environment Variables**
```bash
# Optional: Set API keys for enhanced features
export ANTHROPIC_API_KEY="your-key-here"
export GEMINI_API_KEY="your-key-here"
```

### **AI Provider Preference**
By default, the configuration uses:
1. **Primary**: Claude (Anthropic) via CLI
2. **Secondary**: Gemini CLI
3. **Fallback**: Direct CLI commands

### **Customizing AI Prompts**
Edit your `~/.config/nvim/init.lua` to add custom prompts:

```lua
prompt_library = {
  ["Custom Prompt"] = {
    strategy = "chat",
    description = "Your custom AI workflow",
    opts = {
      mapping = "<leader>acp",
      modes = { "v" },
    },
    prompts = {
      {
        role = "system",
        content = "Your system prompt here...",
      },
      {
        role = "user", 
        content = function(context)
          return "Your user prompt: " .. context.selection
        end,
      },
    },
  },
}
```

## 🚀 **Advanced Features**

### **Context-Aware AI**
The AI integrations understand:
- **Current file type** (Python, JavaScript, etc.)
- **Project structure** (git repository, package.json, etc.)
- **Selected code** (functions, classes, blocks)
- **Git status** (staged changes, diffs)

### **Multi-Provider Support**
Switch between AI providers seamlessly:
- **Claude Code CLI**: Advanced reasoning and coding
- **Gemini CLI**: Fast responses and broad knowledge
- **Direct API**: When CLI tools aren't available

### **Smart Error Handling**
- **Graceful fallbacks** when AI tools aren't available
- **Clear error messages** with installation instructions
- **Progressive enhancement** (works with or without API keys)

## 📚 **Usage Examples**

### **Example 1: Code Review**
```python
# Select this function and press <leader>acr
def process_data(data):
    result = []
    for item in data:
        if item > 0:
            result.append(item * 2)
    return result
```

**AI Response**: *"This function processes positive numbers by doubling them. Consider: 1) Add type hints, 2) Use list comprehension for better performance, 3) Handle edge cases like empty lists..."*

### **Example 2: Test Generation**
```python
# Select this function and press <leader>act  
def calculate_total(prices, tax_rate=0.1):
    return sum(prices) * (1 + tax_rate)
```

**AI Response**: *Generates comprehensive unit tests including edge cases, error conditions, and normal operations.*

### **Example 3: Code Optimization**
```javascript
// Select this code and press <leader>aco
function findUser(users, id) {
    for (let i = 0; i < users.length; i++) {
        if (users[i].id === id) {
            return users[i];
        }
    }
    return null;
}
```

**AI Response**: *"Consider using Array.find() for better readability and performance: `return users.find(user => user.id === id) || null;`"*

## 🎯 **Tips for Effective AI Usage**

### **Best Practices**
1. **Be Specific**: Select relevant code, not entire files
2. **Provide Context**: Use context-aware prompts for better results
3. **Iterate**: Use AI suggestions as starting points
4. **Review**: Always review AI-generated code before using
5. **Learn**: Use AI explanations to improve your understanding

### **When to Use Each Tool**
- **CodeCompanion**: Complex analysis, detailed explanations
- **Gen.nvim**: Quick code generation and transformation
- **AI-Terminals**: Direct CLI interaction and experimentation
- **NeoAI**: Text processing and git workflows

### **Keyboard Workflow Tips**
```vim
# Quick AI review workflow:
1. vip          # Select paragraph/function
2. <leader>acr  # AI code review
3. <leader>ace  # AI explain (if needed)
4. <leader>aco  # AI optimize (if needed)
```

## 🔍 **Troubleshooting**

### **Common Issues**
1. **"AI not available"**: Install Claude Code CLI or Gemini CLI
2. **No response**: Check internet connection and API keys
3. **Plugin errors**: Ensure all dependencies are installed

### **Verification Commands**
```bash
# Check AI CLI tools
claude --version
gemini --version

# Test Neovim health
nvim +checkhealth

# Verify plugins
nvim +Lazy
```

## 🌟 **Advanced Customization**

### **Custom AI Workflows**
Create your own AI workflows by:
1. Adding custom prompts to `prompt_library`
2. Creating new keybindings
3. Integrating with external tools

### **Integration with Existing Tools**
The AI features integrate seamlessly with:
- **LSP**: AI suggestions complement language servers
- **Git**: AI reviews staged changes
- **Telescope**: AI helps with file exploration
- **Tmux**: AI sessions in terminal multiplexer

## 🎉 **Conclusion**

Your Neovim environment now provides **enterprise-grade AI coding assistance** with:
- ✅ **Multiple AI providers** (Claude, Gemini, more)
- ✅ **Comprehensive workflows** (review, test, optimize, document)
- ✅ **Context-aware assistance** (understands your code)
- ✅ **Seamless integration** (works with existing tools)
- ✅ **Flexible interaction** (chat, inline, terminal)

This creates a **next-generation development environment** where AI becomes your intelligent coding partner! 🚀🤖

---

**Happy AI-assisted coding!** 🎯✨