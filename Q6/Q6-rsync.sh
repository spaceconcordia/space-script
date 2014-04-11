#!/bin/sh
# file to install new binaries on Q6
set -e
exec_dir="/home/apps/current"

# creates directory structure
mkdir -p /home/apps
mkdir -p /home/apps/current
mkdir -p /home/apps/new
mkdir -p /home/apps/old
mkdir -p /home/apps/rollback
mkdir -p /home/test
mkdir -p /home/pipes
mkdir -p /home/logs
mkdir -p /home/pids

# demonstration only
mkdir -p /var/log/telemetryPowerLog

# Creates Jobs folder in /current
mkdir -p /home/apps/current/baby-cron
mkdir -p /home/apps/current/space-commander
mkdir -p /home/apps/current/watch-puppy
mkdir -p /home/apps/current/updater
mkdir -p /home/apps/current/space-netman

# Copy binaries
#cp baby-cron /home/apps/current/baby-cron
#cp watch-puppy /home/apps/current/watch-puppy
#cp space-commander /home/apps/current/space-commander
#cp Updater-Q6 /home/apps/current/updater
#cp sat /home/apps/current/space-netman/sat

# copy device drivers
# rsync -av --remove-source-files ad799x.ko /path/to/driver/location
# rsync -av --remove-source-files hmc5843.ko
#rtc-ds3232.ko
#ina2xx.ko

rsync -av --remove-source-files space-commanderQ6 $exec_dir/space-commander/space-commander
rsync -av --remove-source-files watch-puppy $exec_dir/watch-puppy/watch-puppy
rsync -av --remove-source-files baby-cron $exec_dir/baby-cron/baby-cron
rsync -av --remove-source-files sat $exec_dir/space-netman/sat
rsync -av --remove-source-files UpdaterServer-Q6 $exec_dir/space-updater-api/
rsync -av --remove-source-files Updater-Q6 $exec_dir/space-updater/
rsync -av --remove-source-files at-runner.sh /usr/bin/
rsync -av --remove-source-files job-runner-mbcc /usr/bin/

# copy config files
rsync -av --remove-source-files profile /etc/profile

# copy jobs
rsync -av --remove-source-files jobs/ /home/apps/current/jobs/

# copy driver start scripts
rsync -av --remove-source-files ad799x.sh /etc/init.d/
rsync -av --remove-source-files hmc5843.sh /etc/init.d/
rsync -av --remove-source-files ina2xx.sh /etc/init.d/
rsync -av --remove-source-files rtc-ds3232e.sh /etc/init.d/

# Copy test scripts
rsync -av --remove-source-files Q6_helium100.sh /home/test/
rsync -av --remove-source-files system-test.sh /home/test/
rsync -av --remove-source-files read-pipes.sh /home/test/
#rsync -av --remove-source-files start.sh /home/test
rsync -av --remove-source-files AwkTest.awk /home/test/
rsync -av --remove-source-files RunAwkTest.sh /home/test/

#rsync -av --remove-source-files Q6-rsync.sh  /usr/bin/
echo "Self destructing..."
rm Q6-rsync.sh
