# 🧭 **Navigation & Productivity Guide**

Master the modern navigation tools that make your development workflow 3-5x faster.

## 🚀 **Overview**

Your environment includes cutting-edge navigation tools:
- **🔍 fzf** - Fuzzy finder for everything
- **🗂️ zoxide** - Smart directory jumping
- **🔭 Telescope** (Neovim) - Advanced file navigation
- **🔥 Smart aliases** - Intuitive shortcuts
- **🎯 Project management** - Seamless project switching

## 📍 **Directory Navigation**

### **Zoxide - Smart Directory Jumping**

**Basic Usage**:
```bash
z <partial-name>    # Jump to most frequent/recent directory
zi                  # Interactive directory selection
z -                 # Go to previous directory
z ..                # Go up one level (enhanced)
```

**Examples**:
```bash
# After visiting /Users/username/projects/my-app multiple times:
z my       # Jumps directly to my-app
z proj     # Jumps to projects directory
z app      # Jumps to my-app (or most relevant app directory)

# Interactive selection when multiple matches:
zi pro     # Shows all directories matching "pro"
```

**Advanced Features**:
```bash
z foo bar      # Jump to directory matching both "foo" and "bar"
z --stats      # Show access statistics
z --help       # Full command reference
```

### **Enhanced Directory Aliases**
```bash
# Quick navigation
..          # cd ..
...         # cd ../..
....        # cd ../../..

# Project shortcuts
proj        # Fuzzy select and jump to project directory
cdp         # cd to current project root (finds git root)

# Common directories (customize these)
home        # cd ~
work        # cd ~/work
code        # cd ~/code
docs        # cd ~/Documents
down        # cd ~/Downloads
```

## 📁 **File Navigation & Management**

### **Modern File Listing**

**eza (Enhanced ls)**:
```bash
ls          # Modern colorized listing
ll          # Detailed list with icons
la          # Show all files including hidden
lr          # Recursive listing
lt          # Tree view
lg          # Git status aware listing
```

**Advanced eza Options**:
```bash
eza --tree --level=2        # Tree view 2 levels deep
eza --long --git --icons    # Detailed view with git status
eza --sort=modified         # Sort by modification time
eza --group-directories-first # Directories first
```

### **File Finding with fzf**

**Basic File Search**:
```bash
<Ctrl-T>    # Find files (fuzzy search)
<Ctrl-R>    # Search command history
<Alt-C>     # Change directory (fuzzy)
```

**Advanced fzf Usage**:
```bash
# Find and edit files
vim $(fzf)              # Select file with fzf, open in vim
code $(fzf)             # Select file with fzf, open in VS Code

# Multi-select files
fzf -m                  # Multi-select mode

# Search with preview
fzf --preview 'bat {}'  # Show file content preview

# Search in specific directory
find ~/projects | fzf   # Search only in projects
```

**Custom fzf Functions**:
```bash
# Find and cd to directory
fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# Find and edit file
fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}
```

## 📂 **Project Management**

### **Project Switching**

**Main Command**:
```bash
proj        # Fuzzy finder for all projects
            # Searches ~/projects, ~/work, ~/code, etc.
```

**Project Session Management**:
```bash
tm <project>    # Create/attach tmux session for project
                # Auto-layouts: editor + terminal + status

ta <session>    # Attach to existing tmux session
ts              # List all tmux sessions
tk <session>    # Kill tmux session
```

**Project Discovery**:
```bash
# Your setup automatically discovers projects in:
~/projects/*
~/work/*
~/code/*
~/dev/*
~/src/*

# Plus any directory with:
.git/           # Git repositories
package.json    # Node.js projects
requirements.txt # Python projects
Cargo.toml      # Rust projects
go.mod          # Go projects
```

### **Smart Project Context**

**Auto-Detection Features**:
```bash
# When you enter a project directory, auto-enables:
- Git aliases and status
- Language-specific tools (Python venv, Node version, etc.)
- Project-specific environment variables
- AI context awareness for that project type
```

**Project Root Navigation**:
```bash
cdp         # cd to project root (finds .git, package.json, etc.)
root        # Same as cdp

# Works from anywhere in project:
# /projects/my-app/src/components/
cdp  # Takes you to /projects/my-app/
```

## 📝 **Neovim Navigation**

### **Telescope - Advanced File Navigation**

**Core Shortcuts**:
```vim
<C-p>           " Find files (respects .gitignore)
<leader>ff      " Find files
<leader>fg      " Live grep (search in files)
<leader>fb      " Browse buffers
<leader>fh      " Help tags
<leader>fr      " Recent files
<leader>fc      " Commands
<leader>fk      " Keymaps
```

