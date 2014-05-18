#!/bin/bash
COREUTILS_PATH="/home/jamg85/CONSAT1/coreutils"

## export 
## PATH=/tuba_local/crosstool25/crosstool-0.25/result/arm-arm9-linux-gnu/gcc-3.2.1-glibc-2.3.1-binutils-2.14.90.0.7-linux-2.4.21/bin:$PATH
## PATH=/usr/local/lib/mbgcc/bin:$PATH

export 
CROSS_COMPILE=/usr/local/lib/mbgcc/bin/microblazeel-xilinx-linux-gnu-

###export CC=${CROSS_COMPILE}gcc

cd $COREUTILS_PATH
./configure \
--target=microblazeel-xilinx-linux-gnu \
--host=microblazeel-xilinx-linux-gnu \
#--build=microblazeel-xilinx-linux-gnu \
--prefix=$COREUTILS_PATH/coreutils/q6_coreutils_install \

### --host=i686-linux-gnu \
 make
## make LDFLAGS="-static"
