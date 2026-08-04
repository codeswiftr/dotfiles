# AI Coding Agents Guide

This dotfiles repository includes integrated support for modern AI-powered coding agents. This guide covers setup, configuration, and best practices.

## Overview

The unified `ai` command provides a single entry point for all supported agents:

```bash
ai              # Launch default agent (claude)
ai claude       # Launch Claude Code
ai aider        # Launch Aider
ai --list       # Show installed agents
ai --help       # Full help
```

## Agent-Safe Shell Mode

Coding agents should use predictable POSIX command names. Start agent shells with
agent-safe mode when possible:

```bash
DOTFILES_MODE=agent zsh
```

FORGE fleet agents also enable this automatically when `FORGE_AGENT_TYPE` is set.
In agent-safe mode:

- `cat`, `less`, `grep`, `find`, `ls`, `man`, `vim`, `vi`, `tmux`, and common
  runtime commands such as `python3`, `pip`, `node`, `npm`, and `npx` keep their
  standard command behavior.
- pagers default to `cat` for command capture (`PAGER`, `GIT_PAGER`,
  `MANPAGER`, `BAT_PAGER`).
- zsh spelling correction prompts are disabled.

Humans can still use explicit modern tools and shortcuts:

```bash
bat file.txt
rg "pattern"
fd "*.py"
ll
```

Human shells may alias standard names such as `cat` to modern tools such as
`bat`. Use underscore-prefixed aliases when you need the native system command:

```bash
_cat file.txt
_grep "pattern" file.txt
_find . -name "*.py"
_ls -la
_tmux list-sessions
```

Use `agent-safe-status` to inspect the active mode and any remaining aliases.

## Restarts: park agents, then resume (tmux)

**Pragmatic default:** one command family under `dot`.

```bash
# Before reboot / OS update
dot restart status                 # what's running (also: bare `dot restart`)
dot restart handoff-nudge          # optional: ask agents to write HANDOFF.md
dot restart prepare                # polite stop + registry + tmux layout save
dot restart prepare --force        # escalate if stuck
dot restart prepare --force --kill # last resort

# After boot
dot restart resume
dot restart resume --best-effort
tmux attach -t <session>
```

Coding agents keep conversation state in their own stores. What dies on reboot is
the **live TUI in a tmux pane**. We only re-open those TUIs with continue flags.

| Keys | Action |
|------|--------|
| `Ctrl-a Q` | same as `dot restart prepare` |
| `Ctrl-a Y` | same as `dot restart resume` |

**Registry:** `~/.local/share/dotfiles/agent-restart/registry.json`

| Agent | Resume command used |
|-------|---------------------|
| claude | `claude --continue --dangerously-skip-permissions` |
| codex | `codex resume --last` |
| cursor-agent | `cursor-agent --continue` |
| opencode / kilo | `… --continue` |
| others | relaunch in cwd (may need manual session pick) |

| Scenario | What to do |
|----------|------------|
| **Planned reboot** | `dot restart prepare` → reboot → `dot restart resume` |
| **Crash / power loss** | Attach tmux (continuum layout); run continue flags in project dirs; no registry unless you prepared |
| **Agent mid-tool-call** | Always `prepare` first; `--force` only if stuck |

Pane scrollback is not restored (memory). Rely on agent session DBs + handoff notes.

Implementation binary: `bin/agent-restart` (also callable directly).

## Agent Launch Wrappers

Use underscore-prefixed wrappers for manual launches. They force `DOTFILES_MODE=agent`,
plain pagers, and predictable command names before starting the agent:

```bash
_claude
_codex
_kimi
_gemini
_pi
_opencode
_cursor
_agent <command> [args...]
```

The unified `ai` launcher also exports agent-safe mode before it executes an
agent.

Run the shell doctor when aliases or inherited profile state look suspicious:

```bash
agent-doctor
```

It reports watched aliases and `FORGE_API_URL` definitions by file and line
without printing secret values.

## Supported Agents

### Claude Code (Primary)

Anthropic's official agentic coding CLI. Best for:
- Complex multi-file refactoring
- Understanding large codebases
- Long-running development tasks

```bash
# Install
brew install claude          # macOS
curl -fsSL https://claude.ai/install.sh | bash  # Linux

# Usage
ai claude                    # or just: c
claude --resume              # Resume last session
claude --continue            # Continue with context
```

**Configuration**: `~/.claude/settings.json`

### Cursor Agent

