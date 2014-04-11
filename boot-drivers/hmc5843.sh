#! /bin/sh
if lsmod | grep "hmc5843" &> /dev/null ; then
    echo "hmc5842 is already loaded!"
    exit 0
else
    modprobe hmc5843
    echo hmc5883  0x1e > /sys/bus/i2c/devices/i2c-1/new_device
    driverpath=$(find /sys/bus/i2c/devices/1-001e/ -type d -name 'iio:device*')
    export hmc5843path="$driverpath"
    exit 1 # not sure if loaded
fi
