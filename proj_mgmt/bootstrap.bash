#!/bin/bash
# -*- shell-script -*-
MY_DIR=$(dirname $(readlink -f $0))
source $MY_DIR/helper/script_helper_routines.sh



mclay_ansible_update ()
{
  ansible-pull -U https://bitbucket.com/rtmclay/rtm_provision.git mclay.yml
}



git_clone_update_repos ()
{
  BB=(
    "rtm_up:.up:master"
    "lmod:w/lmod:master"
    "xalt:w/xalt:master"
    )
  mkdir -p ~/w/dao

  for i in "${BB[@]}"; do
    pull_update_repo bitbucket.com "rtmclay/" $i
  done

  RR=(
    "g:g:master"
    "shell_startup:w/shell_startup_debug:master"
    "genkey:w/genkey:master"
    "hermes:w/hermes:master"
    "themis:w/themis:master"
    "lua54:w/lua54:master"
    "luatools:w/luatools:master"
    "usefulTools:w/usefulTools:master"
    "cfdtools:w/dao/cfdtools:master"
    )

  for i in "${RR[@]}"; do
    pull_update_repo riverton.ddns.net "" $i
  done
}

root_git_repos_update ()
(
  BB=(
    "rtm_up:.up:master"
    )
  for i in "${BB[@]}"; do
    sudo pull_update_repo bitbucket.com "rtmclay/" $i
  done
)


install_lua54 ()
{
  cd ~
  if [ ! -f /opt/apps/lua/lua/bin/lua ]; then
     cd w/lua54;
    ./build.rtm
  fi
  cd ~
}

install_luatools ()
{
  cd ~
  if [ ! -d /opt/apps/luatools ]; then
    PATH=/opt/apps/lua/lua/bin:$PATH
     cd w/luatools;
    ./build.rtm
    cat > .version <<EOF
.2
EOF
    sudo mv .version /opt/apps/luatools
    sudo chown root: /opt/apps/luatools/.version
  fi
  cd ~
}

cmdA=("install_ssh_keys"
      "minimal_pkg_install"
      "cleanup"
      "root_ansible_update"
      "mclay_ansible_update"
      "root_git_repos_update"
      "git_clone_update_repos"
      "install_lua54"
      "install_luatools"
      )

runMe "${cmdA[@]}"



