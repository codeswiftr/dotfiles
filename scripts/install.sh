#!/bin/bash

# Function to install Oh My Zsh
install_ohmyzsh() {
    echo "Installing Oh My Zsh..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y git zsh
        else
            apt update && apt install -y zsh tmux
        fi
    fi
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    curl -L https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/master/gruvbox.zsh-theme > ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme
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
    cp ~/dotfiles/.vimrc ~/
    vim +'PlugInstall --sync' +qa
}

# Function to clone and setup dotfiles
setup_dotfiles() {
    echo "Cloning and setting up dotfiles..."
    cd ~
    git clone https://github.com/codeswiftr/dotfiles.git
    cd; ln -s -f dotfiles/.tmux.conf
	cd; ln -s -f dotfiles/.vimrc
	cd; ln -s -f dotfiles/.zshrc
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

 

    echo "Setup complete!"
}

main