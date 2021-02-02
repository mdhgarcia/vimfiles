" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
" Because of these same effects (e.g. reloading vimrc), we ensure we only do it once
if &compatible
    set nocompatible
endif

" Autocommand group to auto-reload configuration.
" Grouped to avoid reloading while reloading.
augroup vimrchooks
    au!
    autocmd bufwritepost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

let mapleader=","   " leader is now comma

colorscheme badwolf
syntax enable
set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set number          " show line numbers
set showcmd         " show command in bottom bar
set cursorline      " highlight current line

set wildmenu        " visual autocomplete for command menu
set lazyredraw      " redraw only when we need to (e.g. not in a macro)
set showmatch       " highlight matching [{()}]
set incsearch       " search as characters are entered
set hlsearch        " highlight matches

filetype indent on  "load filteype-specific indent files

" turn off search highlighting using ,<space>
nnoremap <leader><space> :nohlsearch<CR>

" Folding options
set foldenable          " allow code folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
set foldmethod=syntax   " fold based on syntax

" space open/closes folds
nnoremap <space> za

" Movement commands
" move vertically by visual line
nnoremap j gj
nnoremap k gk

" move to beginning/end of line
nnoremap B ^
nnoremap E $

" highlight last inserted text
nnoremap gV `[v`]

" use system clipboards by default
set clipboard=unnamedplus

" Add FZY functionality
function! FzyCommand(choice_command, vim_command)
  try
    let output = system(a:choice_command . " | fzy ")
  catch /Vim:Interrupt/
    " Swallow errors from ^C, allow redraw! below
  endtry
  redraw!
  if v:shell_error == 0 && !empty(output)
    exec a:vim_command . ' ' . output
  endif
endfunction

nnoremap <leader>e :call FzyCommand("ag . --silent -l -g ''", ":e")<cr>
nnoremap <leader>v :call FzyCommand("ag . --silent -l -g ''", ":vs")<cr>
nnoremap <leader>s :call FzyCommand("ag . --silent -l -g ''", ":sp")<cr>

" Ctrl-p for FZY
nnoremap <C-p> <leader>e

" Use minpac for package management as it complements native packages and
" works for both vim and nvim.
function! PackInit() abort
    packadd minpac

    call minpac#init({'status_auto': 'TRUE'})

    " minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " Add other plugins here
    call minpac#add('dense-analysis/ale')
    call minpac#add('vim-airline/vim-airline')
    call minpac#add('mileszs/ack.vim')
    call minpac#add('tpope/vim-fugitive')
    call minpac#add('tpope/vim-surround')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('tpope/vim-unimpaired')
    call minpac#add('airblade/vim-gitgutter')
    call minpac#add('vim-jp/syntax-vim-ex')
    call minpac#add('sjl/badwolf')
endfunction

" Define user commands for updating/cleaning the plugins.
command! PackUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PackClean  source $MYVIMRC | call PackInit() | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()

" Enable completion where available.
" " This setting must be set before ALE is loaded.
let g:ale_completion_enabled = 1
let g:airline#extensions#ale#enabled = 1

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup      " do not keep a backup file, use versions instead
else
  set backup        " keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile    " keep an undo file (undo changes after closing)
  endif
endif

" Some defaults from the example vimrc
set history=10000
set ruler       " show the cursor position all the time
set showcmd     " display incomplete commands
set incsearch       " do incremental searching

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent        " always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
          \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif

" Load all plugins now
packloadall

" Load helptags now after plugins have been loaded
silent! helptags ALL
