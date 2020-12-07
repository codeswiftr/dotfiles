" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'vim-airline/vim-airline'

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }


" Unmanaged plugin (manually installed and updated)
Plug '~/my-prototype-plugin'

" color themes
Plug 'tomasiser/vim-code-dark'
Plug 'morhetz/gruvbox'

" the best for the syntax highlighting
Plug 'sheerun/vim-polyglot'

" for proper indentention
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

" Initialize plugin system
call plug#end()
set nu
colorscheme gruvbox
set bg=dark

" toggle tree view
map <C-n> :NERDTreeToggle<CR>

" folding
au BufNewFile,BufRead *.py
    \ set foldmethod=indent
" nnoremap <space> za
nnoremap <SPACE> <Nop>
let mapleader=" "
nnoremap <Leader>- zM
nnoremap <Leader>= zR

"Reveal in drawer
nmap <Leader>r :NERDTreeFind<CR>
nmap <Leader>b :NERDTreeToggle<CR>

" Make cmds
nmap <F5> :make<CR>

"PLUGIN: FZF
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <Leader>f :Rg<CR>
nnoremap <silent> <Leader>/ :BLines<CR>
nnoremap <silent> <Leader>' :Marks<CR>
nnoremap <silent> <Leader>g :Commits<CR>
nnoremap <silent> <Leader>H :Helptags<CR>
nnoremap <silent> <Leader>hh :History<CR>
nnoremap <silent> <Leader>h: :History:<CR>
nnoremap <silent> <Leader>h/ :History/<CR> 

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

set statusline=
set statusline+=%m
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %{LinterStatus()}

autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
