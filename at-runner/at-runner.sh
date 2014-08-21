#!/bin/sh

# this script runs the at command, and pipes its output to a schedule file, appending the command scheduled
# this script does not manage the schedule file further, if the jobs are exexected or cancelled the schedule file is not updated

usage () { 
  echo "Usage: at-runner.sh [time]" 
  echo "e.g. at-runner.sh 201403231723 test.sh --export text.csv" 
}

quit () {
  exit 0
}

quitbad () {
  exit 1
}

if [ ! $# -eq 0 ] ; then
    attime=$1
    shift
    for arg in $@; do command="$command $arg"; done
else
    usage 
    quitbad
fi;

# [-t] time in iso format
# [tail -n +2] remove the following message: "warning: commands will be executed using /bin/sh"
output="$( echo $command | /usr/bin/at -t $attime 2>&1 | tail -n +2) $command"
confirmation=$(echo "$output" | awk {'print $1'});
if [ "$confirmation" = "job" ];
then
    echo $output >> schedule.log
    echo $output | awk {'print $2'}
else
    # in this case 0 means failure
    echo 0 
fi
