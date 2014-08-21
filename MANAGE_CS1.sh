#!/bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;
NC='\e[0m';black='\e[0;30m';darkgrey='\e[1;30m';blue='\e[0;34m';lightblue='\e[1;34m';green='\e[0;32m';lightgreen='\e[1;32m';cyan='\e[0;36m';lightcyan='\e[1;36m';red='\e[0;31m';lightred='\e[1;31m';purple='\e[0;35m';lightpurple='\e[1;35m';orange='\e[0;33m';yellow='\e[1;33m';lightgrey='\e[0;37m';yellow='\e[1;37m';

git_url='https://github.com/spaceconcordia/'
declare -a SysReqs=('git' 'g++' 'gcc' 'dpkg' 'libpcap-dev' 'libssl-dev')
declare -a Tools=('tmux' 'screen' 'minicom' 'diffutils' )
declare -a RepoList=('acs' 'baby-cron' 'ground-commander' 'HE100-lib' 'mail_arc' 'space-commander' 'space-lib' 'space-jobs' 'space-netman' 'space-script' 'space-tools' 'space-timer-lib' 'space-updater' 'space-updater-api' 'SRT' 'space-payload')
declare -a OperatingSystem=('apt-get')

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
BABYCRON_DIR="$CS1_DIR/baby-cron"
JOBRUNNER_DIR="$CS1_DIR/space-jobs/job-runner"
JOBS_DIR="$CS1_DIR/space-jobs"
SPACESCRIPT_DIR="$CS1_DIR/space-script"
UPLOAD_FOLDER="$CS1_DIR/BUILD/Q6/uploads"

build_environment="PC"      # GLOBAL VARIABLE

# TODO
# make clean on all
# fix apt

# enable non-interactive apt 
export DEBIAN_FRONTEND=noninteractive
# determine distribution and release
DISTRIBUTION="$(lsb_release -i -s)"
REQUIRED_DIST="Ubuntu"
DISTRIBUTION_RELEASE="$(lsb_release -s -r | tail -n +1)"
REQUIRED_RELEASE="14.04"

#EXIT ON ERROR
set -e

quit () {
  echo -e "${green}$1 Exiting gracefully...${NC}"
  exit 1
}

fail () {
  echo -e "${red}$1 Aborting...${NC}"
  exit 1
}

