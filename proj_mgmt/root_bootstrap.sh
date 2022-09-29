#!/bin/bash
# -*- shell-script -*-

WD=$PWD

MY_DIR=$(dirname $(readlink -f $0))
source $MY_DIR/t/helper/script_helper_routines.sh

PATH=~root/bin:$PATH

root_ansible_update ()
{
  sudo ansible-pull -U https://github.com/rtmclay/rtm_provision.git root.yml
}

root_git_clone_repos ()
{
  BB=(
    "rtm_up:.up:master"
     )
  for i in "${BB[@]}"; do
    pull_update_repo bitbucket.com "rtmclay/" $i
  done

  mkdir -p ~/w/dao

  RR=(
    "g:g:master"
    "usefulTools:w/usefulTools:master"
    "setup_testxalt_mysql:w/setup_testxalt_mysql:main"
    "cfdtools:w/dao/cfdtools:master"
    "sysfiles:/opt/sysfiles:master"
    "modulefiles:/opt/apps/modulefiles:master"
    )

  for i in "${RR[@]}"; do
    pull_update_repo riverton.ddns.net "" $i
  done

}

root_up_install ()
{
  if [ -d ~/.rc/bash -a -L ~/.zshrc ]; then
    echo ".up installed"
    return
  fi
  STARTUP_COLLECTION="laptop root" ~/.up/tools/initUP --bz
  rm -f ~/.bashrc ~/.profile
  cd ~/.up
  ./Install.sh
  cd $WD
  if [ ! -d ~/.rc/bash ]; then
    echo "Failed to create ~/.rc/bash"
    exit 1
  fi
  if [ ! -L ~/.zshrc ]; then
    echo "Failed to a .zshrc symlink"
    exit 1
  fi
  cd $WD
}

root_sysfiles_install ()
{
  cd $WD
  if [ ! -d /opt/sysfiles ]; then
    echo 'sysfiles not installed -> exit'
    exit 1
  fi
  cd /opt/sysfiles
  ./Install.sh

  if [ ! -L /etc/profile.d/00_lua.SH ]; then
    echo 'sysfiles not installed -> exiting'
    exit 1
  fi
  cd $WD
}
setup_xalt_account_in_mysql ()
{
  cd ~/w/setup_testxalt_mysql
  ./create_testxalt_db.py
  cd $WD
}


cmdA=("root_ansible_update"
      "root_git_clone_repos"
      "root_up_install"
      "root_sysfiles_install"
      "setup_xalt_account_in_mysql"
      )

runMe "${cmdA[@]}"
