#
#
#
#

FOLDER="."
STR="1234567890"

if [ -n "$1" ]; then
    FOLDER=$1
fi

for j in `seq 1 100`; do
    for i in `seq 1 100`; do
        echo $STR >> $FOLDER"/ACS."$j".log"
    done
done

