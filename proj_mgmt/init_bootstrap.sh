#!/bin/bash
# -*- shell-script -*-

WD=$PWD

if [ ! -f ~mclay/.ssh/authorized_keys ]; then
   if [ ! -f ~mclay/pkg.tar.gz ]; then
     echo "need pkg.tar.gz file"
     exit 1
   fi 
fi

if [ -f ~mclay/pkg.tar.gz ]; then
   echo "unpack pkg.tar.gz"

   mkdir      -p ~mclay/bin
   mkdir      -p ~mclay/t/helper
   sudo mkdir -p ~root/t/helper
   sudo mkdir -p ~root/bin

   cd ~mclay/t
   tar xf ~mclay/pkg.tar.gz

   cp      pkg/scripts/rtm_setup.sh              ~mclay
   cp      pkg/scripts/script_helper_routines.sh ~mclay/t/helper
   sudo cp pkg/scripts/script_helper_routines.sh ~root/t/helper
   cp      pkg/bin/my_*                          ~mclay/bin
   sudo cp pkg/bin/my_*                          ~root/bin
   sudo cp pkg/scripts/root_bootstrap.sh         ~root
   chown -R mclay: ~mclay/bin ~mclay/t ~mclay/rtm_setup.sh
fi
cd $WD

PATH=~mclay/bin:$PATH

MY_DIR=$(dirname $(readlink -f $0))
source $MY_DIR/t/helper/script_helper_routines.sh

install_ssh_keys ()
{
  WD=$PWD
  if [ -d ~mclay/t/pkg ]; then
     cd ~mclay/t

     mkdir -p ~mclay/.ssh
     chmod 700 ~mclay/.ssh
     cp pkg/ssh/mclay/* ~mclay/.ssh
     chown -R mclay: ~mclay/.ssh

     sudo mkdir -p ~root/.ssh
     sudo chmod 700 ~root/.ssh

     sudo cp pkg/ssh/root/* ~root/.ssh
     rm -rf ~mclay/t/pkg
  fi
  cd $WD
}

minimal_pkg_install ()
{
  sudo apt update
  sudo apt install -y ansible git openssh-server seahorse
}

cleanup ()
{
  rm -f ~mclay/pkg.tar.gz
}

cmdA=("install_ssh_keys"
      "minimal_pkg_install"
      "cleanup"
      "root_ansible_update"
      )

runMe "${cmdA[@]}"