IDE-integrated AI agent from Cursor. Best for:
- Real-time code completion
- Inline editing
- Project-wide refactoring

```bash
# Install
brew install --cask cursor   # macOS
# Download from cursor.com    # Linux

# Usage
ai cursor                    # or just: cu
cursor agent                 # Agent mode
```

### Aider

Git-aware pair programming tool. Best for:
- Incremental changes with git commits
- Working with specific files
- Conversational coding

```bash
# Install
uv tool install aider-chat
pip install aider-chat

# Usage
ai aider                     # or just: aa
aider src/main.py           # Work on specific files
aider --watch               # Watch mode
aider --model gpt-4-turbo   # Specific model
```

**Configuration**: `~/.aider.conf.yml`

### OpenCode

Open source AI coding agent. Best for:
- Privacy-conscious development
- Self-hosted deployments
- Customization

```bash
# Install
brew install anomalyco/tap/opencode  # macOS
curl -fsSL https://opencode.ai/install | bash

# Usage
ai opencode                  # or just: oc
opencode chat               # Interactive chat
```

**Configuration**: `~/.config/opencode/config.json`

### Amp

Sourcegraph's coding agent. Best for:
- Enterprise codebases
- Code search integration
- Team collaboration

```bash
# Install
curl -fsSL https://ampcode.com/install.sh | bash

# Usage
ai amp
```

### Pi

Terminal-native coding agent. Best for:
- Minimal setup
- SSH environments
- Quick tasks

```bash
# Install
npm i -g @mariozechner/pi-coding-agent

# Usage
ai pi
pi                          # Direct invocation
```

## API Keys Setup

Create `~/.zshrc.local` or `config/zsh/secrets.zsh`:

```bash
# Required for Claude
export ANTHROPIC_API_KEY="sk-ant-..."

# Required for Aider with OpenAI models
export OPENAI_API_KEY="sk-..."

# Optional
export GEMINI_API_KEY="..."
export GITHUB_TOKEN="ghp_..."
```

## Workflow Functions

### ai-project

Launch agent with automatic context detection:

```bash
ai-project              # Uses CLAUDE.md, AGENTS.md, or README.md
ai-project aider        # Specific agent with context
```

### ai-review

Quick code review:

```bash
ai-review               # Review current directory
ai-review src/          # Review specific path
ai-review *.py          # Review specific files
```

### ai-doc

Generate documentation:

```bash
ai-doc src/api.py       # Document specific file
ai-doc                  # Document current directory
```

### ai-explain

Get code explanations:

```bash
ai-explain complex.py   # Explain specific file
```

### ai-status

Check agent health:

```bash
ai-status               # Shows installed agents and API keys
```

## Tmux Integration

The tmux configuration includes an AI tools menu:

```
Ctrl-a A    → AI Tools Menu
            → Claude Interactive
            → Aider Code Assistant
            → AI Code Review
```

## Project Context Files

Create these files in your project root for better AI context:

### CLAUDE.md

```markdown
# Project Context for Claude

## Overview
Brief project description...

## Architecture
Key components...

## Commands
Common development commands...
```

### AGENTS.md

```markdown
# AI Agent Guidelines

## Coding Style
- Follow PEP8 for Python
- Use TypeScript strict mode

## Testing
- All changes need tests
- Run: pytest -v

## Commit Style
- Use conventional commits
```

## Best Practices

1. **Start with Context**: Always provide CLAUDE.md or README.md
2. **Use Git**: Aider works best in git repositories
3. **Specific Files**: Target specific files when possible
4. **Review Changes**: Always review AI-generated code
5. **Iterate**: Use multiple passes for complex changes

## Troubleshooting

### Agent not found

```bash
ai --list               # Check installed agents
```

### API key errors

```bash
ai-status               # Check API key status
echo $ANTHROPIC_API_KEY # Verify key is set
```

### Permission issues

```bash
chmod +x ~/dotfiles/bin/ai
```

## Cross-Platform Notes

### macOS (Tahoe/Ventura)

All agents work natively. Use Homebrew for installation.

### Linux (Arch/Debian)

Most agents available via curl installers or package managers.

```bash
# Arch
paru -S opencode-bin

# Debian/Ubuntu
snap install cursor  # If available
```

## Related Files

- `bin/ai` - Unified launcher
- `config/agents/agents.zsh` - Aliases and functions
- `config/agents/README.md` - Quick reference
- `.zshrc` - Shell integration
