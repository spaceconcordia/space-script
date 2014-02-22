#
#
# creates directory structure
#
mkdir /home/apps
mkdir /home/apps/current
mkdir /home/apps/new
mkdir /home/apps/old
mkdir /home/apps/rollback
mkdir /home/test
mkdir /home/pipes
mkdir /home/logs
mkdir /home/pids

#
#
# Creates Jobs folder in /current
#
mkdir /home/apps/current/baby-cron
mkdir /home/apps/current/space-commander
mkdir /home/apps/current/watch-puppy
mkdir /home/apps/current/updater

#
#
# Copy binaries
#
cp baby-cron /home/apps/current/baby-cron
cp watch-puppy /home/apps/current/watch-puppy
cp space-commander /home/apps/current/space-commander
cp Updater-Q6 /home/apps/current/updater

#
# 
# Copy test scripts
#
cp start.sh /home/test
cp AwkTest.awk /home/test
cp RunAwkTest.sh /home/test
