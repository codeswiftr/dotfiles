#!/usr/bin/env bash
# =============================================================================
# Dotfiles installer — thin orchestrator (Phase 2)
# Platform pkgs: config/platform/{Brewfile,apt.txt,pacman.txt}
# Pinned CLIs:   mise.toml
# $HOME state:   chezmoi (home/) — required, no fallback linker
# =============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
PLATFORM_DIR="$DOTFILES_DIR/config/platform"
LOG_FILE="${LOG_FILE:-$HOME/dotfiles-install.log}"

PROFILE="standard"
PROFILE_EXPLICIT=false
COMMAND=""
DRY_RUN=false
VERBOSE=false
HEADLESS=false
NO_SUDO=false
SUDO_CMD="sudo"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$LOG_FILE"; }
print_header() { echo -e "\n${BLUE}================================${NC}\n${BLUE}$1${NC}\n${BLUE}================================${NC}"; }
print_info() { echo -e "${CYAN}ℹ️  $1${NC}"; log "INFO: $1"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; log "OK: $1"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; log "WARN: $1"; }
print_error() { echo -e "${RED}❌ $1${NC}" >&2; log "ERR: $1"; }
print_step() { echo -e "${BLUE}⚙️  $1${NC}"; log "STEP: $1"; }
run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    print_info "DRY RUN: $*"
    return 0
  fi
  "$@"
}

detect_os() {
  case "$(uname -s)" in
    Darwin*) echo macos ;;
    Linux*)
      if [[ -f /etc/alpine-release ]]; then echo alpine
      elif [[ -f /etc/arch-release ]]; then echo arch
      elif [[ -f /etc/debian_version ]]; then echo ubuntu
      else echo linux
      fi
      ;;
    *) echo unknown ;;
  esac
}

normalize_profile() {
  case "$PROFILE" in
    full|ai_focused)
      print_warning "Profile '$PROFILE' retired — using 'standard'"
      PROFILE=standard
      ;;
    minimal|standard) ;;
    *)
      print_error "Unknown profile: '$PROFILE' (minimal|standard)"
      exit 1
      ;;
  esac
}

setup_paths() {
  export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

setup_sudo() {
  local os="$1"
  [[ "$os" == "macos" || "$NO_SUDO" == "true" || "$DRY_RUN" == "true" ]] && { SUDO_CMD=""; return 0; }
  if [[ "${EUID:-1}" -eq 0 ]]; then SUDO_CMD=""; return 0; fi
  if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    SUDO_CMD="sudo"
  elif command -v sudo >/dev/null 2>&1; then
    print_info "Requesting sudo for package installs..."
    sudo -v || { print_error "sudo required (or pass --no-sudo)"; return 1; }
    SUDO_CMD="sudo"
  else
    print_warning "No sudo — user-space installs only"
    NO_SUDO=true
    SUDO_CMD=""
  fi
}

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then return 0; fi
  print_step "Installing Homebrew..."
  if [[ "$DRY_RUN" == "true" ]]; then print_info "DRY RUN: Would install Homebrew"; return 0; fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  setup_paths
}

ensure_xcode_cli() {
  xcode-select -p &>/dev/null && return 0
  print_step "Installing Xcode Command Line Tools..."
  [[ "$DRY_RUN" == "true" ]] && { print_info "DRY RUN: Would install Xcode CLI"; return 0; }
  xcode-select --install 2>/dev/null || true
  local elapsed=0
  while ! xcode-select -p &>/dev/null && [[ $elapsed -lt 300 ]]; do
    sleep 5; ((elapsed+=5)) || true
  done
  xcode-select -p &>/dev/null || { print_error "Xcode CLI tools missing"; return 1; }
}

