#!/bin/bash -e
#**********************************************************************************************************************
# AUTHORS : Space Concordia 2014, Joseph
#
# PURPOSE : Creates a tgz package and splits it in smaller part. 
#   N.B. add all valid apps in the validApps array below!!!!! The name has to match the file name (ex : Watych-Puppy -> Watch-Puppy20140101.log)
#
# ARGUMENTS : 
#       -$1    Mandatory - Application (ex. "Watch-Puppy" -> Watch-Puppy*log) - Should match the log filename 
#       -s      size of the parts in bytes.
#       -u      display usage
#       -l      logs directory
#       -t      tgz directory
#
# Untar :
# cat *-part_* | tar zxvf
#**********************************************************************************************************************


function usage(){
        echo "Usage : tgzWizard appName [-s sizeInBytes]"
        echo "                          [-u] [-l logDirectory] [-t tgzDirectory]"
}

if [ $# -eq 0 ]; then
    echo "[ERROR] You provided no arguments!"
    usage
    exit 1
fi

#
# Q6 : /home
#
PATH_ROOT="/home/jamg85/space"

#
#
#
ERR_WARN_PATTERN="(ERROR|WARNING)"

#
# Add all valid application to the array (the ones that are used in the log filename (ex. "Watch-Puppy")
#
validApps=( "Error-Warning" "Baby-Cron" "Watch-Puppy" "Updater" "Process-Updater" )

#
# 
#
LOG_DIR="$PATH_ROOT/logs"

#
# We store the tgz here
#
TGZ_DIR="$PATH_ROOT/tgz"

#
# Temporary file
#
BIG_TGZ="$TGZ_DIR/bigTgz.tgz"

#
# Part files suffix
#
EXT=".tgz.part_"


#
# Default size of the parts in bytes.
#
PART_SIZE=1024 # 1K

#
# Parses command line arguments
#
argType=""

for arg in "$@"; do
    case $argType in
        -s)
            PART_SIZE=$arg
            echo "PART_SIZE has been set to : $PART_SIZE bytes"
        ;;

        -l)
            LOG_DIR=$(readlink -f $arg)
        ;;

        -t)
            BIG_TGZ="$(readlink -f $arg)/bigTgz.tgz"
            TGZ_DIR=$(readlink -f $arg)
        ;;
    esac
    
    argType=""    

    case $arg in
        -s)
            argType=$arg
            ;;
        -u)
            usage
            exit 0;
            ;;
        -l)
            argType=$arg
            ;;
        -t)
            argType=$arg
            ;;

    esac
done 



#
# Validates the application name
#
function isValidApp(){
    local application=$1
    local valid=0

    for app in "${validApps[@]}" 
    do
        if [ $application == $app ]; then
            valid=1
        fi 
    done
    
    if [ $valid == 0 ]; then
        echo "'$application' is not a valid application name"
        exit 1
    fi
}

#
# Files that match $PATTERN will be added to the package.
# ex. : "Watch-Puppy" -> search for "Watch-Puppy*.log"
#

isValidApp $1
PATTERN=$1

#
# This function is executed when the script exits (success or failure)
#
function finish() {
    echo "[INFO] removes temporary files"
    echo "rm $BIG_TGZ"
    rm $BIG_TGZ
    echo "[END]"
}

trap finish EXIT

#
# Extract the ERROR and WARNING
#
if [ $PATTERN == "Error-Warning" ]; then
    for file in $LOG_DIR/*.log ; do
        echo "egrep '$PATTERN' $file >> $FILENAME`date +%Y%m%d`.log"
        egrep $ERR_WARN_PATTERN $file >> $FILENAME`date +%Y%m%d`.log
    done
fi

#
#-------------------
# Perform!
#-------------------
#
echo "cd $LOG_DIR"
cd $LOG_DIR

echo "tar zcvf $BIG_TGZ $PATTERN*.log"
tar zcvf $BIG_TGZ $PATTERN*.log             || { echo "[ERROR] tar failed"; exit 1; }

echo "cd $TGZ_DIR"
cd $TGZ_DIR                       || { echo "[ERROR] cd failed"; exit 1; }

echo "split -b $PART_SIZE $BIG_TGZ $PATTERN`(date +%Y%m%d)`$EXT"
split -b $PART_SIZE $BIG_TGZ $PATTERN$EXT   || { echo "[ERROR} split failed"; exit 1; }

echo "rm $LOG_DIR/$PATTERN*"
rm $LOG_DIR/$PATTERN* 


exit 0;

