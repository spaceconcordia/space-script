#! /bin/. 
if [ -z "$BASH_VERSION" ]; then exec . .  "$0" "$@"; fi;
# deploy_module.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.

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
globals=`find . -type f -name globals.sh`
source $globals || echo "Failed to source $globals"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Function Bodies
#
#------------------------------------------------------------------------------
collect-files () {
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

    cp $SPACESCRIPT_DIR/tgz-wizard/cs1_log_rotation.sh $UPLOAD_FOLDER
    cp $SPACESCRIPT_DIR/tgz-wizard/duChecker.sh $UPLOAD_FOLDER
    cp $SPACESCRIPT_DIR/tgz-wizard/tgzWizard $UPLOAD_FOLDER

    ## TODO test jobs under baby-cron 

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
    
    cp $SPACESCRIPT_DIR/tgz-wizard/cs1_log_rotation.sh $CS1_DIR/BUILD/PC/
    cp $SPACESCRIPT_DIR/tgz-wizard/duChecker.sh $CS1_DIR/BUILD/PC/
    cp $SPACESCRIPT_DIR/tgz-wizard/tgzWizard $CS1_DIR/BUILD/PC/

    #cp $CS1_DIR/space-jobs/job-runner/bin/job-runner $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-updater-api/bin/UpdaterServer $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-updater/bin/PC-Updater $CS1_DIR/BUILD/PC/
    cp $BABYCRON_DIR/bin/baby-cron $CS1_DIR/BUILD/PC/    
    cd $CS1_DIR
    echo -e "${purple}Binaries left in $CS1_DIR/BUILD/PC${NC}"
  fi
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Execution
#
#------------------------------------------------------------------------------
confirm "Collect files for deployment?" && {
  if [ ! $build_environment ] ; then 
    confirm "Prepare deployment for Q6 (else PC)?" && build_environment="Q6" || build_environment="PC"
  fi
  collect-files
}
