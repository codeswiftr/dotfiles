# Dotfiles Modernization Plan

## Overview

This document outlines the complete modernization of the dotfiles repository to support:
- macOS Tahoe (Apple Silicon M3+)
- macOS Ventura (Intel 2018)
- Linux (Arch, Debian-based)
- Modern agentic CLI coding tools

## Phase 1: Commit Current Changes

### New Files to Add
- `bin/agent` - Cursor agent symlink
- `bin/cursor` - Cursor shim with fallback
- `bin/kimi`, `bin/kimi-cli` - Kimi CLI tools
- `bin/repomix` - Code bundler for AI context
- `config/zsh/forge.zsh` - FORGE portfolio management
- `config/zsh/secrets.zsh.example` - Secrets template
- `docs/forge.md` - FORGE documentation
- `scripts/tmux/forge-layout.sh` - FORGE tmux layout
- `config/nvim/lazy-lock.json` - Plugin lockfile

### Modified Files to Review
- `.gitconfig` - Add modern git defaults
- `.gitignore` - Add new patterns
- `.zshrc` - Fleet status function
- `config/starship.toml` - FORGE indicator
- `config/tmux/*.conf` - Cross-platform clipboard
- `config/zsh/aliases.zsh` - AI tool aliases
- `config/zsh/environment.zsh` - FORGE_ROOT
- `config/nvim/lua/tiers/*.lua` - Version compatibility

## Phase 2: Consolidate Tmux Configuration

### Current State (5 files)
```
config/tmux/
├── core.conf          # Core settings + copy mode
├── theme.conf         # Catppuccin theme
├── plugins.conf       # TPM plugins
├── tmux.conf          # Complex config
└── tmux-minimal.conf  # Minimal config
```

### Target State (2 files)
```
config/tmux/
├── tmux.conf          # Complete, cross-platform config
└── scripts/           # Helper scripts
```

### Key Requirements
- Cross-platform clipboard (pbcopy/wl-copy/xclip)
- ~20 essential bindings
- Vi-style copy mode
- Mouse support
- Clean theme

## Phase 3: Create Unified AI Agent System

### New Structure
```
config/agents/
├── agents.zsh         # Unified aliases and functions
├── claude.md          # Claude Code context
├── opencode.json      # OpenCode config
└── README.md          # Agent documentation
```

### Unified Launcher (`bin/ai`)
```bash
#!/bin/bash
# Select and launch AI coding agent
```

### Supported Agents
| Agent | Command | Use Case |
|-------|---------|----------|
| Claude Code | `claude`, `c` | Primary agentic coding |
| Cursor Agent | `cursor agent`, `cu` | IDE-integrated agent |
| Aider | `aider`, `aa` | Git-aware pair programming |
| OpenCode | `opencode`, `oc` | Open source agent |
| Amp | `amp` | Sourcegraph's agent |
| Pi | `pi` | Terminal-native agent |

## Phase 4: Cross-Platform Compatibility

### Clipboard Helper (`lib/clipboard.sh`)
```bash
# Unified clipboard interface
clip_copy()  # Copy to system clipboard
clip_paste() # Paste from system clipboard
```

### Platform Detection
- macOS Tahoe/Ventura: Homebrew paths, pbcopy/pbpaste
- Arch Linux: pacman, wl-copy (Wayland) or xclip
- Debian/Ubuntu: apt, xclip

### PATH Configuration
```bash
# Apple Silicon
/opt/homebrew/bin

# Intel Mac
/usr/local/bin

# Linux
/usr/bin, ~/.local/bin
```

## Phase 5: Simplify ZSH Configuration

### Current Files (20+)
```
config/zsh/
├── ai-enhanced.zsh
├── ai.zsh
├── aliases.zsh
├── completions.zsh
├── core.zsh
├── dot-aliases.zsh
├── environment.zsh
├── forge.zsh
├── functions.zsh
├── history-enhanced.zsh
├── ios-swift.zsh
├── optimization.zsh
├── paths.zsh
├── performance.zsh
├── secrets.zsh.example
├── testing.zsh
├── tmux-title.zsh
├── tools-optimized.zsh
├── tools.zsh
└── web-pwa.zsh
```

### Target Files (8 essential)
```
config/zsh/
├── init.zsh           # Main entry, tool init
├── core.zsh           # Shell options, keybindings
├── paths.zsh          # PATH configuration
├── aliases.zsh        # All aliases (merged)
├── functions.zsh      # Core functions
├── agents.zsh         # AI tool integration
├── forge.zsh          # Optional FORGE workflow
└── local.zsh.example  # Machine-specific template
```

## Phase 6: Git Configuration Improvements

### Additions (from Omarchy)
```gitconfig
[diff]
    algorithm = histogram
    colorMoved = plain
    mnemonicPrefix = true

[commit]
    verbose = true

[rerere]
    enabled = true
    autoupdate = true

[branch]
    sort = -committerdate

[tag]
    sort = -version:refname
```

## Phase 7: Installation Profiles

### Profiles
| Profile | Description | Tools |
|---------|-------------|-------|
| `minimal` | Server/container | zsh, starship, eza, bat, fd, rg |
| `standard` | Daily development | + nvim, tmux, mise, git config |
| `ai-dev` | Agentic coding | + claude, cursor, aider, opencode |
| `full` | Everything | + docker, k8s, all AI tools |

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/user/dotfiles/main/install.sh | bash -s -- ai-dev
```

## Implementation Tasks

### Task 1: Stage and Commit New Files
- [ ] Add new bin files
- [ ] Add forge.zsh and docs
- [ ] Add secrets template
- [ ] Commit with proper message

### Task 2: Consolidate Tmux
- [ ] Merge configs into single file
- [ ] Add cross-platform clipboard
- [ ] Remove redundant files
- [ ] Test on macOS and Linux

### Task 3: Create AI Agent System
- [ ] Create bin/ai launcher
- [ ] Create config/agents/agents.zsh
- [ ] Update aliases.zsh
- [ ] Document in README

### Task 4: Improve Git Config
- [ ] Add omarchy-style improvements
- [ ] Keep user config in .gitconfig.local
- [ ] Update template

### Task 5: Simplify ZSH
- [ ] Audit all config files
- [ ] Merge where possible
- [ ] Remove dead code
- [ ] Improve startup time

### Task 6: Update Documentation
- [ ] Update README with agent info
- [ ] Create docs/agents.md
- [ ] Update installation guide

## Success Metrics

- Shell startup < 300ms
- Tmux bindings ≤ 25
- Single command installation
- Cross-platform clipboard working
- All AI agents accessible via unified interface
