#!/bin/bash

#########################################################
# log
#########################################################

LOG_PREFIX_DEF="[deflt]"
_log_default() {
  echo -e "${LOG_PREFIX_DEF}\t[${FUNCNAME[1]}] $1"
}


#########################################################
# core func
#########################################################

_set_default_env() {
  export JAVA_HOME="/usr/lib/jvm/jdk1.7.0_75"
  export ANDROID_JAVA_HOME=$JAVA_HOME
  export CLASSPATH="${JAVA_HOME}/lib"
  export PATH="${ANDROID_JAVA_HOME}/bin:~/scripts:${PATH}"

  alias mkdird="mkdir `date '+%m%d'` ; cd `date '+%m%d'`"

  export CONF_ENV='None'

  _log_default "paths"
}
_set_default_shell_env() {
  if [[ "$UBUNTU_VERSION" == *"14.04"* ]]; then
    CMD_APT="sudo apt-get"
  else
    CMD_APT="sudo apt"
  fi
  CMD_APT_ADD_REPO="sudo add-apt-repository"

  case $SHELL in
  */zsh)
    stty erase ^H
    ;;
  */bash)
    stty erase ^H
    stty erase ^?
    export -f _dosunix
    export PS1="[\[\e[35;40m\]\t\[\e[0m\]] \[\033[0;94m\]\u@\h \[\e[1;32m\]\w \[\e[0m\] \n \$ "
    ;;
  esac


  _log_default "stty, PS1"
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

  chmod 600 screenrc

  _log_default "git"
}

#########################################################
# Android
#########################################################

reposetdir() {
  export _ANDROID_ROOT="`pwd`"

  _log_default "_ANDROID_ROOT [$_ANDROID_ROOT]"

  local MACH=`uname`
  if [ $MACH = 'Linux' ]; then
    local _RPATH_CCACHE=prebuilts/misc/linux-x86/ccache/
  elif [ $MACH = 'Darwin' ]; then
    local _RPATH_CCACHE=prebuilts/misc/darwin-x86/ccache/
  fi
  local _PATH_CCACHE="${_ANDROID_ROOT}/${_RPATH_CCACHE}"

  if [ -d $_PATH_CCACHE ]; then
    export USE_CCACHE=1
    export CCACHE_DIR="$_ANDROID_ROOT/.ccache"
    $_PATH_CCACHE/ccache -M 50G
    ulimit -S -n 1024
    _log_default "ccache [$_PATH_CCACHE/ccache]"
  fi

  if [ $MACH = 'Linux' ]; then
    local HOST_TOOL="${_ANDROID_ROOT}/out/host/linux-x86/bin/"
    export HOST_ADB="sudo ${HOST_TOOL}adb"
    export HOST_FASTBOOT="sudo ${HOST_TOOL}fastboot"
  else
    local HOST_TOOL=""
    export HOST_ADB="${HOST_TOOL}adb"
    export HOST_FASTBOOT="${HOST_TOOL}fastboot"
  fi

  cd "${_ANDROID_ROOT}"

  if [ -e build/envsetup.sh ] ; then
    source build/envsetup.sh
  fi
}
repolunch() {
  if [ $CONF_ENV != 'None' ]; then
    return
  fi

  reposetdir
  cd $_ANDROID_ROOT

  _log_default "source & lunching......"

  source build/envsetup.sh
  export "`grep -r "^TARGET_PRODUCT" ../buildscript/build.log | head -n 1 | sed "s/^.*TARGET_PRODUCT/TARGET_PRODUCT/"`"
  export "`grep -r "^PROJECT_NAME" ../buildscript/build.log | head -n 1 | sed "s/^.*PROJECT/PROJECT/"`"
  export "`grep -r "^SEC_TEMP_SKIP_BOOTLOADER" ../buildscript/build.log | head -n 1 | sed "s/^.*SEC_TEMP/SEC_TEMP/"`"
  `grep -r "lunch" ../buildscript/build.log | head -n 1 | sed "s/^.*lunch/lunch/"`
}

adb_wait_clean() {
  $HOST_ADB wait-for-device
  $HOST_ADB root
  $HOST_ADB logcat -c
}
adb_log_grep() {
  if [ "$1" = "" ]; then
    _log_default "Usage: adb_log_grep [string]"
    return
  fi
  adb_wait_clean
  $HOST_ADB logcat -vthreadtime | tee tmplog | grep "$1"
}
adb_setprop_rawdump() {
  adb_wait_clean
  $HOST_ADB root
  $HOST_ADB shell su -c setenforce 0
  $HOST_ADB shell setprop persist.camera.feature.osd 1
  $HOST_ADB shell setprop persist.camera.cal.awb 0
  $HOST_ADB shell setprop persist.camera.cal.lsc 0
  $HOST_ADB shell su -c setenforce 0
  $HOST_ADB shell chmod 777 /data
  $HOST_ADB shell chmod 777 /data/misc/camera
  $HOST_ADB shell setprop persist.camera.dumpimg 1310740
  $HOST_ADB shell setprop persist.camera.raw_yuv 1
  $HOST_ADB shell setprop persist.camera.zsl_raw 1
  $HOST_ADB shell setprop persist.camera.zsl_yuv 1
  $HOST_ADB shell setprop persist.camera.dumpmetadata 1
}
adb_key_back() {
  adb_wait_clean
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

  chmod 644 screenrc
  chmod 644 vimrc
  chmod 644 taglist.vim

  rm -rf ~/.vim/plugin
  rm -rf ~/.vim/plugged
  rm -rf ~/.vim
  rm -rf ~/.vimrc
  rm -rf ~/.screenrc
  rm -rf ~/.tmux.conf

  mkdir ~/.vim
  mkdir ~/.vim/plugin
  mkdir ~/.vim/autoload

  mv screenrc ~/.screenrc
  mv vimrc ~/.vimrc
  mv taglist.vim ~/.vim/plugin/taglist.vim
  mv plug.vim ~/.vim/autoload/plug.vim

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
  find . -name "*.c" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.cpp" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.h" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "*.xml" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
  find . -name "Android.mk" -not -path ".git" -exec bash -c '_dosunix "$0"' {} \;
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

_set_default_env
_set_default_shell_env
_set_default_git_env $git_replace_apply

_log_default "Load all"

