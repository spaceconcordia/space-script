#!/bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;

NC='\e[0m';black='\e[0;30m';darkgrey='\e[1;30m';blue='\e[0;34m';lightblue='\e[1;34m';green='\e[0;32m';lightgreen='\e[1;32m';cyan='\e[0;36m';lightcyan='\e[1;36m';red='\e[0;31m';lightred='\e[1;31m';purple='\e[0;35m';lightpurple='\e[1;35m';orange='\e[0;33m';yellow='\e[1;33m';lightgrey='\e[0;37m';yellow='\e[1;37m';

#http://snipplr.com/view/63919/
#API="https://api.github.com"
#GITHUBLIST=`curl --silent -u $USER:$PASS ${API}/orgs/${ORG}/repos -q | grep name | awk -F': "' '{print $2}' | sed -e 's/",//g'`

project_name='https://github.com/spaceconcordia/'
declare -a SysReqs=('git' 'g++' 'gcc' 'dpkg')
declare -a Tools=('tmux' 'screen' 'minicom')
declare -a RepoList=('acs' 'baby-cron' 'ground-commander' 'HE100-lib' 'mail_arc' 'space-commander' 'space-lib' 'space-jobs' 'space-netman' 'space-script' 'space-tools' 'space-timer-lib' 'space-updater' 'space-updater-api' 'SRT' 'watch-puppy')
READ_DIR=$(readlink -f "$0")
CS1_DIR=$(dirname "$READ_DIR")
NETMAN_DIR="$CS1_DIR/space-netman"
SHAKESPEARE_DIR="$CS1_DIR/space-lib/shakespeare"
HELIUM_DIR="$CS1_DIR/HE100-lib/C"
TIMER_DIR="$CS1_DIR/space-timer-lib"
COMMANDER_DIR="$CS1_DIR/space-commander"
WATCHPUPPY_DIR="$CS1_DIR/watch-puppy"
BABYCRON_DIR="$CS1_DIR/baby-cron"
JOBRUNNER_DIR="$CS1_DIR/space-jobs/job-runner"
SPACESCRIPT_DIR="$CS1_DIR/space-script"

#EXIT ON ERROR
set -e

quit () {
  echo -e "${green}Exiting gracefully...${NC}"
  exit 1
}
fail () {
  echo -e "${red}$1 ...Aborting...${NC}"
  exit 1
}

self-update () {
  if [ -f "./space-script/MANAGE_CS1.sh" ]; then
    cd $SPACESCRIPT_DIR
    if ! git-check "."; then
      if confirm "An update for this script may be available. Proceed?"; then
        if check-master-branch ; then
          echo -e "${green}UPDATING ...${NC}"
          cs1-update $SPACESCRIPT_DIR && rsync -vz --update MANAGE_CS1.sh $CS1_DIR/MANAGE_CS1.sh
        fi
      fi
    fi
    cd $CS1_DIR
  fi
}

git-check () {
  echo "Checking repo"
  git --git-dir=$1/.git diff-index --quiet HEAD
  #return $(git --git-dir=$1/.git rev-list HEAD...origin/master --count)
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
    return $return_value
}

check-package () {
    command -v $1 >/dev/null 2>&1
}

check-master-branch () {
    [ $1 ] && gdirectory="--git-dir=$1/.git"
    branch_name="$(git ${gdirectory} symbolic-ref --short -q HEAD)"
    echo "Currently on branch: $branch_name"
    if [ "$branch_name" != "master" ]; then
        confirm "Repository $1 is on the '$branch_name' branch, are you sure you wish to continue?" && return 0 || return 1
    fi
    return 0
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
  echo "Microblaze install not supported yet... See admin for details"
  #cd $CS1_DIR/Microblaze && sh xsc-devkit-installer-lit.sh
}

cs1-install-test-env () {
    if [ ! -d "gtest-1.7.0" ]; then
        wget -c "https://googletest.googlecode.com/files/gtest-1.7.0.zip" -O gtest-1.7.0.zip
        unzip gtest-1.7.0.zip && rm gtest-1.7.0.zip
    fi
    if [ ! -d "cpputest" ]; then
        git clone git://github.com/cpputest/cpputest.git
        cd cpputest
        ./configure
        make
        make -f Makefile_CppUTestExt 
        #cp -r include/* $CS1_DIR/space-commander/include/
        #cp lib/libCppUTest.a $CS1_DIR/space-commander/lib/
        #cp lib/libCppUTestExt.a $CS1_DIR/space-commander/lib/
    fi
}

cs1-clone-all () {
    printf "git clone %s%s .\n" $project_name $1;
    git clone $project_name$item $1
}

