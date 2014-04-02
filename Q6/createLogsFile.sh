#
#
#
#

FOLDER="/home/logs/"
STR="1234567890"

if [ -n "$1" ]; then
    FOLDER=$1
fi

for j in `seq 1 10`; do
    for i in `seq 1 10`; do
        echo $STR >> $FOLDER"/ACS."$j".log"
    done
done