install_platform() {
  local os="$1"
  print_header "Platform packages ($os)"
  case "$os" in
    macos)
      ensure_xcode_cli || return 1
      ensure_brew || return 1
      print_step "brew bundle..."
      run brew bundle --file="$PLATFORM_DIR/Brewfile"
      ;;
    ubuntu)
      if [[ "$NO_SUDO" != "true" ]]; then
        print_step "apt update + install..."
        run $SUDO_CMD apt-get update -qq
        # shellcheck disable=SC2046
        run $SUDO_CMD env DEBIAN_FRONTEND=noninteractive apt-get install -y \
          $(grep -vE '^\s*(#|$)' "$PLATFORM_DIR/apt.txt")
      else
        print_warning "Skipping apt (--no-sudo)"
      fi
      ;;
    arch)
      if [[ "$NO_SUDO" != "true" ]]; then
        print_step "pacman install..."
        # shellcheck disable=SC2046
        run $SUDO_CMD pacman -S --noconfirm --needed \
          $(grep -vE '^\s*(#|$)' "$PLATFORM_DIR/pacman.txt")
      else
        print_warning "Skipping pacman (--no-sudo)"
      fi
      ;;
    alpine)
      print_step "apk essentials..."
      run $SUDO_CMD apk add --no-cache zsh git curl wget neovim mosh bash
      ;;
    *)
      print_warning "Unknown OS '$os' — skipping platform packages"
      ;;
  esac
}

ensure_mise() {
  print_header "mise (pinned CLIs)"
  [[ -f /etc/alpine-release ]] && export MISE_LIBC=musl
  if ! command -v mise >/dev/null 2>&1; then
    print_step "Installing mise..."
    if [[ "$DRY_RUN" == "true" ]]; then
      print_info "DRY RUN: Would install mise"
      return 0
    fi
    if [[ "$(detect_os)" == "macos" ]] && command -v brew >/dev/null 2>&1; then
      brew install mise || curl -fsSL https://mise.run | sh
    else
      curl -fsSL https://mise.run | sh
    fi
    setup_paths
  fi
  command -v mise >/dev/null 2>&1 || { print_warning "mise missing"; return 0; }
  eval "$(mise activate bash 2>/dev/null)" 2>/dev/null || \
    export PATH="$HOME/.local/share/mise/shims:$PATH"
  local src="$DOTFILES_DIR/mise.toml" dst="$HOME/.config/mise/config.toml"
  [[ -f "$src" ]] || return 0
  if [[ "$DRY_RUN" == "true" ]]; then
    print_info "DRY RUN: Would sync mise.toml and run mise install"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  mise trust "$src" >/dev/null 2>&1 || true
  cp "$src" "$dst"
  mise trust "$dst" >/dev/null 2>&1 || true
  print_step "mise install..."
  mise install --quiet 2>/dev/null && print_success "mise tools installed" || \
    print_warning "Some mise tools failed — run: mise install"
}

ensure_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then return 0; fi
  print_step "Installing chezmoi..."
  if [[ "$DRY_RUN" == "true" ]]; then print_info "DRY RUN: Would install chezmoi"; return 0; fi
  if [[ "$(detect_os)" == "macos" ]] && command -v brew >/dev/null 2>&1; then
    brew install chezmoi
  else
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
  fi
  command -v chezmoi >/dev/null 2>&1 || {
    print_error "chezmoi is required (no fallback linker)"
    return 1
  }
}

ensure_herdr() {
  command -v herdr >/dev/null 2>&1 && return 0
  print_step "Installing herdr..."
  run bash "$DOTFILES_DIR/scripts/install-herdr.sh"
}

ensure_neovim_linux() {
  [[ "$(detect_os)" == "macos" ]] && return 0
  command -v nvim >/dev/null 2>&1 && return 0
  print_step "Installing neovim (Linux tarball)..."
  [[ "$DRY_RUN" == "true" ]] && { print_info "DRY RUN: Would install neovim"; return 0; }
  local arch asset url tmp
  case "$(uname -m)" in
    x86_64|amd64) asset="nvim-linux-x86_64.tar.gz" ;;
    aarch64|arm64) asset="nvim-linux-arm64.tar.gz" ;;
    *) print_warning "No neovim tarball for $(uname -m)"; return 0 ;;
  esac
  url="https://github.com/neovim/neovim/releases/latest/download/$asset"
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/nvim.tar.gz"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  mkdir -p "$HOME/.local"
  rm -rf "$HOME/.local/nvim"
  mv "$tmp"/nvim-* "$HOME/.local/nvim"
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"
  print_success "neovim → ~/.local/bin/nvim"
}

