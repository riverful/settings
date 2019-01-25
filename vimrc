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
set shell=bash\ --login

cd ~/workspace
lcd ~/workspace

set tags=tags,./tags,~/builds/repo/tags,~/builds/android/tags,~/workspace/android
set csprg=/usr/local/bin/cscope
set csto=0
set cst

syntax on

let s:uname=system('uname')

call plug#begin('~/.vim/plugged')
Plug 'junegunn/vim-easy-align' " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'https://github.com/junegunn/vim-github-dashboard.git' " Any valid git URL is allowed
"Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets' Multiple Plug commands can be written in a single line using | separators
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' } " On-demand loading
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' } " Using a non-master branch
Plug 'fatih/vim-go', { 'tag': '*' } " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' } " Plugin options
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " Plugin outside ~/.vim/plugged with post-update hook
Plug '~/my-prototype-plugin' " Unmanaged plugin (manually installed and updated)
Plug 'junegunn/fzf.vim'
Plug 'rking/ag.vim'
call plug#end() " Initialize plugin system

filetype on                   " required!
filetype plugin indent on     " required!
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

autocmd FileType c,cpp,h
autocmd BufWritePre <buffer> :%s/\s\+$//e

map <silent> <S-Insert> "+p
imap <silent> <S-Insert> <Esc>"+p

abbr #b /*********************************************************
abbr #e *********************************************************/

if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
  set termencoding=utf-8
else
  set termencoding=cp949
endif

if &term=="xterm" || &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
  set t_Co=16
  set t_Sf=^[[3%dm
  set t_Sb=^[[4%dm
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

if has('gui_running')
  set guifont=DejaVu_Sans_Mono_for_Powerline:h9:cANSI:qDRAFT
  colo torte

elseif s:uname =~ "Darwin"
  python from powerline.vim import setup as powerline_setup
  python powerline_setup()
  python del powerline_setup

elseif s:uname =~ "MINGW64_NT*"
  set guifont=DejaVu_Sans_Mono_for_Powerline:h9:cANSI:qDRAFT
  colo torte

else " linux
  colo torte

endif

let g:minimap_show='<leader>ms'
let g:minimap_update='<leader>mu'
let g:minimap_close='<leader>gc'
let g:minimap_toggle='<leader>gt'

" xclip
" vi -> shell (mac) : <C-c> -> <Cmd-v>
set clipboard=unnamed
vmap <C-c> y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>

" Recursive shortcut
nmap <F1> :source $MYVIMRC<CR>
nmap <F2> :source ~/scripts/script_work.sh <CR>
nmap <F3> :NERDTree<cr>
nmap <F4> :Tlist<cr>
nmap <F5> :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR><CR>
nmap <F6> :set ts=8 sts=8 sw=8 noexpandtab<CR>  " Kernel
nmap <F7> :set ts=2 sts=2 sw=2 expandtab<CR>    " Android (userspace)
nmap <F8> :set ts=4 sts=4 sw=4 expandtab<CR>    " Python

nmap <C-[>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-[>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-[>d :cs find d <C-R>=expand("<cword>")<CR><CR>

nmap <C-g>c :!git cherry-pick <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>v :!git revert <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>g :!git ll --grep=<C-R>=expand("<cword>")<CR><CR>
nmap <C-g>l :!git ll <bar> grep <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>h :!git show <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>r :!git reset --hard<CR><CR>
nmap <C-g>d :!git diff<CR>
nmap <C-g>s :!git status<CR>
