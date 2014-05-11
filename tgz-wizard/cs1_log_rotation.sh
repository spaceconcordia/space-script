#!/bin/bash -e
#**********************************************************************************************************************
# AUTHORS : Space Concordia 2014, Joseph
#
# PURPOSE : calls the tgzWizard on each file present under CS1_LOGS
#           To be run as a cron job
#
# ARGUMENTS : NONE
#
#**********************************************************************************************************************
SPACE_LIB="../../space-lib/include"
source $SPACE_LIB/SpaceDecl.sh



#
# TODO check disk usage and make room if needed (by deleting the oldest tgz files under CS1_TGZ
#




#
# Runs tgzWizard of each file present under CS1_LOGS    
#
for FILE in $CS1_LOGS/*
do
    filepath=`echo $FILE | awk -F "." '{print $1}'` # removes the extension
    file_no_path_no_ext=`echo $filepath | awk -F "/" '{print $4}'` # removes /home/logs/

    echo "$file_no_path_no_ext"
    while [ -f $FILE ]
    do
        ./tgzWizard -f $file_no_path_no_ext -s 500        
    done
done



