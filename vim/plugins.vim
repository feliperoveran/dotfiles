if &compatible
  set nocompatible
end

call plug#begin('~/.vim/bundle')

" Define bundles via Github repos
Plug 'christoomey/vim-tmux-navigator'
Plug 'skwp/vim-colors-solarized'
Plug 'feliperoveran/nerdtree', { 'branch': 'master' } " file explorer
Plug 'ctrlpvim/ctrlp.vim' " fuzzy finder
Plug 'pbrisbin/vim-mkdir' " create folder if it doesn't exist
Plug 'scrooloose/syntastic' " syntax checking
Plug 'thoughtbot/vim-rspec'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-git'
Plug 'tpope/vim-rails'
Plug 'keith/rspec.vim'
Plug 'tpope/vim-surround'
Plug 'vim-ruby/vim-ruby'
Plug 'vim-scripts/tComment'
Plug 'chrisbra/color_highlight'
Plug 'jby/tmux.vim' " tmux syntax
Plug 'itchyny/lightline.vim' " pretty status bar
Plug 'christoomey/vim-tmux-runner'
Plug 'rking/ag.vim'
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-repeat'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-obsession'
Plug 'posva/vim-vue'
Plug 'elixir-editors/vim-elixir'
Plug 'vim-scripts/tabmerge'
Plug 'jparise/vim-graphql'
Plug 'python-mode/python-mode', { 'branch': 'develop' }
Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'hashivim/vim-terraform'
Plug 'gioele/vim-autoswap'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'jodosha/vim-godebug'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'vim-vdebug/vdebug'

if filereadable(expand("~/.plugins.vim.local"))
  source ~/.plugins.vim.local
endif

call plug#end()
