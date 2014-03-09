#!/bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;

#http://snipplr.com/view/63919/
#API="https://api.github.com"
#GITHUBLIST=`curl --silent -u $USER:$PASS ${API}/orgs/${ORG}/repos -q | grep name | awk -F': "' '{print $2}' | sed -e 's/",//g'`

project_name='https://github.com/spaceconcordia/'
declare -a SysReqs=('git' 'g++' 'gcc' 'dpkg')
declare -a Tools=('tmux' 'screen' 'minicom')
declare -a RepoList=('acs' 'baby-cron' 'ground-commander' 'HE100-lib' 'mail_arc' 'space-commander' 'space-lib' 'space-jobs' 'space-netman' 'space-script' 'space-tools' 'space-timer-lib' 'space-updater' 'space-updater-api' 'SRT')
READ_DIR=$(readlink -f "$0")
CURRENT_DIR=$(dirname "$READ_DIR")

#EXIT ON ERROR
set -e

quit () {
  echo "Exiting gracefully..."
  exit 1
}

install-packages () {
    list_name=$1[@]
    list_elements=("${!list_name}")
    confirm "Would you like to install this set of packages [${list_elements[*]}] ?" && $(for item in ${list_elements[*]}; do sudo apt-get -y install $item; done)
    return 0
}

check-installed () {
    list_name=$1[@]
    list_elements=("${!list_name}")
    return_value=0
    for item in ${list_elements[*]}; do check-package $item || {
      echo >&2 "$item is not installed..."
      return_value=1
    }; done
    return 0
}

check-package () {
    command -v $1 >/dev/null 2>&1
}

check-master-branch () {
    branch_name="$(git symbolic-ref --short -q HEAD)"
    echo "Currently on branch: $branch_name"
    if [ "$branch_name" != "master" ]; then 
        confirm "This repo is on the '$branch_name' branch, are you sure you wish to continue?" && return 0 || return 1
    fi
    return 0
}

check-projects () {
  projects_bool=0
  for item in ${RepoList[*]};
  do
    if [ ! -d "$item" ]; then
      projects_bool=1
    fi
  done;
  return $projects_bool
}

check-microblaze () { # should not be in SysReqs, allow PC building without
  check-package microblazeel-xilinx-linux-gnu-c++
}

ensure-system-requirements () {
    check-installed SysReqs || install-packages SysReqs || quit
}

