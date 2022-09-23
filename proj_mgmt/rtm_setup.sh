#!/bin/bash
# -*- shell-script -*-
WD=$PWD
MY_DIR=$(dirname $(readlink -f $0))
source $MY_DIR/t/helper/script_helper_routines.sh

PATH=~/bin:$PATH

git_clone_update_repos ()
{
  BB=(
    "rtm_up:.up:master"
    "luatools:w/luatools:master"
    "lmod:w/lmod:master"
    "xalt:w/xalt:master"
    )

  for i in "${BB[@]}"; do
    pull_update_repo bitbucket.com "rtmclay/" $i
  done

  mkdir -p ~/w/dao

  RR=(
    "g:g:master"
    "shell_startup:w/shell_startup_debug:master"
    "genkey:w/genkey:master"
    "hermes:w/hermes:master"
    "themis:w/themis:master"
    "lua54:w/lua54:master"
    "usefulTools:w/usefulTools:master"
    "cfdtools:w/dao/cfdtools:master"
    )

  for i in "${RR[@]}"; do
    pull_update_repo riverton.ddns.net "" $i
  done
}

mclay_ansible_update ()
{
  ansible-pull -U https://github.com/rtmclay/rtm_provision.git mclay.yml
}

rtm_up_install ()
{
  if [ -d ~/.rc/bash -a -L ~/.zshrc ]; then
    echo ".up installed"
    return
  fi
  STARTUP_COLLECTION="laptop emacs_client" ~/.up/tools/initUP --bz
  rm -f ~/.bashrc ~/.profile ~/.bash_logout
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

install_lua54 ()
{
  cd ~
  if [ ! -f /opt/apps/lua/lua/bin/lua ]; then
     cd w/lua54;
    ./build.rtm
  fi
  cd ~
  unset __LUA_PATH_DEFINED 
  source /etc/profile.d/00_lua.SH
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
  unset __LUA_PATH_DEFINED 
  source /etc/profile.d/00_lua.SH
  cd ~
}

install_luarocks ()
{
  if [ -L /opt/apps/luarocks/luarocks ]; then
    echo "luarocks already installed"
    return
  fi
  cd $WD
  RVER=3.9.1
  wget https://luarocks.org/releases/luarocks-${RVER}.tar.gz
  tar xf luarocks-${RVER}.tar.gz
  rm luarocks-${RVER}.tar.gz
  cd luarocks-${RVER}
  ./configure --prefix=/opt/apps/luarocks/$RVER && make && sudo make install
  cd /opt/apps/luarocks/; sudo ln -s $RVER luarocks

  cd $WD
  if [ ! -L /opt/apps/luarocks/luarocks ]; then
    echo 'no symlink for luarocks -> exiting'
    exit 1
  fi
  
  rm -rf luarocks-$RVER
  unset __LUA_PATH_DEFINED 
  source /etc/profile.d/00_lua.SH
  hash -r
  for i in busted luaposix luafilesystem luacheck; do
    sudo /opt/apps/luarocks/luarocks/bin/luarocks install $i
  done
  unset __LUA_PATH_DEFINED 
  source /etc/profile.d/00_lua.SH
  
}

install_shell_startup_debug ()
{
  if [ -L /opt/apps/shell_startup_debug/shell_startup_debug ]; then
    echo "Shell Startup Debug is installed"
    return
  fi
  
  cd ~/w/shell_startup_debug
  ./build.rtm
  cd /etc/profile.d
  sudo ln -s ../../opt/apps/shell_startup_debug/shell_startup_debug/init/bash 01_shell_startup_debug.SH
  sudo ln -s ../../opt/apps/shell_startup_debug/shell_startup_debug/init/csh  01_shell_startup_debug.CSH
  cd $WD
  if [ ! -L /etc/profile.d/01_shell_startup_debug.SH ]; then
    echo 'Shell Startup Debug is not installed -> exiting'
    exit 1
  fi
}

install_lmod ()
{
  if [ -x /opt/apps/lmod/lmod/libexec/lmod ]; then
    echo "Lmod already installed"
    return
  fi
  cd ~/w/lmod
  if [ -d master ]; then
    cd master
  fi
  if [ -d main ]; then
    cd main
  fi
  ./build.rtm
  sudo ln -s ../../opt/apps/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh
  sudo ln -s ../../opt/apps/lmod/lmod/init/cshrc   /etc/profile.d/z00_lmod.csh

  if [ ! -x /opt/apps/lmod/lmod/libexec/lmod ]; then
    echo "Lmod is not installed"
    exit 1
  fi
  cd $WD
}

cmdA=("git_clone_update_repos"
      "mclay_ansible_update"
      "rtm_up_install"
      "install_lua54"
      "install_luatools"
      "install_luarocks"
      "install_shell_startup_debug"
      "install_lmod"
      )


runMe "${cmdA[@]}"



