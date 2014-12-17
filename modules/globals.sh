#! /bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;
# globals.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.
NC='\e[0m';black='\e[0;30m';darkgrey='\e[1;30m';blue='\e[0;34m';lightblue='\e[1;34m';green='\e[0;32m';lightgreen='\e[1;32m';cyan='\e[0;36m';lightcyan='\e[1;36m';red='\e[0;31m';lightred='\e[1;31m';purple='\e[0;35m';lightpurple='\e[1;35m';orange='\e[0;33m';yellow='\e[1;33m';lightgrey='\e[0;37m';yellow='\e[1;37m'; # colors: echo -e "${red}Text${NC}"

set -e

ensure-correct-path () {
  if [ "$(basename $(pwd))" = "modules" ] ; 
  then 
      echo "Changing to project root"
      cd ../../
  fi
}
ensure-correct-path

READ_DIR=$(pwd)
CS1_DIR=$(dirname "$READ_DIR/..")
NETMAN_DIR="$CS1_DIR/space-netman"
SPACE_LIB="$CS1_DIR/space-lib"
SPACE_INCLUDE="$SPACE_LIB/include"
SHAKESPEARE_DIR="$SPACE_LIB/shakespeare"
HELIUM_DIR="$CS1_DIR/HE100-lib/C"
CHECKSUM_DIR="$CS1_DIR/space-lib/checksum"
TIMER_DIR="$CS1_DIR/space-timer-lib"
COMMANDER_DIR="$CS1_DIR/space-commander"
BABYCRON_DIR="$CS1_DIR/baby-cron"
JOBRUNNER_DIR="$CS1_DIR/space-jobs/job-runner"
JOBS_DIR="$CS1_DIR/space-jobs"
SPACESCRIPT_DIR="$CS1_DIR/space-script"
UPLOAD_FOLDER="$CS1_DIR/BUILD/Q6/uploads"

quit () {
  echo -e "${green}$1 Exiting gracefully...${NC}"
  exit 0
}

fail () {
  echo -e "${red}$1 Aborting...${NC}"
  exit 1
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

su_symlink () {
    if [ $# -ne 2 ] ; then
        return 1
    fi
    source_file=$1
    dest_symlink=$2
    if [ -f $source_file ]; then
        if [ -f $dest_symlink ]; then
            if [ ! -h $dest_symlink ]; then
                echo "sudo ln -s $source_file $dest_symlink"
                sudo ln -s $source_file $dest_symlink
            else
                echo "$dest_symlink is already linked"
                ls -alF $dest_symlink
            fi
        else 
            echo "sudo ln -s $source_file $dest_symlink"
            sudo ln -s $source_file $dest_symlink
        fi
    else 
        echo "Invalid source file provided: $source_file"
    fi
}

symlink () {
    if [ $# -ne 2 ] ; then
        return 1
    fi
    source_file=$1
    dest_symlink=$2
    if [ -f $source_file ]; then
        if [ -f $dest_symlink ]; then
            echo "$dest_symlink already exists"
            if [ ! -h $dest_symlink ]; then
                echo "sudo ln -s $source_file $dest_symlink"
                ln -s $source_file $dest_symlink
            else
                echo "$dest_symlink is already linked"
                ll $dest_symlink
            fi
        else 
            echo "sudo ln -s $source_file $dest_symlink"
            ln -s $source_file $dest_symlink
        fi
    else 
        echo "Invalid source file provided: $source_file"
    fi
}

cs1_mkfifo () {
    dest_pipe=$1 
    if [ ! -p $dest_pipe ]; then
        echo "mkfifo $dest_pipe"
        mkfifo $dest_pipe
    fi
}

#TODO these doesn't belong here
check-package () {
    command -v $1 >/dev/null 2>&1
}
check-microblaze () { # should not be in SysReqs, allow PC building without
    check-package microblazeel-xilinx-linux-gnu-c++
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
