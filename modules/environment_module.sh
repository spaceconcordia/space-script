#! /bin/. 
if [ -z "$BASH_VERSION" ]; then exec . .  "$0" "$@"; fi;
# environment_functions.sh
# Copyright (C) 2014 ngc598 <ngc598@Triangulum>
#
# Distributed under terms of the MIT license.

PROGRAM="environment_functions.sh"
VERSION="0.0.1"
version () { echo "$PROGRAM version $VERSION"; }
usage="usage: environment_functions.sh [options: (-v version), (-u usage) ]"

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Exit on error
#
#------------------------------------------------------------------------------
set -e

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Source global functions
#
#------------------------------------------------------------------------------
globals=`find . -type f -name globals.sh`
source $globals || echo "Failed to source $globals"
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Function bodies
#
#------------------------------------------------------------------------------
remote-config () {
  cd ~
  git clone https://www.github.com/SpaceShawn/space-box space-box
  mv space-box/.bash_aliases ./
  mv space-box/.config/terminator .config/
  mv space-box/.git ./
  mv space-box/.gitignore ./
  mv space-box/.htoprc ./
  mv space-box/.vim ./
  mv space-box/.vimrc ./
}

self-update () {
  SCRIPT_NAME="MANAGE_CS1.sh"
  LOCAL_COPY="$CS1_DIR/$SCRIPT_NAME"
  REPO_COPY="$SPACESCRIPT_DIR/$SCRIPT_NAME"
  if [ -f "$REPO_COPY" ]; then
    cd $CS1_DIR
    if diff $LOCAL_COPY $REPO_COPY >> /dev/null ; then 
        echo -e "${green}This script ($LOCAL_COPY) is up-to-date with the repo version ($REPO_COPY)${NC}"
    else 
        LOCAL_MOD=$(stat -c %Z "$LOCAL_COPY")
        REPO_MOD=$(stat -c %Z "$REPO_COPY")
        if [ "$LOCAL_MOD" -gt "$REPO_MOD" ] ; then 
            echo -e "${yellow}Your local copy of this build script ($LOCAL_COPY) has changes that are not being tracked by git!${NC}"
            confirm "View changes?" && diff $LOCAL_COPY $REPO_COPY 
            if confirm "Overwrite repository version with your local file?" ; then
                if git --git-dir=$SPACESCRIPT_DIR/.git status | grep "MANAGE_CS1.sh" >> /dev/null ; then
                    fail "$REPO_COPY also has modifications since the last pull that risk being overwritten. Please resolve this manually..."
                    #vimdiff $REPO_COPY $LOCAL_COPY 
                else
                    echo -e "${yellow}No conflicts on the repo, overwritting file!${NC}"
                    cp $LOCAL_COPY $REPO_COPY
                fi
            fi
        elif [ "$REPO_MOD" -gt "$LOCAL_MOD" ] ; then
            echo -e "${yellow}Repo copy ($REPO_COPY) of this build script is newer!${NC}"
            confirm "View changes?" && diff $REPO_COPY $LOCAL_COPY 
            confirm "Overwrite your local copy?" && cp $REPO_COPY $LOCAL_COPY && echo "Please restart the script to use the updated file." && return 1
        fi
    fi
    cd $CS1_DIR
  fi
}

ensure-directories () {
  declare -a REQDIR_LIST=("$NETMAN_DIR/lib/include/" "$HELIUM_DIR/inc/" "$TIMER_DIR/inc/" "$BABYCRON_DIR/include/" "$JOBRUNNER_DIR/inc/" "$COMMANDER_DIR/include/" "$HELIUM_DIR/lib/" "$TIMER_DIR/lib/" "$COMMANDER_DIR/lib/" "$BABYCRON_DIR/lib/" "$BABYCRON_DIR/lib/" "$JOBRUNNER_DIR/lib/" "$NETMAN_DIR/lib/include" "$NETMAN_DIR/bin" "$UPLOAD_FOLDER/jobs" "$CS1_DIR/logs" "$CS1_DIR/pipes" "$CS1_DIR/pids" "$CS1_DIR/tgz")
  for item in ${REQDIR_LIST[*]}; do
    mkdir -p $item || fail "Could not create $item"
  done
  if [ ! -d "$CS1_DIR/apps" -o ! -d "/home/apps" ]; then 
      echo -e "${yellow} Linking /home/apps${NC}"
      mkdir -p "$CS1_DIR"/apps/current "$CS1_DIR"/apps/old "$CS1_DIR"/apps/new 
      sudo ln -s "$CS1_DIR"/apps /home/apps && sudo chown -R $(logname):$(logname) /home/apps
  fi
  if [ ! -d "$CS1_DIR/logs" -o ! -d "/home/logs" ]; then 
      echo -e "${yellow} Linking /home/logs${NC}"
      mkdir -p "$CS1_DIR"/logs && sudo ln -s "$CS1_DIR"/logs /home/logs && sudo chown -R $(logname):$(logname) /home/logs
  fi
  if [ ! -d "$CS1_DIR/pipes" -o ! -d "/home/pipes" ]; then
      echo -e "${yellow} Linking /home/pipes${NC}"
      mkdir -p "$CS1_DIR"/pipes && sudo ln -s "$CS1_DIR"/pipes /home/pipes && sudo chown -R $(logname):$(logname) /home/pipes
  fi
  if [ ! -d "$CS1_DIR/tgz" -o ! -d "/home/tgz" ]; then 
      echo -e "${yellow} Linking /home/tgz${NC}"
      mkdir -p "$CS1_DIR"/tgz && sudo ln -s "$CS1_DIR"/tgz /home/tgz && sudo chown -R $(logname):$(logname) /home/tgz
  fi
}

ensure-symlinks () {
  if [ ! -x "$SPACESCRIPT_DIR/at-runner/at-runner.sh" ]; then
      sudo chmod +x $SPACESCRIPT_DIR/at-runner/at-runner.sh
  fi
  if [ ! -f "/usr/bin/at-runner.sh" ]; then 
      sudo ln -s "$SPACESCRIPT_DIR/at-runner/at-runner.sh" /usr/bin/
  fi
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
# Execution
#
#------------------------------------------------------------------------------
ensure-correct-path && self-update && ensure-symlinks && ensure-directories
