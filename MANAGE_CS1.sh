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
SPACE_LIB="$CS1_DIR/space-lib"
SPACE_INCLUDE="$SPACE_LIB/include"
SHAKESPEARE_DIR="$SPACE_LIB/shakespeare"
HELIUM_DIR="$CS1_DIR/HE100-lib/C"
CHECKSUM_DIR="$CS1_DIR/space-lib/checksum"
TIMER_DIR="$CS1_DIR/space-timer-lib"
COMMANDER_DIR="$CS1_DIR/space-commander"
WATCHPUPPY_DIR="$CS1_DIR/watch-puppy"
BABYCRON_DIR="$CS1_DIR/baby-cron"
JOBRUNNER_DIR="$CS1_DIR/space-jobs/job-runner"
JOBS_DIR="$CS1_DIR/space-jobs"
SPACESCRIPT_DIR="$CS1_DIR/space-script"
UPLOAD_FOLDER="$CS1_DIR/BUILD/Q6/uploads"

build_environment="PC"      # GLOBAL VARIABLE

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
        if check-master-branch . ; then
          echo -e "${green}UPDATING ...${NC}"
          cs1-update $SPACESCRIPT_DIR && rsync -avz --update $SPACESCRIPT_DIR/MANAGE_CS1.sh $CS1_DIR/MANAGE_CS1.sh
        fi
      fi
    fi
    cd $CS1_DIR
  fi
}

git-check () {
  [ "$#" -eq 1 ] || fail "Exactly one argument required: path"
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
    [ $1 ] && gdirectory="--git-dir=$1/.git" || gdirectory=""
    branch_name="$(git ${gdirectory} symbolic-ref -q HEAD | sed 's|refs\/heads\/||g')"
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
  offer-space-tools
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
    echo -e "${green}Cloning $1${NC}"
    printf "git clone %s%s .\n" $project_name $1;
    git clone $project_name$item $1
}

cs1-update () {
    cd $1
    branch_name="$(git symbolic-ref -q HEAD | sed 's|refs\/heads\/||g')"
    echo -e "${green}Updating $1 on branch $branch_name ${NC}"
    echo "git pull origin $branch_name #$1"
    git pull origin $branch_name
    cd $CS1_DIR
}

cs1-build-commander () {
    #COMMANDER
    echo -e "${green}Building Commander...${NC}"
    cd $COMMANDER_DIR
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || make buildBin
    #cp $COMMANDER_DIR/include/Net2Com.h $SPACE_INCLUDE/
    #cp $COMMANDER_DIR/include/NamedPipe.h $SPACE_INCLUDE/

    # provide deps for NETMAN
    confirm-build-q6 && make staticlibsQ6.tar || make staticlibs.tar
    cp staticlibs*.tar $NETMAN_DIR/lib/
    cd $NETMAN_DIR/lib
    [ -f staticlibs.tar ] && tar -xf staticlibs.tar
    [ -f staticlibsQ6.tar ] && tar -xf staticlibsQ6.tar
    rm staticlibs*.tar

    # TODO     
    #cp staticlibs*.tar $SPACE_LIB/
    #cd $SPACE_LIB/
    #[ -f staticlibs.tar ] && tar -xf staticlibs.tar
    #[ -f staticlibsQ6.tar ] && tar -xf staticlibsQ6.tar
    #rm staticlibs*.tar
}

cs1-build-netman () {
    echo -e "${green}Building Netman...${NC}"
    cd $NETMAN_DIR
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    cp $COMMANDER_DIR/include/Net2Com.h $NETMAN_DIR/lib/include
    cp $COMMANDER_DIR/include/NamedPipe.h $NETMAN_DIR/lib/include

    confirm-build-q6 && make Q6 || make
}

cs1-build-watch-puppy () {
    echo -e "${green}Building Watch-Puppy...${NC}"
    cd $WATCHPUPPY_DIR
    mkdir -p ./bin ./lib/include
    cp $CS1_DIR/space-lib/shakespeare/inc/shakespeare.h $CS1_DIR/watch-puppy/inc/
    cp $CS1_DIR/space-lib/shakespeare/lib/libshakespeare* $CS1_DIR/watch-puppy/lib/
    check-master-branch || fail "Cannot build project without"
    confirm-build-q6 && make buildQ6 || make buildBin
}

cs1-build-baby-cron () {
    echo -e "${green}Building Baby-Cron...${NC}"
    cd $BABYCRON_DIR
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
  # cp $HELIUM_DIR/inc/SC_he100.h $SPACE_INCLUDE/ # let's only copy here
  cp $COMMANDER_DIR/include/Net2Com.h $HELIUM_DIR/inc/ # depcrecated
  cp $COMMANDER_DIR/include/NamedPipe.h $HELIUM_DIR/inc/ # deprecated

  confirm-build-q6 && sh mbcc-compile-lib-static-cpp.sh || sh x86-compile-lib-static-cpp.sh
  
  cp $HELIUM_DIR/inc/SC_he100.h $SPACE_LIB/ # let's only copy here
  cp $HELIUM_DIR/lib/libhe100* $NETMAN_DIR/lib/ # deprecated
  cp $HELIUM_DIR/inc/SC_he100.h $NETMAN_DIR/lib/include/ # deprecated
}