offer-space-tools () {
    check-installed Tools || install-packages Tools
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

cs1-install-mbcc () {
   confirm "Install Microblaze environment?" && cd $CURRENT_DIR/Microblaze && sh xsc-devkit-installer-lit.sh
}

cs1-clone-all () {
    printf "git clone %s%s .\n" $project_name $1;
    git clone $project_name$item $1
}

cs1-update () {
    cd $1
    printf "git pull origin master #%s\n" $1;
    git pull origin master
    cd $CURRENT_DIR
}

cs1-build-commander () {
    #COMMANDER
    echo "Building Commander..."
    cd $CURRENT_DIR/space-commander
    check-master-branch || quit
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-netman () {
    echo "Building Netman..."
    cd $CURRENT_DIR/space-netman
    check-master-branch || quit
    confirm-build-q6 && make Q6 || make
}

cs1-build-watch-puppy () {
    echo "Building Watch-Puppy"
    cp $CURRENT_DIR/space-lib/shakespeare/inc/shakespeare.h $CURRENT_DIR/watch-puppy/lib/include
    cd $CURRENT_DIR/watch-puppy
    check-master-branch || quit
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-baby-cron () {
    echo "Building baby-cron"
    cd $CURRENT_DIR/baby-cron
    check-master-branch || quit
    cp $CURRENT_DIR/space-lib/shakespeare/inc/shakespeare.h $CURRENT_DIR/baby-cron/lib/include
    mkdir -p ./bin
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-space-updater () {
    echo "Building space-updater"
    cd $CURRENT_DIR/space-updater
    check-master-branch || quit
    mkdir -p ./bin
    confirm-build-q6 && make buildQ6 || make buildPC
}

cs1-build-space-updater-api () {
    echo "Building space-updater-api"
    cd $CURRENT_DIR/space-updater-api
    check-master-branch || quit
    mkdir -p ./bin
    confirm-build-q6 && make buildQ6 || make buildPC
}

cs1-build-pc () {
    build_environment="PC"

    #DEPENDENCIES
    cd $CURRENT_DIR/space-script
    printf "sh get-libs-PC.sh\n"
    sh cs1-get-libs.sh PC

    cs1-build-commander PC
    cs1-build-netman PC
    cs1-build-watch-puppy PC
    cs1-build-space-updater PC
    cs1-build-space-updater-api PC
    cs1-build-baby-cron PC

    #COLLECT FILES
    mkdir -p $CURRENT_DIR/BUILD/PC
    cp $CURRENT_DIR/space-commander/bin/space-commander $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/space-netman/bin/gnd $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/space-netman/bin/sat $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/watch-puppy/bin/watch-puppy $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/space-updater-api/bin/UpdaterServer $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/space-updater/bin/PC-Updater $CURRENT_DIR/BUILD/PC/
    cp $CURRENT_DIR/baby-cron/bin/baby-cron $CURRENT_DIR/BUILD/PC/

    cd $CURRENT_DIR
    echo 'Binaries left in $CURRENT_DIR/BUILD/PC'
}

cs1-build-q6 () {
    build_environment="Q6"

    #DEPENDENCIES
    cd $CURRENT_DIR/space-script
    printf "sh get-libs-Q6.sh\n"
    sh cs1-get-libs.sh Q6

    cs1-build-commander Q6
    cs1-build-netman Q6
    cs1-build-watch-puppy Q6
    cs1-build-space-updater Q6
    cs1-build-space-updater-api Q6
    cs1-build-baby-cron Q6

    #COLLECT FILES
    mkdir -p $CURRENT_DIR/BUILD/Q6
    cp $CURRENT_DIR/space-commander/bin/space-commanderQ6 $CURRENT_DIR/BUILD/Q6/
    cp $CURRENT_DIR/space-netman/bin/gnd-mbcc $CURRENT_DIR/BUILD/Q6/
    cp $CURRENT_DIR/space-netman/bin/sat-mbcc $CURRENT_DIR/BUILD/Q6/sat
    cp $CURRENT_DIR/watch-puppy/bin/watch-puppy $CURRENT_DIR/BUILD/Q6/
    cp $CURRENT_DIR/space-updater-api/bin/UpdaterServer-Q6 $CURRENT_DIR/BUILD/Q6/
    cp $CURRENT_DIR/space-updater/bin/Updater-Q6 $CURRENT_DIR/BUILD/Q6/
    cp $CURRENT_DIR/baby-cron/bin/baby-cron $CURRENT_DIR/BUILD/Q6/
    cp $CURRENT_DIR/space-script/Q6-rsync.sh $CURRENT_DIR/BUILD/Q6/
    cd $CURRENT_DIR/BUILD/Q6/
    tar -cvf $(date --iso)-Q6.tar.gz Q6-rsync.sh sat-mbcc watch-puppy baby-cron space-commanderQ6 UpdaterServer-Q6 Updater-Q6
    cd $CURRENT_DIR
    echo 'Binaries left in $CURRENT_DIR/BUILD/Q6'
    echo "$(date --iso)-Q6.tar.gz left in $CURRENT_DIR/BUILD/Q6, transfer it to Q6, tar -xvf it, and run Q6-rsync.sh"
}
[ -d .git ] && echo "You are in a git directory, please copy this file to a new directory where you plan to build the project!" && quit
ensure-system-requirements
offer-space-tools

echo "Repo size: ${#RepoList[*]}"
echo "Current Dir: $CURRENT_DIR"

for item in ${RepoList[*]}
    do
    if [ -d "$item" ]; then
        cd $item
        CHANGED=$(git diff-index --name-only HEAD --)
        if [ -n "$CHANGED" ]; then
            echo "---"
            printf "%s has local changes\n" $item
            git status
        fi;
        cd $CURRENT_DIR
    fi;
done;

echo "---"
check-projects || confirm "Clone missing projects?" && clone=0;
confirm "Pull updates for cloned projects?" && update=0;
  # TODO only offer updates if updates are available
  # http://stackoverflow.com/questions/3258243/git-check-if-pull-needed

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

check-microblaze || cs1-install-mbcc
confirm "Build project for PC?" && buildPC=0;
check-microblaze && confirm "Build project for Q6?" && buildQ6=0;

if [ $buildPC ]; then
    if [ -d "space-script" ]; then
        cs1-build-pc
    fi;
fi;
# space script directory is required for other scripts
if [ $buildQ6 ]; then
    if [ -d "space-script" ]; then
        cs1-build-q6
    fi;
fi;
