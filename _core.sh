#!/bin/bash

#########################################################
# log
#########################################################

LOG_PREFIX_CORE="[core]"
_log_core() {
  case $SHELL in
  */zsh)
    echo -e "${LOG_PREFIX_CORE}\t[${funcstack[1]}] $1"
    ;;
  */bash)
    echo -e "${LOG_PREFIX_CORE}\t[${FUNCNAME[1]}] $1"
    ;;
  esac
}



#########################################################
# core func
#########################################################

_set_core_java_path() {
  if [ "$1" = "17" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64"
  elif [ "$1" = "18" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
  else
    export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64"
  fi

  export ANDROID_JAVA_HOME=$JAVA_HOME
  export CLASSPATH="${JAVA_HOME}/lib"
  export PATH="${PATH}:${ANDROID_JAVA_HOME}/bin:$HOME/Library/Android/sdk/platform-tools"

  _log_core "JAVA_HOME[$JAVA_HOME]"
}
_set_core_ssh_agent() {
  local _name_daemon='ssh-agent'
  local _pid_daemon=`ps -ef | grep $_name_daemon | grep -v 'grep' | sed 's/ \{1,10\}/:/g' | sed 's/^://g' | cut -f 2 -d ":"`

  # check all pid from ssh-agent
  for pid in ${_pid_daemon[@]}; do
    _log_core "killed : $pid"
    kill -9 $pid
  done

  # ssh-add newly
  eval "$(ssh-agent -s)"
  for key_id in `ls $HOME/.ssh/id_rsa* | grep -v '.pub'`; do
    ssh-add $key_id
  done

  _log_core "Set ssh-agent"
}

#########################################################
# install packages
#########################################################

uninstall_unused_linux_image() {
  dpkg --get-selections | grep 'linux-image*' | awk '{print $1}' | \
    egrep -v "linux-image-$(uname -r)|linux-image-generic" | \
    while read n; do $CMD_APT -y remove $n; done
}
install_java() {
  if [ "$1" = "" ]; then
    _log_core "Usage: install_java [17/18]"
    return
  fi

  if [[ "$1" == "17" ]]; then
    local _ver_jdk="7"
  elif [[ "$1" == "18" ]]; then
    local _ver_jdk="8"
  else
    local _ver_jdk="8"
  fi

  PKG_JDK="openjdk-${_ver_jdk}-jdk"
  $CMD_APT_ADD_REPO ppa:openjdk-r/ppa -y
  $CMD_APT update
  $CMD_APT install $PKG_JDK -y
}


#########################################################
# util
#########################################################

_parse_git_branch () {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
_get_pid() {
  local _name_daemon=$1
  local _pid_daemon=`ps -ef | grep $_name_daemon | grep -v 'grep' | sed 's/ \{1,10\}/:/g' | sed 's/^://g' | cut -f 2 -d ":"`
  for pid in $_pid_daemon; do
    _log_core "$pid"
  done
}
io_check() {
  local BANDWIDTH=`dd if=/dev/zero of=./tmpfile count=4000 bs=1024k | grep copied`
  rm -rf ./tmpfile
  _log_core "bandwidth $BANDWIDTH"
}
git_cleanup_oversize_lfs() {
  if [ -f $HOME/binary ] ; then
    java -jar $HOME/binary/archive/bfg-1.12.14.jar --strip-blobs-bigger-than 30M
  fi

  git reflog expire --expire=now --all
  git gc --prune=now --aggressive
}
java_change() {
  if [ "$1" = "" ]; then
    _log_core "[17/18]"
    return
  fi

  _execute_script n $1

  sudo update-alternatives --config java
  sudo update-alternatives --config javac

  java -version
}
git_solve_conflict() {
 vi `git diff &> log && cat log | grep "diff" | cut -f 3 -d " "` && rm -rf diff
}
git_dev_master_commdiffs() {
 git l dev &> tmp && sed '/Merge/d' tmp > dev_ && git l master_au &> tmp && sed '/Merge/d' tmp > au_ && vimdiff dev_ au_
}
git_dev_master_diffs() {
#  MASTER=`git log --pretty=format:'%H' $1 | sort`
#  DEV=`git log --pretty=format:'%H' $2 | sort`
  local MASTER=`git log --pretty=format:'%H' $1`
  local DEV=`git log --pretty=format:'%H' $2`
  for i in `diff <(echo "${MASTER}") <(echo "${DEV}") | grep '^>' | sed 's/^> //'`;
  do
    git --no-pager log -1 --oneline $i | sed '/Merge/d' ;
  done
}
gowork() {
  local _work_date=$(date +"%Y_%m%d")
  local _work_folder="$HOME/workspace/$_work_date"

  if [ -d "$_work_folder" ] ; then
    cd $_work_folder
  else
    echo "Newly make today folder."
    mkdir $_work_folder
  fi
}


#########################################################
# temp
#########################################################

is_file() {
  [ -f "$1" ]
}
is_file0() {
  return 0
}
is_file1() {
  return 1
}
is_test_folder() {
  if test -e $1
  then
    echo "Yes"
  else
    echo "No"
  fi
}
test_temp() {
  if is_file0 || is_file1 ; then
    echo "Exist"
  else
    echo "No"
  fi
}
test_check_num_char() {
  if [ $# -ne 1 ] ; then
    echo "Usage: $ test_check_num_char [input]"
    echo "    $ check_num_char aaaa"
    echo "    $ check_num_char 123411"
    return;
  else
    local _var=$1
  fi

  if  [ $_var -eq $_var 2> /dev/null ]; then
    echo "number"
  else
    echo "no number"
  fi
}


#########################################################
# manage scripts
#########################################################

_pgit() {
  cd $HOME/$2
  git push $1 master
}
ugit() {
  if [ "$1" = "" -o "$2" = "" ]; then
    _log_core "Usage: ugit [origin] [branch]"
    return
  fi
  local NOW=$(date +"%Y-%m-%d %H:%M:%S")
  cd $HOME/$2
  git remote update $1
#  git fetch $1
#  git co master
  git add .
  git commit -a -m "$NOW"
  git rebase origin/master
#  git pull $1 master
  _pgit $1 $2
}
ugc()
{
  if [ "$1" = "" ]; then
    _to="$HOME/$_ENV/"
  else
    _to=$1
  fi
  cd
  wget https://github.com/riverful/settings/raw/master/_core.sh
  wget https://github.com/riverful/settings/raw/master/_default.sh
  mv _default.sh $_to/_default.sh
  mv _core.sh $_to/_core.sh
  echo "$_to/_default.sh"
  echo "$_to/_core.sh"
}


#########################################################
# excute
#########################################################

source $HOME/$_ENV/_default.sh $1

_log_core "Load all"

