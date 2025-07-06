#!/usr/bin/env bash

# Quick setup script for local testing
# This is a simplified version for immediate use

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Quick Dotfiles Setup${NC}"

# Get current directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing configs
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo -e "${YELLOW}📦 Backing up existing configs...${NC}"
for file in ~/.zshrc ~/.vimrc ~/.tmux.conf ~/.gitconfig ~/.config/nvim; do
    if [[ -e "$file" ]]; then
        cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
    fi
done

# Link configurations
echo -e "${YELLOW}🔗 Linking configurations...${NC}"

# ZSH
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Neovim
mkdir -p "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/.config/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Tmux
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Tmux scripts
mkdir -p "$HOME/.config/tmux/scripts"
ln -sf "$DOTFILES_DIR/.config/tmux/scripts/tmux-sessionizer" "$HOME/.config/tmux/scripts/tmux-sessionizer"
chmod +x "$HOME/.config/tmux/scripts/tmux-sessionizer"

echo -e "${GREEN}✅ Configurations linked!${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Run: source ~/.zshrc"
echo "2. Install missing tools with: ./install.sh"
echo "3. Backup saved to: $BACKUP_DIR"

echo -e "\n${GREEN}🎉 Quick setup complete!${NC}"