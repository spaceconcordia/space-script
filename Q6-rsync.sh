#!/bin/sh
# file to install new binaries on Q6
set -e
exec_dir="/home/apps/current"
rsync -av --remove-source-files space-commanderQ6 $exec_dir/space-commander/space-commander
rsync -av --remove-source-files watch-puppy $exec_dir/watch-puppy/watch-puppy
rsync -av --remove-source-files baby-cron $exec_dir/baby-cron/baby-cron
rsync -av --remove-source-files sat-mbcc $exec_dir/space-netman/sat
rsync -av --remove-source-files UpdaterServer-Q6 $exec_dir/space-updater-api/
rsync -av --remove-source-files Updater-Q6 $exec_dir/space-updater/
echo "Self destructing..."
rm Q6-rsync.sh
