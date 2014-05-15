#!/bin/sh -e
#**********************************************************************************************************************
# AUTHORS : Space Concordia 2014, Joseph
#
# PURPOSE :  Extracts lines from a specified log file, compresses in a .tgz file and split the file according to the 
#            parameters.
#   N.B. add all valid apps to the validApps string below!!!!! The name has to match the file name 
#        (ex : Watych-Puppy -> Watch-Puppy20140101.log)
#  
#   N.B. This script dos NOT work with DASH! By default /bin/sh -> /bin/dash in Ubuntu, change that to
#         /bin/sh -> /bin/bash 
#
#   to untar multiple parts     :   cat Watch-Puppy20010101.0.tgz* | tar jx -C dest_folder 
# 
# ARGUMENTS : 
#       -f     filename
#       -a     subsystem (ex. "Watch-Puppy") - should match the log filename
#       -s     archive max size 
#       -n     number of lines to extract from the log file
#       -u     display usage
#       -l     logs directory
#       -t     tgz directory
#
#**********************************************************************************************************************
SPACE_LIB="../../space-lib/include"
if [ -f $SPACE_LIB/SpaceDecl.sh ]; then
    source $SPACE_LIB/SpaceDecl.sh  # source PC
else
    source /etc/SpaceDecl.h         # source Q6
fi


usage() 
{
        echo "Usage : tgzWizard [-f filename] [-a app] [-d date]"
        echo "                  [-s sizeOfBigTgz] [-p sizeOfTgzParts] [-n numberOfLinesToExtract]"
        echo "                  [-u] [-l logDirectory] [-t tgzDirectory]"
}

###
#   Checks if required arguments are there
##
if [ $# -eq 0 ]; then
    echo "[ERROR] You provided no arguments!"
    usage
    exit 1
fi
##
#
##

PATH_ROOT="/home"           ### HARDCODED ROOT PATH <===============================

LOG_DIR="$CS1_LOGS"         # -l log directory
TGZ_DIR="$CS1_TGZ"          # -t tgz directory
TGZ_MAX_SIZE=$((1 * 1024))  # -s Default max size of the archives
PART_SIZE=190               # -p Default part size
NUM_LINES=50                # -n Default number of lines to extract from the log file
SOURCE=""                   # -f filename
APP=""                      # -a subsystem/app
DATE=`date +%Y%m%d`         # -d date - default to current date 'YYYYmmdd'

#
# Add all valid application to the string (the ones that are used in the log filename (ex. "Watch-Puppy")
#
validApps="Error-Warning Baby-cron Process-Updater Updater Watch-Puppy"

ERR_WARN_PATTERN="(ERROR|WARNING)"      # regex for the egrep
EXTRACT_TMP="."                         # Temporary file path
COUNT=0                                 # Unsigned integer ... Watch-Puppy20140101.$COUNT.tgz
DEST=""                                 # tgz archive' name



#
# Parses command line arguments
#
argType=""

for arg in "$@"; do
    case $argType in
        -a) 
            APP=$arg
        ;;
        -d)
            DATE=$arg
        ;;
        -f)
            SOURCE=$arg
        ;;
        -n)
            NUM_LINES=$arg
            echo "NUM_LINES has been set to : $NUM_LINES"
        ;;

        -s)
            TGZ_MAX_SIZE=$arg
            echo "TGZ_MAX_SIZE has been set to : $TGZ_MAX_SIZE bytes"
        ;;

        -l)
            LOG_DIR=$(readlink -f $arg)
        ;;
        -p)
            PART_SIZE=$arg
        ;;

        -t)
            TGZ_DIR=$(readlink -f $arg)
        ;;
    esac
    
    argType=""    

    case $arg in
        -a) 
            argType=$arg
        ;;
        -d)
            argType=$arg
        ;;
        -f)
            argType=$arg
        ;;
        -n) 
            argType=$arg
        ;;
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
        -p)
            argType=$arg
        ;;
        -t)
            argType=$arg
        ;;
    esac
done 

