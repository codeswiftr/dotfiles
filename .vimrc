" Set nocompatible to ensure Vim is not in Vi compatibility mode                                                                                                                                                                                                   
set nocompatible                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                   
" Enable filetype plugins                                                                                                                                                                                                                                          
filetype off                                                                                                                                                                                                                                                       
filetype plugin indent on                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                   
" Set encoding                                                                                                                                                                                                                                                     
set encoding=utf-8                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                   
" Enable syntax highlighting                                                                                                                                                                                                                                       
syntax enable                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                   
" Set leader key                                                                                                                                                                                                                                                   
let mapleader = "\<Space>"                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                                   
" Set line numbering                                                                                                                                                                                                                                               
set number                                                                                                                                                                                                                                                         
set relativenumber                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                   
" Highlight current line                                                                                                                                                                                                                                           
set cursorline                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                   
" Enable mouse support                                                                                                                                                                                                                                             
set mouse=a                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                   
" Set tab and indent options                                                                                                                                                                                                                                       
set tabstop=4                                                                                                                                                                                                                                                      
set shiftwidth=4                                                                                                                                                                                                                                                   
set expandtab                                                                                                                                                                                                                                                      
set smartindent                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                   
" Set the backspace behavior                                                                                                                                                                                                                                       
set backspace=indent,eol,start                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                   
" Use system clipboard                                                                                                                                                                                                                                             
set clipboard+=unnamedplus                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                                   
" Disable swap files                                                                                                                                                                                                                                               
set noswapfile                                                                                                                                                                                                                                                     
set nobackup                                                                                                                                                                                                                                                       
set nowritebackup                        

" Search settings
set incsearch
set hlsearch
set ignorecase
set smartcase

" Set split directions
set splitbelow
set splitright

" Start plugins section
call plug#begin('~/.vim/plugged')

" Plugin list
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'szw/vim-maximizer'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'

" Git wrapper support
Plug 'tpope/vim-fugitive'

" Vim Session support
Plug 'tpope/vim-obsession'

" Initialize plugin system
call plug#end()

" Lightline configuration
set noshowmode
set laststatus=2

" NERDTree configuration
nnoremap <leader>n :NERDTreeToggle<CR>

" fzf configuration
nnoremap <leader>f :Files<CR>
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.9  }  }

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

" coc.nvim configuration
" Use <tab> for trigger completion and navigate the completion list
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Gruvbox color scheme
colorscheme gruvbox
set background=dark

" Custom commands or additional configurations

" toggle tree view
map <C-n> :NERDTreeToggle<CR>

" jk to go to normal mode
inoremap jk <esc>

" Update vim
nmap <Leader>I :PlugInstall<CR>
nmap <Leader>E :e ~/.vimrc<CR>
nmap <Leader>R :source ~/.vimrc<CR>
nma <Leader>w :w<CR>
nma <Leader>wq :wq<CR>

"Reveal in drawer
nmap <Leader>t :NERDTreeFind<CR>
nmap <Leader>b :NERDTreeToggle<CR>
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeAutoDeleteBuffer = 1
autocmd StdinReadPre * let s:std
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | :vertical resize 30 | endif
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

nnoremap <leader>m :MaximizerToggle!<CR>


" move through splits
nmap sv <C-w>v
nmap sk :wincmd k<cr>
nmap sj :wincmd j<cr>
nmap sh :wincmd h<cr>
nmap sl :wincmd l<cr>


" vim fugitive keys
nmap <Leader>gs :G<CR>
nmap <Leader>gh :diffget //3<CR>
nmap <Leader>gu :diffget //2<CR>
nmap <Leader>gc :GCheckout<CR>

nnoremap <leader>gb :GBranches<CR>
nnoremap <leader>ga :Git fetch --all<CR>

" End of .vimrc