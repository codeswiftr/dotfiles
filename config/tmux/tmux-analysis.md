# Tmux Configuration Analysis - Critical Issues

## Current Binding Conflicts Identified

### 1. **CRITICAL: `Ctrl-a + c` Conflict**
- **Expected**: `new-window` (standard tmux behavior)
- **Current**: `split-window -h -c "#{pane_current_path}" "claude --interactive"`
- **Impact**: Cannot create new windows normally

### 2. **CRITICAL: `Ctrl-a + d` Conflict**  
- **Expected**: `detach-client` (standard tmux behavior)
- **Current**: `split-window -v -c "#{pane_current_path}" "docker compose up"`
- **Impact**: Cannot detach from sessions normally

### 3. **CRITICAL: Copy/Paste Issues**
- **Copy mode works**: `Ctrl-a + [` enters copy mode
- **Vi copy mode**: `Space` to select, `y` to copy, `Enter` copies
- **Paste**: Should be `Ctrl-a + ]` but not clear if working
- **Mouse copy**: Double-click and mouse drag should work but may be broken

## Current Configuration Complexity

### Binding Count Analysis
- **Total prefix bindings**: 60+ (extremely complex)
- **Expected for tier 1**: 10 essential bindings
- **Problem**: Complex AI/dev bindings overriding basic functionality

### Key Bindings Currently Hijacked by AI/Dev Tools
```
c → claude --interactive (should be new-window)
d → docker compose up (should be detach-client)  
a → aider (conflicts with standard attach)
f → fastapi dev (conflicts with standard find)
g → git status (conflicts with standard goto-pane)
t → pytest-watch (conflicts with standard clock)
```

## Standard Tmux Expectations vs Current State

### Essential Operations (BROKEN)
1. `Ctrl-a + c` → new window ❌ (launches Claude)
2. `Ctrl-a + d` → detach ❌ (launches Docker)
3. Copy/paste workflow ❓ (partially working)

### Working Operations  
1. `Ctrl-a + |` → horizontal split ✅
2. `Ctrl-a + -` → vertical split ✅
3. `Ctrl-a + h/j/k/l` → pane navigation ✅ (from tier1)
4. `Ctrl-a + [` → copy mode ✅

## Copy/Paste Analysis

### Current Copy Mode Bindings
- **Enter copy mode**: `Ctrl-a + [`
- **Vi-style selection**: `Space` to start, `v` for visual
- **Copy**: `y` or `Enter` 
- **Paste**: `Ctrl-a + ]` (needs verification)
- **Mouse**: Double-click, drag selection should auto-copy

### Potential Copy Issues
1. Missing `]` paste binding in prefix table
2. Copy command may not integrate with system clipboard
3. Mouse integration might be broken

## Recommendations for Streamlining

### Priority 1: Restore Essential Functions
1. **Fix `c` binding**: Remove Claude binding, restore `new-window`
2. **Fix `d` binding**: Remove Docker binding, restore `detach-client`
3. **Verify paste**: Ensure `Ctrl-a + ]` works for paste
4. **Test mouse copy**: Verify mouse selection copies to system clipboard

### Priority 2: Simplify Configuration
1. **Move AI tools to different keys**: Use `Ctrl-a + A` for AI menu instead
2. **Create tool launcher**: Single key opens tool selection menu
3. **Preserve only essential bindings**: Max 15 prefix bindings total

### Priority 3: Fix Copy/Paste Workflow
1. **System clipboard integration**: Ensure copy goes to system clipboard
2. **Mouse support verification**: Test mouse drag to copy
3. **Paste key binding**: Verify `Ctrl-a + ]` paste works

## Suggested Streamlined Layout

### Core Functions (10 bindings)
```
c → new-window (FIXED)
d → detach-client (FIXED) 
x → kill-pane
| → split horizontal
- → split vertical
h/j/k/l → navigate panes
s → session picker
r → reload config
? → help
```

### Tool Access (5 bindings max)
```
A → AI tools menu (claude, aider, gemini)
D → Dev tools menu (docker, fastapi, etc)
T → Testing menu (pytest, playwright, etc)
G → Git tools menu
M → Monitoring tools (htop, etc)
```

### Copy/Paste (3 bindings)
```
[ → enter copy mode
] → paste from buffer  
C-c → copy to system clipboard (in copy mode)
```