cs1-update () {
    cd $1
    branch_name="$(git symbolic-ref --short -q HEAD)"
    echo -e "${green}Updating $1 on branch $branch_name ${NC}"
    echo "git pull origin $branch_name #$1"
    git pull origin $branch_name
    cd $CS1_DIR
}

cs1-build-commander () {
    #COMMANDER
    echo -e "${green}Building Commander...${NC}"
    cd $CS1_DIR/space-commander
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || make buildBin
    
    # provide deps for NETMAN
    confirm-build-q6 && make staticlibsQ6.tar || make staticlibs.tar
    cp staticlibs*.tar $NETMAN_DIR/lib/
    cd $NETMAN_DIR/lib
    tar -xf staticlibs.tar
    rm staticlibs.tar
}

cs1-build-netman () {
    echo -e "${green}Building Netman...${NC}"
    cd $CS1_DIR/space-netman
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include  
    cp $COMMANDER_DIR/include/Net2Com.h $NETMAN_DIR/lib/include
    cp $COMMANDER_DIR/include/NamedPipe.h $NETMAN_DIR/lib/include

    confirm-build-q6 && make Q6 || make
}

cs1-build-watch-puppy () {
    echo -e "${green}Building Watch-Puppy...${NC}"
    cd $CS1_DIR/watch-puppy
    mkdir -p ./bin ./lib/include
    cp $CS1_DIR/space-lib/shakespeare/inc/shakespeare.h $CS1_DIR/watch-puppy/inc/
    cp $CS1_DIR/space-lib/shakespeare/lib/libshakespeare* $CS1_DIR/watch-puppy/lib/
    check-master-branch || fail "Cannot build project without"
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-baby-cron () {
    echo -e "${green}Building Baby-Cron...${NC}"
    cd $CS1_DIR/baby-cron
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    cp $CS1_DIR/space-lib/shakespeare/inc/shakespeare.h $CS1_DIR/baby-cron/include/
    cp $CS1_DIR/space-lib/shakespeare/lib/libshakespeare* $CS1_DIR/baby-cron/lib/
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-helium () {
  echo -e "${green}Building HE-100 Library...${NC}"
  cd $HELIUM_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p $CS1_DIR/HE100-lib/C/lib
  echo "cd: \c" 
  pwd
  cp $COMMANDER_DIR/include/Net2Com.h $HELIUM_DIR/inc/
  cp $COMMANDER_DIR/include/NamedPipe.h $HELIUM_DIR/inc/  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
  cp lib/libhe100* $NETMAN_DIR/lib/
  cp inc/SC_he100.h $NETMAN_DIR/lib/include/
}

cs1-build-job-runner () {
    echo -e "${green}Building Job-Runner...${NC}"
    cd $CS1_DIR/space-jobs/job-runner
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./inc
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-shakespeare () {
  echo -e "${green}Building shakespeare...${NC}"
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

cs1-build-space-updater () {
    echo -e "${green}Building Space-Updater...${NC}"
    cd $CS1_DIR/space-updater
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || make buildPC
}

cs1-build-space-updater-api () {
    echo -e "${green}Building Space-Updater-API...${NC}"
    cd $CS1_DIR/space-updater-api
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || make buildPC
}

cs1-build-timer () {
  echo -e "${green}Building timer Library...${NC}"
  cd $TIMER_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p $CS1_DIR/space-timer-lib/lib
  echo "cd: \c"
  pwd
  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
  cp lib/libtimer* $NETMAN_DIR/lib
  cp lib/libtimer* $HELIUM_DIR/lib
  #cp lib/libtimer* $JOBRUNNER_DIR/lib
  cp inc/timer.h $NETMAN_DIR/lib/include
  cp inc/timer.h $HELIUM_DIR/inc
  #cp inc/timer.h $JOBRUNNER_DIR/inc
}

ensure-directories () {
  declare -a REQDIR_LIST=("$NETMAN_DIR/lib/include/" "$HELIUM_DIR/inc/" "$TIMER_DIR/inc/" "$BABYCRON_DIR/include/" "$JOBRUNNER_DIR/inc/" "$COMMANDER_DIR/include/" "$WATCHPUPPY_DIR/lib/include/" "$HELIUM_DIR/lib/" "$TIMER_DIR/lib/" "$COMMANDER_DIR/lib/" "$WATCHPUPPY_DIR/lib/" "$BABYCRON_DIR/lib/" "$BABYCRON_DIR/lib/" "$JOBRUNNER_DIR/lib/" "" "$NETMAN_DIR/lib/include" "$NETMAN_DIR/bin" )
  for item in ${REQDIR_LIST[*]}; do 
    mkdir -p $item
    #[ ! -d $item ] && fail "$item does not exist and/or was not created properly"
  done
}

cs1-build-pc () {
    build_environment="PC"
    echo -e "${green}Building for $build_environment...${NC}"
    ensure-directories

    #DEPENDENCIES
    #cd $CS1_DIR/space-script
    #printf "sh cs1-libs.sh\n"
    #sh cs1-get-libs.sh PC

    #libraries
    cs1-build-timer PC
    cs1-build-shakespeare PC
    cs1-build-helium PC

    cs1-build-commander PC
    cs1-build-netman PC
    #cs1-build-job-runner PC
    cs1-build-watch-puppy PC
    cs1-build-space-updater PC
    cs1-build-space-updater-api PC
    cs1-build-baby-cron PC

    #COLLECT FILES
    mkdir -p $CS1_DIR/BUILD/PC
    cp $CS1_DIR/space-commander/bin/space-commander $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-netman/bin/gnd $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-netman/bin/sat $CS1_DIR/BUILD/PC/
    #cp $CS1_DIR/space-jobs/job-runner/bin/job-runner $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/watch-puppy/bin/watch-puppy $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-updater-api/bin/UpdaterServer $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-updater/bin/PC-Updater $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/baby-cron/bin/baby-cron $CS1_DIR/BUILD/PC/

    cd $CS1_DIR
    echo 'Binaries left in $CS1_DIR/BUILD/PC'
}

cs1-build-q6 () {
    build_environment="Q6"
    echo -e "${green}Building for $build_environment...${NC}"
    ensure-directories

    #DEPENDENCIES
    #cd $CS1_DIR/space-script
    #printf "sh cs1-libs.sh\n"
    #sh cs1-get-libs.sh Q6

    #libraries
    cs1-build-timer Q6
    cs1-build-shakespeare Q6
    cs1-build-helium Q6

    cs1-build-commander Q6
    cs1-build-netman Q6
    #cs1-build-job-runner Q6
    cs1-build-watch-puppy Q6
    cs1-build-space-updater Q6
    cs1-build-space-updater-api Q6
    cs1-build-baby-cron Q6

    #COLLECT FILES
    mkdir -p $CS1_DIR/BUILD/Q6
    cp $CS1_DIR/space-commander/bin/space-commanderQ6 $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-netman/bin/gnd-mbcc $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-netman/bin/sat-mbcc $CS1_DIR/BUILD/Q6/sat
    #cp $CS1_DIR/space-jobs/job-runner/bin/job-runner-mbcc $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/watch-puppy/bin/watch-puppy $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-updater-api/bin/UpdaterServer-Q6 $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-updater/bin/Updater-Q6 $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/baby-cron/bin/baby-cron $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-script/Q6-rsync.sh $CS1_DIR/BUILD/Q6/

    cp $CS1_DIR/space-script/system-test.sh $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-script/at-runner/at-runner.sh $CS1_DIR/BUILD/Q6/
    
    cp $CS1_DIR/space-script/boot-drivers/ad799x.sh $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-script/boot-drivers/hmc5842.sh $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-script/boot-drivers/ina2xx.sh $CS1_DIR/BUILD/Q6/
    cp $CS1_DIR/space-script/boot-drivers/rtc-ds3232e.sh $CS1_DIR/BUILD/Q6/

    cd $CS1_DIR/BUILD/Q6/
    tar -cvf $(date --iso)-Q6.tar.gz Q6-rsync.sh sat-mbcc watch-puppy baby-cron space-commanderQ6 UpdaterServer-Q6 Updater-Q6
    cd $CS1_DIR
    echo 'Binaries left in $CS1_DIR/BUILD/Q6'
    echo -e "${purple}$(date --iso)-Q6.tar.gz left in $CS1_DIR/BUILD/Q6, transfer it to Q6, tar -xvf it, and run Q6-rsync.sh${NC}"
}

[ -d .git ] && fail "You are in a git directory, please copy this file to a new directory where you plan to build the project!"
ensure-system-requirements
offer-space-tools
self-update

echo "Repo size: ${#RepoList[*]}"
echo "Current Dir: $CS1_DIR"

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
            check-master-branch $item && cs1-update $item
        fi;
    fi;
done;

confirm "Build project for PC?" && buildPC=0;
check-microblaze || confirm "Install Microblaze environment?" && cs1-install-mbcc
#check-microblaze || echo "Microblaze is not installed, ask someone how to install it"
check-microblaze && confirm "Build project for Q6?" && buildQ6=0
if [ ! -d "gtest-1.7.0" -o ! -d "cpputest" ]; then
   confirm "Install Test Environment?" && cs1-install-test-env
fi

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
