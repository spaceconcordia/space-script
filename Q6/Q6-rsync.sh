#!/bin/sh
# file to install new binaries on Q6 or PC

declare -a AppList=('acs' 'baby-cron' 'space-commander' 'job-runner' 'netman' 'tgz-wizard' 'at-runner' 'space-updater' 'space-updater-api' 'space-payload')

display_usage()
{
    echo "Usage :           [-m maxDu] [-p] [-f targetFilesystem] [-u]"
    echo
    echo "          -p  prompt before cleanup"
    exit 0
}

ARGS=$(getopt -o um:pf: -n "$0"  -- "$@");

if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$ARGS";

while true; do
    case "$1" in
        -q)
        ;;
        -p)
        ;;
    esac
done
set -e
exec_dir="/home/apps/current"
RSYNC_FLAGS= -av --remove-source-files


execute-on-q6 ()
{
    writeprotect off

    

    sync
    writeprotect on
}

execute-on-pc ()
{

}

ensure-directory-structure ()
{
    mkdir -p /home/apps
    mkdir -p /home/apps/current
    mkdir -p /home/apps/new
    mkdir -p /home/apps/old
    mkdir -p /home/apps/rollback
    mkdir -p /home/test
    mkdir -p /home/pipes
    mkdir -p /home/logs
    mkdir -p /home/pids

    for item in ${AppList} 
        mkdir -p /home/apps/current/$item
        mkdir -p /home/apps/new/$item
        mkdir -p /home/apps/old/$item
        mkdir -p /home/apps/rollback/$item
    done
}

ensure-kernel-files () {
    # copy device drivers
    echo "not implemented yet"
    # rsync -av --remove-source-files ad799x.ko /path/to/driver/location
    # rsync -av --remove-source-files hmc5843.ko
    #rtc-ds3232.ko
    #ina2xx.ko
}

rsync-files () {
    rsync -av --remove-source-files space-commander* $exec_dir/space-commander/space-commander
    rsync -av --remove-source-files watch-puppy* $exec_dir/watch-puppy/watch-puppy
    rsync -av --remove-source-files baby-cron* $exec_dir/baby-cron/baby-cron
    rsync -av --remove-source-files sat $exec_dir/space-netman/sat
    rsync -av --remove-source-files UpdaterServer* $exec_dir/space-updater-api/
    rsync -av --remove-source-files Updater* $exec_dir/space-updater/
    rsync -av --remove-source-files job-runner* /usr/bin/

    rsync -av --remove-source-files SpaceDecl.sh /home/apps/current/tgz-wizard/
    rsync -av --remove-source-files duChecker.sh /home/apps/current/tgz-wizard/
    rsync -av --remove-source-files cs1_log_rotation.sh /home/apps/current/tgz-wizard/
    
    # copy config files
    rsync -av --remove-source-files profile /etc/profile

    # copy jobs
    rsync -av --remove-source-files jobs/ /home/apps/current/jobs/

    # copy driver start scripts
    rsync -av --remove-source-files rcS /etc/init.d/
    rsync -av --remove-source-files I01ad799x.sh /etc/init.d/
    rsync -av --remove-source-files I02hmc5843.sh /etc/init.d/
    rsync -av --remove-source-files I03ina2xx.sh /etc/init.d/
    rsync -av --remove-source-files I04rtc-ds3232e.sh /etc/init.d/

    # Copy log rotation scripts
    chmod +x tgzWizard.sh
    rsync -av --remove-source-files tgzWizard.sh /usr/bin/
    chmod +x cs1_log_rotation.sh
    rsync -av --remove-source-files cs1_log_rotation.sh /usr/bin/
    rsync -av --remove-source-files SpaceDecl.sh /etc/

    # Copy test scripts
    rsync -av --remove-source-files Q6_helium100.sh /home/test/
    rsync -av --remove-source-files system-test.sh /home/test/
    rsync -av --remove-source-files read-pipes.sh /home/test/
    #rsync -av --remove-source-files start.sh /home/test
    rsync -av --remove-source-files AwkTest.awk /home/test/
    rsync -av --remove-source-files RunAwkTest.sh /home/test/

    #rsync -av --remove-source-files Q6-rsync.sh  /usr/bin/

    # System utilities
    rsync $RSYNC_FLAGS split /usr/bin
}

echo "Self destructing..."
rm Q6-rsync.sh