ensure_uv_bun_linux() {
  [[ "$(detect_os)" == "macos" ]] && return 0
  if ! command -v uv >/dev/null 2>&1; then
    print_step "Installing uv..."
    run bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    setup_paths
  fi
  if ! command -v bun >/dev/null 2>&1; then
    print_step "Installing bun..."
    run bash -c 'curl -fsSL https://bun.sh/install | bash'
    setup_paths
  fi
}

install_networking() {
  print_header "Networking (Tailscale + Mosh)"
  if ! command -v tailscale >/dev/null 2>&1; then
    print_step "Installing Tailscale..."
    case "$(detect_os)" in
      macos) run brew install tailscale ;;
      ubuntu|linux)
        [[ "$DRY_RUN" == "true" ]] && print_info "DRY RUN: Would install Tailscale" || \
          curl -fsSL https://tailscale.com/install.sh | sh
        ;;
      arch) run $SUDO_CMD pacman -S --noconfirm --needed tailscale ;;
      *) print_warning "Install Tailscale manually for this OS" ;;
    esac
  fi
  run bash "$DOTFILES_DIR/scripts/install-mosh.sh" || print_warning "mosh install had issues"
}

install_deployment() {
  print_header "Deployment CLIs"
  if ! command -v railway >/dev/null 2>&1; then
    case "$(detect_os)" in
      macos) run brew install railway ;;
      *)
        [[ "$DRY_RUN" == "true" ]] && print_info "DRY RUN: Would install railway" || \
          bash -c 'curl -fsSL https://railway.com/install.sh | sh' || true
        ;;
    esac
  fi
  if ! command -v wrangler >/dev/null 2>&1; then
    if command -v bun >/dev/null 2>&1; then
      run bun add -g wrangler || true
    elif command -v npm >/dev/null 2>&1; then
      run npm install -g wrangler || true
    fi
  fi
}

install_ai_tools() {
  print_header "Daily AI agents"
  local os; os="$(detect_os)"
  # Claude
  if ! command -v claude >/dev/null 2>&1; then
    if [[ "$os" == "macos" ]]; then
      run brew install --cask claude-code || true
    else
      [[ "$DRY_RUN" == "true" ]] && print_info "DRY RUN: Would install Claude Code" || \
        curl -fsSL https://claude.ai/install.sh | bash || true
    fi
  fi
  # Cursor agent
  if ! command -v agent >/dev/null 2>&1 && [[ ! -d "$HOME/.cursor-agent" ]]; then
    [[ "$DRY_RUN" == "true" ]] && print_info "DRY RUN: Would install Cursor CLI" || \
      curl https://cursor.com/install -fsS | bash || true
  fi
  # OpenCode
  if ! command -v opencode >/dev/null 2>&1; then
    if [[ "$os" == "macos" ]]; then
      run brew install anomalyco/tap/opencode || true
    else
      [[ "$DRY_RUN" == "true" ]] && print_info "DRY RUN: Would install OpenCode" || \
        curl -fsSL https://opencode.ai/install | bash || true
    fi
  fi
  # Codex
  if ! command -v codex >/dev/null 2>&1; then
    if [[ "$os" == "macos" ]]; then
      run brew install --cask codex || true
    elif command -v npm >/dev/null 2>&1; then
      run npm install -g @openai/codex || true
    fi
  fi
  # Pi
  if ! command -v pi >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    run npm install -g @mariozechner/pi-coding-agent || true
  fi
  # Kimi
  if ! command -v kimi >/dev/null 2>&1 && command -v uv >/dev/null 2>&1; then
    run uv tool install kimi-cli || true
  fi
}

link_dotfiles() {
  print_header "Applying dotfiles (chezmoi)"
  ensure_chezmoi || return 1
  local src="$DOTFILES_DIR/home"
  if [[ "$DRY_RUN" == "true" ]]; then
    print_info "DRY RUN: Would apply chezmoi from $src"
    chezmoi --source "$src" managed 2>/dev/null | while read -r f; do
      print_info "  would manage: $f"
    done || print_info "DRY RUN: chezmoi managed list unavailable"
    print_success "Dry run completed"
    return 0
  fi
  if chezmoi --source "$src" apply --force; then
    print_success "Dotfiles applied via chezmoi"
  else
    print_error "chezmoi apply failed"
    return 1
  fi
}

