#! /bin/bash 
if [ -z "$BASH_VERSION" ]; then exec bash bash  "$0" "$@"; fi;
# build_functions.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.

PROGRAM="build_functions.sh"
VERSION="0.0.1"
version () { echo "$PROGRAM version $VERSION"; }
usage="usage: build_functions.sh [options: (-v version), (-u usage) ]"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Exit on error
#
#------------------------------------------------------------------------------
set -e


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Function Bodies
#
#------------------------------------------------------------------------------
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

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Source global functions
#
#------------------------------------------------------------------------------
globals=`find . -type f -name globals.sh`
source $globals || echo "Failed to source $globals"

check-master-branch () {
    [ $1 ] && gdirectory="--git-dir=$1/.git" || gdirectory=""
    branch_name="$(git ${gdirectory} symbolic-ref -q HEAD | sed 's|refs\/heads\/||g')"
    echo "Currently on branch: $branch_name"
    if [ "$branch_name" != "master" ]; then
        confirm "Repository $1 is on the '$branch_name' branch, are you sure you wish to continue?" && return 0 || return 1
    fi
    return 0
}

cs1-build-commander () {
    #COMMANDER
    echo -e "${green}Building Commander $build_environment ...${NC}"
    cd $COMMANDER_DIR
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || bash csmake.sh -c
    confirm-build-q6 && make staticlibsQ6.tar || make staticlibs.tar
}

cs1-build-netman () {
    echo -e "${green}Building Netman...${NC}"
    cd $NETMAN_DIR
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && bash csmake.sh -q || bash csmake.sh
}

cs1-build-baby-cron () {
    echo -e "${green}Building Baby-Cron...${NC}"
    cd $BABYCRON_DIR
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-helium () {
  echo -e "${green}Building HE-100 Library...${NC}"
  cd $HELIUM_DIR
  check-master-branch || fail "Cannot build project without"
  echo "cd: \c"
  pwd

  confirm-build-q6 && bash csmake.sh -q || bash csmake.sh 
}

cs1-build-fletcher () {
  echo -e "${green}Building Fletcher Checksum Library...${NC}"
  cd $CHECKSUM_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p $CHECKSUM_DIR/lib
  confirm-build-q6 && sh mbcc-compile-lib-static.sh || sh x86-compile-lib-static.sh
}

cs1-build-job-runner () {
  echo -e "${green}Building Job-Runner...${NC}"
  cd $JOBRUNNER_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p ./bin ./lib ./inc
  confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-jobs () {
  echo -e "${green}Building Jobs...${NC}"
  declare -a JOBS_LIST=('read-pwr-ad7998' 'read-pwr-ina219' 'MagReading' 'disable-AHRM' 'enable-AHRM' 'SolarPanelTemperature_Sensor')
  cd $JOBS_DIR
  check-master-branch || fail "Cannot build project without"
  for item in ${JOBS_LIST[*]}; do
    cd $item 
    mkdir -p ./bin ./lib ./inc ./include
    confirm-build-q6 && make buildQ6 || make buildBin
    cp bin/* $UPLOAD_FOLDER/jobs/
    cd $JOBS_DIR
  done
}

cs1-build-shakespeare () {
  echo -e "${green}Building shakespeare...${NC}"
  cd $SHAKESPEARE_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p $SHAKESPEARE_DIR/lib
  echo "cd: \c"
  pwd
  confirm-build-q6 && bash csmake.sh Q6 || bash  csmake.sh test
}

cs1-build-space-updater () {
    echo -e "${green}Building Space-Updater...${NC}"
    cd $CS1_DIR/space-updater
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-space-updater-api () {
    echo -e "${green}Building Space-Updater-API...${NC}"
    cd $CS1_DIR/space-updater-api
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-timer () {
  echo -e "${green}Building timer Library...${NC}"
  cd $TIMER_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p $CS1_DIR/space-timer-lib/lib
  echo "cd: \c"
  pwd
  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
}

cs1-build-utls () {
  echo -e "${green}Building cs1_utls Library...${NC}"
  cd $SPACE_LIB/utls
  confirm-build-q6 && bash csmake.sh -q || bash csmake.sh 
}

cs1-install-mbcc () {
  echo "Microblaze install not supported yet... See admin for details"
  #cd $CS1_DIR/Microblaze && sh xsc-devkit-installer-lit.sh
}

cs1-build-libs() {
    #libraries
    cs1-build-utls $1
    cs1-build-timer $1
    cs1-build-shakespeare $1
    cs1-build-fletcher $1
    cs1-build-helium $1
}

cs1-build () {
    [ "$#" -eq 0 ] && fail "No build environment specified..." 
    build_environment="$1"
    echo -e "${orange}Building for $build_environment...${NC}"
    cs1-build-libs $build_environment

    #executables
    cs1-build-commander $build_environment
    cs1-build-netman $build_environment
    cs1-build-job-runner $build_environment
    # TODO renable when jobs are fixed # cs1-build-jobs $build_environment
    cs1-build-space-updater $build_environment
    cs1-build-space-updater-api $build_environment
    cs1-build-baby-cron $build_environment
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Execution
#
#------------------------------------------------------------------------------
confirm "Build project for PC?" && buildPC=0;
check-microblaze || confirm "Install Microblaze environment?" && cs1-install-mbcc
check-microblaze && confirm "Build project for Q6?" && buildQ6=0

if [ $buildPC ]; then
    if [ -d "space-script" ]; then
        cs1-build PC
    fi
fi
if [ $buildQ6 ]; then
    if [ -d "space-script" ]; then
        cs1-build Q6
    fi
fi
