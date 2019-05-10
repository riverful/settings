"============================ default setting =================================
set number
set mouse=a
set nocsverb
set encoding=utf-8
set ruler
set sm
set incsearch
set hlsearch
set showmatch
set wmnu
set lpl
set ic
set scs
set sc
set sel=exclusive
set bg=dark
set colorcolumn=80
set ff=unix
set ts=2 sts=2 sw=2 expandtab  " For Android (userspace)
set list
set lcs=tab:>-
set nocompatible              " be iMproved
set csverb
set viminfo+=!
set laststatus=2
set noshowmode
set cmdheight=2
"set shell=bash\ --login
set guicursor=

"set autochdir
"autocmd VimEnter * silent! cd %:p:h

syntax on

let s:uname=system('uname')

filetype on                   " required!
filetype plugin indent on     " required!
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

"autocmd FileType c,cpp,h
autocmd BufWritePre <buffer> :%s/\s\+$//e

"cd ~/

"============================ cscope & ctags ==================================
set tags=tags,./tags,~/builds/repo/tags,~/builds/android/tags,~/workspace/android
set csto=0
set cst


"============================ plugin ==========================================
call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align' " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'https://github.com/junegunn/vim-github-dashboard.git' " Any valid git URL is allowed
"Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets' Multiple Plug commands can be written in a single line using | separators
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' } " On-demand loading
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' } " Using a non-master branch
Plug 'fatih/vim-go', { 'tag': '*' } " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' } " Plugin options
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " Plugin outside ~/.vim/plugged with post-update hook
Plug '~/my-prototype-plugin' " Unmanaged plugin (manually installed and updated)
Plug 'junegunn/fzf.vim'
Plug 'rking/ag.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'wincent/ferret'
Plug 'mileszs/ack.vim'
Plug 'vim-jp/vim-cpp'
Plug 'tomasiser/vim-code-dark'
Plug 'dunstontc/vim-vscode-theme'
"Plug 'octol/vim-cpp-enhanced-highlight'
"Plug 'bfrg/vim-cpp-modern'
Plug 'gdoorenbos/gd-vim-colors'
"Plug 'ronakg/quickr-cscope.vim'
"Plug 'bbchung/clighter8'
"Plug 'bbchung/clighter'
"Plug 'jeaye/color_coded'
call plug#end() " Initialize plugin system

"============================ NERD tree =======================================
let Tlist_Use_Right_Window = 1
let g:NERDTreeWinSize=30
let Tlist_WinWidth = 35
let g:go_version_warning = 0

"============================ vim-cpp-enhanced-highlight ======================
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1

let g:cpp_concepts_highlight = 1

"============================ vim-cpp-modern ==================================
let g:cpp_simple_highlight = 1
let g:cpp_named_requirements_highlight = 1

""============================ vim-cpp-enhanced-highlight ======================
let g:airline_theme = 'codedark'

"let g:quickr_cscope_keymaps = 0
"let g:quickr_cscope_use_qf_g = 1

"============================ options ==========================================
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
  set termencoding=utf-8
else
  set termencoding=cp949
endif

if &term=="xterm" || &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
  set t_Co=256
  set t_Sf=^[[3%dm
  set t_Sb=^[[4%dm
  set t_ut=
  fixdel
endif

if version >= 500
  func! Sts()
    let st = expand("<cword>")
    exe "sts ".st
  endfunc
  nmap ,st :call Sts()<cr>

  func! Tj()
    let st = expand("<cword>")
    exe "tj ".st
  endfunc
  nmap ,tj :call Tj()<cr>
endif


"============================ system dependency ===============================
if has('gui_running')
  set csprg=/usr/local/bin/cscope
  set guifont=DejaVu_Sans_Mono_for_Powerline:h9:cANSI:qDRAFT
  colo torte

elseif s:uname =~ "Darwin"
  set csprg=/usr/local/bin/cscope

elseif s:uname =~ "MINGW64_NT*"
  set csprg=/c/Users/heungjun/scoop/shims/cscope
  set guifont=DejaVu_Sans_Mono_for_Powerline:h9:cANSI:qDRAFT
  colo torte

else " linux
"  colo dark_plus
  colo codedark

endif

if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  colo torte
  "command -nargs=? Guifont call rpcnotify(0, 'Gui', 'SetFont', "<args>")
  "let g:GuiFont="DejaVu Sans Mono for Powerline:h9"
  GuiFont DejaVu Sans Mono for Powerline:h9:cANSI:qDRAFT

"    tnoremap <Esc> <C-\><C-n>
  set csprg=C:\Users\heungjun\share\util
endif


set hlsearch
hi Search ctermbg=DarkBlue
hi Search ctermfg=NONE

"============================ mapping =========================================
abbr #b /*********************************************************
abbr #e *********************************************************/

set clipboard=unnamed " xclip : vi -> shell (mac) : <C-c> -> <Cmd-v>
vmap <C-c> y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>

map <silent> <S-Insert> "+p
imap <silent> <S-Insert> <Esc>"+p

map! jk <Esc>

" Recursive shortcut
nmap <F2> :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR><CR>
nmap <F3> :NERDTreeToggle<cr>
nmap <F4> :Tlist<cr>
nmap <F5> :set ts=8 sts=8 sw=8 noexpandtab<CR>  " Kernel
nmap <F6> :set ts=2 sts=2 sw=2 expandtab<CR>    " Android (userspace)
nmap <F7> :set ts=4 sts=4 sw=4 expandtab<CR>    " Python
nmap <F10> :source $MYVIMRC<CR>:PlugInstall<CR>

nmap <C-[>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-[>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-[>d :cs find d <C-R>=expand("<cword>")<CR><CR>

nmap <C-S-f>o :Files<CR><CR>
nmap <C-S-f>p :Ack <C-R>=expand("<cword>")<CR><CR>
noremap <C-w><C-Up> :resize +5<CR>
noremap <C-w><C-Down> :resize -5<CR>

nmap <C-g>c :!git cherry-pick <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>v :!git revert <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>g :!git ll --grep=<C-R>=expand("<cword>")<CR><CR>
nmap <C-g>l :!git ll <bar> grep <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>h :!git show <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>r :!git reset --hard<CR><CR>
nmap <C-g>d :!git diff<CR>
nmap <C-g>s :!git status<CR>
