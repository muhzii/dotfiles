set encoding=utf-8

"
" Leader
"
let mapleader = " "

"
" Editor settings.
"
set nu
set relativenumber
set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set nowrap
set scrolloff=2
set showcmd       " display incomplete commands
set ruler         " show the cursor position all the time
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands
set modelines=0   " Disable modelines as a security precaution
set nomodeline
set tabstop=4 softtabstop=4 shiftwidth=4 autoindent
set expandtab smarttab
set incsearch ignorecase smartcase hlsearch  " Incremental search
set emoji
set cmdheight=2
set updatetime=25
set foldmethod=syntax
set foldlevel=5
set ttimeout ttimeoutlen=10  " Enforce timeout for keycodes sent by the terminal.
set splitbelow splitright  " More natural feel when opening vim splits.
set clipboard=unnamedplus
set termguicolors
set hidden

" Enable autoread for file changes.
set autoread
autocmd FocusGained,BufEnter * checktime

" Show the whild menu.
set wildmenu

" Show matching brackets.
set showmatch
set mat=2

"
" Editor colors
"
set colorcolumn=81
set background=dark
let g:gruvbox_contrast_dark = "hard"
colorscheme gruvbox

" Enable undercurls inside terminals that support it.
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"

" Change cursor shape for different editing modes.
let &t_SI = "\<Esc>[5 q"
let &t_SR = "\<Esc>[3 q"
let &t_EI = "\<Esc>[ q"

" Workaround for xterm-kitty, see: https://github.com/kovidgoyal/kitty/issues/108
" vim hardcodes background color erase even if the terminfo file does
" not contain BCE (not to mention that libvte based terminals
" incorrectly contain bce in their terminfo files). This causes
" incorrect background rendering when using a color theme with a
" background color.
let &t_ut=''

" Highlight for bad spelling errors.
autocmd ColorScheme * highlight SpellBad guisp=#fabd2f

" Clear search highlights using F3.
nnoremap <F3> :noh<CR>

" Automatically rebalance windows on vim resize.
autocmd VimResized * :wincmd =

" Zoom a vim pane, <C-w> to rebalance.
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>

" Move a line of text using alt+j/k
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

"
" Highlight trailing whitespaces.
"
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufWinLeave * call clearmatches()

"
" Netrw.
"
let g:netrw_winsize=25
let g:netrw_banner=0
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

noremap <silent> <leader>n :Explore<CR>

" Set tags for vim-fugitive
set tags^=.git/tags

"
" Python-syntax configurations.
"
let g:python_highlight_space_errors = 0
let g:python_highlight_func_calls = 0
let g:python_highlight_all = 1

"
" Better-vim-tmux-resizer configurations.
"
let g:tmux_resizer_no_mappings = 1
nnoremap <silent> <C-Left> :TmuxResizeLeft<CR>
nnoremap <silent> <C-Down> :TmuxResizeDown<CR>
nnoremap <silent> <C-Up> :TmuxResizeUp<CR>
nnoremap <silent> <C-Right> :TmuxResizeRight<CR>

" Open current buffers.
noremap <silent> <leader>b :Buffers<CR>

" Open project files.
noremap <silent> <leader>f :Files<CR>

command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

"
" ALE configurations.
"
let g:ale_enabled = 1
let g:ale_disable_lsp = 1
let g:ale_completion_enabled = 0
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_javascript_eslint_executable = 'eslint_d --cache'

let g:ale_linters = {
   \'typescript': ['eslint'],
   \'javascript': ['eslint'],
   \'go': ['staticcheck', 'gofmt', 'golint', 'go vet'],
   \}

let g:ale_fixers = {
   \'go': ['goimports', 'gofmt'],
   \'javascript': ['eslint'],
   \'typescript': ['eslint'],
   \}

function! DebugMsg(msg) abort
  if !exists("g:DebugMessages")
    let g:DebugMessages = []
  endif
  call add(g:DebugMessages, a:msg)
endfunction

function! PrintDebugMsgs() abort
  if empty(get(g:, "DebugMessages", []))
    echo "No debug messages."
    return
  endif
  for ln in g:DebugMessages
    echo "- " . ln
  endfor
endfunction

command DebugStatus call PrintDebugMsgs()

augroup CocRefreshALE
  autocmd!
  autocmd User ALEWantResults call CocActionAsync('diagnosticRefresh')
augroup END

"
" git-gutter Configurations.
"
let g:gitgutter_sign_added = '▐'
let g:gitgutter_sign_modified = '▐'
let g:gitgutter_sign_removed = '▶'
let g:gitgutter_set_sign_backgrounds = 1

autocmd ColorScheme * highlight GitGutterAdd guifg=#577857 ctermfg=65
autocmd ColorScheme * highlight GitGutterChange guifg=#567387 ctermfg=67
autocmd ColorScheme * highlight GitGutterDelete guifg=#656e76 ctermfg=102

"
" Key bindings for plugins and useful commands.
"

" Map Ctrl+p to open fuzzy find (FZF)
nnoremap <C-p> :Files<cr>

" Go back to last misspelled word and pick first suggestion.
inoremap <C-s> <C-G>u<Esc>[s1z=`]a<C-G>u

" Use <leader>t to run golang tests.
autocmd BufEnter *.go nmap <leader>t <Plug>(go-test)

noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

nnoremap <silent> D :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" ctrl-j/k to navigate completion items and <CR> to accept selected item.
inoremap <silent><expr> <c-k> coc#pum#visible() ? coc#pum#prev(1) : coc#refresh()
inoremap <silent><expr> <c-j> coc#pum#visible() ? coc#pum#next(1) : coc#refresh()
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Show references (mapping starts with the leader as not to conflict with
" ReplaceWithRegister plugin).
nmap <silent> <leader>gr <Plug>(coc-references)
" Show implementation.
nmap <silent> gi <Plug>(coc-implementation)
" Go to definition
nmap <silent> gd <Plug>(coc-definition)
" Go to type definiton.
nmap <silent> gy <Plug>(coc-type-definition)

" Refactor/ rename symbols names with \+r (for use with Coc).
nmap <leader>r <Plug>(coc-rename)

"
" Configurations for snippets.
"
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-tab>"  " List all snippets for current filetype

"
" vim-plug section.
"
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'

Plug 'vim-python/python-syntax'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'mileszs/ack.vim'

Plug 'airblade/vim-gitgutter'

Plug 'dense-analysis/ale'

Plug 'itchyny/lightline.vim'

Plug 'tpope/vim-commentary'

Plug 'tpope/vim-surround'

Plug 'gregsexton/MatchTag'

Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'

Plug 'christoomey/vim-tmux-navigator'

Plug 'RyanMillerC/better-vim-tmux-resizer'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-unimpaired'

Plug 'tpope/vim-vinegar'

Plug 'tpope/vim-repeat'

Plug 'vim-scripts/ReplaceWithRegister'

Plug 'editorconfig/editorconfig-vim'

"Plug 'vim-airline/vim-airline'

call plug#end()