#
# if -a argument has been provided, validates.
#
if [ "$APP" != "" ]; then
    if ( `echo $APP | grep $validApp` -eq 1 ); then 
        echo "'$APP' is not a valid application name"
        exit 1
    fi
fi





#####
# build SOURCE and DEST (ex. 'Watch-Puppy20140101.log'
#
if [ "$SOURCE" != "" ]; then
    SOURCE="$SOURCE"
else
    SOURCE="$APP$DATE"
fi

DEST="$SOURCE"

# 'tgzaa' is the suffixe of the first part created by the 'split' command
# if this file exists, it is because the .log file was to big for a single
# TGZ_MAX_SIZE archive.
while [ -f "$TGZ_DIR/$DEST.$COUNT.tgzaa" ]      
do
    COUNT=$[$COUNT+1]
done

EXTRACT_TMP="$EXTRACT_TMP/$DEST.log"
DEST="$DEST.$COUNT.tgz"
SOURCE="$SOURCE.log"
#
#
##################




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 
# TITLE : finish
#
# PUPOSE : This is executed when the script exits (success or failure)
#
#------------------------------------------------------------------------------
finish() 
{
    echo "[INFO] EXIT signal trapped" 1>&2
    echo "[END]" 1>&2
}

trap finish EXIT

#
# Extract the ERROR and WARNING
#
if [ "$PATTERN" == "Error-Warning" ]; then
    FILENAME=$PATTERN`date +%Y%m%d`.log
    for file in $LOG_DIR/*.log ; do
        #echo "egrep '$ERR_WARN_PATTERN' $file >> $FILENAME"
        egrep $ERR_WARN_PATTERN $file >> $FILENAME || { echo "continue..."; }
    done

    mv $FILENAME $LOG_DIR

fi

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 
# TITLE : extract_lines 
#
# PUPOSE : creates and compresses archive of approximately TGZ_MAX_SIZE.
#           1. the lines are extracted from SOURCE >> EXTRACT_TMP
#           2. the lines are removed from SOURCE
#           3. an archive is created, containing EXTRACT_TMP 
#           4. go to step 1 if archive size is SMALLER than TGZ_MAX_SIZE
#
#------------------------------------------------------------------------------
extract_lines()
{
    local archive_size=0

    while [ $archive_size -le $TGZ_MAX_SIZE -a  `wc -l $LOG_DIR/$SOURCE | awk '{print $1}'` -gt 0 ] 
    do

        sed -n "1,$NUM_LINES p" $LOG_DIR/$SOURCE >> $EXTRACT_TMP         # extracts the first NUM_LINES from SOURCE
        sed -i "1,$NUM_LINES d" $LOG_DIR/$SOURCE                         # removes  the first NUM_LINES from SOURCE

        tar -cvf $TGZ_DIR/$DEST.tmp   $EXTRACT_TMP     1>&2              # append to DEST
        gzip $TGZ_DIR/$DEST.tmp   || { echo "[ERROR] $0:$LINENO - gzip $TGZ_DIR/$DEST.tmp failed"; } 
        mv $TGZ_DIR/$DEST.tmp.gz $TGZ_DIR/$DEST

        archive_size=`stat -c %s $TGZ_DIR/$DEST`
    done

    if [ -f $EXTRACT_TMP ]; then
        rm $EXTRACT_TMP || { echo "[ERROR] $0:$LINENO - rm $EXTRACT_TMP failed"; }
    fi

    if [ `wc -l $LOG_DIR/$SOURCE | awk '{print $1}'` -eq 0 ]; then 
        rm $LOG_DIR/$SOURCE
    fi
}


#
#-------------------
# Perform!
#-------------------
#

extract_lines

if [ -f $TGZ_DIR/$DEST ]; then
    split -b $PART_SIZE $TGZ_DIR/$DEST $TGZ_DIR/$DEST || { echo "[ERROR] $0:$LINENO - split failed"; exit 1; }
    rm $TGZ_DIR/$DEST
fi



exit 0;

