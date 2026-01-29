# AI Agent Configuration

This directory contains configuration and integration for AI-powered coding agents.

## Supported Agents

| Agent | Command | Description |
|-------|---------|-------------|
| Claude Code | `ai claude` or `c` | Anthropic's agentic coding CLI |
| Cursor Agent | `ai cursor` or `cu` | IDE-integrated AI agent |
| Aider | `ai aider` or `aa` | Git-aware pair programming |
| OpenCode | `ai opencode` or `oc` | Open source AI agent |
| Amp | `ai amp` | Sourcegraph's coding agent |
| Pi | `ai pi` | Terminal-native agent |
| Gemini | `ai gemini` | Google's AI assistant |
| Kimi | `ai kimi` | Moonshot AI assistant |

## Quick Start

```bash
# Launch default agent (claude)
ai

# Launch specific agent
ai aider
ai cursor

# List installed agents
ai --list

# Get help
ai --help
```

## Configuration

### Default Agent

Set your preferred default agent:

```bash
export AI_DEFAULT_AGENT="claude"  # or aider, cursor, etc.
```

### API Keys

Required environment variables (add to `~/.zshrc.local` or `config/zsh/secrets.zsh`):

```bash
# Anthropic (Claude)
export ANTHROPIC_API_KEY="sk-ant-..."

# OpenAI (for Aider with GPT-4)
export OPENAI_API_KEY="sk-..."

# Google (Gemini)
export GEMINI_API_KEY="..."
```

## Aliases

Quick shortcuts defined in `agents.zsh`:

```bash
c       # claude
cu      # cursor agent
aa      # aider
oc      # opencode
```

## Functions

### ai-project

Launch agent with automatic project context detection:

```bash
ai-project claude    # Detects CLAUDE.md, AGENTS.md, README.md
ai-project aider
```

### ai-review

Quick code review:

```bash
ai-review            # Review current directory
ai-review src/       # Review specific path
```

### ai-doc

Generate documentation:

```bash
ai-doc src/main.py
```

### ai-explain

Explain code:

```bash
ai-explain complex_function.py
```

### ai-status

Check agent health and API key status:

```bash
ai-status
```

## Installation

### Claude Code

```bash
# macOS
brew install claude

# Linux
curl -fsSL https://claude.ai/install.sh | bash
```

### Aider

```bash
uv tool install aider-chat
# or
pip install aider-chat
```

### OpenCode

```bash
# macOS
brew install anomalyco/tap/opencode

# Linux
curl -fsSL https://opencode.ai/install | bash
```

### Amp

```bash
curl -fsSL https://ampcode.com/install.sh | bash
```

### Cursor

```bash
# macOS
brew install --cask cursor

# Download from https://cursor.com/download
```

## Files

- `agents.zsh` - Shell aliases and functions
- `README.md` - This documentation

## Tips

1. **Project Context**: Create `CLAUDE.md` or `AGENTS.md` in your project root for agent context
2. **Git Integration**: Aider works best when run from a git repository
3. **Multiple Agents**: Use `ai-compare` to get responses from multiple agents
4. **Tmux Integration**: Use `Ctrl-a A` in tmux for AI tools menu
