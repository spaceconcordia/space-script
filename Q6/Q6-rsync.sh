#!/bin/sh
# file to install new binaries on Q6 or PC

declare -a AppList=('acs' 'baby-cron' 'space-commander' 'job-runner' 'netman' 'tgz-wizard' 'at-runner' 'space-updater' 'space-updater-api' 'space-payload')

set -e
exec_dir="/home/apps/new"
RSYNC_FLAGS=" -av --remove-source-files"
RSYNC="rsync"
SYNC_COMMAND="$(RSYNC) $(RSYNC_FLAGS)"

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

ensure_directory_structure ()
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

#TODO 
ensure_kernel_files () {
    # copy device drivers
    echo "not implemented yet"
    # $SYNC_COMMAND ad799x.ko /path/to/driver/location
    # $SYNC_COMMAND hmc5843.ko
    #rtc-ds3232.ko
    #ina2xx.ko
}

sync_files() {
    $SYNC_COMMAND ./ / # expect all files to be in correct directory structure
}

symlink () {
    if [ ! -L $1 ] ; then
        ln -s $1 $2
    fi
}

create_symlinks () {
    # link config files
    symlink $exec_dir/etc/profile                /etc/profile

    # link driver start scripts
    symlink $exec_dir/etc/rcS                           $exec_dir/etc/init.d/
    symlink $exec_dir/boot/I01ad799x.sh           /etc/init.d/
    symlink $exec_dir/boot/I02hmc5843.sh          /etc/init.d/
    symlink $exec_dir/boot/I03ina2xx.sh           /etc/init.d/
    symlink $exec_dir/boot/I04rtc-ds3232e.sh      /etc/init.d/

    # link log rotation scripts
    symlink $exec_dir/tgz_wizard/tgzWizard.sh         /usr/bin/
    symlink $exec_dir/tgz_wizard/duChecker.sh         /usr/bin/
    symlink $exec_dir/tgz_wizard/cs1_log_rotation.sh  /usr/bin/
    symlink $exec_dir/scripts/SpaceDecl.sh            /etc/
}

execute_on_q6 ()
{
    writeprotect off

    # make the changes
    sync_files  

    # Q6 stuff
    sync
    writeprotect on

    filesleft=$(ls -1 targetdir | wc -l)
    if [ filesleft -eq 1 ] ; then
        echo "Upload was successful"
    else
        echo "Some files were leftover..."
        find . -type f
    fi

    create-symlinks

    echo "Self destructing..."
    rm Q6-rsync.sh
}

find . -type f
confirm "This script will overwrite all shown project files, continue?" && execute_on_q6
