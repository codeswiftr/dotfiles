#!/bin/bash

# Function to install Oh My Zsh
install_ohmyzsh() {
    echo "Installing Oh My Zsh..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y git zsh language-pack-en
        else
            apt update && apt install -y git zsh language-pack-en
            update-locale
        fi
    fi
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended && exit
    curl -L https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/master/gruvbox.zsh-theme > ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme
    omz theme set gruvbox
    omz theme use gruvbox
    echo "Oh My Zsh installed!"
}

# Function to install Tmux
install_tmux() {
    echo "Installing Tmux..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then

        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y tmux
        else
            apt update && apt install -y tmux
        fi

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install tmux
        sudo gem install iStats
    fi

    @echo "\n[Installing tpm ..]"
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

# Function to install and configure Vim
install_vim() {
    echo "Installing Vim..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo apt install -y vim
            sudo apt install -y fzf ripgrep
        else
            apt install -y vim
            apt install -y fzf ripgrep
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew upgrade vim
        brew install fzf ripgrep
    fi
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +'PlugInstall --sync' +qa
}

install_node() {
    echo "Installing Node..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y nodejs npm
        else
            apt update && apt install -y nodejs npm
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install node
    fi
}

# Function to clone and setup dotfiles
setup_dotfiles() {
    echo "Cloning and setting up dotfiles..."
    cd ~
    git clone https://github.com/codeswiftr/dotfiles.git
    cd; rm .tmux.conf;  ln -s -f dotfiles/.tmux.conf
    cd; rm .vimrc;  ln -s -f dotfiles/.vimrc
	cd; rm .zshrc; ln -s -f dotfiles/.zshrc
}

# Main installation function
main() {
    echo "Starting setup..."
    

    # Install Oh My Zsh
    install_ohmyzsh

    # Setup dotfiles
    setup_dotfiles

    # Install Tmux
    install_tmux

    # Install and configure Vim
    install_vim

    install_node

    echo "Setup complete!"
}

main
