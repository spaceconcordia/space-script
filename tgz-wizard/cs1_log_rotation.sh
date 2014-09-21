#!/bin/sh
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
DIR=`dirname $0`
SPACE_LIB="$HOME/CONSAT1/space-lib/include"
if [ -f $SPACE_LIB/SpaceDecl.sh ]; then     # on PC
    source $SPACE_LIB/SpaceDecl.sh
    TGZWIZARD=$DIR/tgzWizard
    DUCHECKER="$DIR/duChecker.sh -f sda1"
else                                        # on Q6
    source $DIR/SpaceDecl.sh
    TGZWIZARD=$DIR/tgzWizard
    DUCHECKER="$DIR/duChecker.sh -f xdm_root"
fi

#
# Error Codes
#
E_CANT_OPEN_FILE=66
#
# check disk usage and make room if needed (by deleting the oldest tgz files under CS1_TGZ)
#
sh $DUCHECKER 

#
# Runs tgzWizard of each file present under CS1_LOGS    
#
for FILE in $CS1_LOGS/*
do
    sts=0
    filepath=`echo $FILE | awk -F "." '{print $1}'` # removes the extension
    file_no_path_no_ext=`echo $filepath | awk -F "/" '{print $4}'` # removes /home/logs/

    while [ -f $FILE ] && [ $sts -ne $E_CANT_OPEN_FILE ]
    do
        sh $TGZWIZARD -f $file_no_path_no_ext -s 500        ## see tgzWizard -u for more options
        sts=$?
    done
done



