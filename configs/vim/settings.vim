""===============THEME===============================/
" gruvbox:dark/light
" colorscheme gruvbox
colorscheme gruvbox-material
" colorscheme catppuccin
set background=dark
let g:gruvbox_contrast_dark="hard"

""================ minimap =======================
let g:minimap_width = 10
let g:minimap_auto_start = 0
let g:minimap_auto_start_win_enter = 1

""==============SETTINGS==============================
let g:vimtools_spellmorse = 1 "" pliegues
syntax on
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set ttyfast
set t_Co=256
set guioptions=egmrti
set gfn=Monospace\ 10
set cursorline
set cursorcolumn
set clipboard=unnamedplus
set ruler
set number
set relativenumber
set mouse=r
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set showmatch
set hlsearch
set incsearch
set ignorecase
" set autochdir
set errorbells
" set visualbell
setlocal spell spelllang=es
filetype indent on
set nocompatible
set splitbelow
set splitright
set colorcolumn=80
set noswapfile


"" fzf.vim
set wildmode=list:longest,list:full
" set wildoptions=pum
" set widlmenu
" set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__
let $FZF_DEFAULT_COMMAND =  "find * -path '*/\.*' -prune -o -path 'node_modules/**' -prune -o -path 'target/**' -prune -o -path 'dist/**' -prune -o  -type f -print -o -type l -print 2> /dev/null"

""================= CAMBIO FORMA CURSOR SEGUN MODO =================
let &t_SR = "\033]12;199\x7\e[3 q"
let &t_SI = "\033]12;199\x7\e[5 q"
let &t_EI = "\033]12;deepskyblue\x7\e[1 q"

augroup myCmds
  au!
  autocmd VimEnter * silent !echo -ne "\033]12;deepskyblue\x7\e[1 q"
augroup END

"====================== STARTIFY =====================================
let g:startify_bookmarks = [
  \ { 'z': '~/.zshrc' },
  \ { 'v': '~/.config/vim/.' },
  \ { 'w': '~/programacion/java/.' },
  \ ]

let g:startify_custom_header = [
  \'  _________   _____  .____ ____   _________   ',
  \' /   _____/  /  _  \ |    |\   \ /   /  _  \  ',
  \' \_____  \  /  /_\  \|    | \   Y   /  /_\  \ ',
  \' /        \/    |    \    |__\     /    |    \',
  \'/_______  /\____|__  /_______ \___/\____|__  /',
  \'        \/         \/        \/            \/ ',
  \]

let g:startify_lists = [
      \ { 'header': ['   Bookmarks'],       'type': 'bookmarks' },
      \ { 'header': ['   MRU'],            'type': 'files' },
      \ { 'header': ['   MRU '. getcwd()], 'type': 'dir' },
      \ ]

"config switch-key-maps 
"
let g:mapleader = "\<Space>"
let g:maplocalleader = ','
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

"============== GIT===================="
let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ 'Modified'  :'✹',
                \ 'Staged'    :'✚',
                \ 'Untracked' :'✭',
                \ 'Renamed'   :'➜',
                \ 'Unmerged'  :'═',
                \ 'Deleted'   :'✖',
                \ 'Dirty'     :'✗',
                \ 'Ignored'   :'☒',
                \ 'Clean'     :'✔︎',
                \ 'Unknown'   :'?',
                \ }

let g:NERDTreeWinPos = "right"
