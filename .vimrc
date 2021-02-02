" disable compatibility with vi
set nocompatible

" Vim plug - installed plugins 
call plug#begin('~/.vim/plugged')


Plug 'junegunn/vim-easy-align'

Plug 'https://github.com/junegunn/vim-github-dashboard.git'

Plug 'ryanoasis/vim-devicons'

" nerd tree related
Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin' |
            \ Plug 'ryanoasis/vim-devicons'

Plug 'vim-airline/vim-airline'

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

Plug 'scrooloose/syntastic'
Plug 'dbeniamine/cheat.sh-vim'

" color themes
Plug 'tomasiser/vim-code-dark'
Plug 'morhetz/gruvbox'

" the best for the syntax highlighting
Plug 'sheerun/vim-polyglot'

" for prop indentention
Plug 'Vimjas/vim-python-pep8-indent'

" a tagbar that learns from LSP servers
Plug 'liuchengxu/vista.vim'

"  an asynchronous linter plugin
Plug 'dense-analysis/ale'

Plug 'jeetsukumaran/vim-pythonsense'

Plug 'jiangmiao/auto-pairs'

Plug 'davidhalter/jedi-vim'

" Git wrapper support
Plug 'tpope/vim-fugitive'

" Vim Session support
Plug 'tpope/vim-obsession'

" Debugger Plugins
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

Plug 'vim-utils/vim-man'
Plug 'mbbill/undotree'
Plug 'stsewd/fzf-checkout.vim'
Plug 'vuciv/vim-bujo'
Plug 'tpope/vim-dispatch'
Plug 'mhinz/vim-signify'

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'

" shortcut helper
Plug 'liuchengxu/vim-which-key'

" On-demand lazy load
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!']  }


" easier commenting
Plug 'preservim/nerdcommenter'

" Initialize plugin system
call plug#end()
set rnu
set cursorline
set nu
set encoding=UTF-8
set ic

let g:NERDTreeGitStatusUseNerdFonts = 1
"select the color scheme
colorscheme gruvbox
set bg=dark

" toggle tree view
map <C-n> :NERDTreeToggle<CR>

" folding
au BufNewFile,BufRead *.py
    \ set foldmethod=indent
" nnoremap <space> za
nnoremap <SPACE> <Nop>

inoremap jk <esc>

let g:mapleader = "\<Space>"
let g:maplocalleader = ','
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

nnoremap <Leader>- zM
nnoremap <Leader>= zR

"Reveal in drawer
nmap <Leader>t :NERDTreeFind<CR>
nmap <Leader>b :NERDTreeToggle<CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeAutoDeleteBuffer = 1
autocmd StdinReadPre * let s:std
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | :vertical resize 60 | endif
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Make cmds
nmap <F5> :make<CR>

" Update vim
nmap <Leader>I :PlugInstall<CR>
nmap <Leader>E :e ~/.vimrc<CR>
nmap <Leader>R :source ~/.vimrc<CR>
nma <Leader>w :w<CR>
nma <Leader>wq :wq<CR>
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.9  }  }

"PLUGIN: FZF
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <C-p> :GFiles<CR>
nnoremap <silent> <Leader>p :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>
nnoremap <silent> <Leader>/ :BLines<CR>
nnoremap <silent> <Leader>' :Marks<CR>
nnoremap <silent> <Leader>g :Commits<CR>
nnoremap <silent> <Leader>H :Helptags<CR>
nnoremap <silent> <Leader>hh :History<CR>
nnoremap <silent> <Leader>h: :History:<CR>
nnoremap <silent> <Leader>h/ :History/<CR> 

function! s:update_fzf_colors()
    let rules =
                \ { 'fg':      [['Normal',       'fg']],
                \ 'bg':      [['Normal',       'bg']],
                \ 'hl':      [['Comment',      'fg']],
                \ 'fg+':     [['CursorColumn', 'fg'], ['Normal', 'fg']],
                \ 'bg+':     [['CursorColumn', 'bg']],
                \ 'hl+':     [['Statement',    'fg']],
                \ 'info':    [['PreProc',      'fg']],
                \ 'prompt':  [['Conditional',  'fg']],
                \ 'pointer': [['Exception',    'fg']],
                \ 'marker':  [['Keyword',      'fg']],
                \ 'spinner': [['Label',        'fg']],
                \ 'header':  [['Comment',      'fg']] }
    let cols = []
    for [name, pairs] in items(rules)
        for pair in pairs
            let code = synIDattr(synIDtrans(hlID(pair[0])), pair[1])
            if !empty(name) && code > 0
                call add(cols, name.':'.code)
                break
            endif
        endfor
    endfor
    let s:orig_fzf_default_opts = get(s:, 'orig_fzf_default_opts', $FZF_DEFAULT_OPTS)
    let $FZF_DEFAULT_OPTS = s:orig_fzf_default_opts .
                \ empty(cols) ? '' : (' --color='.join(cols, ','))
endfunction

augroup _fzf
    autocmd!
    autocmd ColorScheme * call <sid>update_fzf_colors()
augroup END


" linters

let g:ale_linters = {
      \   'python': ['flake8', 'pylint'],
      \   'javascript': ['eslint'],
      \}

let g:ale_fixers = {
      \    'python': ['yapf'],
      \}
nmap <F10> :ALEFix<CR>
let g:ale_fix_on_save = 1

function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  return l:counts.total == 0 ? '✨ all good ✨' : printf(
        \   '😞 %dW %dE',
        \   all_non_errors,
        \   all_errors
        \)
endfunction

