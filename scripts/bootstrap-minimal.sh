#!/bin/sh
# =============================================================================
# Minimal bootstrap — works on any POSIX system in under 60 seconds
# Installs: git, mise, essential dotfiles symlinks
# Does NOT require: zsh, Python, sudo (detects and adapts)
# =============================================================================
set -e

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/$(git config --global user.name 2>/dev/null || echo 'bogdanmosescu')/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
MISE_VERSION="${MISE_VERSION:-v2025.4.0}"  # pin for reproducibility

# ---- Logging ----------------------------------------------------------------
info()  { printf '\033[0;34m[info]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[0;32m[ok]\033[0m    %s\n' "$*"; }
warn()  { printf '\033[0;33m[warn]\033[0m  %s\n' "$*"; }
die()   { printf '\033[0;31m[fail]\033[0m  %s\n' "$*" >&2; exit 1; }

# ---- Detect OS + package manager -------------------------------------------
detect_pm() {
    if command -v apk     >/dev/null 2>&1; then echo "apk";     return; fi
    if command -v apt-get >/dev/null 2>&1; then echo "apt";     return; fi
    if command -v dnf     >/dev/null 2>&1; then echo "dnf";     return; fi
    if command -v pacman  >/dev/null 2>&1; then echo "pacman";  return; fi
    if command -v brew    >/dev/null 2>&1; then echo "brew";    return; fi
    echo "unknown"
}

install_pkg() {
    local pkg="$1"
    case "$(detect_pm)" in
        apk)    apk add --no-cache "$pkg" ;;
        apt)    sudo apt-get install -y -q "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        pacman) sudo pacman -S --noconfirm "$pkg" ;;
        brew)   brew install "$pkg" ;;
        *)      warn "Unknown package manager; cannot install $pkg" ;;
    esac
}

# Alpine musl detection
if [ -f /etc/alpine-release ]; then
    export MISE_LIBC=musl
fi

# ---- Ensure git is available ------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
    info "Installing git..."
    install_pkg git
fi

# ---- Clone dotfiles ---------------------------------------------------------
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    info "Cloning dotfiles from $DOTFILES_REPO..."
    git clone --depth=1 "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    info "Dotfiles already cloned at $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only origin main 2>/dev/null || true
fi

# ---- Install mise (pinned version) ------------------------------------------
if ! command -v mise >/dev/null 2>&1; then
    info "Installing mise $MISE_VERSION..."
    curl -fsSL "https://mise.run" | MISE_VERSION="$MISE_VERSION" sh
    export PATH="$HOME/.local/bin:$PATH"
else
    ok "mise already installed: $(mise --version)"
fi

# ---- Activate mise and install pinned tools ---------------------------------
if command -v mise >/dev/null 2>&1; then
    info "Installing mise-managed tools..."
    cp "$DOTFILES_DIR/mise.toml" "$HOME/.config/mise/config.toml" 2>/dev/null || true
    eval "$(mise activate sh)" 2>/dev/null || export PATH="$HOME/.local/share/mise/shims:$PATH"
    mise install --quiet 2>/dev/null || warn "Some mise tools failed to install"
    ok "mise tools installed"
fi

# ---- Minimal symlinks -------------------------------------------------------
info "Linking minimal config files..."
mkdir -p "$HOME/.config"

link_if_missing() {
    local src="$1" dst="$2"
    if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
        ln -sf "$src" "$dst"
        ok "Linked $dst"
    else
        info "Already exists: $dst"
    fi
}

link_if_missing "$DOTFILES_DIR/config/tmux/tmux.conf"    "$HOME/.tmux.conf"
link_if_missing "$DOTFILES_DIR/config/nvim"              "$HOME/.config/nvim"

# .zshrc: only link if zsh is available
if command -v zsh >/dev/null 2>&1; then
    link_if_missing "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
fi

# ---- Done -------------------------------------------------------------------
ok "Minimal bootstrap complete!"
echo ""
echo "  Next steps:"
echo "  1. Copy .env.local.example to ~/.env.local and fill in secrets"
echo "  2. Run: dot setup    (full install)"
echo "  3. Or:  source ~/.zshrc"
echo ""
