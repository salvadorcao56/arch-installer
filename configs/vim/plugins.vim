call plug#begin(expand('~/.vim/plugged'))
" Plug 'morhetz/gruvbox' " gruvbox theme
" TEMA GRUVBOX
Plug 'sainnhe/gruvbox-material'
Plug 'catppuccin/nvim'
"Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'artur-shaik/vim-javacomplete2' 
Plug 'scrooloose/nerdtree' "nertree
Plug 'jistr/vim-nerdtree-tabs'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'vim-scripts/grep.vim'
Plug 'majutsushi/tagbar'
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'alvan/vim-closetag'
Plug 'pekepeke/ref-javadoc'
Plug 'moznion/jcommenter.vim'
"Plug 'puremourning/vimspector'
Plug 'sbdchd/neoformat'
Plug 'mctechnology17/vimtools'  
Plug 'wfxr/minimap.vim'  
Plug 'hsanson/vim-android'  
" Plug 'vim-scripts/jcommenter.vim'
Plug 'vim-scripts/java_getset.vim'
" Use release branch (recommended, no build needed)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'fannheyward/coc-pyright', {'do': 'yarn install'}
Plug 'fannheyward/coc-clangd', {'do': 'yarn install'}
Plug 'elixir-lsp/coc-elixir', {'do': 'yarn install && NODE_OPTIONS=--openssl-legacy-provider yarn prepack'}
Plug 'java-lsp/coc-java', {'do': 'yarn install'}
Plug 'josa42/coc-go', {'do': 'yarn install'}
Plug 'fannheyward/coc-rust-analyzer', {'do': 'yarn install'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install'}
Plug 'iamcco/coc-angular', {'do': 'yarn install && yarn build'}
" Plug 'neoclide/coc-java'
Plug 'elixir-editors/vim-elixir' "este si"
Plug 'voldikss/vim-floaterm'
Plug 'mhinz/vim-startify'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'liuchengxu/vim-which-key'
" Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'windwp/vim-floaterm-repl'
Plug 'skywind3000/asyncrun.vim'
Plug 'turbio/bracey.vim'
Plug 'kkoomen/vim-doge', { 'do': 'npm i --no-save && npm run build:binary:unix' }
" Treesitter
Plug 'nvim-treesitter/nvim-treesitter'

call plug#end()