show_profiles() {
  print_header "Installation profiles"
  echo -e "${BLUE}minimal${NC}"
  echo -e "  ${CYAN}Headless / servers — platform essentials + mise + chezmoi${NC}"
  echo ""
  echo -e "${BLUE}standard${NC}"
  echo -e "  ${CYAN}Default — + Tailscale/Mosh, deploy CLIs, daily AI agents${NC}"
  echo ""
}

show_help() {
  cat <<EOF
Dotfiles installer (mise + platform manifests + chezmoi)

USAGE:
    $0 [OPTIONS] [COMMAND]

COMMANDS:
    install [PROFILE]   Install (default: standard)
    link                Apply chezmoi only
    profiles            List profiles
    verify              Run scripts/check.sh

OPTIONS:
    -p, --profile NAME  minimal | standard
    -d, --dry-run       Preview actions
    --headless, --yes   Non-interactive
    --no-sudo           User-space only
    -h, --help          Help

EXAMPLES:
    $0                          # install standard
    $0 install minimal
    $0 --dry-run install standard
    $0 link

Platform:  config/platform/{Brewfile,apt.txt,pacman.txt}
CLIs:      mise.toml
Home:      chezmoi (home/)
EOF
}

install_profile() {
  local profile="$1" os
  os="$(detect_os)"
  normalize_profile
  profile="$PROFILE"

  print_header "Installing profile: $profile"
  print_info "OS: $os"

  setup_paths
  install_platform "$os" || print_warning "Platform packages had issues"
  ensure_mise
  ensure_chezmoi || return 1
  ensure_herdr || print_warning "herdr install had issues"
  ensure_neovim_linux
  ensure_uv_bun_linux

  if [[ "$profile" == "standard" ]]; then
    install_networking
    install_deployment
    install_ai_tools
  fi

  link_dotfiles || return 1

  if [[ "$DRY_RUN" == "true" ]]; then
    print_success "Dry run completed - no changes made!"
  else
    print_header "Final verification"
    if [[ -x "$DOTFILES_DIR/scripts/check.sh" ]] && \
       "$DOTFILES_DIR/scripts/check.sh" --quiet 2>/dev/null; then
      print_success "Setup completed and verified"
    else
      print_warning "Some checks need attention — run: just check"
    fi
    print_info "Restart your shell or: source ~/.zshrc"
  fi
  print_info "Log: $LOG_FILE"
}

main() {
  if [[ "${DOTFILES_MODE:-}" == "agent" ]]; then
    HEADLESS=true
    export DOTFILES_NONINTERACTIVE=1
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--profile) PROFILE="$2"; PROFILE_EXPLICIT=true; shift 2 ;;
      -d|--dry-run) DRY_RUN=true; shift ;;
      -v|--verbose) VERBOSE=true; shift ;;
      --headless|--yes) HEADLESS=true; export DOTFILES_NONINTERACTIVE=1; shift ;;
      --no-sudo) NO_SUDO=true; SUDO_CMD=""; shift ;;
      -h|--help) show_help; exit 0 ;;
      install)
        COMMAND=install
        if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
          PROFILE="$2"; PROFILE_EXPLICIT=true; shift 2
        else
          shift
        fi
        ;;
      profiles) COMMAND=profiles; shift ;;
      verify) COMMAND=verify; shift ;;
      link) COMMAND=link; shift ;;
      *) print_error "Unknown option: $1"; show_help; exit 1 ;;
    esac
  done

  COMMAND="${COMMAND:-install}"
  touch "$LOG_FILE"
  log "=== start command=$COMMAND profile=$PROFILE dry=$DRY_RUN ==="

  case "$COMMAND" in
    install)
      setup_sudo "$(detect_os)" || true
      install_profile "$PROFILE"
      ;;
    link)
      setup_paths
      link_dotfiles
      ;;
    profiles) show_profiles ;;
    verify)
      exec "$DOTFILES_DIR/scripts/check.sh"
      ;;
    *)
      print_error "Unknown command: $COMMAND"
      exit 1
      ;;
  esac
}

main "$@"
