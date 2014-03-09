#!/bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;

declare -a SysReqs=('g++' 'gcc' 'microblazeel-xilinx-linux-gnu-c++' 'microblazeel-xilinx-linux-gnu-cc')
for item in ${SysReqs[*]}; do command -v $item >/dev/null 2>&1 || { echo >&2 "I require $item but it's not installed.  Aborting."; exit 1; }; done

set -e # exit on errors or failed steps

cd ..
CS1=$(pwd)
NETMAN_DIR="$CS1/space-netman"
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
  cd $CS1/space-lib/shakespeare
  check-master-branch || exit 1
  mkdir -p $CS1/space-lib/shakespeare/lib
  echo "cd: \c"
  pwd
  cp inc/shakespeare.h $NETMAN_DIR/lib/include
  confirm-build-q6 && sh mbcc-compile-lib-static.sh || sh x86-compile-lib-static.sh
  cp lib/libshakespeare.a $NETMAN_DIR/lib
}

build-helium () {
  # Builds libhe100.a 
  echo 'Building HE-100 Library...'
  cd $CS1/HE100-lib/C
  check-master-branch || exit 1
  mkdir -p $CS1/HE100-lib/C/lib
  echo "cd: \c" 
  pwd
  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
  cp lib/libhe100* $NETMAN_DIR/lib
  cp inc/SC_he100.h $NETMAN_DIR/lib/include
  cd $NETMAN_DIR/lib 
  #mv libhe100* $NETMAN_DIR/lib # why this line
}

build-timer () {
  # Timer library
  echo 'Building timer Library...'
  cd $CS1/space-timer-lib 
  check-master-branch || exit 1
  mkdir -p $CS1/space-timer-lib/lib
  echo "cd: \c" 
  pwd
  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
  cp lib/libtimer* $NETMAN_DIR/lib
  cp inc/timer.h $NETMAN_DIR/lib/include
}

build-commander () {
  # namedpipe & commander
  echo 'Building Namedpipes and commander libs...'
  cd $CS1/space-commander
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

setup-netman
build-shakespeare
build-helium
build-timer
build-commander

cd $NETMAN_DIR/lib
ls -al
