#!/bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;
NC='\e[0m';black='\e[0;30m';darkgrey='\e[1;30m';blue='\e[0;34m';lightblue='\e[1;34m';green='\e[0;32m';lightgreen='\e[1;32m';cyan='\e[0;36m';lightcyan='\e[1;36m';red='\e[0;31m';lightred='\e[1;31m';purple='\e[0;35m';lightpurple='\e[1;35m';orange='\e[0;33m';yellow='\e[1;33m';lightgrey='\e[0;37m';yellow='\e[1;37m';

git_url='https://github.com/spaceconcordia/'
declare -a RepoList=('acs' 'baby-cron' 'ground-commander' 'HE100-lib' 'space-commander' 'space-lib' 'space-jobs' 'space-netman' 'space-script' 'space-tools' 'space-timer-lib' 'space-updater' 'space-updater-api' 'space-payload')

READ_DIR=$(readlink -f "$0")
CS1_DIR=$(dirname "$READ_DIR")
SPACESCRIPT_DIR="$CS1_DIR/space-script"

declare -a SourceLibraries=("$SPACESCRIPT_DIR/modules/environment_module.sh" "$SPACESCRIPT_DIR/modules/systemreq_module.sh"  "$SPACESCRIPT_DIR/modules/build_module.sh" "$SPACESCRIPT_DIR/modules/deploy_module.sh" )

build_environment="PC"      # GLOBAL VARIABLE

# TODO
# make clean on all
# fix apt

# enable non-interactive apt 
export DEBIAN_FRONTEND=noninteractive
# determine distribution and release

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Exit on error
#
#------------------------------------------------------------------------------
set -e

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Define functions
#
#------------------------------------------------------------------------------
quit () {
  echo -e "${green}$1 Exiting gracefully...${NC}"
  exit 0
}

fail () {
  echo -e "${red}$1 Aborting...${NC}"
  exit 1
}

check-projects () {
  projects_bool=0
  for item in ${RepoList[*]};
  do
    if [ ! -d "$item" ]; then
      echo "$item repository is missing..."
      projects_bool=1
    fi
  done;
  return $projects_bool
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

check-master-branch () {
    [ $1 ] && gdirectory="--git-dir=$1/.git" || gdirectory=""
    branch_name="$(git ${gdirectory} symbolic-ref -q HEAD | sed 's|refs\/heads\/||g')"
    echo "Currently on branch: $branch_name"
    if [ "$branch_name" != "master" ]; then
        confirm "Repository $1 is on the '$branch_name' branch, are you sure you wish to continue?" && return 0 || return 1
    fi
    return 0
}

cs1-clone-all () {
    echo -e "${green}Cloning $1${NC}"
    printf "git clone %s%s .\n" $git_url $1;
    git clone $git_url$item $1
}

cs1-update () {
    cd $1
    branch_name="$(git symbolic-ref -q HEAD | sed 's|refs\/heads\/||g')"
    echo -e "${green}Updating $1 on branch $branch_name ${NC}"
    echo "git pull origin $branch_name #$1"
    git pull origin $branch_name
    cd $CS1_DIR
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Parsing command line arguments
#
#------------------------------------------------------------------------------

# TODO tldp.org/LDP/abs/html/tabexpansion.html
[ -d .git ] && fail "You are in a git directory, please copy this file to a new directory where you plan to build the project!"

usage () {
    echo "./MANAGE_CS1.sh   [options]"
    echo "  -v               version"
    echo "  [-h or --help]   usage"
    echo "  -L               build and distribute libs only"
    echo "  -J               build jobs"
    echo "  --buildPC        build entire project with g++"
    echo "  --buildQ6        build entire project for MicroBlaze"
}

usage

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Parsing command line arguments
#
#------------------------------------------------------------------------------
argType=""
while getopts "cqg:n:uvm:s" opt; do
    case "$opt" in
        b) bash build_module.sh; quit;
        ;; 
        u) GROUP=$OPTARG
        ;;
        m) MULTIPLE_RUN=$OPTARG
        ;;
        n) SINGLE_TEST="-n $OPTARG" 
        ;;
        q) MBCC=1
        ;;
        s) SKIP_TEST=1 
        ;;
        u)
            usage
            exit 0;
        ;;
        v) TODEVNULL=0 ;;
    esac
done

echo "Repo size: ${#RepoList[*]}"
echo "Current Dir: $CS1_DIR"

check-changes () {
    for item in ${RepoList[*]}
        do
        if [ -d "$item" ]; then
            cd $item
            CHANGED=$(git diff-index --name-only HEAD --)
            if [ -n "$CHANGED" ]; then
                echo "---"
                echo -e "${red}$item has local changes...${NC}"
                git status
            fi;
            cd $CS1_DIR
        fi;
    done;
}

check-changes

echo "---"
check-projects || confirm "Clone missing projects?" && clone=0;
check-projects && confirm "Pull updates for cloned projects?" && update=0;

    for item in ${RepoList[*]}
    do
        if [ $clone ]; then
            if [ ! -d "$item" ]; then
                cs1-clone-all $item
            fi;
        fi;
        if [ $update ]; then
            if [ -d "$item" ]; then
                cs1-update $item
            fi;
        fi;
    done;
    cd $CS1_DIR

echo "running modules if present..."
# run the modules in order of the array
for item in ${SourceLibraries[*]}
do
    echo "Checking $item"
    if [ -e $item ]; then
        echo "Running $item"
        bash $item
    else
        fail "$item not found..."
    fi
done
