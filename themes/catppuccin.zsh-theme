# ============================================================================
# Catppuccin ZSH Theme - Modern 2025 Edition
# Based on the popular Catppuccin color scheme
# ============================================================================

# Catppuccin Mocha color palette
local rosewater="#f5e0dc"
local flamingo="#f2cdcd"
local pink="#f5c2e7"
local mauve="#cba6f7"
local red="#f38ba8"
local maroon="#eba0ac"
local peach="#fab387"
local yellow="#f9e2af"
local green="#a6e3a1"
local teal="#94e2d5"
local sky="#89dceb"
local sapphire="#74c7ec"
local blue="#89b4fa"
local lavender="#b4befe"
local text="#cdd6f4"
local subtext1="#bac2de"
local subtext0="#a6adc8"
local overlay2="#9399b2"
local overlay1="#7f849c"
local overlay0="#6c7086"
local surface2="#585b70"
local surface1="#45475a"
local surface0="#313244"
local base="#1e1e2e"
local mantle="#181825"
local crust="#11111b"

# Current state tracking
CURRENT_BG='NONE'

# Powerline characters
() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0' # 
}

# Begin a segment
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# OS icon context
prompt_context() {
  case "$OSTYPE" in
    darwin*)  OS_LOGO="󰀵" ;; # Apple logo
    linux*)   OS_LOGO="󰌽" ;; # Linux logo
    *)        OS_LOGO="󰟀" ;; # Generic computer
  esac
  prompt_segment "$surface1" "$lavender" "$OS_LOGO"
}

# Current directory with modern icons
prompt_dir() {
  local dir_icon="󰉋"
  local current_dir="${PWD/#$HOME/~}"
  
  # Truncate if too long
  if [[ ${#current_dir} -gt 40 ]]; then
    current_dir="...${current_dir: -37}"
  fi
  
  prompt_segment "$sapphire" "$base" "$dir_icon $current_dir"
}

# Git status with modern styling
prompt_git() {
  (( $+commands[git] )) || return
  
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local repo_path=$(git rev-parse --git-dir 2>/dev/null)
    local ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="󰊢 $(git rev-parse --short HEAD 2> /dev/null)"
    local branch_name="${ref#refs/heads/}"
    
    # Git status checks
    local git_status=""
    local status_color="$green"
    
    # Check for various git states
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
      status_color="$yellow"
      
      # Count different types of changes
      local modified=$(git status --porcelain 2>/dev/null | grep -c '^.M')
      local staged=$(git status --porcelain 2>/dev/null | grep -c '^[AM]')
      local untracked=$(git status --porcelain 2>/dev/null | grep -c '^??')
      
      [[ $modified -gt 0 ]] && git_status+=" 󰷬$modified"
      [[ $staged -gt 0 ]] && git_status+=" 󰐗$staged"
      [[ $untracked -gt 0 ]] && git_status+=" 󰋗$untracked"
    fi
    
    # Check for ahead/behind
    local ahead_behind=""
    local upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [[ -n $upstream ]]; then
      local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
      local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)
      
      [[ $ahead -gt 0 ]] && ahead_behind+=" 󰶣$ahead"
      [[ $behind -gt 0 ]] && ahead_behind+=" 󰶡$behind"
    fi
    
    prompt_segment "$status_color" "$base" "󰊢 $branch_name$git_status$ahead_behind"
  fi
}

# Python virtual environment
prompt_virtualenv() {
  if [[ -n $VIRTUAL_ENV && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    local venv_name=$(basename $VIRTUAL_ENV)
    prompt_segment "$green" "$base" "󰌠 $venv_name"
  fi
}

# Node.js version (if in a JS project)
prompt_node() {
  if [[ -f package.json ]] && command -v node >/dev/null 2>&1; then
    local node_version=$(node --version 2>/dev/null | sed 's/v//')
    prompt_segment "$green" "$base" "󰎙 $node_version"
  fi
}

# Status indicators
prompt_status() {
  local symbols=()
  
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$red}%}󰅙"
  [[ $UID -eq 0 ]] && symbols+="%{%F{$yellow}%}󰯄"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$blue}%}󰜎"
  
  [[ -n "$symbols" ]] && prompt_segment "$surface0" "$text" "${(j: :)symbols}"
}

# Command execution time
prompt_cmd_time() {
  if [[ -n $cmd_exec_time ]] && [[ $cmd_exec_time -ge 2 ]]; then
    local time_display=""
    if [[ $cmd_exec_time -ge 60 ]]; then
      local minutes=$((cmd_exec_time / 60))
      local seconds=$((cmd_exec_time % 60))
      time_display="${minutes}m${seconds}s"
    else
      time_display="${cmd_exec_time}s"
    fi
    prompt_segment "$peach" "$base" "󰔛 $time_display"
  fi
}

# Main prompt builder
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_virtualenv
  prompt_node
  prompt_cmd_time
  prompt_end
}

# Right prompt with additional info
build_rprompt() {
  local time_str="%{%F{$overlay1}%}%T%{%f%}"
  echo -n "$time_str"
}

# Command execution time tracking
preexec() {
  cmd_start_time=$SECONDS
}

precmd() {
  if [[ -n $cmd_start_time ]]; then
    cmd_exec_time=$((SECONDS - cmd_start_time))
    unset cmd_start_time
  else
    unset cmd_exec_time
  fi
}

# Set prompts
PROMPT='%{%f%b%k%}$(build_prompt) '
RPROMPT='$(build_rprompt)'

# Enable prompt substitution
setopt PROMPT_SUBST