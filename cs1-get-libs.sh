#!/bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;

declare -a PCReqs=('g++' 'gcc')
declare -a Q6Reqs=('microblazeel-xilinx-linux-gnu-c++' 'microblazeel-xilinx-linux-gnu-cc')

if [ "$1" = "Q6" ]; then
    for item in ${Q6Reqs[*]}; do command -v $item >/dev/null 2>&1 || { echo >&2 "I require $item but it's not installed.  Aborting."; exit 1; }; done
else
    for item in ${PCReqs[*]}; do command -v $item >/dev/null 2>&1 || { echo >&2 "I require $item but it's not installed.  Aborting."; exit 1; }; done
fi; 

set -e # exit on errors or failed steps

cd ..
CS1=$(pwd)
NETMAN_DIR="$CS1/space-netman"
SHAKESPEARE_DIR="$CS1/space-lib/shakespeare"
HELIUM_DIR="$CS1/HE100-lib/C"
TIMER_DIR="$CS1/space-timer-lib"
COMMANDER_DIR="$CS1/space-commander"
WATCHPUPPY_DIR="$CS1/watch-puppy"
BABYCRON_DIR="$CS1/baby-cron"
JOBRUNNER_DIR="$CS1/space-jobs/job-runner"

echo "CS1 Dir: $CS1"

if [ "$#" -ne 1 ]; then
  echo "Enter the build environment"
  read build_environment
else 
  build_environment=$1
fi

check-master-branch () {
    branch_name="$(git symbolic-ref --short -q HEAD)"
    echo "Currently on branch: $branch_name"
    if [ "$branch_name" != "master" ]; then 
        confirm "This repo is on the '$branch_name' branch, are you sure you wish to continue?" && return 0 || return 1
    fi
    return 0
}

confirm () {
    read -r -p "${1:-[y/N]} [y/N] " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

confirm-build-q6 () {    
    case $build_environment in
      "Q6") 
            true
            ;;
        *)
            false
            ;;
    esac
}

setup-netman () {
  echo "Netman Dir: $NETMAN_DIR"
  mkdir -p $NETMAN_DIR/lib/include
  mkdir -p $NETMAN_DIR/bin
}

build-shakespeare () {
  echo 'Building shakespeare...'
  cd $SHAKESPEARE_DIR
  check-master-branch || exit 1
  mkdir -p $SHAKESPEARE_DIR/lib
  echo "cd: \c"
  pwd
  cp inc/shakespeare.h $NETMAN_DIR/lib/include/
  cp inc/shakespeare.h $HELIUM_DIR/inc/
  cp inc/shakespeare.h $TIMER_DIR/inc/
  cp inc/shakespeare.h $COMMANDER_DIR/include/
  cp inc/shakespeare.h $WATCHPUPPY_DIR/lib/include/
  cp inc/shakespeare.h $BABYCRON_DIR/include/
  cp inc/shakespeare.h $JOBRUNNER_DIR/inc/

  confirm-build-q6 && sh mbcc-compile-lib-static.sh || sh x86-compile-lib-static.sh

  cp lib/libshakespeare* $NETMAN_DIR/lib/
  cp lib/libshakespeare* $HELIUM_DIR/lib/
  cp lib/libshakespeare* $TIMER_DIR/lib/
  cp lib/libshakespeare* $COMMANDER_DIR/lib/
  cp lib/libshakespeare* $WATCHPUPPY_DIR/lib/
  cp lib/libshakespeare* $BABYCRON_DIR/lib/
  cp lib/libshakespeare* $JOBRUNNER_DIR/lib/
}

build-helium () {
  echo 'Building HE-100 Library...'
  cd $HELIUM_DIR
  check-master-branch || exit 1
  mkdir -p $CS1/HE100-lib/C/lib
  echo "cd: \c" 
  pwd
  cp $COMMANDER_DIR/include/Net2Com.h $HELIUM_DIR/inc/
  cp $COMMANDER_DIR/include/NamedPipe.h $HELIUM_DIR/inc/  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
  cp lib/libhe100* $NETMAN_DIR/lib/
  cp inc/SC_he100.h $NETMAN_DIR/lib/include/
}

build-timer () {
  echo 'Building timer Library...'
  cd $TIMER_DIR
  check-master-branch || exit 1
  mkdir -p $CS1/space-timer-lib/lib
  echo "cd: \c"
  pwd
  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
  cp lib/libtimer* $NETMAN_DIR/lib
  cp lib/libtimer* $HELIUM_DIR/lib
  cp inc/timer.h $NETMAN_DIR/lib/include
}

build-commander () {
  echo 'Building Namedpipes and commander libs...'
  cd $COMMANDER_DIR
  check-master-branch || exit 1
  mkdir -p $CS1/space-commander/lib
  mkdir -p $CS1/space-commander/bin
  echo "cd: \c"
  pwd
  cp include/Net2Com.h $NETMAN_DIR/lib/include
  cp include/NamedPipe.h $NETMAN_DIR/lib/include
  
  # TODO
  echo "Redundant?!" # check netman build deps
  confirm-build-q6 && make buildQ6 || make buildBin
  cp bin/space-commander* $NETMAN_DIR/bin
  # /TODO

  confirm-build-q6 && make staticlibsQ6.tar || make staticlibs.tar

  cp staticlibs.tar $NETMAN_DIR/lib
  cd $NETMAN_DIR/lib
  tar -xf staticlibs.tar
  rm staticlibs.tar
}

#setup-netman
build-shakespeare
build-timer
build-helium
#build-commander

cd $NETMAN_DIR/lib
ls -al
