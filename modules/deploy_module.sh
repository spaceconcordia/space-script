#! /bin/. 
if [ -z "$BASH_VERSION" ]; then exec . .  "$0" "$@"; fi;
# deploy_module.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.
# Credit to https://stackoverflow.com/a/3232082 for confirm function
NC='\e[0m';black='\e[0;30m';darkgrey='\e[1;30m';blue='\e[0;34m';lightblue='\e[1;34m';green='\e[0;32m';lightgreen='\e[1;32m';cyan='\e[0;36m';lightcyan='\e[1;36m';red='\e[0;31m';lightred='\e[1;31m';purple='\e[0;35m';lightpurple='\e[1;35m';orange='\e[0;33m';yellow='\e[1;33m';lightgrey='\e[0;37m';yellow='\e[1;37m'; # colors: echo -e "${red}Text${NC}"

declare -a SysReqs=('dialog' 'whiptail'); for item in ${SysReqs[*]}; do command -v $item >/dev/null 2>&1 || { echo >&2 "I require $item but it's not installed.  Aborting."; exit 1; }; done

PROGRAM="deploy_module.sh"
VERSION="0.0.1"
version () { echo "$PROGRAM version $VERSION"; }
usage="usage: deploy_module.sh [options: (-v version), (-u usage) ]"

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

set -e
source `find . -type f -name globals.sh`

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
