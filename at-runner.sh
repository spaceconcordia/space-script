#!/bin/sh
if [ $1 ] && [ $2 ] ; then
    attime=$1
    script=$2
else
    read attime
    read script
fi;
# sed or awk or grep to strip out warning: commands will be executed using /bin/sh
output="$( at -t $attime -f $script 2>&1) $script"
echo $output > schedule.log
