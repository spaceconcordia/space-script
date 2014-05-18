#!/bin/sh
#**********************************************************************************************************************
#
# AUTHORS : Space Concordia 2014, Joseph
#
# REFERENCE : http://git.savannah.gnu.org/cgit/coreutils.git/plain/README-hacking
#
#**********************************************************************************************************************

COREUTILS_GIT="git://git.sv.gnu.org/coreutils"          #   git repo, assuming you have git installed
apps=(autoconf automake autopoint gperf texinfo)        #   those are needed to build coreutils
$COREUTILS_PATH="./coreutils"

read -p "clone $COREUTILS_GIT ? [y|N]" choice
case "$choice" in
    y|Y)    git clone $COREUTILS_GIT;;
    n|N|'') echo "Skipping cloning of $COREUTILS_GIT..."; echo;;
esac

for app in ${apps[@]}
do
	read -p "Install $app ? [y|N]" choice
	case "$choice" in 
	  y|Y ) apt-get install $app;;
	  n|N|'' ) echo "Skipping installation of $app..."; echo;;
	esac
done

read -p "run the bootstraping now? ? [y|N]" choice
case "$choice" in
    y|Y)    cd $COREUTILS_PATH; ./bootstrap;
            echo "Now you can run : ./configure && make && make check" echo;;   ### remove Werror from the generated makefile!!!
    n|N|'') echo "Skipping bootstrap step..."; echo;;
esac

echo "exit"