self-update () {
  SCRIPT_NAME="MANAGE_CS1.sh"
  LOCAL_COPY="$CS1_DIR/$SCRIPT_NAME"
  REPO_COPY="$SPACESCRIPT_DIR/$SCRIPT_NAME"
  if [ -f "$REPO_COPY" ]; then
    cd $CS1_DIR
    if diff $LOCAL_COPY $REPO_COPY >> /dev/null ; then 
        echo -e "${green}This script ($LOCAL_COPY) is up-to-date with the repo version ($REPO_COPY)${NC}"
    else 
        LOCAL_MOD=$(stat -c %Z "$LOCAL_COPY")
        REPO_MOD=$(stat -c %Z "$REPO_COPY")
        if [ "$LOCAL_MOD" -gt "$REPO_MOD" ] ; then 
            echo -e "${yellow}Your local copy of this build script ($LOCAL_COPY) has changes that are not being tracked by git!${NC}"
            confirm "View changes?" && diff $LOCAL_COPY $REPO_COPY 
            if confirm "Overwrite repository version with your local file?" ; then
                if git --git-dir=$SPACESCRIPT_DIR/.git status | grep "MANAGE_CS1.sh" >> /dev/null ; then
                    fail "$REPO_COPY also has modifications since the last pull that risk being overwritten. Please resolve this manually..."
                    #vimdiff $REPO_COPY $LOCAL_COPY 
                else
                    echo -e "${yellow}No conflicts on the repo, overwritting file!${NC}"
                    cp $LOCAL_COPY $REPO_COPY
                fi
            fi
        elif [ "$REPO_MOD" -gt "$LOCAL_MOD" ] ; then
            echo -e "${yellow}Repo copy ($REPO_COPY) of this build script is newer!${NC}"
            confirm "View changes?" && diff $REPO_COPY $LOCAL_COPY 
            confirm "Overwrite your local copy?" && cp $REPO_COPY $LOCAL_COPY && quit "Please restart the script to use the updated file."
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
    if confirm "Would you like to install this set of packages [${list_elements[*]}] ?";
    then 
        echo "sudo apt-get -y install ${list_elements[*]}"
        sudo apt-get -y install ${list_elements[*]}
    fi
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
    if check-installed SysReqs ; then
      echo "System requirements met"
    else 
      echo "Attempting to install system requirements"
      sudo apt-get install git build-essential 
      install-packages SysReqs || fail
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
    if [ ! -d "CppUTest" ]; then
        git clone git://github.com/cpputest/cpputest.git CppUTest
        cd CppUTest
        ./configure
        make
        make -f Makefile_CppUTestExt 
        cp -r include/* $SPACE_INCLUDE
        cp lib/libCppUTest.a $SPACE_LIB/lib/
        cp lib/libCppUTestExt.a $SPACE_LIB/lib/
        cd $CS1_DIR
    fi
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

cs1-build-commander () {
    #COMMANDER
    echo -e "${green}Building Commander $build_environment ...${NC}"
    cd $COMMANDER_DIR
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make buildQ6 || bash csmake -c
    cp $COMMANDER_DIR/include/Net2Com.h $SPACE_INCLUDE/
    cp $COMMANDER_DIR/include/NamedPipe.h $SPACE_INCLUDE/

    confirm-build-q6 && make staticlibsQ6.tar || make staticlibs.tar
    cp lib/*.a $SPACE_LIB/lib/
    cp staticlibs*.tar $SPACE_LIB/lib/
    cd $SPACE_LIB/lib
    [ -f staticlibs.tar ] && tar -xf staticlibs.tar
    [ -f staticlibsQ6.tar ] && tar -xf staticlibsQ6.tar
    rm staticlibs*.tar
}

cs1-build-netman () {
    echo -e "${green}Building Netman...${NC}"
    cd $NETMAN_DIR
    check-master-branch || fail "Cannot build project without"
    mkdir -p ./bin ./lib ./include
    confirm-build-q6 && make Q6 || make
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

  confirm-build-q6 && bash csmake.sh Q6 || bash csmake.sh

  cp $HELIUM_DIR/lib/* $SPACE_LIB/lib/
  cp $HELIUM_DIR/inc/SC_he100.h $SPACE_LIB/include/ 
}

cs1-build-fletcher () {
  echo -e "${green}Building Fletcher Checksum Library...${NC}"
  cd $CHECKSUM_DIR
  check-master-branch || fail "Cannot build project without"
  mkdir -p $CHECKSUM_DIR/lib
  confirm-build-q6 && sh mbcc-compile-lib-static.sh || sh x86-compile-lib-static.sh
  cp $CHECKSUM_DIR/lib/libfletcher* $SPACE_LIB/lib/
  
  cp $CHECKSUM_DIR/inc/fletcher.h $SPACE_LIB/include/
  cp $CHECKSUM_DIR/inc/fletcher.h $COMMANDER_DIR/include/
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
  cp inc/shakespeare.h $SPACE_LIB/include/

  confirm-build-q6 && bash csmake.sh Q6 || bash csmake.sh test

  cp lib/libshakespeare* $SPACE_LIB/lib/
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
  cp lib/libtimer* $SPACE_LIB/lib
  cp inc/timer.h $SPACE_LIB/include/
}

cs1-build-utls () {
  echo -e "${green}Building cs1_utls Library...${NC}"
  cd $SPACE_LIB/utls
  bash csmake.sh 
}

ensure-operating-system () {
    if [ "$DISTRIBUTION" == "$REQUIRED_DIST" -a "$DISTRIBUTION_RELEASE" == "$REQUIRED_RELEASE" ] ; then 
        echo -e "${green}Correct distribution and OS ($DISTRIBUTION $DISTRIBUTION_RELEASE)${NC}"
    else
        echo -e "${red}Warning, WrongOS! Need $REQUIRED_DIST $REQUIRED_RELEASE, you have $DISTRIBUTION $DISTRIBUTION_RELEASE${NC}"
    fi
    check-installed OperatingSystem || fail "This script depends on apt-get, and thus requires a Debian-based system. With some modification you can get this to run on other systems and with their package managers. Have fun."
}

ensure-symlinks () {
  if [ ! -f "/usr/bin/at-runner.sh" ]; then 
      sudo ln -s "$SPACESCRIPT_DIR/at-runner/at-runner.sh" /usr/bin/
  fi;
}

ensure-directories () {
  declare -a REQDIR_LIST=("$NETMAN_DIR/lib/include/" "$HELIUM_DIR/inc/" "$TIMER_DIR/inc/" "$BABYCRON_DIR/include/" "$JOBRUNNER_DIR/inc/" "$COMMANDER_DIR/include/" "$HELIUM_DIR/lib/" "$TIMER_DIR/lib/" "$COMMANDER_DIR/lib/" "$BABYCRON_DIR/lib/" "$BABYCRON_DIR/lib/" "$JOBRUNNER_DIR/lib/" "$NETMAN_DIR/lib/include" "$NETMAN_DIR/bin" "$UPLOAD_FOLDER/jobs" "$CS1_DIR/logs" "$CS1_DIR/pipes" "$CS1_DIR/pids" "$CS1_DIR/tgz")
  for item in ${REQDIR_LIST[*]}; do
    mkdir -p $item
    #[ ! -d $item ] && fail "$item does not exist and/or was not created properly"
  done
  if [ ! -d "$CS1_DIR/logs" -o ! -d "/home/logs" ]; then 
      echo -e "${yellow} Linking /home/logs${NC}"
      mkdir -p "$CS1_DIR"/logs && sudo ln -s "$CS1_DIR"/logs /home/logs && sudo chown -R $(logname):$(logname) /home/logs
  fi
  if [ ! -d "$CS1_DIR/pipes" -o ! -d "/home/pipes" ]; then
      echo -e "${yellow} Linking /home/pipes${NC}"
      mkdir -p "$CS1_DIR"/pipes && sudo ln -s "$CS1_DIR"/pipes /home/pipes && sudo chown -R $(logname):$(logname) /home/pipes
  fi
  if [ ! -d "$CS1_DIR/tgz" -o ! -d "/home/tgz" ]; then 
      echo -e "${yellow} Linking /home/tgz${NC}"
      mkdir -p "$CS1_DIR"/tgz && sudo ln -s "$CS1_DIR"/tgz /home/tgz && sudo chown -R $(logname):$(logname) /home/tgz
  fi
}

cs1-build-libs() {
    #libraries
    ensure-directories
    cs1-build-timer $1
    cs1-build-shakespeare $1
    cs1-build-fletcher $1
    cs1-build-helium $1
    cs1-build-utls $1
}

cs1-build () {
    [ "$#" -eq 0 ] && fail "No build environment specified..." 
    build_environment="$1"
    echo -e "${orange}Building for $build_environment...${NC}"
    ensure-directories
    ensure-symlinks

    cs1-build-libs $build_environment

    #executables
    cs1-build-commander $build_environment
    cs1-build-netman $build_environment
    cs1-build-job-runner $build_environment
    # TODO renable when jobs are fixed # cs1-build-jobs $build_environment
    cs1-build-space-updater $build_environment
    cs1-build-space-updater-api $build_environment
    cs1-build-baby-cron $build_environment

    #COLLECT FILES
    echo -e "${purple}Collecting files for $build_environment... ${NC}"
    if confirm-build-q6; then  
      ls $CS1_DIR/BUILD/Q6
      cp $COMMANDER_DIR/bin/space-commanderQ6 $UPLOAD_FOLDER/
      cp $NETMAN_DIR/bin/gnd-mbcc $UPLOAD_FOLDER/../
      cp $NETMAN_DIR/bin/sat-mbcc $UPLOAD_FOLDER/sat
      cp $CS1_DIR/space-jobs/job-runner/bin/job-runner-mbcc $UPLOAD_FOLDER/
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
      cp $CS1_DIR/space-updater-api/bin/UpdaterServer $CS1_DIR/BUILD/PC/
      cp $CS1_DIR/space-updater/bin/PC-Updater $CS1_DIR/BUILD/PC/
      cp $BABYCRON_DIR/bin/baby-cron $CS1_DIR/BUILD/PC/    
      cd $CS1_DIR
      echo -e "${purple}Binaries left in $CS1_DIR/BUILD/PC${NC}"
    fi
}

# START EXECUTION
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
self-update
ensure-operating-system
ensure-system-requirements

for arg in "$@"; do
    case $arg in
        "-v")
            version; quit;
        ;;
        "-h")
            usage; quit;
        ;;
        "--help")
            usage; quit;
        ;;
        "-buildQ6")
            cs1-build Q6; quit;
        ;;
        "--buildPC")
            cs1-build PC; quit;
        ;;
        "-L") cs1-build-libs; quit;
        ;;
        "-J") cs1-build-libs; cs1-build-jobs; quit;
    esac
done

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
check-projects && confirm "Pull updates for cloned projects?" && update=0;
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

if [ ! -d "gtest-1.7.0" -o ! -d "CppUTest" ]; then
    confirm "Install Test Environment (GTest and CPPUTest)?" && cs1-install-test-env
fi
confirm "Build project for PC?" && buildPC=0;
check-microblaze || confirm "Install Microblaze environment?" && cs1-install-mbcc
check-microblaze && confirm "Build project for Q6?" && buildQ6=0

if [ $buildPC ]; then
    if [ -d "space-script" ]; then
        cs1-build PC
    fi;
fi;
if [ $buildQ6 ]; then
    if [ -d "space-script" ]; then
        cs1-build Q6
    fi;
fi;
