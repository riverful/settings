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
syntax on

let s:uname=system('uname')

set rtp+=~/.vim/bundle/vundle
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'vim-airline/vim-airline'
Plugin 'fugitive.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'sjl/gundo.vim'
Plugin 'gregsexton/gitv'
Plugin 'SrcExpl'
Plugin 'Source-Explorer-srcexpl.vim'
Plugin 'highlight.vim'
Plugin 'severin-lemaignan/vim-minimap'
Bundle 'majutsushi/tagbar'
if has('gui_running')
  echo "gui running"
elseif s:uname =~ "MINGW64_NT*"
  echo "Ming running"
else
  Bundle 'Shougo/neocomplete.vim'
endif
call vundle#end()

filetype on
filetype plugin indent on
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

autocmd FileType c,cpp,h
autocmd BufWritePre <buffer> :%s/\s\+$//e

"SrcExpl
let g:SrcExpl_isUpdateTags = 0

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

" Gvim setting
if has('gui_running')
  set guifont=DejaVu_Sans_Mono_for_Powerline:h9:cANSI:qDRAFT
  colo torte

elseif s:uname =~ "MINGW64_NT*"
  set guifont=DejaVu_Sans_Mono_for_Powerline:h9:cANSI:qDRAFT
  colo torte

elseif s:uname =~ "Darwin"
  set tags=./tags
  if filereadable("/usr/local/bin/cscope")
    set csprg=/usr/local/bin/cscope
  endif
  if filereadable("/usr/bin/cscope")
    set csprg=/usr/bin/cscope
  endif
  set csto=0
  set cst

  set laststatus=2
  set noshowmode

  " neocomplete
  " Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
  let g:acp_enableAtStartup = 0   " Disable AutoComplPop.
  let g:neocomplete#enable_at_startup = 1   " Use neocomplete.
  let g:neocomplete#enable_smart_case = 1   " Use smartcase.
  let g:neocomplete#sources#syntax#min_keyword_length = 3 " Set minimum syntax keyword length.

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
        \ 'default' : '',
        \ 'vimshell' : $HOME.'/.vimshell_hist',
        \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif

  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  " Plugin key-mappings.
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? "\<C-y>" : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  " Close popup by <Space>.
  "inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

  " AutoComplPop like behavior.
  "let g:neocomplete#enable_auto_select = 1

  " Shell like behavior(not recommended).
  "set completeopt+=longest
  "let g:neocomplete#enable_auto_select = 1
  "let g:neocomplete#disable_auto_complete = 1
  "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

  " For perlomni.vim setting.
  " https://github.com/c9s/perlomni.vim
  let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

else " linux
  set tags=./tags
  if filereadable("/usr/local/bin/cscope")
    set csprg=/usr/local/bin/cscope
  endif
  if filereadable("/usr/bin/cscope")
    set csprg=/usr/bin/cscope
  endif
  set csto=0
  set cst

  set laststatus=2
  set noshowmode

  " neocomplete
  " Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
  let g:acp_enableAtStartup = 0   " Disable AutoComplPop.
  let g:neocomplete#enable_at_startup = 1   " Use neocomplete.
  let g:neocomplete#enable_smart_case = 1   " Use smartcase.
  let g:neocomplete#sources#syntax#min_keyword_length = 3 " Set minimum syntax keyword length.

  " Define dictionary.
  let g:neocomplete#sources#dictionary#dictionaries = {
        \ 'default' : '',
        \ 'vimshell' : $HOME.'/.vimshell_hist',
        \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

  " Define keyword.
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif

  let g:neocomplete#keyword_patterns['default'] = '\h\w*'

  " Plugin key-mappings.
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()

  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? "\<C-y>" : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  " Close popup by <Space>.
  "inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

  " AutoComplPop like behavior.
  "let g:neocomplete#enable_auto_select = 1

  " Shell like behavior(not recommended).
  "set completeopt+=longest
  "let g:neocomplete#enable_auto_select = 1
  "let g:neocomplete#disable_auto_complete = 1
  "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

  " Enable heavy omni completion.
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  "let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  "let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
  "let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

  " For perlomni.vim setting.
  " https://github.com/c9s/perlomni.vim
  let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

endif



" xclip
" vi -> shell (mac) : <C-c> -> <Cmd-v>
set clipboard=unnamed
vmap <C-c> y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>
nmap <C-v> :call setreg("\"",system("xclip -o -selection clipboard"))<CR>p

inoremap jk <esc>

nmap <C-r>r :source $MYVIMRC<CR>
nmap <C-r>g :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR><CR>
nmap <C-r>3 :set ts=8 sts=8 sw=8 noexpandtab<CR>  " Kernel
nmap <C-r>4 :set ts=2 sts=2 sw=2 expandtab<CR>    " Android (userspace)
nmap <C-r>5 :set ts=4 sts=4 sw=4 expandtab<CR>    " Python
nmap <F6> :TagbarToggle<cr>
nmap <F7> :Tlist<cr>
nmap <F8> :SrcExplToggle<cr>
nmap <F9> :Gitv<cr>

nmap <C-[>s :scs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>g :scs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>c :scs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>t :scs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>e :scs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-[>f :scs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-[>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-[>d :scs find d <C-R>=expand("<cword>")<CR><CR>

nmap <C-g>c :!git cherry-pick <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>v :!git revert <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>g :!git ll --grep=<C-R>=expand("<cword>")<CR><CR>
nmap <C-g>l :!git ll <bar> grep <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>h :!git show <C-R>=expand("<cword>")<CR><CR>
nmap <C-g>r :!git reset --hard<CR><CR>
nmap <C-g>d :!git diff<CR>
nmap <C-g>s :!git status<CR>
