#! /bin/sh
if [ lsmod | grep "ad799x" &> /dev/null ] ; then
    echo "ad799x is already loaded"
    exit 0; # driver is loaded
else
    modprobe ad799x
    echo ad7998 0x21 > /sys/bus/i2c/devices/i2c-1/new_device
    echo ad7998 0x22 > /sys/bus/i2c/devices/i2c-1/new_device
    echo ad7998 0x23 > /sys/bus/i2c/devices/i2c-1/new_devicereturn 1; # driver is not loaded
    exit 1 # not sure if loaded
fi   
