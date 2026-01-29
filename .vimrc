" Minimal vim config - prefer nvim
if has('nvim')
  " Running as nvim, config in ~/.config/nvim
  finish
endif

" Basic vim settings for compatibility
set nocompatible
syntax on
set number
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2

" Enable mouse support in compatible terminals
if has('mouse')
  set mouse=a
endif

" Better search
set incsearch
set hlsearch
set ignorecase
set smartcase

" Better command-line completion
set wildmenu
set wildmode=longest:full,full

" Persistent undo (if available)
if has('persistent_undo')
  set undofile
  set undodir=~/.vim/undo
  if !isdirectory(&undodir)
    call mkdir(&undodir, 'p', 0700)
  endif
endif
