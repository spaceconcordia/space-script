#!/bin/sh -e
#**********************************************************************************************************************
# AUTHORS : Space Concordia 2014, Joseph
#
# PURPOSE : calls the tgzWizard on each file present under CS1_LOGS
#           To be run as a cron job, add a line to the crontab file :
#                               $ crontab -e
#
# ARGUMENTS : NONE
#
#**********************************************************************************************************************
SPACE_LIB="../../space-lib/include"
if [ -f $SPACE_LIB/SpaceDecl.sh ]; then     # on PC
    source $SPACE_LIB/SpaceDecl.sh
    TGZWIZARD=./tgzWizard
    DUCHECKER="./duChecker.sh -f sda1"
else                                        # on Q6
    source /etc/SpaceDecl.sh
    TGZWIZARD=tgzWizard
    DUCHECKER="/usr/bin/duChecker.sh -f xdm_root"
fi

#
# check disk usage and make room if needed (by deleting the oldest tgz files under CS1_TGZ)
#
sh $DUCHECKER 

#
# Runs tgzWizard of each file present under CS1_LOGS    
#
for FILE in $CS1_LOGS/*
do
    filepath=`echo $FILE | awk -F "." '{print $1}'` # removes the extension
    file_no_path_no_ext=`echo $filepath | awk -F "/" '{print $4}'` # removes /home/logs/

    while [ -f $FILE ]
    do
        $TGZWIZARD -f $file_no_path_no_ext -s 500        ## see tgzWizard -u for more options
    done
done