**Advanced Telescope**:
```vim
<leader>fw      " Find word under cursor
<leader>fm      " Find marks
<leader>fq      " Find quickfix
<leader>fl      " Find loclist
<leader>ft      " Find tags
<leader>fd      " Find diagnostics

# Git integration
<leader>gb      " Git branches
<leader>gc      " Git commits
<leader>gs      " Git status
<leader>gf      " Git files
```

**Telescope Tips**:
```vim
# In Telescope picker:
<C-n>/<C-p>     " Navigate up/down
<C-u>/<C-d>     " Scroll preview up/down
<C-q>           " Send to quickfix list
<Tab>           " Toggle selection (multi-select)
<C-x>           " Open in horizontal split
<C-v>           " Open in vertical split
<C-t>           " Open in new tab
<Esc>           " Close picker
```

### **Buffer & Window Navigation**

**Buffer Management**:
```vim
<leader>bd      " Delete buffer
<leader>bD      " Delete buffer (force)
<leader>bn      " Next buffer
<leader>bp      " Previous buffer
<leader>bf      " Find buffer (Telescope)
```

**Window Navigation**:
```vim
<C-h>           " Move to left window
<C-j>           " Move to down window
<C-k>           " Move to up window
<C-l>           " Move to right window

<leader>wv      " Vertical split
<leader>wh      " Horizontal split
<leader>wc      " Close window
<leader>wo      " Only window (close others)
```

## 🗑️ **Tmux Navigation**

### **Session Management**

**Session Shortcuts**:
```bash
# Prefix key: Ctrl-A (customized from Ctrl-B)

Prefix + s      # Session selector (fuzzy)
Prefix + $      # Rename session
Prefix + d      # Detach session
Prefix + D      # Choose session to detach

# Command line (outside tmux)
tm new-session  # Create named session
ta session-name # Attach to session
ts              # List sessions
tk session-name # Kill session
```

### **Window Management**

**Window Shortcuts**:
```bash
Prefix + c      # Create new window
Prefix + ,      # Rename window
Prefix + n      # Next window
Prefix + p      # Previous window
Prefix + 1-9    # Switch to window number
Prefix + w      # Window selector (interactive)
Prefix + &      # Kill window
```

### **Pane Management**

**Pane Navigation**:
```bash
Prefix + h      # Move to left pane
Prefix + j      # Move to down pane
Prefix + k      # Move to up pane
Prefix + l      # Move to right pane

Prefix + q      # Show pane numbers
Prefix + q + number  # Switch to pane number

# Splits
Prefix + %      # Vertical split
Prefix + "      # Horizontal split
Prefix + x      # Kill pane
```

**Pane Resizing**:
```bash
Prefix + M-h    # Resize left
Prefix + M-j    # Resize down
Prefix + M-k    # Resize up
Prefix + M-l    # Resize right

Prefix + z      # Zoom/unzoom pane
```

### **Smart Tmux Layouts**

**Development Layouts**:
```bash
tm <project>    # Auto-creates optimal layout:
                # ┌───────────────────────┐
                # │      Neovim Editor      │
                # │    (main code pane)    │
                # ├───────────┐───────────┤
                # │   Terminal  │  Git Status  │
                # │   (shell)   │   (watch)    │
                # └───────────┴───────────┘
```

**AI Development Layout**:
```bash
Prefix + A      # Launch AI-assisted development session
                # ┌───────────┐───────────┐
                # │   Neovim   │  AI Terminal │
                # │  (coding)  │  (Claude)    │
                # ├───────────├───────────┤
                # │ Git Status │  Python REPL │
                # │ (monitor)  │  (testing)   │
                # └───────────┴───────────┘
```

## 🔍 **Search & Text Navigation**

### **ripgrep (rg) - Super Fast Search**

**Basic Usage**:
```bash
rg "search-term"                # Search in current directory
rg "search-term" path/          # Search in specific path
rg -i "search-term"             # Case insensitive
rg -w "word"                    # Word boundaries only
```

**Advanced ripgrep**:
```bash
# File type filtering
rg "function" --type py         # Search only Python files
rg "const" --type js            # Search only JavaScript files
rg "TODO" --type-add 'config:*.{yml,yaml,json}' --type config

# Context and formatting
rg "error" -A 3 -B 3           # Show 3 lines before/after
rg "pattern" --json            # JSON output
rg "pattern" --stats           # Show statistics

# Exclude patterns
rg "search" --glob '!*.log'     # Exclude log files
rg "search" --glob '!node_modules/**'  # Exclude node_modules
```

### **fd - Fast File Finding**

**Basic Usage**:
```bash
fd filename                     # Find files by name
fd -e py                        # Find all Python files
fd -e js -e ts                  # Find JS and TS files
fd -t d "folder"                # Find directories only
```