"set statusline=
"set statusline+=%m
"set statusline+=\ %f
"set statusline+=%=
"set statusline+=\ %{LinterStatus()}

set updatetime=50
set colorcolumn=80

" already displayed in the air line
set noshowmode

" disable anoying bells
set noerrorbells

" configure tabs
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nowrap

" undo support
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile

set hlsearch
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
 

if executable('rg')
    let g:rg_derive_root='true'
endif

" FZF customization
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8  }  }
let $FZF_DEFAULT_OPTS='--reverse'

let $FZF_DEFAULT_OPTS='--reverse'
let g:fzf_branch_actions = {
    \ 'rebase': {
      \   'prompt': 'Rebase> ',
      \   'execute': 'echo system("{git} rebase {branch}")',
      \   'multiple': v:false,
      \   'keymap': 'ctrl-r',
      \   'required': ['branch'],
      \   'confirm': v:false,
      \ },
    \ 'track': {
        \   'prompt': 'Track> ',
        \   'execute': 'echo system("{git} checkout --track {branch}")',
        \   'multiple': v:false,
        \   'keymap': 'ctrl-t',
        \   'required': ['branch'],
        \   'confirm': v:false,
        \ },
    \}

"let g:vimspector_enable_mappings = 'HUMAN'
" packadd! vimspector

" Debugger remaps
nnoremap <leader>m :MaximizerToggle!<CR>
nnoremap <leader>dd :call vimspector#Launch()<CR>
nnoremap <leader>dc :call GotoWindow(g:vimspector_session_windows.code)<CR>
nnoremap <leader>dt :call GotoWindow(g:vimspector_session_windows.tagpage)<CR>
nnoremap <leader>dv :call GotoWindow(g:vimspector_session_windows.variables)<CR>
nnoremap <leader>dw :call GotoWindow(g:vimspector_session_windows.watches)<CR>
nnoremap <leader>ds :call GotoWindow(g:vimspector_session_windows.stack_trace)<CR>
nnoremap <leader>do :call GotoWindow(g:vimspector_session_windows.output)<CR>
nnoremap <leader>de :call vimspector#Reset()<CR>

nnoremap <leader>dtcb :call vimspector#CleanLineBreakpoint()<CR>

nmap <leader>dl <Plug>VimspectorStepInto
nmap <leader>dj <Plug>VimspectorStepOver
nmap <leader>dk <Plug>VimspectorStepOut
nmap <leader>d_ <Plug>VimspectorRestart
nnoremap <leader>d<space> :call vimspector#Continue()<CR>

nmap <leader>drc <Plug>VimspectorRunToCursor
nmap <leader>dbp <Plug>VimspectorToggleBreakpoint
nmap <leader>dcbp <Plug>VimspectorToggleConditionalBreakpoint

" Resize
nnoremap <Leader>+ :vertical resize +5<CR>
nnoremap <Leader>- :vertical resize -5<CR>

" vim TODO
nmap <Leader>tu <Plug>BujoChecknormal
nmap <Leader>th <Plug>BujoAddnormal
let g:bujo#todo_file_path = $HOME . "/.cache/bujo"

" vim fugitive keys
nmap <Leader>gs :G<CR>
nmap <Leader>gh :diffget //3<CR>
nmap <Leader>gu :diffget //2<CR>
nmap <Leader>gc :GCheckout<CR>

nnoremap <leader>gb :GBranches<CR>
nnoremap <leader>ga :Git fetch --all<CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" easy allign set" syntastyc
let g:syntastic_javascript_checkers = [ 'jshint'  ]
let g:syntastic_ocaml_checkers = ['merlin']
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_shell_checkers = ['shellcheck']

autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python set sw=4
autocmd FileType python set ts=4
autocmd FileType python set sts=4

" disable arrow keys to learn faster

fun! DisableArrowKeys()
    nnoremap <buffer> <Left> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    nnoremap <buffer> <Right> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    nnoremap <buffer> <Up> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    nnoremap <buffer> <Down> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    nnoremap <buffer> <PageUp> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    nnoremap <buffer> <PageDown> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>

    inoremap <buffer> <Left> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    inoremap <buffer> <Right> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    inoremap <buffer> <Up> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    inoremap <buffer> <Down> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    inoremap <buffer> <PageUp> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    inoremap <buffer> <PageDown> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>

    vnoremap <buffer> <Left> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    vnoremap <buffer> <Right> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    vnoremap <buffer> <Up> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    vnoremap <buffer> <Down> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    vnoremap <buffer> <PageUp> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
    vnoremap <buffer> <PageDown> <Esc>:echo "Hard mode enabled! Use home row keys HJKL"<CR>
endfun

autocmd VimEnter,BufNewFile,BufReadPost * silent! call DisableArrowKeys()

nnoremap <Leader>ct :!cointop<CR>P

" disable autoindent when pasting text
" source: https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode

let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

function! XTermPasteBegin()
    set pastetoggle=<Esc>[201~
    set paste
    return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

if &term =~ "xterm\\|rxvt"
   " use an orange cursor in insert mode
   silent! let &t_SI = "\e[5 q\e]12;orange\x7"
   " use a red cursor in replace mode
   silent! let &t_SR = "\e[3 q\e]12;red\x7"
   " use a green cursor otherwise
   silent! let &t_EI = "\e[2 q\e]12;green\x7"
   silent !echo -ne "\033]12;green\007"
endif

nnoremap <F6> :UndotreeToggle<CR>


" move through splits
nmap sv <C-w>v
nmap sj :wincmd k<cr>
nmap sj :wincmd j<cr>
nmap sh :wincmd h<cr>
nmap sl :wincmd l<cr>

