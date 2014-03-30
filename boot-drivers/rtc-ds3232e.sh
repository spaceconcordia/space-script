#! /bin/sh
if lsmod | grep "$MODULE" &> /dev/null ; then
    echo "$MODULE is loaded!"
    exit 0
else
    # Realtime clock
    modprobe rtc-ds3232e
    echo ds3232 0x68 > /sys/bus/i2c/devices/i2c-1/new_device
    exit 1 # not sure if driver was loading correctly
fi
