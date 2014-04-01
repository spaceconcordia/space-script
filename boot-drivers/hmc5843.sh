#! /bin/sh
if lsmod | grep "hmc5842" &> /dev/null ; then
    echo "hmc5842 is already loaded!"
    exit 0
else
    modprobe hmc5843
    echo hmc5883  0x1e > /sys/bus/i2c/devices/i2c-1/new_device
    exit 1 # not sure if loaded
fi