**Advanced fd**:
```bash
# Size and date filters
fd --size +1m                   # Files larger than 1MB
fd --changed-within 1d          # Files changed within 1 day
fd --changed-before 1w          # Files older than 1 week

# Execute commands
fd -e py -x wc -l {}            # Count lines in all Python files
fd -e js -x prettier --write {} # Format all JS files
```

## ⚡ **Performance Navigation Tips**

### **Shell Navigation Optimization**

**Fast Directory Switching**:
```bash
# Use zoxide instead of cd:
z proj          # Instead of: cd ~/projects/my-project
z doc           # Instead of: cd ~/Documents
zi              # Interactive when unsure

# Combine with other tools:
z proj && ll    # Jump and list
z proj && nvim  # Jump and edit
```

**Efficient File Operations**:
```bash
# Use modern tools:
eza instead of ls
fd instead of find
rg instead of grep
bat instead of cat

# Combine tools:
fd . | fzf | xargs nvim    # Find, select, edit
rg "TODO" | fzf           # Search, select result
```

### **Keyboard Shortcuts Summary**

**Shell (Zsh)**:
```bash
Ctrl-T          # fzf file finder
Ctrl-R          # fzf history search
Alt-C           # fzf directory changer
Ctrl-A          # Beginning of line
Ctrl-E          # End of line
Ctrl-W          # Delete word backward
Ctrl-U          # Delete line backward
```

**Tmux (Prefix: Ctrl-A)**:
```bash
Prefix + c      # New window
Prefix + 1-9    # Switch window
Prefix + h/j/k/l # Navigate panes
Prefix + z      # Zoom pane
Prefix + s      # Session selector
```

**Neovim**:
```vim
<C-p>           " File finder
<leader>fg      " Grep search
<leader>fb      " Buffer browser
gd              " Go to definition
K               " Documentation
<C-h/j/k/l>     " Window navigation
```

## 🎨 **Visual Navigation Aids**

### **Terminal Visual Enhancements**

**Starship Prompt Information**:
- **Git status** - Branch, dirty files, ahead/behind
- **Directory context** - Current path with smart truncation
- **Tool versions** - Python, Node, Go, Rust versions when relevant
- **Performance** - Command duration for slow commands
- **Status indicators** - Success/error status with colors

**eza Icons and Colors**:
- **File type icons** - Instantly recognize file types
- **Git status colors** - Modified, staged, untracked files
- **Permission indicators** - Executable, readable, writable
- **Size and date formatting** - Human-readable sizes and dates

### **Neovim Visual Navigation**

**Telescope Previews**:
- **File content preview** - See content before opening
- **Git diff preview** - Review changes in picker
- **Help preview** - Documentation alongside options

**Status Line Information**:
- **File path** - Current file and project context
- **Git branch** - Current branch and status
- **LSP status** - Language server connection
- **AI status** - AI tool availability

## 📋 **Navigation Workflow Examples**

### **Starting a New Task**
```bash
# 1. Switch to project
proj                    # Fuzzy select project
# or
z myproject

# 2. Create development session
tm myproject           # Optimal tmux layout

# 3. Navigate to relevant files
# In Neovim (auto-opens):
<C-p>                  # Find files
<leader>fg "function"  # Search for specific code

# 4. Open related files
<leader>fb             # Browse recent buffers
gd                     # Go to definition
```

### **Code Investigation Workflow**
```bash
# 1. Search for concept across project
rg "authentication" --type py

# 2. Navigate to relevant file
cd $(dirname $(rg -l "auth" | head -1))
nvim $(rg -l "auth" | head -1)

# 3. Explore related code
# In Neovim:
gd                     # Go to definition
gr                     # Find references
<leader>fg "related"   # Search for related terms
```

### **Multi-File Editing Workflow**
```bash
# 1. Find all files to edit
fd -e py | fzf -m > files_to_edit.txt

# 2. Open all in Neovim
nvim $(cat files_to_edit.txt)

# 3. Navigate between buffers
<leader>fb             # Buffer browser
<leader>bn/<leader>bp  # Next/previous buffer

# 4. Make changes across files
# Use search and replace, AI assistance, etc.
```

## 🎉 **Navigation Mastery**

You now have **world-class navigation capabilities** with:

✅ **Instant Directory Jumping** - zoxide learns your patterns  
✅ **Fuzzy Everything** - fzf for files, history, commands  
✅ **Smart Project Management** - Seamless project switching  
✅ **Advanced File Search** - ripgrep + fd for lightning-fast search  
✅ **Intelligent Tmux** - Layouts that adapt to your workflow  
✅ **Neovim Excellence** - Telescope for advanced code navigation  

**Navigate like a pro and watch your productivity soar!** 🚀

---

**Related Guides**:
- 🚀 [Getting Started](getting-started.md) - Basic navigation setup
- ⚡ [Performance](performance.md) - Optimize navigation speed
- 🤖 [AI Workflows](ai-workflows.md) - AI-assisted navigation
