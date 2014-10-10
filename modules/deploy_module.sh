#! /bin/. 
if [ -z "$BASH_VERSION" ]; then exec . .  "$0" "$@"; fi;
# deploy_module.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# TODO
#
#------------------------------------------------------------------------------
#rsync $RSYNC_FLAGS split                    /usr/bin

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
# Folder Structure
#
#------------------------------------------------------------------------------
if [ ! $UPLOAD_FOLDER ] ; then
    echo "No upload folder selected, please enter one:"
    read UPLOAD_FOLDER
fi

root="$UPLOAD_FOLDER/$(date --iso)"
etc="$root/etc"
home="$root/home"
apps="$home/apps"
apps_new="$apps/new" # place new files here, space-updater-api will ensure new file or rollback
apps_current="$apps/current"
apps_old="$apps/old"
logs="$home/logs"
pids="$home/pids"

apps_etc="$apps_new/etc"

ground="~/CONSAT1/ground"

commander="$apps_new/space-commander"
baby_cron="$apps_new/baby-cron"
netman="$apps_new/space-netman"
updaterapi="$apps_new/space-updater-api"
updater="$apps_new/space-updater"
spacejobs="$apps_new/jobs"
tgz_wizard="$apps_new/tgz-wizard"

initd="$etc/init.d"
bin="/usr/bin"
tests="$home/tests"

scripts="$apps_new/scripts"
boot_scripts="$apps_new/boot/"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Function Bodies
#
#------------------------------------------------------------------------------
make_directories () {
    mkdir -p $etc $home $apps $apps_etc $apps_new $apps_current $apps_old $logs $pids $ground $commander $baby_cron $netman $updaterapi $updater $spacejobs $tgz_wizard $initd $bin $tests $scripts $boot_scripts
}

collect_files () {
  echo -e "${purple}Collecting files for $build_environment... ${NC}"
  if confirm-build-q6; then  
    make_directories 
    ls $CS1_DIR/BUILD/Q6
    cp $COMMANDER_DIR/bin/space-commanderQ6                 $commander/space-commander
    cp $NETMAN_DIR/bin/sat-mbcc                             $netman/space-netman
    cp $CS1_DIR/space-updater-api/bin/UpdaterServer-Q6      $updaterapi/
    cp $CS1_DIR/space-updater/bin/Updater-Q6                $updater/
    cp $BABYCRON_DIR/bin/baby-cron                          $baby_cron/
    
    cp $CS1_DIR/space-jobs/job-runner/bin/job-runner-mbcc   $spacejobs/job-runner

    cp $SPACESCRIPT_DIR/tgz-wizard/tgzWizard                $tgz_wizard/
    cp $SPACESCRIPT_DIR/tgz-wizard/cs1_log_rotation.sh      $tgz_wizard/
    cp $SPACESCRIPT_DIR/tgz-wizard/duChecker.sh             $tgz_wizard/
    
    cp $SPACE_LIB/include/SpaceDecl.sh                      $apps_etc/
    
    ## TODO test jobs under baby-cron/tests/jobs
    
    cp $SPACESCRIPT_DIR/Q6/*                                $tests/
    mv $tests/Q6-rsync.sh                                   $root/
    cp $SPACESCRIPT_DIR/at-runner/at-runner.sh              $scripts/
    cp $SPACESCRIPT_DIR/boot-drivers/*.sh                   $boot_scripts/
    
    chmod +x $UPLOAD_FOLDER/*
    cd $UPLOAD_FOLDER
    tar -cpvf $(date --iso)-Q6.tar.gz * 
    mv $(date --iso)-Q6.tar.gz ../
    ls
    cd $CS1_DIR
    echo 'Binaries left in $CS1_DIR/BUILD/Q6'
    echo -e "${purple}Left archive: $CS1_DIR/BUILD/Q6/$(date --iso)-Q6.tar.gz left in, transfer it to Q6, tar -xvf it, and run Q6-rsync.sh${NC}"
  else
    root="$CS1_DIR/BUILD/PC"
    make_directories 
    cp $COMMANDER_DIR/bin/space-commander                   $CS1_DIR/BUILD/PC/
    cp $NETMAN_DIR/bin/gnd                                  $CS1_DIR/BUILD/PC/
    cp $NETMAN_DIR/bin/sat                                  $CS1_DIR/BUILD/PC/
    
    cp $SPACESCRIPT_DIR/tgz-wizard/cs1_log_rotation.sh      $CS1_DIR/BUILD/PC/
    cp $SPACESCRIPT_DIR/tgz-wizard/duChecker.sh             $CS1_DIR/BUILD/PC/
    cp $SPACESCRIPT_DIR/tgz-wizard/tgzWizard                $CS1_DIR/BUILD/PC/

    #cp $CS1_DIR/space-jobs/job-runner/bin/job-runner $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-updater-api/bin/UpdaterServer         $CS1_DIR/BUILD/PC/
    cp $CS1_DIR/space-updater/bin/PC-Updater                $CS1_DIR/BUILD/PC/
    cp $BABYCRON_DIR/bin/baby-cron                          $CS1_DIR/BUILD/PC/    
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
  collect_files
}
