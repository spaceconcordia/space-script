#!/bin/sh
#**********************************************************************************************************************
#
# AUTHORS : Space Concordia 2014, Joseph
# 
# PURPOSE : download/compile coreutils for Q6 (in particular : we needed to compile the 'split' command)
#
# REFERENCE : http://git.savannah.gnu.org/cgit/coreutils.git/plain/README-hacking
#
#**********************************************************************************************************************

COREUTILS_GIT="git://git.sv.gnu.org/coreutils"          #   git repo, assuming you have git installed
apps=(autoconf automake autopoint gperf texinfo)        #   those are needed to build coreutils
COREUTILS_PATH="./coreutils"

read -p "clone $COREUTILS_GIT ? [y|N]" choice
case "$choice" in
    y|Y)    git clone $COREUTILS_GIT;;
    n|N|'') echo "Skipping cloning of $COREUTILS_GIT..."; echo;;
esac
echo;

#
# Installs dependencies
#
for app in ${apps[@]}
do
	read -p "Install $app ? [y|N]" choice
	case "$choice" in 
	  y|Y ) apt-get install $app;;
	  n|N|'' ) echo "Skipping installation of $app..."; echo;;
	esac

    echo;
done

#
# boostrap
#
read -p "run the bootstraping now? [y|N]" choice
case "$choice" in
    y|Y)    cd $COREUTILS_PATH; ./bootstrap;;
    n|N|'') echo "Skipping bootstrap step..."; echo;;
esac
echo;

#
# ./configure
#
read -p "Configure now? (should NOT be root for this step!) [y|N]" choice
case "$choice" in
    y|Y)    sh cross_compile_coreutils.sh ;;
    n|N|'') echo "Skipping configuration step..."; echo;;
esac

#
# farewell
#
echo;
echo "Now edit the Makefile : remove the 'Werror' flag!"
echo "Run 'make', the binaries are under ./coreutils/src"

#
# exit
# 
echo "exit"
