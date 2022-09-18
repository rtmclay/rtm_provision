#!/bin/bash
# -*- shell-script -*-

prepend_path ()
{
  envName=$1
  val=${!envName}
  if [ -z "$val" ]; then
    export $envName=$2
  else
    export $envName=$2:$val
  fi
    
}

function bannerMsg ()
{
  local RED=$'\033[1;31m'
  local NONE=$'\033[0m'
  echo ""
  echo "${RED}=======================================================================${NONE}"
  echo $1
  echo "${RED}=======================================================================${NONE}"
  echo ""
}

runMe()
{
  local cmdA=("$@")

  local rt
  local t0
  local t1
  local t_start
  local t_end
  local j
  local jj
  local i
  local ignoreError
  local j=0
  t0=$(my_epoch)
  for i in "${cmdA[@]}" ; do
    ignoreError=
    if [ "x${i:0:1}" = x- ]; then
      i=${i:1}
      ignoreError=1
    fi

    t_start=$(my_epoch)
    j=$((j+1))
    jj=$(printf "%02d" $j)
    echo
    echo "%%---------------------------------%%"
    echo "   " $jj: $i
    echo "%%---------------------------------%%"
    echo

    eval $i
    t_end=$(my_epoch)
    rt=$(echo "$t_end - $t_start" | bc)
    echo
    echo "Build time for $jj: $i $(my_seconds2time $rt)"
    echo
    if [ -z "$ignoreError" -a $? != 0 ]; then
      break
    fi
  done
  t1=$(my_epoch)
  rt=$(echo "$t1 - $t0" | bc)
  bannerMsg "Build time for all: $(my_seconds2time $rt)"
}

if [ ! -f ~mclay/.ssh/authorized_keys ]; then
   if [ ! -f ~mclay/pkg.tar.gz ]; then
     echo "need pkg.tar.gz file"
     exit 1
   fi 
fi

if [ -f ~mclay/pkg.tar.gz ]; then
   echo "unpack pkg.tar.gz"

   mkdir -p ~mclay/bin
   mkdir -p ~mclay/t


   cd ~mclay/t
   tar xf ~mclay/pkg.tar.gz

   cp pkg/bin/my_* ~mclay/bin
   chown -R mclay: ~mclay/bin ~mclay/t 
fi

PATH=~mclay/bin:$PATH

install_ssh_keys ()
{
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
}

minimal_pkg_install ()
{
  sudo apt update
  sudo apt install -y ansible git openssh-server seahorse
}

cleanup ()
{
  rm ~mclay/pkg.tar.gz
}

root_ansible_update ()
{
  sudo ansible-pull -U https://bitbucket.com/rtmclay/rtm_provision.git root.yml
}

mclay_ansible_update ()
{
  ansible-pull -U https://bitbucket.com/rtmclay/rtm_provision.git mclay.yml
}

git_up_repo ()
{
  cd ~
  if [ ! -d ~/.up ]; then
    git clone git@bitbucket.com:rtmclay/rtm_up .up
  fi
  cd .up; git pull origin master
}


cmdA=("install_ssh_keys"
      "minimal_pkg_install"
      "cleanup"
      "root_ansible_update"
      "mclay_ansible_update"
      "git_up_repo"
      )

runMe "${cmdA[@]}"



