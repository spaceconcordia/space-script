#! /bin/bash
if [ -z "$BASH_VERSION" ]; then exec bash "$0" "$@"; fi;
# system-health.sh
# Copyright (C) 2014 spaceconcordia <spaceconcordia@mustang>
#
# Distributed under terms of the MIT license.
#
# colors: echo -e "${red}Text${NC}"

fail () {
  echo "$1"
  exit 1
}
quit () {
  exit 0
}

OUTPUTLIMIT=190

usage="usage: system-health.sh [options] "
#if [ $# -eq 0 ]; then echo "No arguments supplied... $usage"; fi 
CPUUSAGE=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')
FREERAM=$(free -m | grep Mem | awk '{print $4}')
PRIMARYDISK="/dev/mapper/xdm_root"
PRIMARYDISK="/dev/sda5"
FREEDISKSPACE=$(df -h "$PRIMARYDISK" | grep "$PRIMARYDISK" | awk '{print $4}' )
LOADAVG=$(cat /proc/loadavg)
UPTIME=$(cat /proc/uptime)

OUTPUTSTRING="[CPU:$CPUUSAGE] [RAM:$FREERAM] [DF:$FREEDISKSPACE] [LA:$LOADAVG] [UT:$UPTIME]"
OUTPUTLENGTH=$(echo $OUTPUTSTRING | wc -m)

STAT=$(cat /proc/stat) # divide and format


echo $OUTPUTSTRING
if [ $OUTPUTLENGTH -ge $OUTPUTLIMIT ]; then 
  fail "Output is too long $OUTPUTLENGTH > $OUTPUTLIMIT"
fi
