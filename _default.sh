#!/bin/bash

#########################################################
# log
#########################################################

LOG_PREFIX_DEF="[deflt]"
_log_default() {
  case $SHELL in
  */zsh)
    echo -e "${LOG_PREFIX_DEF}\t[${funcstack[1]}] $1"
    ;;
  */bash)
    echo -e "${LOG_PREFIX_DEF}\t[${FUNCNAME[1]}] $1"
    ;;
  esac
}


#########################################################
# core func
#########################################################

_set_default_env() {
  export JAVA_HOME="/usr/lib/jvm/jdk1.7.0_75"
  export ANDROID_JAVA_HOME=$JAVA_HOME
  export CLASSPATH="${JAVA_HOME}/lib"
  export PATH="${ANDROID_JAVA_HOME}/bin:$HOME/$_ENV:${PATH}"

  # alias
  alias ugs="ugit origin $_ENV ; cd $HOME"
  alias ugr="source $HOME/$_ENV/setup.sh"
  alias mkdird="mkdir `date '+%m%d'` ; cd `date '+%m%d'`"
  alias timetake="time sh -c "
  alias portcheck="netstat -tnlp ; nmap localhost"
  alias gsf="git submodule foreach"
  alias gsi="git submodule update --init --recursive"
  alias git_recover="git fsck ; git gc ; git prune ; git repack ; git fsck "
  alias networkhost="nmap -sn 192.168.2.0/24 | grep \"Nmap scan\" "

  stty erase '^H'
  stty erase '^?'
#    setxkbmap -layout us -option ctrl:nocaps

  # according to mach
  local MACH=`uname`
  if [ $MACH = 'Linux' ]; then
    export UBUNTU_VERSION=`lsb_release -a | grep "Description" | cut -d ' ' -f 2`
  fi

  # according to shell
  case $SHELL in
  */bash)
    export -f _dosunix
    export PS1="[\[\e[35;40m\]\t\[\e[0m\]] \[\033[0;94m\]\u@\h \[\e[1;32m\]\w \[\e[0m\] \n \$ "
    ;;
  */zsh)
    export PROMPT='
%{$fg_bold[blue]%} %M %{$fg_bold[green]%}%~%{$reset_color%}$(git_prompt_info) ⌚ %{$fg_bold[red]%}%*%{$reset_color%}
$ '
    export RPROMPT='$(ruby_prompt_info)'
    ;;
  esac

  _log_default "PATH, stty, alias, PS1"
}
_set_default_git_env() {
  if [ "$1" != "y" ]; then
    return
  fi

  git config --global user.name "none"
  git config --global user.email "noname@noname.com"
  git config --global core.fileMode false
  git config --global branch.current "yellow reverse"
  git config --global branch.local "yellow"
  git config --global branch.remote "green"
  git config --global diff.meta "yellow bold"
  git config --global diff.frag "magenta bold"
  git config --global diff.old "red bold"
  git config --global diff.new "green bold"
  git config --global status.added "yellow"
  git config --global status.changed "green"
  git config --global status.untracked "cyan"
  git config --global color.ui true
  git config --global core.whitespace "fix,-indent-with-non-tab,trailing-space,cr-at-eol"
  git config --global core.editor vim
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.lg "log -p"
  git config --global alias.lla "log --graph --decorate --pretty=oneline --abbrev-commit --all"
  git config --global alias.ls "log --stat"
  git config --global alias.ll "log --pretty=format:\"%C\(yellow\)%h %C(cyan)%\>\(12\)%cd %Cgreen%\<\(20,trunc\)%aN %Creset%s %C\(red\)%d\" --date=short --graph"
  git config --global alias.ld "log -p --stat"
  git config --global alias.l "log --pretty=format:\"%C\(yellow\)%h %C(cyan)%\>\(12\)%cd %Cgreen%\<\(20,trunc\)%aN %Creset%s %C\(red\)%d\" --date=short"

  git config --global --replace-all core.fileMode false
  git config --global core.whitespace trailing-space
#  git config --global core.autocrlf false

  git config --global merge.tool vimdiff
  git config --global merge.conflictstyle diff3
  git config --global mergetool.prompt false

  git config --global oh-my-zsh.hide-dirty 1

  _log_default "git"
}

#########################################################
# Android
#########################################################

