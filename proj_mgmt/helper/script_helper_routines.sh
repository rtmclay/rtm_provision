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

pull_update_repo ()
{
  service=$1
  account=$2
  repo=${3%%:*}
  pair=${3#*:}
  dir=${pair%:*}
  branch=${pair#*:}
  cd ~
  
  if [ ! -d ~/$dir -a ! -d $dir ]; then
    echo "git clone git@$service:${account}$repo $dir"
          git clone git@$service:${account}$repo $dir
  fi
  echo "cd $dir; git pull origin $branch"
        cd $dir; git pull origin $branch
  cd ~
}
