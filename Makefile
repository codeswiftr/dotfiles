

help:
	@echo "\N[DOCKER]"
	@echo "install-docker-ubuntu - installs docker and docker-compose on Ubuntu"
	@echo "install-docker-osx - installs homebrew (you can skip this at runtime), docker and docker-compose on OSX"

	@echo "\n[CLEAN]"
	@echo "clean - remove all build, test, coverage and Python artifacts"
	@echo "clean-docker - stop docker containers and remove orphaned images and volumes"
	@echo "clean-py - remove test, coverage and Python file artifacts"

	@echo "\n[Vim-IDE] -> oh my zsh + tmux + vim = LOVE"
	@echo "install - install vim and tmux and clone the dotfiles repository"

install-docker-ubuntu:
	sudo apt-get remove docker docker-engine docker.io containerd runc
	sudo apt-get update
	sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt-key fingerprint 0EBFCD88
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(shell lsb_release -cs) stable" || { echo "$(shell lsb_release -cs) is not yet supported by docker.com."; exit 1; }
	sudo apt-get update
	sudo apt-get install -y docker-ce gettext
	sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(shell uname -s)-$(shell uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

install-docker-osx:
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew update
	brew cask install docker
	brew install docker-compose gettext

clean: clean-docker clean-py

clean-docker:
	docker-compose down -t 60
	docker system prune -f

clean-py:
	find . -name '*.pyc' -delete
	find . -name '*.pyo' -delete
	find . -name '.coverage' -delete

vim:
	@echo "\n [Upgrading vim] ..."
	brew upgrade vim
	@echo "install fzf and ripgrep"
	brew install fzf ripgrep
	@echo "\n[Installing vim-plug -> a minimalist plugin manager]"
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

	@echo "\n[Downloading default .vimrc file for python dev]"
	curl -fLo ~/.vimrc --create-dirs \
    https://raw.githubusercontent.com/codeswiftr/.make-env/master/.vimrc
	@echo "\n[Done] -> Installing plugins.."
	vim +'PlugInstall --sync' +qa	

ohmyzsh:
	@echo "\n[Installing oh-my-zsh]"
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	curl -L https://raw.githubusercontent.com/sbugzu/gruvbox-zsh/master/gruvbox.zsh-theme > ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme

tmux:
	@echo "\n[Installing tmux ..]"
	brew install tmux


install-fonts:
	@echo "\n[Installing nerd font ..]"
	brew tap homebrew/cask-fonts
	brew cask install font-hack-nerd-font

clone:
	@echo "\n[Cloning dotfiles repo ..]"
	cd; git clone https://github.com/codeswiftr/dotfiles.git

links:
	@echo "\n[Creating sym links ..]"
	ln -s -f dotfiles/.tmux.conf
	ln -s -f dotfiles/.vimrc
	ln -s -f dotfiles/.zshrc

install: clone links install-fonts vim tmux ohmyzsh
