#! /bin/. 
if [ -z "$BASH_VERSION" ]; then exec . .  "$0" "$@"; fi;
# systemreq_module.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Script details
#
#------------------------------------------------------------------------------
PROGRAM="systemreq_module.sh"
VERSION="0.0.1"
version () { echo "$PROGRAM version $VERSION"; }
usage="usage: systemreq_module.sh [options: (-v version), (-u usage) ]"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Arrays to easily add dependencies
#
#------------------------------------------------------------------------------
declare -a OperatingSystem=('apt-get')
declare -a SysReqs=('git' 'g++' 'gcc' 'dpkg' 'libpcap-dev' 'libssl-dev' 'build-essential' 'zip')
declare -a Tools=('tmux' 'screen' 'minicom' 'diffutils' )

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# enable non-interactive apt
#
#------------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Source global functions
#
#------------------------------------------------------------------------------
global_file=`find . -type f -name globals.sh`
source $global_file

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Distribution and version dependencies
#
#------------------------------------------------------------------------------
DISTRIBUTION="$(lsb_release -i -s)"
REQUIRED_DIST="Ubuntu"
DISTRIBUTION_RELEASE="$(lsb_release -s -r | tail -n +1)"
REQUIRED_RELEASE="14.04"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Function bodies
#
#------------------------------------------------------------------------------
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
        if ! dpkg-query -W $item
        then 
            echo >&2 "$item is not installed..."
            return_value=1
        fi
      }; 
    done
    return $return_value
}

ensure-system-requirements () {
    if check-installed SysReqs ; then
      echo -e "${green}System requirements met${NC}"
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

cs1-install-test-env () {
    if [ ! -d "gtest-1.7.0" ]; then
        wget -c "https://googletest.googlecode.com/files/gtest-1.7.0.zip" -O gtest-1.7.0.zip
        unzip gtest-1.7.0.zip && rm gtest-1.7.0.zip
    fi
    if [ ! -d "CppUTest" ]; then
        wget -c https://github.com/cpputest/cpputest.github.io/blob/master/releases/cpputest-3.5.zip?raw=true -O CppUTest.zip
        unzip CppUTest.zip
        mv cpputest-3.5 CppUTest
        cd CppUTest/
        pwd
        ./configure
        make
        make -f Makefile_CppUTestExt 
        cd $CS1_DIR
    fi
}

ensure-test-environment() {
    if [ ! -d "gtest-1.7.0" -o ! -d "CppUTest" ]; then
        confirm "Install Test Environment (GTest and CPPUTest)?" && cs1-install-test-env
    fi
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Execution
#
#------------------------------------------------------------------------------
echo "Executing systemreq_module, current directory is: $(pwd)"
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
ensure-correct-path
ensure-operating-system
ensure-system-requirements && ensure-test-environment
offer-space-tools
