#! /bin/. 
if [ -z "$BASH_VERSION" ]; then exec . .  "$0" "$@"; fi;
# systemreq_module.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.
# Credit to https://stackoverflow.com/a/3232082 for confirm function
NC='\e[0m';black='\e[0;30m';darkgrey='\e[1;30m';blue='\e[0;34m';lightblue='\e[1;34m';green='\e[0;32m';lightgreen='\e[1;32m';cyan='\e[0;36m';lightcyan='\e[1;36m';red='\e[0;31m';lightred='\e[1;31m';purple='\e[0;35m';lightpurple='\e[1;35m';orange='\e[0;33m';yellow='\e[1;33m';lightgrey='\e[0;37m';yellow='\e[1;37m'; # colors: echo -e "${red}Text${NC}"

declare -a OperatingSystem=('apt-get')
declare -a SysReqs=('git' 'g++' 'gcc' 'dpkg' 'libpcap-dev' 'libssl-dev' 'build-essential')
declare -a Tools=('tmux' 'screen' 'minicom' 'diffutils' )

PROGRAM="systemreq_module.sh"
VERSION="0.0.1"
version () { echo "$PROGRAM version $VERSION"; }
usage="usage: systemreq_module.sh [options: (-v version), (-u usage) ]"

argType=""
for arg in "$@"; do
    case $argType in
        -v)
            version
        ;;
        -u)
            usage 
        ;;
    esac
done

global_file=`find . -type f -name globals.sh`
source $global_file

ensure-operating-system () {
    if [ "$DISTRIBUTION" == "$REQUIRED_DIST" -a "$DISTRIBUTION_RELEASE" == "$REQUIRED_RELEASE" ] ; then 
        echo -e "${green}Correct distribution and OS ($DISTRIBUTION $DISTRIBUTION_RELEASE)${NC}"
    else
        echo -e "${red}Warning, WrongOS! Need $REQUIRED_DIST $REQUIRED_RELEASE, you have $DISTRIBUTION $DISTRIBUTION_RELEASE${NC}"
    fi
    check-installed OperatingSystem || fail "This script depends on apt-get, and thus requires a Debian-based system. With some modification you can get this to run on other systems and with their package managers. Have fun."
}

check-installed () {
    list_name=$1[@]
    list_elements=("${!list_name}")
    return_value=0
    for item in ${list_elements[*]}; do 
      check-package $item || {
        echo >&2 "$item is not installed..."
        return_value=1
      }; 
    done
    return $return_value
}

ensure-system-requirements () {
    if check-installed SysReqs ; then
      echo "System requirements met"
    else 
      echo "Attempting to install system requirements"
      sudo apt-get install git build-essential 
      install-packages SysReqs || fail
    fi
}

install-packages () {
    list_name=$1[@]
    list_elements=("${!list_name}")
    if confirm "Would you like to install this set of packages [${list_elements[*]}] ?";
    then 
        echo "sudo apt-get -y install ${list_elements[*]}"
        sudo apt-get -y install ${list_elements[*]}
    fi
}

offer-space-tools () {
    echo "Some tools are recommended for working on the Q6. Checking if installed..."
    if check-installed Tools ; then
      echo "Suggested tools already present"
    else 
      echo "Attempting to install system requirements"
      sudo apt-get install screen minicom
    fi
}

ensure-test-environment() {
    if [ ! -d "gtest-1.7.0" -o ! -d "CppUTest" ]; then
        confirm "Install Test Environment (GTest and CPPUTest)?" && cs1-install-test-env
    fi
}

ensure-operating-system
ensure-system-requirements
ensure-test-environment
