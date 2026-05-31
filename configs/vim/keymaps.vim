
"=============== REMAPEO VIM =======================
:imap jk <Esc>
:vmap jk <Esc>
:imap ii <Esc>
:vmap ii <Esc>
nnoremap <Esc> :noh<CR>
nnoremap <leader>css :CocSearch
nnoremap <leader>fs :Files<cr>
" nnoremap <leader>fg :Files<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>x :so %<cr>

"==================== TABS ==========================
nnoremap tw :tabnew<CR>
noremap tp :tabprevious<CR>
noremap tn :tabNext<CR>
noremap tc :tabclose<CR>
noremap to :tabonly<CR>

"======================= GIT =======================
noremap <Leader>gg :!lazygit<CR>
" noremap <Leader>ga :Git write<CR>
" noremap <Leader>gc :Git commit<CR>
" noremap <Leader>gsh :Git push<CR>
" noremap <Leader>gll :Git pull<CR>
" noremap <Leader>gs :Git status<CR>
" noremap <Leader>gb :Git blame<CR>
" noremap <Leader>
" noremap <Leader>gr :Git remove<CR>

"======================= JavaComplete =======================
"Para agregar todas las importaciones faltantes con F6:
nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
"Para eliminar todas las importaciones no utilizadas con F7:
nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
nmap <leader>jA <Plug>(JavaComplete-Generate-Accessors)
nmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
nmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
nmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
nmap <leader>jts <Plug>(JavaComplete-Generate-ToString)
nmap <leader>jeq <Plug>(JavaComplete-Generate-EqualsAndHashCode)
nmap <leader>jc <Plug>(JavaComplete-Generate-Constructor)
nmap <leader>jcc <Plug>(JavaComplete-Generate-DefaultConstructor)

imap <C-j>s <Plug>(JavaComplete-Generate-AccessorSetter)
imap <C-j>g <Plug>(JavaComplete-Generate-AccessorGetter)
imap <C-j>a <Plug>(JavaComplete-Generate-AccessorSetterGetter)


"======================= NERDTree =======================
" nnoremap <silent> <C-a> :NERDTreeToggle<CR>
nmap <leader>e :NERDTreeToggle<CR>

"======================= TERMINAL =======================
nnoremap <silent> ff :FloatermNew fzf<CR>
nnoremap <silent> <M-t>sh :terminal<CR>
nnoremap <C-t> :below terminal<CR>
nnoremap <leader>t :below terminal<CR>
" nnoremap <C-n> :terminal<CR>
nnoremap <C-r> :below vertical terminal<CR>
noremap fw :FloatermNew<CR>
noremap ft :FloatermToggle<CR>
let g:floaterm_repl_runner= "~/scripts/runner.sh"
noremap fr :FloatermRepl<CR>

"======================= WINDOW RESIZE =====================
nnoremap <silent> <right> :vertical resize +5 <CR>
nnoremap <silent> <left> :vertical resize -5 <CR>
nnoremap <silent> <up> :resize +5 <CR>
nnoremap <silent> <down> :resize -5 <CR>
vmap <F5> :so %<CR>
nmap <F5> :so %<CR>
nmap <F2> :so %<CR>
vmap <F2> :so %<CR>

"=================== SHOW KEYMAPS =====================
nnoremap <F12> :map<CR>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"============== PLANTILLAS =======================
nnoremap <Leader>html :-1read $HOME/.config/vim/plantillas/plantilla.html<CR>
nnoremap <Leader>java :-1read $HOME/.config/vim/plantillas/plantilla.java<CR>
nnoremap <Leader>main :-1read $HOME/.config/vim/plantillas/main.java<CR>
nnoremap <Leader>print :-1read $HOME/.config/vim/plantillas/print.java<CR>
nnoremap <Leader>println :-1read $HOME/.config/vim/plantillas/println.java<CR>
nnoremap <Leader>scan :-1read $HOME/.config/vim/plantillas/scan.java<CR>
nnoremap <Leader>eclim :!/opt/eclipse/eclimd<CR>
"nnoremap ,c :-1read $HOME/.vim/plantillas/plantilla
nnoremap <Leader>cc :-1read $HOME/.config/vim/plantillas/plantilla.cpp<CR>
nnoremap <Leader>go :-1read $HOME/.config/vim/plantillas/plantilla.go<CR>
 nnoremap <Leader>scala :-1read $HOME/.config/vim/plantillas/plantilla.scala<CR>


"=============== Teclas guia =====================
inoremap ;gui 
inoremap <leader><leader> <Esc>/<Enter>"_c4l
vnoremap <leader><leader> <Esc>/<Enter>"_c4l
nnoremap <leader><leader> <Esc>/<Enter>"_c4l

"=================== pliegues ====================
nnoremap <leader>pl :zf<CR>

"===============setter and getter===================
nnoremap <leader>sg :InsertBothGetterSetter<CR>
nnoremap <leader>s :InsertSetterOnly<CR>
nnoremap <leader>g :InsertGetterOnly<CR>

"===================SPLIT===========================
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Buffer nav
noremap <leader>b :buffers<CR>
noremap <leader>bn :bp<CR>
noremap <leader>bp :bn<CR>
noremap <leader>bc :bc<CR>

"" Close buffer
noremap <leader>bc :bd<CR>

"============== on/off SpellMorse ================
nnoremap <silent> <TAB>. :VimToolsSpellMorse<CR>
" next language
nnoremap <silent> <TAB>, :VimToolsSpellMorseIdioms<CR>
" on/off MatheModus
inoremap <silent> <TAB>m <Esc>:VimToolsMatheModus<CR>i<RIGHT>
" on/off MaxWindows
nnoremap <silent> <Leader>m :VimToolsMaxWindows<CR>

"============= Startify==============================
nmap <C-n> :Startify <CR>

"============= Compilin and run ==================
nnoremap <Leader>r :!/home/salva/scripts/ejecutar.sh %<CR>
nnoremap <Leader>fr :FloatermNew --autoclose=0 /home/salva/scripts/ejecutar.sh %<CR>
nnoremap <Leader>h :FloatermNew --autoclose=0 bat /home/salva/.config/vim/keymaps.vim %<CR>

"============ Ejecutar en navegador en tiempo real =================="
noremap br :Bracey<CR>

"======================= Documentacion ============================"
nmap <leader>d <Plug>(DocGen)

"===================== añadir ; al final de la linea
nnoremap <Leader>; $a;<Esc>

"======================= AI Chat (opencode / ollama) ======================
function! AIChatCallback(id, result)
  if a:result < 0
    return
  elseif a:result == 0
    below terminal ++close opencode
  elseif a:result == 1
    let model = input("Ollama model: ", "qwen2.5-coder:3b")
    if model != ""
      execute "below terminal ++close ollama run " . model
    endif
  endif
endfunction

function! AIChat()
  call popup_menu(['opencode', 'ollama'], {
        \ 'title': 'AI Chat provider:',
        \ 'callback': 'AIChatCallback',
        \ 'border': [],
        \ 'mapping': 0,
        \ })
endfunction
nnoremap <silent> <leader>a :call AIChat()<CR>

"======================= AI Chat directo ======================
nnoremap <leader>o :FloatermNew opencode<CR>
nnoremap <leader>ot :FloatermNew opencode run "explícame el archivo %"<CR>
nnoremap <leader>ol :below terminal ++close ollama run qwen2.5-coder:3b<CR>
nnoremap <leader>oo :below terminal ++close ollama run qwen2.5-coder:7b<CR>
