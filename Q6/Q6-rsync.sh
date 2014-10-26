#!/bin/sh
# file to install new binaries on Q6 or PC

set -e
exec_dir="/home/apps/new"
RSYNC_FLAGS=" -av --remove-source-files"
RSYNC="rsync"
SYNC_COMMAND="$RSYNC $RSYNC_FLAGS"

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
    $SYNC_COMMAND --exclude Q6-rsync.sh --exclude *.tar.gz ./ / # expect all files to be in correct directory structure
}

symlink () {
    if [ ! -L $2 ] ; then
        ln -s $1 $2
    fi
}

create_symlinks () {
    # link driver start scripts
    #symlink $exec_dir/boot/I01ad799x.sh           /etc/init.d/I01ad799x.sh
    #symlink $exec_dir/boot/I02hmc5843.sh          /etc/init.d/I02hmc5843.sh
    #symlink $exec_dir/boot/I03ina2xx.sh           /etc/init.d/I03ina2xx.sh
    #symlink $exec_dir/boot/I04rtc-ds3232e.sh      /etc/init.d/I04rtc-ds3232e.sh

    # link log rotation scripts
    symlink $exec_dir/tgz_wizard/tgzWizard.sh         /usr/bin/tgzwizard.sh
    symlink $exec_dir/tgz_wizard/duChecker.sh         /usr/bin/duChecker.sh
    symlink $exec_dir/tgz_wizard/cs1_log_rotation.sh  /usr/bin/cs1_log_rotation.sh
    symlink $exec_dir/scripts/SpaceDecl.sh            /etc/SpaceDecl.sh

    # can't do this, because if /home is not ready, boot will fail catastrophically. Need to copy the files manually somehow
    # link config files
    # symlink $exec_dir/etc/rcS                     /etc/init.d/
    # symlink $exec_dir/etc/profile                /etc/profile
}

execute_on_q6 ()
{
    writeprotect off

    # make the changes
    sync_files  

    # Q6 stuff
    sync
    writeprotect on

    filesleft=$(ls -1 | wc -l)
    if [ $filesleft -eq 4 ] ; then
        echo "Upload was successful"
    else
        echo "Some files were leftover..."
        find . -type f
    fi

    create_symlinks

    # ensure permissions
    chmod +x /etc/init.d/I01ad799x.sh
    chmod +x /etc/init.d/I02hmc5843.sh
    chmod +x /etc/init.d/I03ina2xx.sh
    chmod +x /etc/init.d/I04rtc-ds3232e.sh

    echo "Self destructing..."
    rm Q6-rsync.sh
}

find . -type f
confirm "This script will overwrite all shown project files, continue?" && execute_on_q6
