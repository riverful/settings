#!/bin/bash

#########################################################
# core func
#########################################################

_set_java_path() {
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
  echo "[script] Set java path: [$JAVA_HOME]"
}
_set_alias() {
  # usage of rsync
  #   rsync -azrt --exclude '~/xxx' --exclude 'yyy' /mnt/to/ /mnt/from/
  # -e 'ssh -p 2222'

  OPTS_RSYNC="-avzogc --stats"
  OPTS_RSYNC_DELETE="-avzogc --stats --delete"
  OPTS_RSYNC_SSH="${OPTS_RSYNC} -e 'ssh -p 2222'"
  OPTS_RSYNC_SSH_DELETE="${OPTS_RSYNC_DELETE} -e 'ssh -p 2222'"

  alias rsyncs="sudo rsync ${OPTS_RSYNC_SSH}"
  alias rsyncs_sync="sudo rsync ${OPTS_RSYNC_SSH_DELETE}"

  alias du_sh_sort="du -sh * | sort -nr"
  alias du_sk_sort="du -sk * | sort -nr"
  alias adb_host='${HOST_ADB}'
  alias fastboot_host='${HOST_FASTBOOT}'

  alias screen_new="screen -s bash -S "
  alias screen_ls="screen -ls"
  alias screen_attach="screen -dr "

  alias tmxnew="tmux -2 new -s "
  alias tmxls="tmux -2 ls"
  alias tmxattach="tmux -2 attach -t "

  alias ls='ls -hF --color=tty'
  alias grepc="GREP_OPTIONS='color=auto grep"
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
    echo "Usage: install_java [17/18]"
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
install_dev_android() {
  install_java 17
  install_java 18
  $CMD_APT install git-core gnupg flex bison gperf build-essential \
    zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
    libgl1-mesa-dev libxml2-utils xsltproc unzip -y
  $CMD_APT autoremove
}
install_default() {
  if [[ "$UBUNTU_VERSION" == *"14.04"* ]]; then
    $CMD_APT_ADD_REPO ppa:jonathonf/vim -y # newest vim
  fi

  $CMD_APT update

  $CMD_APT install cmake clang vim ctags cscope htop tree screen python-dev \
    gparted python-pip synapse jq -y

  pip install --upgrad pip

  IS_UBUNTU_DESKTOP=`dpkg -l ubuntu-desktop`
  if [[ "$IS_UBUNTU_DESKTOP" == *"dpkg-query: no packages found"* ]]; then
    echo "[scripts] Ubuntu Server setting"
    $CMD_APT install openssh-server rdesktop sysstat -y # Server

  elif [[ "$IS_UBUNTU_DESKTOP" =~ "The Ubuntu desktop system" ]]; then
    echo "[scripts] Ubuntu Desktop setting"
    $CMD_APT install unity-tweak-tool gnome-tweak-tool synapse numix-* \
      compizconfig-settings-manager gconf-editor -y # Desktop
  fi

  $CMD_APT autoremove
}
install_all_pkgs() {
  install_default
  install_env
  install_dev_android
}


#########################################################
# util
#########################################################

_parse_git_branch () {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
_get_pid() {
  local NAME_DAEMON=$1
  local PID_DAEMON=`ps -ef | grep $NAME_DAEMON | grep -v 'grep' | sed 's/ \{1,10\}/:/g' | sed 's/^://g' | cut -f 2 -d ":"`
  for pid in $PID_DAEMON; do
    echo "[script] get_pid: $pid"
  done
}
_set_ssh_agent() {
  local NAME_DAEMON='ssh-agent'
  local PID_DAEMON=`ps -ef | grep $NAME_DAEMON | grep -v 'grep' | sed 's/ \{1,10\}/:/g' | sed 's/^://g' | cut -f 2 -d ":"`

  # check all pid from ssh-agent
  for pid in $PID_DAEMON; do
    echo "[script] killed : $pid"
    kill -9 $pid
  done

  # ssh-add newly
  eval "$(ssh-agent -s)"
  for key_id in `ls $HOME/.ssh/id_rsa* | grep -v '.pub'`; do
    ssh-add $key_id
  done
  echo "[script] Set ssh-agent"
}
timetake() {
  time sh -c "$1"
}
io_check() {
  local BANDWIDTH=`dd if=/dev/zero of=./tmpfile count=4000 bs=1024k | grep copied`
  rm -rf ./tmpfile
  echo "[script] bandwidth $BANDWIDTH"
}
port_check() {
  netstat -tnlp
  nmap localhost
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
    echo "Usage: java_change [17/18]"
    return
  fi

  _execute_script $1

  sudo update-alternatives --config java
  sudo update-alternatives --config javac

  java -version
}
git_recover() {
  git fsck; git gc; git prune; git repack; git fsck;
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
    echo "Usage: ugit [origin] [branch]"
    return
  fi
  local NOW=$(date +"%Y-%m-%d %H:%M:%S")
  cd $HOME/$2
  git remote update $1
  git fetch $1
  git co master
  git add .
  git commit -a -m "$NOW"
  git pull $1 master
  _pgit $1 $2
}
update_scripts_core() {
  cd
  wget https://raw.githubusercontent.com/riverful/settings/master/script_core.sh
  wget https://raw.githubusercontent.com/riverful/settings/master/script_default.sh
  mv script_default.sh ~/scripts/
  mv script_core.sh ~/scripts/
}


#########################################################
# excute
#########################################################

source $HOME/scripts/script_default.sh $1

echo "[script] Load core script"