cs1-build-fletcher () {
  echo -e "${green}Building Fletcher Checksum Library...${NC}"
  cd $CHECKSUM_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p $CHECKSUM_DIR/lib
  confirm-build-q6 && sh mbcc-compile-lib-static.sh || sh x86-compile-lib-static.sh
  #cp $CHECKSUM_DIR/lib/libfletcher* $SPACE_LIB/lib/;
  cp $CHECKSUM_DIR/lib/libfletcher* $NETMAN_DIR/lib/;
  cp $CHECKSUM_DIR/lib/libfletcher* $HELIUM_DIR/lib/;
  cp $CHECKSUM_DIR/lib/libfletcher* $COMMANDER_DIR/lib/;
  
  #cp $CHECKSUM_DIR/inc/fletcher.h $SPACE_LIB/lib/include/;
  cp $CHECKSUM_DIR/inc/fletcher.h $NETMAN_DIR/lib/include/;
  cp $CHECKSUM_DIR/inc/fletcher.h $HELIUM_DIR/inc/;
  cp $CHECKSUM_DIR/inc/fletcher.h $COMMANDER_DIR/include/;
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
      #cp $SHAKESPEARE_DIR/inc/shakespeare.h include/
      #cp $SHAKESPEARE_DIR/lib/libshakespeare* lib/
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
  cp inc/shakespeare.h $NETMAN_DIR/lib/include/
  cp inc/shakespeare.h $HELIUM_DIR/inc/
  cp inc/shakespeare.h $TIMER_DIR/inc/
  cp inc/shakespeare.h $COMMANDER_DIR/include/
  cp inc/shakespeare.h $WATCHPUPPY_DIR/inc/
  cp inc/shakespeare.h $BABYCRON_DIR/include/
  cp inc/shakespeare.h $JOBRUNNER_DIR/inc/
  cp inc/shakespeare.h $JOBS_DIR/read-pwr-ad7998/inc/

  confirm-build-q6 && sh mbcc-compile-lib-static.sh || sh x86-compile-lib-static.sh

  cp lib/libshakespeare* $NETMAN_DIR/lib/
  cp lib/libshakespeare* $HELIUM_DIR/lib/
  cp lib/libshakespeare* $TIMER_DIR/lib/
  cp lib/libshakespeare* $COMMANDER_DIR/lib/
  cp lib/libshakespeare* $WATCHPUPPY_DIR/lib/
  cp lib/libshakespeare* $BABYCRON_DIR/lib/
  cp lib/libshakespeare* $JOBRUNNER_DIR/lib/
  cp lib/libshakespeare* $JOBS_DIR/read-pwr-ad7998/lib/
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
  cp lib/libtimer* $NETMAN_DIR/lib
  cp lib/libtimer* $HELIUM_DIR/lib
  cp lib/libtimer* $JOBRUNNER_DIR/lib
  #cp lib/libtimer* $JOBRUNNER_DIR/lib
  cp inc/timer.h $NETMAN_DIR/lib/include
  cp inc/timer.h $HELIUM_DIR/inc
  cp inc/timer.h $JOBRUNNER_DIR/inc
  #cp inc/timer.h $JOBRUNNER_DIR/inc
}

ensure-directories () {
  declare -a REQDIR_LIST=("$NETMAN_DIR/lib/include/" "$HELIUM_DIR/inc/" "$TIMER_DIR/inc/" "$BABYCRON_DIR/include/" "$JOBRUNNER_DIR/inc/" "$COMMANDER_DIR/include/" "$WATCHPUPPY_DIR/lib/include/" "$HELIUM_DIR/lib/" "$TIMER_DIR/lib/" "$COMMANDER_DIR/lib/" "$WATCHPUPPY_DIR/lib/" "$WATCHPUPPY_DIR/inc/" "$BABYCRON_DIR/lib/" "$BABYCRON_DIR/lib/" "$JOBRUNNER_DIR/lib/" "$NETMAN_DIR/lib/include" "$NETMAN_DIR/bin" "$UPLOAD_FOLDER/jobs")
  for item in ${REQDIR_LIST[*]}; do
    mkdir -p $item
    #[ ! -d $item ] && fail "$item does not exist and/or was not created properly"
  done
}

