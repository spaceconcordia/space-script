#!/bin/bash
#**********************************************************************************************************************
#
# AUTHORS : Space Concordia 2014, Joseph
#
# FILE : cross_compile_coreutils.sh
#
# PURPOSE : run the ./configure step for microblaze cross-compilation
#
# REFERENCE : http://git.savannah.gnu.org/cgit/coreutils.git/plain/README-hacking
#
#**********************************************************************************************************************
COREUTILS_PATH=$(readlink -f "./coreutils")

export 
CROSS_COMPILE=/usr/local/lib/mbgcc/bin/microblazeel-xilinx-linux-gnu-

cd $COREUTILS_PATH
./configure \
--target=microblazeel-xilinx-linux-gnu \
--host=microblazeel-xilinx-linux-gnu \
#--prefix=$COREUTILS_PATH/coreutils/q6_coreutils_install 
