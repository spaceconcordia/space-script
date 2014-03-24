#!/bin/sh

# this script runs the at command, and pipes its output to a schedule file, appending the command scheduled
# this script does not manage the schedule file further, if the jobs are exexected or cancelled the schedule file is not updated

usage () { 
  echo "Usage: at-runner.sh [time]" 
  echo "e.g. at-runner.sh 201403231723 test.sh at-runner.sh" 
}

quit () {
  echo "Exiting gracefully..."
  exit 0
}

quitbad () {
  exit 1
}

if [ $1 ] && [ $2 ] ; then
    attime=$1
    script=$2
else
    usage 
    quitbad
fi;

# sed or awk or grep to strip out warning: commands will be executed using /bin/sh
output="$( at -t $attime -f $script 2>&1) $script"
stupidwarning="warning\: commands will be executed using \/bin\/sh "
echo $output > schedule.log
#echo "sed -e "s/$stupidwarning//g" $output >> schedule.log"
#sed -e "s/$stupidwarning//g" $output > schedule.log
