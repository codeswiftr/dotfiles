After a couple of months, of working more with Unix tooling I now finally ready to attmpt switching to Vim with proper syntax highlighting, smart code completion, and refactoring capabilities. Read on to see what it looks like.

Disclaimer: I made this 

#TL;DR:

Basics: vim-plug, scrooloose/nerdtree, tpope/vim-commentary and junegunn/fzf.vim
sheerun/vim-polyglot for the syntax highlighting
Vimjas/vim-python-pep8-indent for proper indenting
dense-analysis/ale is an asynchronous linter plugin. Use it with flake8 and pylint; plus google/yapf as a formatter.
neoclide/coc.nvim with neoclide/coc-python for intellisense code completion

## Installation
```bash
    apt-get update && apt-get curl git cmake vim;\
    echo "\n[Installing vim-plug -> a minimalist plugin manager]";\
	  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim;\
    echo "\n[Downloading default .vimrc]"; curl -fLo ~/.vimrc --create-dirs\
    https://raw.githubusercontent.com/codeswiftr/.make-env/master/.vimrc;\
    echo "\n[Done] -> Installing plugins.."; vim +'PlugInstall --sync' +qa

```

## Essentials

Let's start with a list of some general-purpose plugins which I find irreplaceable for any language.

vim-plug is a minimalistic plugin manager
scrooloose/nerdtree to navigate the file tree
junegunn/fzf.vim fuzzy search through the files (and much more, really)
tpope/vim-commentary ( or scrooloose/nerdcommenter ) — press gcc to comment out a line or gc to comment a selection in visual mode
liuchengxu/vista.vim which is a "tagbar" that learns from LSP servers
The other plugins I use include

jeetsukumaran/vim-pythonsense provides some Python-specific text objects: classes, functions, etc
jiangmiao/auto-pairs inserts closing quotes and parenthesis as you type
The colorscheme used on the screenshots is joshdick/onedark.vim, which is inspired by the Atom theme.

## Syntax highlighting

Vim comes with syntax highlighting for many popular languages, including Python, though it is not always the best one.

There are several options to improve the default highlighting.

numirias/semshi, in my opinion, is the best. It works with Neovim only and requires the Python 3 support.
sheerun/vim-polyglot includes support for many languages including Python
python-mode/python-mode is also a decent one although it comes with a lots of other stuff beside highlighting which I don't quite like
Semshi
Semshi (on the left) vs. the default one
My favorite color scheme for now (which I switch quite often) is tomasiser/vim-code-dark

## Indentation

For identation I added Vimjas/vim-python-pep8-indent plugin. It does a great job complying with the PEP8 style guide and it is configured to format on save.

## Folding

Folding (:help foldmethod) is when you collapse chunks of code to eliminate distraction.

The best approximation is to use the folding method indent though it doesn't work ideally.

```vim
au BufNewFile,BufRead *.py \
  set foldmethod=indent
```
To toggle a fold you can press za (:help fold-commands), and I have it mapped to Space for convenience.

nnoremap <space> za
Linting & Fixing

The fantastical dense-analysis/ale plugin can be used for linting (which essentially means checking for syntax errors) and auto-fixing extremely well. It's asynchronous, meaning that it won't block the UI while running an external linter, and it supports a great range of languages and tools.

Python
Python + ALE = ❤️
ALE highlights problems with your code in the gutter. When you move the cursor to the problematic line, it shows the full error message at the bottom of the screen.

By default, ALE will use all linters (which are just executables) it could find on your machine. Run :ALEInfo to see which linters are available and which are enabled.

It is better though to explicitly specify which ones you're going to use with a particular filetype:
```vim
let g:ale_linters = {
       \   'python': ['flake8', 'pylint'],
      \   'ruby': ['standardrb', 'rubocop'],
      \   'javascript': ['eslint'],
      \}
```
Some of the linters are also capable of fixing the problems in your code. ALE has a special command :ALEFix that fixes the whole file. So far, I'm only Google's YAPF as a fixer that formats the whole file when I press F10 or save the current buffer.

```vim
let g:ale_fixers = {
      \    'python': ['yapf'],
        \}
nmap <F10> :ALEFix<CR>
let g:ale_fix_on_save = 1
```

The last option is a huge time saver — it will automatically fix (and thus format) your file on save.

I also have a little piece of configuration that shows the total number of warnings and errors in the status line. Very convenient.
```vim
function! LinterStatus() abort
  let  l:counts = ale#statusline#Count(bufnr(''))

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
```

## Jedi

Jedi is a "language server" (see my LSP article), a separate process running in the background and analyzing your code.

Other clients (editors or IDEs) can connect to the server and request some information, like completion options, or "go to definition" coordinates.

Basically, Jedi is an IDE as a service, without the GUI.

In order to use it, you need to install it with pip install jedi, and then also add a client. The davidhalter/jedi Vim plugin does a good job.

Here's what it can do:
```
Press ctrl + space for the completion options
<leader>d goes to definition
<leader>g goes to assignment
K shows the documentation
and more..
```
