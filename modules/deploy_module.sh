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
apps_new="$apps/current" # place new files here, space-updater-api will ensure new file or rollback
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
boot_scripts="$initd"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Function Bodies
#
#------------------------------------------------------------------------------
make_directories () {
    mkdir -p $etc $home $apps $apps_etc $apps_new $apps_current $apps_old $logs $pids $ground $commander $baby_cron $netman $updaterapi $updater $spacejobs $tgz_wizard $initd $bin $tests $scripts $boot_scripts
}

build_pcd() {
    cd $CS1_DIR/space-pcd/pcd-1.1.6
    sudo make clean
    sudo make pcd
    sudo make install 
}

collect_files () {
  echo -e "${purple}Collecting files for $build_environment... ${NC}"
  if confirm-build-q6; then  
    make_directories 
    ls $CS1_DIR/BUILD/Q6
    cp $COMMANDER_DIR/bin/space-commanderQ6/space-commanderQ6   $commander/space-commander
    cp $NETMAN_DIR/bin/sat-mbcc                                 $netman/space-netman
    cp $CS1_DIR/space-updater-api/bin/UpdaterServer-Q6          $updaterapi/
    cp $CS1_DIR/space-updater/bin/Updater-Q6                    $updater/
    cp $BABYCRON_DIR/bin/baby-cron                              $baby_cron/
    
    cp $CS1_DIR/space-jobs/job-runner/bin/job-runner-mbcc       $spacejobs/job-runner
    #cp $CS1_DIR/space-jobs/jobs/bin/*                           $spacejobs/

    cp $SPACESCRIPT_DIR/tgz-wizard/tgzWizard                    $tgz_wizard/
    cp $SPACESCRIPT_DIR/tgz-wizard/cs1_log_rotation.sh          $tgz_wizard/
    cp $SPACESCRIPT_DIR/tgz-wizard/duChecker.sh                 $tgz_wizard/
    
    cp $SPACE_LIB/include/SpaceDecl.sh                          $tgz_wizard/
    
    ## TODO test jobs under baby-cron/tests/jobs
    
    cp $SPACESCRIPT_DIR/testing/settime_rtc_commander_test.sh   $tests/
    cp $SPACESCRIPT_DIR/Q6/*                                    $tests/
    mv $tests/Q6-rsync.sh                                       $root/
    cp $SPACESCRIPT_DIR/at-runner/at-runner.sh                  $scripts/
    cp $SPACESCRIPT_DIR/boot-drivers/*.sh                       $boot_scripts/
    
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
    mkdir -p $root
    make_directories 
    cp $COMMANDER_DIR/bin/space-commander/space-commander   $CS1_DIR/BUILD/PC/
    cp $NETMAN_DIR/bin/gnd                                  $CS1_DIR/BUILD/PC/
    cp $NETMAN_DIR/bin/sat                                  $CS1_DIR/BUILD/PC/
    cp $NETMAN_DIR/bin/mock_sat                             $CS1_DIR/BUILD/PC/
    
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

ground_station_setup () {
   echo "Building Ground Commander"
   cd $COMMANDER_DIR/
   make buildGroundCommander
   cp $COMMANDER_DIR/bin/ground-commander/ground-commander   $CS1_DIR/BUILD/PC/

   build_pcd

   echo "Linking Named Pipes"
   cs1_mkfifo /home/pipes/gnd-input
   cs1_mkfifo /home/pipes/gnd-out-sat-in
   cs1_mkfifo /home/pipes/sat-out-gnd-in
   echo "Linking Binaries"
   su_symlink $CS1_DIR/BUILD/PC/gnd /usr/bin/gnd
   su_symlink $CS1_DIR/BUILD/PC/sat /usr/bin/sat
   su_symlink $CS1_DIR/BUILD/PC/mock_sat /usr/bin/mock_sat
   su_symlink $CS1_DIR/BUILD/PC/space-commander /usr/bin/space-commander
   su_symlink $CS1_DIR/BUILD/PC/ground-commander /usr/bin/ground-commander

   su_symlink $CS1_DIR/BUILD/PC/cs1_log_rotation.sh /usr/bin/cs1_log_rotation.sh
   su_symlink $CS1_DIR/BUILD/PC/duChecker.sh /usr/bin/duChecker.sh
   su_symlink $CS1_DIR/BUILD/PC/tgzWizard /usr/bin/tgzWizard

   su_symlink $CS1_DIR/ground-commander/BASH/ground-control.sh /usr/bin/ground-control
   su_symlink $CS1_DIR/ground-commander/Python/gs.py /usr/bin/ground-control.py

   su_symlink $CS1_DIR/space-tools/echo-for-pipes/decode-command.rb /usr/bin/decode-command.rb  
   su_symlink $CS1_DIR/space-tools/echo-for-pipes/getlog-command.rb /usr/bin/getlog-command.rb  
   su_symlink $CS1_DIR/space-tools/echo-for-pipes/gettime-command.rb /usr/bin/gettime-command.rb  
   su_symlink $CS1_DIR/space-tools/echo-for-pipes/reboot-command.rb /usr/bin/reboot-command.rb  
   su_symlink $CS1_DIR/space-tools/echo-for-pipes/update-command.rb /usr/bin/update-command.rb  
   su_symlink $CS1_DIR/space-tools/echo-for-pipes/step2.rb /usr/bin/step2.rb  
   touch /home/logs/gs.log
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

confirm "Prepare Ground Control dependencies?" && ground_station_setup