cs1-build () {
    [ "$#" -eq 0 ] && fail "No build environment specified..." 
    build_environment="$1"
    echo -e "${orange}Building for $build_environment...${NC}"
    ensure-directories

    #libraries
    cs1-build-timer $build_environment
    cs1-build-shakespeare $build_environment
    cs1-build-fletcher $build_environment
    cs1-build-helium $build_environment

    #executables
    cs1-build-commander $build_environment
    cs1-build-netman $build_environment
    cs1-build-job-runner $build_environment
    cs1-build-jobs $build_environment
    cs1-build-watch-puppy $build_environment
    cs1-build-space-updater $build_environment
    cs1-build-space-updater-api $build_environment
    cs1-build-baby-cron $build_environment

    #COLLECT FILES
    echo -e "${purple}Should Collect files for $build_environment ${NC}"
    if confirm-build-q6; then  
      ls $CS1_DIR/BUILD/Q6
      cp $COMMANDER_DIR/bin/space-commanderQ6 $UPLOAD_FOLDER/
      cp $NETMAN_DIR/bin/gnd-mbcc $UPLOAD_FOLDER/../
      cp $NETMAN_DIR/bin/sat-mbcc $UPLOAD_FOLDER/sat
      cp $CS1_DIR/space-jobs/job-runner/bin/job-runner-mbcc $UPLOAD_FOLDER/
      cp $WATCHPUPPY_DIR/bin/watch-puppy $UPLOAD_FOLDER/
      cp $CS1_DIR/space-updater-api/bin/UpdaterServer-Q6 $UPLOAD_FOLDER/
      cp $CS1_DIR/space-updater/bin/Updater-Q6 $UPLOAD_FOLDER/
      cp $BABYCRON_DIR/bin/baby-cron $UPLOAD_FOLDER/

      cp $SPACESCRIPT_DIR/tgz-wizard/tgzWizard $UPLOAD_FOLDER/
      cp $SPACESCRIPT_DIR/tgz-wizard/cs1_log_rotation.sh $UPLOAD_FOLDER/
      cp $SPACE_LIB/include/SpaceDecl.sh $UPLOAD_FOLDER/

      cp $SPACESCRIPT_DIR/Q6/* $UPLOAD_FOLDER/
      cp $SPACESCRIPT_DIR/at-runner/at-runner.sh $UPLOAD_FOLDER/

      cp $SPACESCRIPT_DIR/boot-drivers/*.sh $UPLOAD_FOLDER/
      
      chmod +x $UPLOAD_FOLDER/*
      cd $UPLOAD_FOLDER
      tar -cvf $(date --iso)-Q6.tar.gz * 
      mv $(date --iso)-Q6.tar.gz ../
      ls
      cd $CS1_DIR
      echo 'Binaries left in $CS1_DIR/BUILD/Q6'
      echo -e "${purple}$(date --iso)-Q6.tar.gz left in $CS1_DIR/BUILD/Q6, transfer it to Q6, tar -xvf it, and run Q6-rsync.sh${NC}"
    else
      mkdir -p $CS1_DIR/BUILD/PC
      cp $COMMANDER_DIR/bin/space-commander $CS1_DIR/BUILD/PC/
      cp $NETMAN_DIR/bin/gnd $CS1_DIR/BUILD/PC/
      cp $NETMAN_DIR/bin/sat $CS1_DIR/BUILD/PC/
      #cp $CS1_DIR/space-jobs/job-runner/bin/job-runner $CS1_DIR/BUILD/PC/
      cp $WATCHPUPPY_DIR/bin/watch-puppy $CS1_DIR/BUILD/PC/
      cp $CS1_DIR/space-updater-api/bin/UpdaterServer $CS1_DIR/BUILD/PC/
      cp $CS1_DIR/space-updater/bin/PC-Updater $CS1_DIR/BUILD/PC/
      cp $BABYCRON_DIR/bin/baby-cron $CS1_DIR/BUILD/PC/    
      cd $CS1_DIR
      echo -e "${purple}Binaries left in $CS1_DIR/BUILD/PC${NC}"
    fi
}

[ -d .git ] && fail "You are in a git directory, please copy this file to a new directory where you plan to build the project!"
ensure-system-requirements
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
cd $CS1_DIR
confirm "Build project for PC?" && buildPC=0;
check-microblaze || confirm "Install Microblaze environment?" && cs1-install-mbcc
check-microblaze && confirm "Build project for Q6?" && buildQ6=0

if [ $buildPC ]; then
    if [ -d "space-script" ]; then
        cs1-build PC
    fi;
fi;
# space script directory is required for other scripts
if [ $buildQ6 ]; then
    if [ -d "space-script" ]; then
        cs1-build Q6
    fi;
fi;

if [ ! -d "gtest-1.7.0" -o ! -d "cpputest" ]; then
   confirm "Install Test Environment?" && cs1-install-test-env
fi