adbwaitclean() {
  $HOST_ADB wait-for-device
  $HOST_ADB root
  $HOST_ADB logcat -c
}
adbloggrep() {
  if [ "$1" = "" ]; then
    _log_default "Usage: adb_log_grep [string]"
    return
  fi
  $HOST_ADB logcat -v time | tee tmplog | grep "$1"
}
adbcleanloggrep() {
  if [ "$1" = "" ]; then
    _log_default "Usage: adb_log_grep [string]"
    return
  fi
  adbwaitclean
  $HOST_ADB logcat -vthreadtime | tee tmplog | grep "$1"
}
adbkeyback() {
  adbwaitclean
  $HOST_ADB shell input keyevent 4
}


#########################################################
# setup environment
#########################################################
install_env() {
  rm -rf _env_temp
  mkdir _env_temp
  cd _env_temp

  wget https://github.com/riverful/settings/raw/master/screenrc
  wget https://github.com/riverful/settings/raw/master/vimrc
  wget https://github.com/riverful/settings/raw/master/taglist.vim
  wget https://github.com/junegunn/vim-plug/raw/master/plug.vim

  chmod 600 screenrc
  chmod 644 vimrc
  chmod 644 taglist.vim

  rm -rf $HOME/.vim/plugin
  rm -rf $HOME/.vim/plugged
  rm -rf $HOME/.vim
  rm -rf $HOME/.vimrc
  rm -rf $HOME/.screenrc
  rm -rf $HOME/.tmux.conf

  mkdir $HOME/.vim
  mkdir $HOME/.vim/plugin
  mkdir $HOME/.vim/autoload

  mv screenrc $HOME/.screenrc
  mv vimrc $HOME/.vimrc
  mv taglist.vim $HOME/.vim/plugin/taglist.vim
  mv plug.vim $HOME/.vim/autoload/plug.vim

  vim +PlugInstall +qall

  cd ..
  rm -rf _env_temp
}


#########################################################
# util
#########################################################
mk_cscope_ctags() {
  local in_file=$1
  path_root_cscope=""
  if [ "$in_file" = "." ] ; then
    local path_root_cscope="."
    _log_default "ALL: ${path_root_cscope}"
  elif [ ! -e "$in_file" ] ; then
    if [ -e "./cscope.paths" ]; then
      while read _file_path
      do
        path_root_cscope+="$_file_path "
      done < ./cscope.paths
      _log_default "from list file default, path: ${path_root_cscope}"
    else
      _log_default "no input"
    fi
  else
    while read _file_path
    do
      path_root_cscope+="$_file_path "
    done < $in_file
    mv $in_file cscope.paths
    _log_default "from list file: $1, path: ${path_root_cscope}"
  fi

  rm -rf cscope.files cscope.out tags
  find $path_root_cscope -type f \( -name '*.py' -o -name '*.c' -o -name '*.cpp' -o -name '*.cc' -o -name '*.h' -o -name '*.s' -o -name '*.S' \) ! \( -path "*.git*" \) -print > cscope.files
  cscope -b -i cscope.files
  ctags --sort=foldcase -L cscope.files
}
_dosunix() {
  dos2unix -f $1
  chmod 644 $1
}
dosunix_files() {
  find . -name "*.bat" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.txt" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.c" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.cpp" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.h" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.py" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.xml" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.xsd" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.mk" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "Makefile" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
}
gitcreate() {
  wget https://github.com/riverful/settings/raw/master/gitignore
  mv gitignore .gitignore

  dosunix_files

  git init
  git add .
  git config core.fileMode false
  git commit -a -m "Init"
}
_path_remove() {
  # Delete path by parts so we can never accidentally remove sub paths
  PATH=${PATH//":$1:"/":"} # delete any instances in the middle
  PATH=${PATH/#"$1:"/} # delete any instance at the beginning
  PATH=${PATH/%":$1"/} # delete any instance in the at the end
}


#########################################################
# excute
#########################################################

git_replace_apply="n"

if [ $# -eq 1 ]; then
  if [ "$1" = "y" ]; then
    git_replace_apply="y"
  fi
fi

if [ $_ENV = "" ]; then
  export _ENV=".env"
fi

_set_default_env
_set_default_git_env $git_replace_apply

_log_default "Load all"

