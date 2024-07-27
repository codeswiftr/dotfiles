After a couple of months of working more with Unix tooling, I am now finally ready to attempt switching to Vim with proper syntax highlighting, smart code completion, and refactoring capabilities. Read on to see what it looks like.

# TL;DR:

oh my zsh + tmux + vim = ❤️ LOVE

## Installation

To set up the environment with all necessary tools and plugins, simply run the following command:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/codeswiftr/dotfiles/master/scripts/install.sh)"
```

## Essentials

The `install.sh` script will automatically install and configure the following essential plugins and tools:

- **vim-plug**: A minimalistic plugin manager
- **scrooloose/nerdtree**: To navigate the file tree
- **junegunn/fzf.vim**: Fuzzy search through the files (and much more)
- **tpope/vim-commentary**: Press `gcc` to comment out a line or `gc` to comment a selection in visual mode
- **liuchengxu/vista.vim**: A "tagbar" that learns from LSP servers
- **sheerun/vim-polyglot**: For syntax highlighting
- **Vimjas/vim-python-pep8-indent**: For proper indenting
- **dense-analysis/ale**: An asynchronous linter plugin. Use it with `flake8` and `pylint`, plus `google/yapf` as a formatter
- **neoclide/coc.nvim**: With `neoclide/coc-python` for IntelliSense code completion


## Key Mappings
- Pane Navigation:
  - sv: Split vertically.
  - sh, sj, sk, sl: Move between splits.
- NERDTree:
  - `<leader>n`: Toggle NERDTree.
  - `<leader>t`: Find current file in NERDTree.
- fzf:
  - `<leader>f`: Open file search.
  - `coc.nvim`:
  - `<TAB>`: Trigger completion.
  - `<S-TAB>`: Navigate completion list.
- General:
  - jk: Exit insert mode.
  - `<leader>I`: Install plugins.
  - `<leader>E`: Edit `.vimrc`.
  - `<leader>R`: Source `.vimrc`.
  - `<leader>w`: Save file.
  - `<leader>wq`: Save and quit.

## tmux Integration
- Pane Switching:
  - C-h, C-j, C-k, C-l: Switch panes.
- Window Navigation:
  - C-h: Previous window.
  - C-l: Next window.
  - Tab: Last active window.


For more details, refer to the [dotfiles repository](https://github.com/codeswiftr/dotfiles).



This update ensures that users are directed to use the `install.sh` script for setting up their environment, which simplifies the process and avoids potential issues with manual installation.

I hope this helps! Let me know if you have any questions.

