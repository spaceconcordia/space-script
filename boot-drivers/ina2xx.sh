#! /bin/sh
if lsmod | grep ina2xx &> /dev/null ; then
    echo "ina2xx is loaded!"
    exit 0
else
    modprobe ina2xx
    echo ina219 0x40 > /sys/bus/i2c/devices/i2c-1/new_device
    driverpath=$(find /sys/bus/i2c/devices/1-0040/ -type d -name 'iio:device*')
    sed -i "s|INA2XXPATH=.*|INA2XXPATH='$driverpath'|g" /etc/profile        
    exit 1 # not sure if loaded
fi
