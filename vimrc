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
set ts=2 sts=2 sw=2 expandtab  " for android (userspace)
set list
set lcs=tab:>-
set nocompatible              " be improved
set csverb
set viminfo+=!
set laststatus=2
set noshowmode
set cmdheight=2
"set shell=bash\ --login
set guicursor=
set autochdir

cd ~/
"lcd ~/workspace

set tags=tags,./tags,~/builds/repo/tags,~/builds/android/tags,~/workspace/android
set csprg=/usr/local/bin/cscope
set csto=0
set cst

syntax on

let s:uname=system('uname')

call plug#begin('~/.vim/plugged')
plug 'junegunn/vim-easy-align' " shorthand notation; fetches https://github.com/junegunn/vim-easy-align
plug 'https://github.com/junegunn/vim-github-dashboard.git' " any valid git url is allowed
"plug 'sirver/ultisnips' | plug 'honza/vim-snippets' multiple plug commands can be written in a single line using | separators
plug 'scrooloose/nerdtree', { 'on':  'nerdtreetoggle' } " on-demand loading
plug 'tpope/vim-fireplace', { 'for': 'clojure' }
plug 'rdnetto/ycm-generator', { 'branch': 'stable' } " using a non-master branch
plug 'fatih/vim-go', { 'tag': '*' } " using a tagged release; wildcard allowed (requires git 1.9.2 or above)
plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' } " plugin options
plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " plugin outside ~/.vim/plugged with post-update hook
plug '~/my-prototype-plugin' " unmanaged plugin (manually installed and updated)
plug 'junegunn/fzf.vim'
plug 'rking/ag.vim'
call plug#end() " initialize plugin system

filetype on                   " required!
filetype plugin indent on     " required!
highlight extrawhitespace ctermbg=red guibg=red
match extrawhitespace /\s\+$/

autocmd filetype c,cpp,h
autocmd bufwritepre <buffer> :%s/\s\+$//e

map <silent> <s-insert> "+p
imap <silent> <s-insert> <esc>"+p

abbr #b /*********************************************************
abbr #e *********************************************************/

if v:lang =~ "utf8$" || v:lang =~ "utf-8$"
  set termencoding=utf-8
else
  set termencoding=cp949
endif

if &term=="xterm" || &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
  set t_co=16
  set t_sf=^[[3%dm
  set t_sb=^[[4%dm
  fixdel
endif

if version >= 500
  func! sts()
    let st = expand("<cword>")
    exe "sts ".st
  endfunc
  nmap ,st :call sts()<cr>

  func! tj()
    let st = expand("<cword>")
    exe "tj ".st
  endfunc
  nmap ,tj :call tj()<cr>
endif

if has('gui_running')
  set guifont=dejavu_sans_mono_for_powerline:h9:cansi:qdraft
  colo torte

elseif s:uname =~ "darwin"
  python from powerline.vim import setup as powerline_setup
  python powerline_setup()
  python del powerline_setup

elseif s:uname =~ "mingw64_nt*"
  set guifont=dejavu_sans_mono_for_powerline:h9:cansi:qdraft
  colo torte

else " linux
  colo torte

endif

if has('nvim')
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  colo torte
  "command -nargs=? guifont call rpcnotify(0, 'gui', 'setfont', "<args>")
  "let g:guifont="dejavu sans mono for powerline:h9"
  "guifont dejavu sans mono for powerline:h9:cansi:qdraft

"    tnoremap <esc> <c-\><c-n>
endif

let g:minimap_show='<leader>ms'
let g:minimap_update='<leader>mu'
let g:minimap_close='<leader>gc'
let g:minimap_toggle='<leader>gt'

" xclip
" vi -> shell (mac) : <c-c> -> <cmd-v>
set clipboard=unnamed
vmap <c-c> y:call system("xclip -i -selection clipboard", getreg("\""))<cr>:call system("xclip -i", getreg("\""))<cr>
map! <tab><tab> <esc>

" recursive shortcut
nmap <f2> :redir @a<cr>:g//<cr>:redir end<cr>:new<cr>:put! a<cr><cr>
nmap <f3> :nerdtreetoggle<cr>
nmap <f4> :tlist<cr>
nmap <f5> :set ts=8 sts=8 sw=8 noexpandtab<cr>  " kernel
nmap <f6> :set ts=2 sts=2 sw=2 expandtab<cr>    " android (userspace)
nmap <f7> :set ts=4 sts=4 sw=4 expandtab<cr>    " python
nmap <f9> :e $myvimrc<cr>
nmap <f10> :source $myvimrc<cr>

nmap <c-[>s :cs find s <c-r>=expand("<cword>")<cr><cr>
nmap <c-[>g :cs find g <c-r>=expand("<cword>")<cr><cr>
nmap <c-[>c :cs find c <c-r>=expand("<cword>")<cr><cr>
nmap <c-[>t :cs find t <c-r>=expand("<cword>")<cr><cr>
nmap <c-[>e :cs find e <c-r>=expand("<cword>")<cr><cr>
nmap <c-[>f :cs find f <c-r>=expand("<cfile>")<cr><cr>
nmap <c-[>i :cs find i ^<c-r>=expand("<cfile>")<cr>$<cr>
nmap <c-[>d :cs find d <c-r>=expand("<cword>")<cr><cr>

nmap <c-g>c :!git cherry-pick <c-r>=expand("<cword>")<cr><cr>
nmap <c-g>v :!git revert <c-r>=expand("<cword>")<cr><cr>
nmap <c-g>g :!git ll --grep=<c-r>=expand("<cword>")<cr><cr>
nmap <c-g>l :!git ll <bar> grep <c-r>=expand("<cword>")<cr><cr>
nmap <c-g>h :!git show <c-r>=expand("<cword>")<cr><cr>
nmap <c-g>r :!git reset --hard<cr><cr>
nmap <c-g>d :!git diff<cr>
nmap <c-g>s :!git status<cr>
