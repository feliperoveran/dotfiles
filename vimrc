scriptencoding utf-8
set encoding=utf-8

" Leader
let mapleader = " "

set backspace=2   " Backspace deletes like most programs in insert mode
set history=1000  " a lot of history
set ruler         " show the cursor position all the time
set hlsearch
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands
set ignorecase    " Ignore case when searching...
set smartcase     " ...unless we type a capital
set showmode      "Show current mode down the bottom
set visualbell    " No noise
set nowrap        "Don't wrap lines

syntax on

so ~/.vim/plugins.vim

" laod custom settings
so ~/.vim/settings.vim

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown

  " Enable spellchecking for Markdown
  autocmd FileType markdown setlocal spell

  " Automatically wrap at 80 characters for Markdown
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80

  " Automatically wrap at 72 characters and spell check git commit messages
  autocmd FileType gitcommit setlocal textwidth=72
  autocmd FileType gitcommit setlocal spell

  " Allow stylesheets to autocomplete hyphenated words
  autocmd FileType css,scss,sass setlocal iskeyword+=-
augroup END

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  " let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
  let g:ctrlp_user_command =
      \ 'ag %s --files-with-matches -g ""  --hidden --ignore=.git'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif
" Default to filename searches
let g:ctrlp_by_filename = 1

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Numbers
set number
set numberwidth=5
" Make easy to navigate
set relativenumber

" enable list of completion
set wildmode=list:longest,list:full

" skip tmp files
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.cache

" Exclude Javascript files in :Rtags via rails.vim due to warnings when parsing
let g:Tlist_Ctags_Cmd="ctags --exclude='*.js'"

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" configure syntastic syntax checking to check on open as well as save
let g:syntastic_check_on_open=1
let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute \"ng-"]
let g:syntastic_eruby_ruby_quiet_messages =
    \ {"regex": "possibly useless use of a variable in void context"}

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Always use vertical diffs
set diffopt+=vertical

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" ================ Organize swap files ================
silent !mkdir $HOME/.dotfiles/vim/swap > /dev/null 2>&1
set directory^=$HOME/.dotfiles/vim/swap//

" Uncomment to automatically attach VIM to a runner TMUX pane
" let is_tmux = $TMUX
" if is_tmux != ""
"   autocmd VimEnter * VtrAttachToPane
" endif

let g:solarized_termtrans=1
syntax enable
set background=dark
colorscheme solarized

" This gets the current directory name, not the fullpath, needed to see if the
" ./script/<dirname> exists so it can be called when running specs
let script_name = split(getcwd(), "/")[-1]

if filereadable(expand("./script/" . script_name))
  let g:rspec_command = "VtrSendCommandToRunner! " . "./script/" . script_name . " rspec {spec}"
elseif filereadable(expand("./scripts/" . script_name))
  let g:rspec_command = "VtrSendCommandToRunner! " . "./scripts/" . script_name . " rspec {spec}"
else
  let g:rspec_command = "VtrSendCommandToRunner! bundle exec rspec {spec}"
endif

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

let g:ctrlp_show_hidden=1

" Vim markdown preview options
" https://github.com/JamshedVesuna/vim-markdown-preview
let vim_markdown_preview_github=1
let vim_markdown_preview_hotkey='<C-o>'
let vim_markdown_preview_toggle=1

let NERDTreeIgnore = ['\.pyc$', '__pycache__']

set title titlestring=
let g:autoswap_detect_tmux = 1

" augroup AutomaticSwapRecoveryAndDelete
"   autocmd!
"   autocmd SwapExists * :let v:swapchoice = 'r' | let b:swapname = v:swapname
"   autocmd VimLeave * :if exists("b:swapname") | call delete(b:swapname) | endif
" augroup end

" vim-terraform
let g:terraform_fmt_on_save=1

let g:VtrClearSequence = "clear\r"

" pymode
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_rope_completion_bind = "<C-Space>"
let g:pymode_python = 'python3'
let g:pymode_options_max_line_length = 120
let g:jedi#popup_on_dot = 0
let g:jedi#use_splits_not_buffers = "bottom"

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
endif

" vim-go
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1

let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

let g:go_auto_type_info = 1

" Run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

" Map go functions. Ex: `\b` for building, `\r` for running and `\b` for running test.
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
